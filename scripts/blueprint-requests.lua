if not lrm.blueprint_requests then lrm.blueprint_requests = {} end

function lrm.blueprint_requests.get_inventory_entity(player, ent_text, action_txt, subject_txt)
    if not lrm.check_logistics_available (player) then return nil end
    
    local entity = global["inventories-open"][player.index] and player.opened or player.opened_self and player.character or nil

    if not (entity and entity.valid and entity.object_name == "LuaEntity") then
        if settings.get_player_settings(player)["LogisticRequestManager-default_to_user"].value then
            return player.character
        else
            if (ent_text and action_txt and subject_txt) then
                lrm.error(player, {"messages.no_request_entity_selected", ent_text, action_txt, subject_txt})
            end
            return nil
        end
    end
    
    local logistic_point   = entity and entity.get_logistic_point   and entity.get_logistic_point(defines.logistic_member_index.character_requester) or nil
    local control_behavior = entity and entity.get_control_behavior and entity.get_control_behavior() or nil
    
    if (
         ( ( not (logistic_point == nil) )
       and ( (logistic_point.mode == defines.logistic_mode.requester )                                          -- requester
          or (logistic_point.mode == defines.logistic_mode.buffer    ) ) )                                      -- buffer
      or
         ( ( not (control_behavior == nil) ) 
         and (control_behavior.type == defines.control_behavior.type.constant_combinator)                       -- constant combinator
         and (settings.get_player_settings(player)["LogisticRequestManager-allow_constant_combinator"].value) ) -- constant combinator enabled via setting
       ) then 
        return (entity)
    else
        if settings.get_player_settings(player)["LogisticRequestManager-default_to_user"].value then
            return player.character
        else
            if (ent_text and action_txt and subject_txt) then
---@diagnostic disable-next-line: need-check-nil
                lrm.error(player, {"messages.open-entity-does-not-support-requests", entity.localised_name})
            end
            return nil
        end
    end
end

function lrm.blueprint_requests.get_event_entities(event)
    local player = game.players[event.player_index]
    local entity = nil
    
    if ( event.gui_type == defines.gui_type.entity ) then
        entity = event.entity
    end
    
    if ( event.gui_type == defines.gui_type.controller ) then
        entity = player and player.character or nil
    end
    
    if not entity then
        return nil
    end
    
    return player, entity
end

script.on_event(defines.events.on_tick, function(event)
    local bring_to_front = global["bring_to_front"] or {}
    if table_size(bring_to_front) > 0 then 
        lrm.gui.bring_to_front()
    end

    local data_to_view = global["data_to_view"]
    if table_size(data_to_view) > 0 then
        for index, _ in pairs(data_to_view) do
            if (game.tick % ( global["data_to_view"][index].ticks or 10) ) == 0 then 
                lrm.gui.display_preset_junk (index)
            end
        end
    end

end)

script.on_event(defines.events.on_gui_opened, function(event)
    local player, inventory = lrm.blueprint_requests.get_event_entities(event)
    
    if not (player and inventory) then return end
    
    global["inventories-open"][player.index] = true
    lrm.gui.set_gui_elements_enabled(player)
    
    if not (global.feature_level == "1.0") then
        local frame_flow = player and player.gui.screen
        local master_frame = frame_flow and frame_flow[lrm.defines.gui.master] or nil
        if master_frame and master_frame.visible then
            global["bring_to_front"][player.index] = 2
            master_frame.bring_to_front()
        end
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    local player, inventory = lrm.blueprint_requests.get_event_entities(event)
    if not (player and inventory) then return end

    global["inventories-open"][player.index] = false
    global["bring_to_front"][player.index]   = nil
    lrm.gui.set_gui_elements_enabled(player)
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