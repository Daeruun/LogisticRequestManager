if not lrm.request_manager then lrm.request_manager = {} end

function lrm.request_manager.request_blueprint(player)
	if not (player.is_cursor_blueprint()) then 
		return nil 
	end

	local entity = lrm.blueprint_requests.get_inventory_entity(player, {"messages.target-entity"}, {"messages.append"}, {"messages.blueprint"})
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
	local slots = entity.request_slot_count + required_slots
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

function lrm.request_manager.apply_preset(preset_data, entity)
	local logistic_point = entity.get_logistic_point(defines.logistic_member_index.character_requester)
	if (	not (logistic_point.mode == defines.logistic_mode.requester ) 			-- no requester
		and not (logistic_point.mode == defines.logistic_mode.buffer ) 	) then		-- no buffer
		return nil
	end
	
	logistic_point = entity.get_logistic_point(defines.logistic_member_index.character_provider)
	local set_slot = nil
	if not (logistic_point) then 						-- no auto-trash
		set_slot = entity.set_request_slot
	else
		if entity.type == "character" then		-- easy & quite certain
			set_slot = entity.set_personal_logistic_slot 
		else											-- spidertron OK & quite sure that this will work for modded vehicles as well...
			set_slot = entity.set_vehicle_logistic_slot
		end
	end
	
	if not set_slot then 
		return nil 
	end
	
	-- clear current logistic slots
	local slots = entity.request_slot_count
	
	for i = 1, slots do
		entity.clear_request_slot(i)
	end
	
	-- get required number of personal logistic slots
	slots = table_size(preset_data or {})
	
	-- as only players personal logistic slots support min & max requests, we need to destinguish between player-character and entities like requester-box or similar
	if not (logistic_point) then 						-- no auto-trash
		for i = 1, slots do
			local item = preset_data[i]
			if item and item.name and not (game.item_prototypes[item.name] == nil) then
				set_slot({name=item.name, count=item.min}, i)
			end
		end
	else
		for i = 1, slots do
			local item = preset_data[i]
			if item and item.name and not (game.item_prototypes[item.name] == nil) then
				set_slot(i, item)
			end
		end
	end
end

function lrm.request_manager.save_preset(player, preset_number, preset_name)
	local entity = lrm.blueprint_requests.get_inventory_entity(player, {"messages.source-entity"}, {"messages.save"}, {"messages.preset"})
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
	if slots % 10 then
		slots = slots + 10 - (slots % 10)
	end
	if slots < 40 then 
		slots = 40
	end
	local get_slot = nil

	local logistic_provider_point = entity.get_logistic_point(defines.logistic_member_index.character_provider) 
	if not (logistic_provider_point) then 						-- no auto-trash
		get_slot = entity.get_request_slot
	else
		if entity.type == "character" then				-- easy & quite certain
			get_slot = entity.get_personal_logistic_slot
		else											-- spidertron OK & quite sure that this will work for modded vehicles as well...
			get_slot = entity.get_vehicle_logistic_slot
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

function lrm.request_manager.load_preset(player, preset_number)
	local player_presets = global["preset-data"][player.index]
	local preset = player_presets[preset_number]
	if not preset then return end
	
	local entity = lrm.blueprint_requests.get_inventory_entity(player, {"messages.target-entity"}, {"messages.load"}, {"messages.preset"})
	if entity and entity.valid then
		lrm.request_manager.apply_preset(preset, entity)
	else
		return nil
	end
end

function lrm.request_manager.delete_preset(player, preset_number)
	global["preset-names"][player.index][preset_number] = nil
	global["preset-data"][player.index][preset_number] = nil
end

function lrm.request_manager.import_preset(player)
	local encoded_string = lrm.gui.get_import_string(player)
	if not (encoded_string) or encoded_string == "" then
		return nil
	end

	local decoded_string = game.decode_string(encoded_string)
	if decoded_string and (decoded_string ~= "") then
		local preset_data = game.json_to_table(decoded_string)
		if preset_data and (next(preset_data) ~= nil) then
			return preset_data
		end
	end
	lrm.error(player, {"messages.error-invalid-string"})
end

function lrm.request_manager.save_imported_preset(player, preset_name)
	local preset_data = lrm.request_manager.import_preset(player)
	local last_slot = table_size (preset_data)
	
	if (preset_data[last_slot].LRM_preset_name) then
		preset_data[last_slot] = nil
	end

	local player_presets = global["preset-names"][player.index]
	local total = 0
	for number, name in pairs(player_presets) do
		if number > total then total = number end
	end
	
	local preset_number = total + 1

	global["preset-names"][player.index][preset_number] = preset_name
	global["preset-data"][player.index][preset_number]  = preset_data

	return preset_number
end

function lrm.request_manager.export_preset(player, preset_number, coded)
	local preset_table = {}

	local preset_name = global["preset-names"][player.index][preset_number]
	local preset_data = global["preset-data"][player.index][preset_number]
	local slots = table_size(preset_data) or 0

	if slots > 0 then
		for i = 1, slots do
			local slot = preset_data[i]
			if slot.name ~= nil then
				table.insert(preset_table, slot)
			else
				table.insert(preset_table, "")
			end
		end
	end

	table.insert(preset_table, {LRM_preset_version = 1, LRM_preset_name = preset_name[1] or preset_name})
	local jsoned_table   = game.table_to_json(preset_table)
	local encoded_string = game.encode_string(jsoned_table)

	return encoded_string
end