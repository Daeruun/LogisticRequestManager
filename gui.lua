local mod_gui = require 'mod-gui'
local util = require 'util'
require 'defines'
if not lrm.gui then lrm.gui = {} end

-- [toggle button]

-- GUI:
-- - invisible master frame
--   - frame
--     - titlebar 
--     - [toolbar]
--     - body
--       - flow:-> scrollpane, flow: v - request-window
--                                     - entity-flow

--  main - always shown when open     |optional, toggled by [E]|optional, toggled by [I]  |substitutes import after OK
-- ----------------------------------------------------------------------------------------------------------------
-- - title                          X - export                X - import                X - preview             X -
-- ----------------------------------------------------------------------------------------------------------------
-- - [t-field] [S+][S][A][E][I][T][BP]-[                       ]-[                       ]- [t-field       ] [S+] -
-- ------------------------------------[        textbox        ]-[        textbox        ]-------------------------
-- - presets  -[ # # # # # # # # # # ]-[                       ]-[                       ]-[ # # # # # # # # # # ]-
-- -    .     -[ # # # # # # # # # # ]-[                       ]-[                       ]-[ # # # # # # # # # # ]-
-- -    .     -[ # # # # # # # # # # ]-[                       ]-[                       ]-[ # # # # # # # # # # ]-
-- -    .     -[ # # # # # # # # # # ]-[                       ]-[                       ]-[ # # # # # # # # # # ]-
-- -          -[ # # # # # # # # # # ]-[                       ]-[                       ]-[ # # # # # # # # # # ]-
-- -          -Entity [E]             -                     [OK]-                     [OK]-                       -
-- ----------------------------------------------------------------------------------------------------------------

function lrm.gui.destroy(player)
    local frame_flow = player.gui.screen
    if frame_flow[lrm.defines.gui.frame] then 
        frame_flow[lrm.defines.gui.frame].destroy()
    end
    local button_flow = mod_gui.get_button_flow(player)
    if button_flow[lrm.defines.gui.toggle_button] then
        button_flow[lrm.defines.gui.toggle_button].destroy()
    end
    button_flow=nil
end

function lrm.gui.build_toggle_button(player)
    local button_flow = mod_gui.get_button_flow(player)
    if not button_flow[lrm.defines.gui.toggle_button] then
        button_flow.add {
            type = "sprite-button",
            name = lrm.defines.gui.toggle_button,
            sprite = "item/logistic-robot",
            style = mod_gui.button_style,
            tooltip = {"tooltip.button", {"common.SHIFT"}}
        }
    end
end


function lrm.gui.build_gui(player)
    local frame_flow = player.gui.screen

    local gui_master = frame_flow[lrm.defines.gui.master] or frame_flow.add {
        type = "frame",
        name = lrm.defines.gui.master,
        style = "invisible_frame",
        direction = "horizontal"
    }

    local location = global["screen_location"][player.index] or {85, 65}
    if not next(location) then location = {85 ,65} end
    gui_master.location = location

    lrm.gui.build_main_frame (player)
    lrm.gui.build_export_frame(player)
    lrm.gui.build_import_frame(player)
    lrm.gui.build_import_preview_frame(player)
    gui_master.visible = true
end

function lrm.gui.build_main_frame (player)
    local frame_flow = player.gui.screen
    local gui_master = frame_flow and frame_flow[lrm.defines.gui.master]
    local gui_frame = gui_master and gui_master[lrm.defines.gui.frame] or nil

    if gui_frame then 
        return
    end

    gui_frame = gui_master.add {
        type = "frame",
        name = lrm.defines.gui.frame,
        style = lrm.defines.gui.frame,
        direction = "vertical"
    }

    lrm.gui.build_title_bar(player, gui_frame, {"gui.title"})
    lrm.gui.build_tool_bar(player, gui_frame)
    lrm.gui.build_body(player, gui_frame)
end

function lrm.gui.build_title_bar(player, gui_frame, localized_title)
    if not gui_frame then 
        return 
    end

    local gui_title_flow = gui_frame.add {
        type = "flow",
        name = lrm.defines.gui.title_flow,
        style = lrm.defines.gui.title_flow,
        direction = "horizontal"
    }
    gui_title_flow.drag_target = gui_frame.parent

    local gui_title_frame = gui_title_flow.add {
        type = "frame",
        name = lrm.defines.gui.title_frame,
        style = lrm.defines.gui.title_frame,
        caption = localized_title or "",
        single_line = true
    }
    gui_title_frame.drag_target = gui_frame.parent


    gui_title_flow.add {
        type = "sprite-button",
        name = lrm.defines.gui.close_button,
        style = lrm.defines.gui.close_button,
        sprite = "utility/close_white"
    }
end

function lrm.gui.build_tool_bar(player, gui_frame)
    if not gui_frame then 
        return 
    end


    local gui_toolbar = gui_frame.add {
        type = "flow",
        name = lrm.defines.gui.toolbar,
        direction = "horizontal"
    }
    gui_toolbar.style.vertical_align = "center"

    local save_as_textfield = gui_toolbar.add {
        type = "textfield",
        name = lrm.defines.gui.save_as_textfield,
        style = lrm.defines.gui.save_as_textfield,
    }
    
    local save_as_button = gui_toolbar.add {
        type = "sprite-button",
        name = lrm.defines.gui.save_as_button,
        style = "shortcut_bar_button",
        sprite = "LRM-save-as",
    }
    save_as_button.style.padding = 2

    local save_button = gui_toolbar.add {
        type = "sprite-button",
        name = lrm.defines.gui.save_button,
        style = "shortcut_bar_button",
        sprite = "LRM-save",
    }
    save_button.style.padding = 2

    local export_button = gui_toolbar.add {
        type = "sprite-button",
        name = lrm.defines.gui.export_button,
        style = "shortcut_bar_button",
        sprite = "utility/export",
    }
    export_button.style.padding = 4

    local import_button = gui_toolbar.add {
        type = "sprite-button",
        name = lrm.defines.gui.import_button,
        style = "shortcut_bar_button",
        sprite = "utility/import",
    }
    import_button.style.right_margin = 5
    import_button.style.padding = 4


    local delete_button = gui_toolbar.add {
        type = "sprite-button",
        name = lrm.defines.gui.delete_button,
        style = "shortcut_bar_button_red",
        sprite = "utility/trash",
    }
    delete_button.style.right_margin = 5
    delete_button.style.padding = 4

    local blueprint_button = gui_toolbar.add {
        type = "sprite-button",
        name = lrm.defines.gui.blueprint_button,
        style = lrm.defines.gui.blueprint_button,
        sprite = "item.blueprint",
    }

    lrm.gui.set_gui_elements_enabled(player)
end

function lrm.gui.build_body(player, gui_frame)
    if not gui_frame then 
        return 
    end

    local gui_body_flow = gui_frame.add {
        type = "flow",
        name = lrm.defines.gui.body,
        direction = "horizontal"
    }
    lrm.gui.build_preset_list(player, gui_body_flow)

    local gui_body_flow_right = gui_body_flow.add {
        type = "flow",
        name = lrm.defines.gui.body_right,
        direction = "vertical"
    }

    local request_window = gui_body_flow_right.add {
        type = "scroll-pane",
        name = lrm.defines.gui.request_window,
        style = lrm.defines.gui.request_window
    }
    request_window.vertical_scroll_policy = "auto-and-reserve-space"
    request_window.style.vertical_align = "bottom"
    
    lrm.gui.build_slots(player, nil, request_window)

    lrm.gui.build_target_menu(player, gui_body_flow_right)
end
function lrm.gui.build_target_menu(player, parent)
    if not parent then 
        return 
    end
    if not player then 
        return 
    end
    
    local target_menu = parent.add {
        type = "flow",
        name = lrm.defines.gui.target_menu,
        direction = "horizontal"
    }
    target_menu.style.top_margin = 1
    target_menu.style.left_margin = 5

    local label = target_menu.add {
        type = "label",
        name = lrm.defines.gui.target_label,
        caption = {"gui.target_label"}
    }

    local target_slot = target_menu.add {
        type = "sprite-button",
        name = lrm.defines.gui.target_slot,
        style = "inventory_slot"
    }

    local empty = target_menu.add {
        type = "empty-widget",
        name = lrm.defines.gui.empty,
        width = 20
    }
    empty.style.horizontally_stretchable = "on"

    local load_button = target_menu.add {
        type = "sprite-button",
        name = lrm.defines.gui.load_button,
        style = "item_and_count_select_confirm",
        sprite = "LRM-apply",
        tooltip = {"tooltip.load-preset"}
    }
    load_button.enabled = inventory_open
    load_button.style.padding = 4
    -- load_button.style.right_margin = 5
    load_button.style.width = 40
    load_button.style.height = 40

    lrm.gui.set_target(player, target_slot)
end
function lrm.gui.build_preset_list(player, gui_body_flow)
    if not player then 
        return 
    end
    if not gui_body_flow then 
        local frame   = lrm.gui.get_gui_frame(player, lrm.defines.gui.frame)
        gui_body_flow = frame and frame[lrm.defines.gui.body] or nil
    end

    if not gui_body_flow then return end

    local preset_list = gui_body_flow[lrm.defines.gui.preset_list] or gui_body_flow.add {
        type = "scroll-pane",
        name = lrm.defines.gui.preset_list,
        style = lrm.defines.gui.preset_list,
    }
    preset_list.vertical_scroll_policy = "always"
    preset_list.horizontal_scroll_policy = "never"
    
    preset_list.clear()
    
    local presets = global["preset-names"][player.index]
    for index,preset in pairs(presets) do
        local button = preset_list.add {
            type = "button",
            name = lrm.defines.gui.preset_button .. index,
            style = lrm.defines.gui.preset_button,
            caption = preset,
            tooltip = preset
        }
        if index <= lrm.defines.protected_presets then
            button.caption = { "", preset, "*" }
            button.tooltip = { "", preset, " - ", {"gui.protected_preset"}}
        end
    end
end

function lrm.gui.build_slots(player, preset_slots, parent_to_extend)
    
    local request_table = parent_to_extend[lrm.defines.gui.request_table] or parent_to_extend.add {
        type = "table",
        name = lrm.defines.gui.request_table,
        style = lrm.defines.gui.request_table,
        column_count = 10
    }

    request_table.clear()

    -- no request-table if nothing is selected
    if ( preset_slots == nil ) then return end
    
    local slots = preset_slots
    for i = 1, slots do
        local request = request_table.add {
            type = "choose-elem-button",
            name = lrm.defines.gui.request_slot .. i,
            elem_type = "signal",
            style = lrm.defines.gui.request_slot,

            
        }
        request.locked = true    -- read only flag
        
        local min = request.add {
            type = "label",
            name = lrm.defines.gui.request_min .. i,
            style = lrm.defines.gui.request_count,
            ignored_by_interaction = true
        }
        
        local max = request.add {
            type = "label",
            name = lrm.defines.gui.request_max .. i,
            style = lrm.defines.gui.request_count,
            ignored_by_interaction = true
        }
        
    end
end

function lrm.gui.set_gui_elements_enabled(player)
    -- get tool-bar elements
    local frame                = lrm.gui.get_gui_frame(player, lrm.defines.gui.frame) 
    if not ( frame and frame.visible and frame.parent.visible ) then return false end
    
    local toolbar              = frame and frame[lrm.defines.gui.toolbar] or nil

    local save_as_textfield    = toolbar and toolbar[lrm.defines.gui.save_as_textfield] or nil    -- entity only
    local save_as_button       = toolbar and toolbar[lrm.defines.gui.save_as_button] or nil       -- entity only;        round up(?)

    local save_button          = toolbar and toolbar[lrm.defines.gui.save_button] or nil          -- entity + preset;    round up(?)

    local delete_button        = toolbar and toolbar[lrm.defines.gui.delete_button] or nil        -- preset only
    local export_button        = toolbar and toolbar[lrm.defines.gui.export_button] or nil        -- preset only

    local blueprint_button     = toolbar and toolbar[lrm.defines.gui.blueprint_button] or nil     -- entity only;        append, max=∞, round up(?)

    -- get target-menu elements
    local body                 = frame and frame[lrm.defines.gui.body]
    local body_right           = body and body[lrm.defines.gui.body_right]
    local target_menu          = body_right and body_right[lrm.defines.gui.target_menu]

    local target_slot          = target_menu and target_menu[lrm.defines.gui.target_slot]
    local load_button          = target_menu and target_menu[lrm.defines.gui.load_button] or nil  -- entity + preset;    append + round up

    -- get states
    local selected_preset      = global["presets-selected"][player.index] or nil
    local preset_name          = selected_preset and global["preset-names"][player.index] and global["preset-names"][player.index][selected_preset] or ""
    local preset_selected      = (selected_preset and selected_preset > 0) or false
    local open_entity          = lrm.blueprint_requests.get_inventory_entity(player)
    local inventory_open       = open_entity and open_entity.valid or false
    local logistic_provider    = inventory_open and open_entity.get_logistic_point(defines.logistic_member_index.character_provider)
    local max_configurable     = logistic_provider and logistic_provider.mode == defines.logistic_mode.active_provider or false
    local combinator_allowed   = player.mod_settings["LogisticRequestManager-allow_constant_combinator"].value or false
    local append_blueprints    = player.mod_settings["LogisticRequestManager-always_append_blueprints"].value or false
    local unlimited_blueprints = player.mod_settings["LogisticRequestManager-blueprint_item_requests_unlimited"].value or false
    
    -- set target icon
    lrm.gui.set_target(player, target_slot)

    -- define reusable tooltip-parts
    local entity_icon         = open_entity and "[img=entity." .. open_entity.name .. "]" or ""   -- icon to display in tooltips
    local no_entity_tooltip   = combinator_allowed and "messages.no_request_entity_or_combinator_selected" or "messages.no_request_entity_selected"
    local append_tooltip      = lrm.gui.create_modifiertooltip(player, "append")
    local undefined_max_as_infinit_tooltip = lrm.gui.create_modifiertooltip(player, "undefined_max_as_infinit")
    local round_up_tooltip    = lrm.gui.create_modifiertooltip(player, "round_up")
    

    -- configure buttons
    if (inventory_open) then
        lrm.gui.set_gui_element (save_as_textfield,    true,  {"tooltip.save_as_textfield"})
        if (max_configurable) then
            lrm.gui.set_gui_element (save_as_button,       true,  {"", {"tooltip.save_as",           entity_icon}, round_up_tooltip })
        else
            lrm.gui.set_gui_element (save_as_button,       true,  {"", {"tooltip.save_as",           entity_icon}, undefined_max_as_infinit_tooltip, round_up_tooltip })
        end
        -- blueprints are special
        if (append_blueprints and unlimited_blueprints) then
            lrm.gui.set_gui_element (blueprint_button, true,  {"", {"tooltip.always_append_blueprints", entity_icon}, round_up_tooltip })
        elseif unlimited_blueprints then
            lrm.gui.set_gui_element (blueprint_button, true,  {"", {"tooltip.blueprint-request",        entity_icon}, append_tooltip, round_up_tooltip })
        elseif append_blueprints then
            lrm.gui.set_gui_element (blueprint_button, true,  {"", {"tooltip.blueprint-request",        entity_icon}, undefined_max_as_infinit_tooltip, round_up_tooltip })
        else
            lrm.gui.set_gui_element (blueprint_button, true,  {"", {"tooltip.blueprint-request",        entity_icon}, append_tooltip, undefined_max_as_infinit_tooltip, round_up_tooltip })
        end
        -- 
        if (preset_selected) then
            if (selected_preset>10) then 
                if (max_configurable) then
                    lrm.gui.set_gui_element (save_button,      true,  {"", {"tooltip.save-preset",       preset_name, entity_icon}, round_up_tooltip })
                else
                    lrm.gui.set_gui_element (save_button,      true,  {"", {"tooltip.save-preset",       preset_name, entity_icon}, undefined_max_as_infinit_tooltip, round_up_tooltip })
                end
            else
                lrm.gui.set_gui_element (save_button,      false, {"messages.protected-preset", {"messages.save"} })
            end
            lrm.gui.set_gui_element (load_button,      true,  {"", {"tooltip.load-preset",       preset_name, entity_icon}, append_tooltip, round_up_tooltip })
        else
            lrm.gui.set_gui_element (save_button,      false, {"messages.select-preset", {"messages.save"} })
            lrm.gui.set_gui_element (load_button,      false, {"messages.select-preset", {"messages.load"} })
        end
    else
        lrm.gui.set_gui_element (save_as_textfield,    false, {no_entity_tooltip, {"messages.source-entity"}, {"messages.save"},   {"messages.preset"} })
        lrm.gui.set_gui_element (save_as_button,       false, {no_entity_tooltip, {"messages.source-entity"}, {"messages.save"},   {"messages.preset"} })
        lrm.gui.set_gui_element (save_button,          false, {no_entity_tooltip, {"messages.source-entity"}, {"messages.save"},   {"messages.preset"} })
        lrm.gui.set_gui_element (blueprint_button,     false, {no_entity_tooltip, {"messages.target-entity"}, {"messages.append"}, {"messages.blueprint"} })
        lrm.gui.set_gui_element (load_button,          false, {no_entity_tooltip, {"messages.target-entity"}, {"messages.load"},   {"messages.preset"} })
    end
    if (preset_selected) then
        lrm.gui.set_gui_element (export_button,        true,  {"tooltip.export-preset", preset_name} )
        lrm.gui.set_gui_element (delete_button,        true,  {"tooltip.delete-preset", preset_name} )

    else
        lrm.gui.set_gui_element (export_button,        false, {"messages.select-preset", {"messages.export"} })
        lrm.gui.set_gui_element (delete_button,        false, {"messages.select-preset", {"messages.delete"} })
    end

    return true
end

function lrm.gui.set_gui_element(gui_element, flag, tooltip_string)
    if not (gui_element) or (flag == nil) then
        return
    end

    gui_element.enabled = flag
    gui_element.tooltip = tooltip_string or ""
end

function lrm.gui.create_modifiertooltip(player, modifier_name)
    if not (player and modifier_name) then return "" end
    local function_enabled  = player.mod_settings["LogisticRequestManager-enable-" .. modifier_name].value or nil
    local function_modifier = player.mod_settings["LogisticRequestManager-modifier-" .. modifier_name].value or nil

    if not (function_enabled and function_modifier) then return "" end
    
    function_modifier={"", "[color=yellow]", {"common." .. function_modifier}, "[/color]"}
    local tooltip_string=""

    if (function_enabled=="never") then
        tooltip_string = ""
    elseif (function_enabled=="always") then
        tooltip_string = {"tooltip.function-" .. modifier_name}
    elseif (function_enabled=="on_modifier") then
        tooltip_string = {"", "\n", {"tooltip.function-" .. modifier_name}, " ", {"tooltip.on_modifier", function_modifier}, "." }
    elseif (function_enabled=="not_on_modifier") then
        tooltip_string =  {"", "\n", {"tooltip.function-" .. modifier_name}, " ", {"tooltip.if_not_modifier", function_modifier}, "." }
    else
        tooltip_string =  ""
    end
    return tooltip_string
end

function lrm.gui.bring_to_front()
    for index, count in pairs(global["bring_to_front"]) do
        local player = game.players[index] or nil
        if player then
            local frame = lrm.gui.get_gui_frame(player, lrm.defines.gui.frame)
            if frame and frame.parent and frame.parent.visible then 
                if not (global.feature_level == "1.0") then
                    frame.parent.bring_to_front()
                end
                if count > 1 then
                    count = count - 1
                else
                    count = nil
                end
                
                global["bring_to_front"][player.index] = count
            else
                global["bring_to_front"][player.index] = nil
            end
        end
    end
end

function lrm.gui.set_target(player, target_slot)
    if not (player and target_slot) then return end

    local inventory_open = lrm.blueprint_requests.get_inventory_entity(player)
    
    target_slot.sprite = inventory_open and ("entity." .. inventory_open.name)
    target_slot.tooltip = inventory_open and inventory_open.localised_name or ""
end

function lrm.gui.build(player)
    if not ( lrm.check_logistics_available (player) ) then return end
    
    lrm.gui.build_toggle_button(player)
    lrm.gui.build_gui(player)
end

function lrm.gui.force_rebuild(player)
    local button_flow = mod_gui.get_button_flow(player)
    local button=false
    if button_flow[lrm.defines.gui.toggle_button] then
        button_flow[lrm.defines.gui.toggle_button].destroy()
        button=true
    end

    local frame_flow    = player.gui.screen
    local master        = frame_flow and frame_flow[lrm.defines.gui.master] or nil
    local frame         = lrm.gui.get_gui_frame(player, lrm.defines.gui.frame)
    local export_frame  = lrm.gui.get_gui_frame(player, lrm.defines.gui.export_frame)
    local import_frame  = lrm.gui.get_gui_frame(player, lrm.defines.gui.import_frame)

    local visible_master        = master       and master.visible       or false
    local visible_frame         = frame        and frame.visible        or false
    local visible_export_frame  = export_frame and export_frame.visible or false
    local visible_import_frame  = import_frame and import_frame.visible or false

    if master then master.destroy() end

    lrm.gui.build(player)

    if lrm.check_logistics_available(player) then
        lrm.gui.build_toggle_button(player) 

        master       = frame_flow and frame_flow[lrm.defines.gui.master] or nil
        frame        = lrm.gui.get_gui_frame(player, lrm.defines.gui.frame)
        export_frame = lrm.gui.get_gui_frame(player, lrm.defines.gui.export_frame)
        import_frame = lrm.gui.get_gui_frame(player, lrm.defines.gui.import_frame)
    
        if master       then master       .visible = visible_master       end
        if frame        then frame        .visible = visible_frame        end
        if export_frame then export_frame .visible = visible_export_frame end
        if import_frame then import_frame .visible = visible_import_frame end
    elseif button then
        lrm.gui.build_toggle_button(player) 
    end
end

function lrm.gui.get_save_as_name(player, parent_frame)
    local toolbar = parent_frame and parent_frame[lrm.defines.gui.toolbar]
    local textfield = toolbar and toolbar[lrm.defines.gui.save_as_textfield]

    return textfield and textfield.text
end
function lrm.gui.clear_save_as_name(player, parent_frame)
    local toolbar = parent_frame and parent_frame[lrm.defines.gui.toolbar]
    local textfield = toolbar and toolbar[lrm.defines.gui.save_as_textfield]

    if textfield then textfield.text="" end
end

function lrm.gui.select_preset(player, preset_selected)
    local button_to_select = lrm.defines.gui.preset_button .. preset_selected

    local frame            = lrm.gui.get_gui_frame(player, lrm.defines.gui.frame)
    local body             = frame and frame[lrm.defines.gui.body]       or nil
    local preset_list      = body  and body[lrm.defines.gui.preset_list] or nil

    local enabled_state    = not(preset_selected == nil) and preset_selected > 0  or false
    local inventory_open   = not(global["inventories-open"][player.index] == nil) or false

    if not preset_list then return end

    for _, preset in pairs(preset_list.children) do
        if preset.name == button_to_select then
            preset.style = lrm.defines.gui.preset_button_selected
            preset_list.scroll_to_element(preset)
        else
            preset.style = lrm.defines.gui.preset_button
        end
    end
end

function lrm.gui.display_preset(player, preset_data, request_window)
    local slots = preset_data and table_size(preset_data)

    if not request_window then
        local frame      = lrm.gui.get_gui_frame(player, lrm.defines.gui.frame)
        local body       = frame and frame[lrm.defines.gui.body]
        local body_right = body  and body[lrm.defines.gui.body_right]
        
        request_window = body_right and body_right[lrm.defines.gui.request_window]
        if not request_window then return end
    end

    lrm.gui.build_slots(player, slots, request_window)

    if slots == nil then return end
    -- there is nothing to display...

    local request_table = request_window[lrm.defines.gui.request_table]
    
    for i = 1, slots do
        local item = preset_data and preset_data[i] or nil
        if item and item.name then
            -- TODO see if there's a way to detect prototype name changes
            local valid_prototype = true
            if (item.type == "item") and game.item_prototypes[item.name] then
                request_table.children[i].elem_value = {name=item.name, type="item"}
            elseif (item.type == "fluid") and game.fluid_prototypes[item.name] then
                request_table.children[i].elem_value = {name=item.name, type="fluid"}
            elseif (item.type == "virtual" or item.type == "virtual-signal") and game.virtual_signal_prototypes[item.name] then
                request_table.children[i].elem_value = {name=item.name, type="virtual"}
            else
                valid_prototype = false
            end

            if (valid_prototype) then
                -- min should always be there, but we make sure...
                if item.min then
                    request_table.children[i].children[1].caption = util.format_number(item.min, true)
                else
                    request_table.children[i].children[1].caption = ""
                end
                if not (global.feature_level == "1.0") and ( ( item.max == "" ) or (item.min==item.max) ) then
                    request_table.children[i].children[1].style.bottom_padding = 0
                    request_table.children[i].children[2] = nil
                elseif ( not item.max or item.max == 0xFFFFFFFF ) then
                    request_table.children[i].children[1].style.bottom_padding = 10
                    request_table.children[i].children[2].style = lrm.defines.gui.request_infinit
                    request_table.children[i].children[2].caption = "∞" -- replace by icon?
                else
                    request_table.children[i].children[1].style.bottom_padding = 10
                    request_table.children[i].children[2].style = lrm.defines.gui.request_count
                    request_table.children[i].children[2].caption = util.format_number(item.max, true)
                end
            else
                request_table.children[i].elem_value = {name="LRM-dummy-item", type="item"}
                if (item.type == "item") or (item.type == "fluid") or (item.type == "virtual") then
                    request_table.children[i].tooltip = {"tooltip.missing-object", {"common.The-" .. item.type or ""}, item.name}
                else
                    request_table.children[i].tooltip = {"tooltip.invalid-type", item.type or "", item.name}
                end
            end
        else
            -- as the table was just created, there is nothing to clear
        end
    end
end

function lrm.gui.delete_preset(player, preset)
    local frame = lrm.gui.get_gui_frame(player, lrm.defines.gui.frame)
    local body = frame and frame[lrm.defines.gui.body]
    local preset_list = body and body[lrm.defines.gui.preset_list]
    preset_list[lrm.defines.gui.preset_button .. preset].destroy()

    -- clear the request-table to make it clear that no template is selected
    local body_right = body and body[lrm.defines.gui.body_right]
    local request_window = bodbody_righty and body_right[lrm.defines.gui.request_window]

    if ( request_window and request_window[lrm.defines.gui.request_table] ) then
        request_window[lrm.defines.gui.request_table].destroy()
    end
end

function lrm.gui.build_export_frame(player)
    local export_frame, code_textbox = lrm.gui.build_code_frame(player, lrm.defines.gui.export_frame, {"gui.export-title"}, true)
end

function lrm.gui.display_export_code(player, encoded_string)
    local frame_flow   = player.gui.screen
    local gui_master   = frame_flow and frame_flow[lrm.defines.gui.master]
    local gui_frame    = gui_master and gui_master[lrm.defines.gui.export_frame] or nil
    local code_textbox = gui_frame  and gui_frame[lrm.defines.gui.code_textbox] or nil

    code_textbox.text = encoded_string

    gui_frame.visible = true
end

function lrm.gui.build_import_frame(player)
    local import_frame, code_textbox = lrm.gui.build_code_frame(player, lrm.defines.gui.import_frame, {"gui.import-title"}, false)
end

function lrm.gui.build_code_frame(player, frame_name, localized_frame_title, export)
    local frame_flow = player.gui.screen
    local gui_master = frame_flow and frame_flow[lrm.defines.gui.master]

    if gui_master and gui_master[frame_name] then 
        return
    end

    local code_frame = gui_master.add {
        type = "frame",
        name = frame_name,
        style = frame_name,
        direction = "vertical",
    }
    code_frame.visible = false
    code_frame.style.width = 444

    lrm.gui.build_title_bar(player, code_frame, localized_frame_title)


    local code_textbox = code_frame.add {
        type = "text-box",
        name = lrm.defines.gui.code_textbox,
        style = lrm.defines.gui.code_textbox,
    }
    code_textbox.word_wrap = true
    code_textbox.read_only = export

    local gui_toolbar = code_frame.add {
        type = "flow",
        name = lrm.defines.gui.toolbar,
        direction = "horizontal"
    }
    gui_toolbar.style.vertical_align = "bottom"

    -- manually align buttons with request_window (bottom)
    gui_toolbar.style.height = 43

    local empty = gui_toolbar.add {
        type = "empty-widget",
        name = lrm.defines.gui.empty,
    }
    empty.style.horizontally_stretchable = "on"

    local confirm_button = gui_toolbar.add {
        type = "button",
        name = lrm.defines.gui.OK_button,
        style = lrm.defines.gui.save_as_button,
        caption = {"gui.ok"}
    }
    
    return code_frame, code_textbox
end

function lrm.gui.get_import_string(player)
    local frame        = lrm.gui.get_gui_frame(player, lrm.defines.gui.import_frame)
    local code_textbox = frame and frame[lrm.defines.gui.code_textbox] or nil

    return (code_textbox and code_textbox.text)
end
function lrm.gui.clear_import_string(player)
    local frame        = lrm.gui.get_gui_frame(player, lrm.defines.gui.import_frame)
    local code_textbox = frame and frame[lrm.defines.gui.code_textbox] or nil

    if code_textbox then code_textbox.text="" end
end

function lrm.gui.build_import_preview_frame (player)
    local frame_flow = player.gui.screen
    local gui_master = frame_flow and frame_flow[lrm.defines.gui.master] or nil
    local gui_frame  = gui_master and gui_master[lrm.defines.gui.import_preview_frame] or nil

    if gui_frame then 
        return
    end

    local gui_frame = gui_master.add {
        type = "frame",
        name = lrm.defines.gui.import_preview_frame,
        style = lrm.defines.gui.import_preview_frame,
        direction = "vertical",
    }
    gui_frame.visible = false

    lrm.gui.build_title_bar(player, gui_frame, {"gui.import-preview-title"})

    local gui_toolbar = gui_frame.add {
        type = "flow",
        name = lrm.defines.gui.toolbar,
        direction = "horizontal"
    }
    gui_toolbar.style.vertical_align = "center"

    local save_as_textfield = gui_toolbar.add {
        type = "textfield",
        name = lrm.defines.gui.save_as_textfield,
        style = lrm.defines.gui.save_as_textfield
    }
    
    local save_as_button = gui_toolbar.add {
        type = "sprite-button",
        name = lrm.defines.gui.save_as_button,
        style = "shortcut_bar_button",
        sprite = "LRM-save-as",
        tooltip = {"tooltip.save-as", {"tooltip.imported-string"}}
    }
    save_as_button.style.padding = 2

    local request_window = gui_frame.add {
        type = "scroll-pane",
        name = lrm.defines.gui.request_window,
        style = lrm.defines.gui.request_window
    }
    request_window.vertical_scroll_policy = "auto-and-reserve-space"
end

function lrm.gui.show_imported_preset(player, preset_data)
    local frame             = lrm.gui.get_gui_frame(player, lrm.defines.gui.import_preview_frame)
    local request_window    = frame   and frame[lrm.defines.gui.request_window] or nil
    local toolbar           = frame   and frame[lrm.defines.gui.toolbar] or nil
    local preset_name_field = toolbar and toolbar[lrm.defines.gui.save_as_textfield] or nil


    if not request_window then
        return
    end

    if not preset_data then
        return
    end
    
    local last_slot = table_size(preset_data)
    if (preset_data[last_slot].LRM_preset_name) then
        preset_name_field.text = preset_data[last_slot].LRM_preset_name.translated or preset_data[last_slot].LRM_preset_name
        preset_data[last_slot] = nil
    end

    frame.visible = true
    lrm.gui.display_preset (player, preset_data, request_window)
end

function lrm.gui.get_gui_frame(player, frame_name)
    local frame_flow = player.gui.screen
    local gui_master = frame_flow and frame_flow[lrm.defines.gui.master] or nil
    local gui_frame  = gui_master and gui_master[frame_name] or nil
    return gui_frame
end

function lrm.gui.show_frame(player, frame_name)
    local frame = lrm.gui.get_gui_frame(player, frame_name)
    if frame then frame.visible = true end
end
function lrm.gui.hide_frame(player, frame_name)
    local frame = lrm.gui.get_gui_frame(player, frame_name)
    if frame then frame.visible = false end
end