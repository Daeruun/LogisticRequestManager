function get_inventory_entity(player, ent_text, action_txt, subject_txt)
	local entity = global["inventories-open"][player.index]

	if not (entity) then
		if settings.get_player_settings(player)["LRM-default-to-user"].value then
			return player.character
		else
			player.print ({"messages.no-request-entity-selected", ent_text, action_txt, subject_txt})
			return nil
		end
	end
	
	local logistic_requester_point = entity and entity.get_logistic_point(defines.logistic_member_index.character_requester) 
	if not (logistic_requester_point) then
		if settings.get_player_settings(player)["LRM-default-to-user"].value then
			return player.character
		else
			player.print ({"open-entity-does-not-support-requests", {entity.name} })
			return nil
		end
	end
	return entity
end

function get_event_entities(event)
	local player = game.players[event.player_index]
	local entity = nil
	
	if event.gui_type == defines.gui_type.entity then
		entity = event.entity
	end
	
	if event.gui_type == defines.gui_type.controller then
		entity = player and player.character or nil
	end

	if not entity then 
		return nil 
	end

	return player, entity
end

function on_tick()
	local inventories = global["inventories-open"] or {}
	
	if table_size(inventories) == 0 then
		unregister_on_tick()
		return
	end
	
	for player_index,inventory in pairs(inventories) do
		local player = game.players[player_index]
		if not (player and player.valid and inventory and inventory.valid) then
			global["inventories-open"][player_index] = nil
			return
		end
		
		for slot = 1, inventory.request_slot_count do
			local request = inventory.get_request_slot(slot)
			if request and (request.name == "blueprint" or request.name == "blueprint-book") then
				inventory.clear_request_slot(slot)
				request_manager.request_blueprint(player, inventory)
			end
		end
	end
end

function register_on_tick()
	global.on_tick = true
	script.on_event(defines.events.on_tick, on_tick)
end

function unregister_on_tick()
	global.on_tick = false
	script.on_event(defines.events.on_tick, nil)
end

function check_on_tick()
	if global.on_tick and table_size(global["inventories-open"]) == 0 then
		unregister_on_tick()
	end
end

script.on_event(defines.events.on_gui_opened, function(event)
	local player, inventory = get_event_entities(event)
	
	if not (player and inventory) then return end
	global["inventories-open"][player.index] = inventory
	gui.set_gui_elements_enabled(player)
	
	register_on_tick()
end)

script.on_event(defines.events.on_gui_closed, function(event)
	local player = get_event_entities(event)
	if not player then return end
	global["inventories-open"][player.index] = nil
	gui.set_gui_elements_enabled(player)
	
	check_on_tick()
end)

script.on_load(function()
	if global.on_tick then
		register_on_tick()
	end
end)