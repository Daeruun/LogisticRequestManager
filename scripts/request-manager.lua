if not request_manager then request_manager = {} end

function request_manager.request_blueprint(player)
	-- if not (player.is_cursor_blueprint()) then 
	-- 	return nil 
	-- end

	local entity = get_inventory_entity(player, {"messages.target-entity"}, {"messages.append"}, {"messages.blueprint"})
	if not (entity and entity.valid) then
		return nil
	end
	local blueprint = player.cursor_stack
	
	if not (blueprint and blueprint.valid and blueprint.valid_for_read) then
		return nil
	end
	
	if blueprint.is_blueprint_book and blueprint.active_index then
		blueprint = blueprint.get_inventory(defines.inventory.item_main)[blueprint.active_index]
	end
	
	if not blueprint.is_blueprint then
		return nil
	end
	
	if next(blueprint.cost_to_build) == nil then
		return nil
	end
	
	local required_slots = 0
	local blueprint_items = {}
	for item, count in pairs(blueprint.cost_to_build) do
		if item and not (game.item_prototypes[item] == nil) then
			required_slots = required_slots + 1
			blueprint_items[item] = count
		end
	end
	
	local free_slots = {}
	local slots = entity.request_slot_count -- + required slots - not usable in 0.18.x
	for i = 1, slots do
		local request = entity.get_request_slot(i)
		if request then
			-- If the item is already being requested add the count rather than overwriting it
			if blueprint_items[request.name] then
				blueprint_items[request.name] = blueprint_items[request.name] + request.count
				required_slots = required_slots - 1
			end
		else
			free_slots[i] = true
		end
	end
	
	-- no longer required in 1.1.x as all slots can grow as required
	if required_slots > table_size(free_slots) then
		if entity.type == "character" then
			slots = entity.character_logistic_slot_count + required_slots
			entity.character_logistic_slot_count = slots
		else
			player.print({"messages.not-enough-slots", {"messages.blueprint"}})
			return nil
		end
	end
	--

	for i = 1, slots do
		local request = entity.get_request_slot(i)
		if request then
			if blueprint_items[request.name] then
				entity.set_request_slot({name = request.name, count = blueprint_items[request.name]}, i)
				blueprint_items[request.name] = nil
			end
		end
	end
	
	for name,count in pairs(blueprint_items) do
		local slot = next(free_slots, nil)
		free_slots[slot] = nil
		entity.set_request_slot({name = name, count = count}, slot)
	end
end

function request_manager.apply_preset(player, preset_data, entity) -- player no longer required in 1.1.x
	local logistic_point = entity.get_logistic_point(defines.logistic_member_index.character_requester)
	if (	not (logistic_point.mode == defines.logistic_mode.requester ) 			-- no requester
		and not (logistic_point.mode == defines.logistic_mode.buffer ) 	) then		-- no buffer
		return nil
	end
	
	logistic_point = entity.get_logistic_point(defines.logistic_member_index.character_provider)
	if not (logistic_point) then 						-- no auto-trash
		set_slot = entity.set_request_slot
		
		-- no longer required in 1.1.x as all slots can grow as required
		local slots = entity.request_slot_count
		local preset_size = table_size(preset_data)
		if preset_size > slots then				 		
			local valid_item_requests={}
			local valid_item_count=0
			for i=1, preset_size do
				local item = preset_data[i]
				if item and item.name and not (game.item_prototypes[item.name] == nil) then
					valid_item_count = valid_item_count + 1
					valid_item_requests[valid_item_count] = item
					--player.print("found valid item #"..valid_item_count..":"..item.name)
				end
			end
			if valid_item_count > slots then
				player.print({"messages.not-enough-slots", {"messages.preset"}})
				return nil
			else
				preset_data = valid_item_requests
			end
		end
		--
		clear_slot = entity.clear_request_slot	-- in 1.1.x this works for character as well
	else
		if entity.type == "character" then		-- easy & quite certain
			set_slot = entity.set_personal_logistic_slot
			clear_slot = entity.clear_personal_logistic_slot
		-- else											-- spidertron OK & quite sure that this will work for modded vehicles as well...
		-- 	set_slot = entity.set_vehicle_logistic_slot
		end
	end
	
	if not set_slot then 
		return nil 
	end
	
	-- clear current logistic slots
	local slots = entity.request_slot_count
	
	for i = 1, slots do
		clear_slot(i)	-- in 1.1.x entity.clear_request_slot(i) can be used for all entities
	end
	
	-- get required number of personal logistic slots
	slots = table_size(preset_data or {})
	
	-- as only players personal logistic slots support min & max requests, we need to destinguish between player-character and entities like requester-box or similar
	if not (logistic_point) then 						-- no auto-trash
		if slots > entity.request_slot_count then 		-- no longer required in 1.1.x as all slots can grow as required
			player.print({"messages.not-enough-slots", {"messages.preset"}})
			return nil
		end
		
		for i = 1, slots do
			local item = preset_data[i]
			if item and item.name and not (game.item_prototypes[item.name] == nil) then
				set_slot({name=preset_data[i].name, count=item.min}, i)
			end
		end
	else
		entity.character_logistic_slot_count = slots	-- no longer required in 1.1.x as all slots can grow as required
		for i = 1, slots do
			local item = preset_data[i]
			if item and item.name and not (game.item_prototypes[item.name] == nil) then
				set_slot(i, item)
			end
		end
	end
end

function request_manager.save_preset(player, preset_number, preset_name)
	local entity = get_inventory_entity(player, {"messages.source-entity"}, {"messages.save"}, {"messages.preset"})
	if not (entity and entity.valid) then
		return nil
	end

	local player_presets = global["preset-names"][player.index]
	local total = 0
	for number, name in pairs(player_presets) do
		if number > total then total = number end
		if preset_number == number then
			preset_name = name
		end
	end
	
	if preset_number == 0 then
		preset_number = total + 1
	end

	local request_data = {}
	local slots = entity.request_slot_count
	-- not usefull before 1.1.x
	--if slots % 10 then
	--	slots = slots + 10 - (slots % 10)
	--end
	--if slots < 40 then 
	--	slots = 40
	--end
	--
	local get_slot = nil

	local logistic_point = entity.get_logistic_point(defines.logistic_member_index.character_provider) 
	if not (logistic_point) then 						-- no auto-trash
		get_slot = entity.get_request_slot
	else
		if entity.type == "character" then				-- easy & quite certain
			get_slot = entity.get_personal_logistic_slot
		-- else											-- spidertron OK & quite sure that this will work for modded vehicles as well...
		-- 	get_slot = entity.get_vehicle_logistic_slot
		end
	end

	if not get_slot then 
		return nil 
	end
	
	for i = 1, slots do
		local request = get_slot(i) -- .get_personal_logistic_slot(i)
		if request and request.name then
			request_data[i] = { name = request.name, min = request.min or request.count, max = request.max or 0xFFFFFFFF }
		else
			request_data[i] = { nil }
		end
	end
	
	global["preset-names"][player.index][preset_number] = preset_name
	global["preset-data"][player.index][preset_number]  = request_data
	
	return preset_number
end

function request_manager.load_preset(player, preset_number)
	local player_presets = global["preset-data"][player.index]
	local preset = player_presets[preset_number]
	if not preset then return end
	
	local entity = get_inventory_entity(player, {"messages.target-entity"}, {"messages.load"}, {"messages.preset"})
	if entity and entity.valid then
		request_manager.apply_preset(player, preset, entity) -- player no longer required in 1.1.x
	else
		return nil
	end
end

function request_manager.delete_preset(player, preset_number)
	global["preset-names"][player.index][preset_number] = nil
	global["preset-data"][player.index][preset_number] = nil
end