if not lrm.blueprint_requests then lrm.blueprint_requests = {} end

function lrm.blueprint_requests.get_inventory_entity(player, ent_text, action_txt, subject_txt)
	local entity = global["inventories-open"][player.index] and player.opened or player.opened_self and player.character or nil

	if not (entity and entity.valid) then
		if settings.get_player_settings(player)["LogisticRequestManager-default_to_user"].value then
			return player.character
		else
			if (ent_text and action_txt and subject_txt) then
				lrm.error(player, {"messages.no-request-entity-selected", ent_text, action_txt, subject_txt})
			end
			return nil
		end
	end
	
	local logistic_point = entity and entity.get_logistic_point(defines.logistic_member_index.character_requester) 
	local control_behavior = entity and entity.get_control_behavior()
	if ( ( not (logistic_point) 
		 or (	not (logistic_point.mode == defines.logistic_mode.requester ) 			-- no requester
			and not (logistic_point.mode == defines.logistic_mode.buffer ) 	) )			-- no buffer
		and ( not ( (control_behavior)													
				and (control_behavior.type == defines.control_behavior.type.constant_combinator) -- no constant combinaor
				and (settings.get_player_settings(player)["LogisticRequestManager-allow_constant_combinator"].value or false) ) ) ) then 
		if settings.get_player_settings(player)["LogisticRequestManager-default_to_user"].value then
			return player.character
		else
			if (ent_text and action_txt and subject_txt) then
				lrm.error(player, {"messages.open-entity-does-not-support-requests", entity.localised_name})
			end
			return nil
		end
	end
	return entity
end



function lrm.blueprint_requests.get_event_entities(event)
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

function lrm.blueprint_requests.on_tick()
	local bring_to_front = global["bring_to_front"] or {}
	if table_size(bring_to_front) > 0 then 
		lrm.gui.bring_to_front()
	else
		lrm.blueprint_requests.unregister_on_tick()
	end
end

function lrm.blueprint_requests.register_on_tick()
	global.on_tick = true
	script.on_event(defines.events.on_tick, lrm.blueprint_requests.on_tick)
end

function lrm.blueprint_requests.unregister_on_tick()
	global.on_tick = false
	script.on_event(defines.events.on_tick, nil)
end

script.on_event(defines.events.on_gui_opened, function(event)
	local player, inventory = lrm.blueprint_requests.get_event_entities(event)
	
	if not (player and inventory) then return end
	
	global["inventories-open"][player.index] = true
	lrm.gui.set_gui_elements_enabled(player)
	
	if not (global.feature_level == "1.0") then
		global["bring_to_front"][player.index]	 = 2
	end
	if lrm.gui.set_gui_elements_enabled(player) then
		lrm.blueprint_requests.register_on_tick()
	end
end)

script.on_event(defines.events.on_gui_closed, function(event)
	local player, inventory = lrm.blueprint_requests.get_event_entities(event)
	if not (player and inventory) then return end
	global["inventories-open"][player.index] = false
	global["bring_to_front"][player.index]	 = nil
	lrm.gui.set_gui_elements_enabled(player)
	
	lrm.blueprint_requests.unregister_on_tick()
end)

script.on_event(defines.events.on_entity_died, function(event)
	for _, player in pairs(game.players) do
		 inventory_entity = (global["inventories-open"][player.index] and player.opened) or nil

		 if inventory_entity and inventory_entity==event.entity then
			global["inventories-open"][player.index]=false
			lrm.gui.set_gui_elements_enabled(player)
		end

	end
	
end,{
	{filter="type", type = "logistic-container"},
	{filter="type", type = "spider-vehicle"},
	{filter="type", type = "constant-combinator"}
})

script.on_load(function()
--  	if global.on_tick then
--  		lrm.blueprint_requests.register_on_tick()
--  	end
	lrm.commands.init()
end)