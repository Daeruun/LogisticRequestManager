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
-- - presets  -[ # # # # # # # # # # x ]-[                       ]-[                       ]-[ # # # # # # # # # # ]-
-- -    .     -[ # # # # # # # # # # x ]-[                       ]-[                       ]-[ # # # # # # # # # # ]-
-- -    .     -[ # # # # # # # # # # x ]-[                       ]-[                       ]-[ # # # # # # # # # # ]-
-- -    .     -[ # # # # # # # # # # x ]-[                       ]-[                       ]-[ # # # # # # # # # # ]-
-- -          -[ # # # # # # # # # # x ]-[                       ]-[                       ]-[ # # # # # # # # # # ]-
-- -          - [U][D]  Entity [E]      -                     [OK]-                     [OK]-                       -
-- ----------------------------------------------------------------------------------------------------------------

function lrm.gui.destroy(player)
    local frame_flow = player.gui.screen 
    if frame_flow[lrm.defines.gui.master] then 
        frame_flow[lrm.defines.gui.master].destroy()
    end
    local button_flow = mod_gui.get_button_flow(player)
    if button_flow[lrm.defines.gui.toggle_button] then
        button_flow[lrm.defines.gui.toggle_button].destroy()
    end
    button_flow=nil
    
    player.set_shortcut_available("shortcut-LRM-input-toggle-gui", false)
end

function lrm.gui.build_toggle_button(player)
    if settings.get_player_settings(player)["LogisticRequestManager-hide_toggle_gui_button"].value then
        return
    end
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
    lrm.gui.build_autotrash_frame (player)
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
        tooltip = {"tooltip.import-preset"}
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
    
    local request_notice_flow = request_window.add {
        type = "flow",
        name = lrm.defines.gui.request_notice,
        direction = "horizontal"
    }
    request_notice_flow.visible = false
    request_notice_flow.style.horizontal_align = "center"
    request_notice_flow.style.vertical_align = "center"
    request_notice_flow.style.margin = 4
    

    local request_notice_sprite = request_notice_flow.add {
        type = "sprite",
        name = lrm.defines.gui.request_notice_sprite,
        sprite = "utility/warning_icon"
    }
    request_notice_sprite.style.right_margin = 4

    local request_notice = request_notice_flow.add {
        type = "label",
        name = lrm.defines.gui.request_notice
    }
    -- request_notice.style.maximal_width = request_window.style.maximal_width
    -- request_notice.style.width  = 300
    -- request_notice.style.height = 64
    -- request_notice.style.horizontal_align = "center"
    -- request_notice.style.vertical_align = "center"
    -- request_notice.style.vertically_stretchable = "on"
    -- request_notice.style.horizontally_stretchable = "on"
    -- request_notice.style.horizontally_squashable = "on"
    -- request_notice.word_wrap = true
    -- request_notice.read_only = true
    -- request_notice.selectable = false
    request_notice.style.single_line = false
    request_notice.style.font = "default-bold"


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
    target_menu.style.left_margin = 1

    local up = target_menu[lrm.defines.gui.preset_button_up] or target_menu.add {
        type = "sprite-button",
        name = lrm.defines.gui.preset_button_up,
        style = "shortcut_bar_button",
        sprite = "LRM-preset-arrow-up",
        tooltip = {"tooltip.move-preset-up"},
    }
    up.style.padding = 4
    local down = target_menu[lrm.defines.gui.preset_button_down] or target_menu.add {
        type = "sprite-button",
        name = lrm.defines.gui.preset_button_down,
        style = "shortcut_bar_button",
        sprite = "LRM-preset-arrow-down",
        tooltip = {"tooltip.move-preset-down"},
    }
    down.style.padding = 4
    down.style.right_margin = 10
    local spacer = target_menu.add {
        type = "empty-widget",
        name = lrm.defines.gui.empty .. "_",
        minimum_width = 10,
        maximum_width = 10,
    }

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

    local autotrash_button = target_menu.add {
        type = "sprite-button",
        name = lrm.defines.gui.autotrash_button,
        style = "shortcut_bar_button",
        -- caption = {"gui.autotrash-title"},
        tooltip = {"tooltip.autotrash"},
        sprite = "LRM-autotrash",
        top_margin = 1
    }
    autotrash_button.style.padding = 4
    autotrash_button.style.top_margin = 1
    autotrash_button.style.height = 40

    local load_button = target_menu.add {
        type = "sprite-button",
        name = lrm.defines.gui.load_button,
        style = "item_and_count_select_confirm",
        sprite = "LRM-apply",
        tooltip = {"tooltip.load-preset"},
    }
    load_button.mouse_button_filter = {
        "left", 
        "middle", 
        "right", 
    }
    load_button.enabled = false
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
        column_count = 11
    }

    request_table.clear()

    -- no request-table if nothing is selected
    if ( preset_slots == nil ) then return end

    local slots = preset_slots

    for i = 1, slots do
        local request = request_table.add {
            type = "sprite-button",
            --type = "choose-elem-button",
            name = lrm.defines.gui.request_slot .. i,
            --elem_type = "signal",
            style = lrm.defines.gui.request_slot,
        }
        -- request.locked = true    -- read only flag
        
        local min = request.add {
            type = "label",
            name = lrm.defines.gui.request_min,
            style = lrm.defines.gui.request_count,
            ignored_by_interaction = true
        }
        
        local max = request.add {
            type = "label",
            name = lrm.defines.gui.request_max,
            style = lrm.defines.gui.request_count,
            ignored_by_interaction = true
        }
        
        if i % 10 == 0 then
            local clear_line = request_table.add {
                type = "sprite-button",
                --type = "choose-elem-button",
                name = lrm.defines.gui.preset_clear_row .. i/10,
                --elem_type = "signal",
                style = "shortcut_bar_button",
                size = 16,
                sprite = "utility/trash"
            }
        end
        
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
    local logistic_provider    = inventory_open and open_entity and open_entity.get_logistic_point and open_entity.get_logistic_point(defines.logistic_member_index.character_provider)
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
    local rename_tooltip    = {"", "\n", {"tooltip.rename-preset", {"", "[color=yellow]", {"common.SHIFT"}, "[/color]"} } }
    local subtract_tooltip    = {"", "\n\n", {"tooltip.function-subtract", {"", "[color=yellow]", {"common.R-CLICK"}, "[/color]"} },  (max_configurable and lrm.gui.create_modifiertooltip(player, "append", "subtract_max" ) or "") }

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
            lrm.gui.set_gui_element (blueprint_button, true,  {"", {"tooltip.always_append_blueprints", entity_icon}, round_up_tooltip, subtract_tooltip })
        elseif unlimited_blueprints then
            lrm.gui.set_gui_element (blueprint_button, true,  {"", {"tooltip.blueprint-request",        entity_icon}, append_tooltip, round_up_tooltip, subtract_tooltip })
        elseif append_blueprints then
            lrm.gui.set_gui_element (blueprint_button, true,  {"", {"tooltip.blueprint-request",        entity_icon}, undefined_max_as_infinit_tooltip, round_up_tooltip, subtract_tooltip })
        else
            lrm.gui.set_gui_element (blueprint_button, true,  {"", {"tooltip.blueprint-request",        entity_icon}, append_tooltip, undefined_max_as_infinit_tooltip, round_up_tooltip, subtract_tooltip })
        end
        -- 
        if (preset_selected) then
            if (selected_preset>10) then 
                if (max_configurable) then
                    lrm.gui.set_gui_element (save_button,      true,  {"", {"tooltip.save-preset",       preset_name, entity_icon}, round_up_tooltip, rename_tooltip })
                else
                    lrm.gui.set_gui_element (save_button,      true,  {"", {"tooltip.save-preset",       preset_name, entity_icon}, undefined_max_as_infinit_tooltip, round_up_tooltip, rename_tooltip })
                end
            else
                lrm.gui.set_gui_element (save_button,      false, {"messages.protected-preset", {"messages.save"} })
            end
            lrm.gui.set_gui_element (load_button,      true,  {"", {"tooltip.load-preset",       preset_name, entity_icon}, append_tooltip, round_up_tooltip, subtract_tooltip })
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

function lrm.gui.create_modifiertooltip(player, modifier_name, function_name)
    if not (player and modifier_name) then return "" end
    local function_enabled  = player.mod_settings["LogisticRequestManager-enable-" .. modifier_name].value or false
    local function_modifier = player.mod_settings["LogisticRequestManager-modifier-" .. modifier_name].value

    if not (function_enabled and function_modifier) then return "" end
    
    function_modifier = {"", "[color=yellow]", {"common." .. function_modifier}, "[/color]"}
    local tooltip_string

    if (function_enabled=="never") then
        tooltip_string = ""
    elseif (function_enabled=="always") then
        tooltip_string = {"tooltip.function-" .. (function_name or modifier_name)}
    elseif (function_enabled=="on_modifier") then
        tooltip_string = {"", "\n", {"tooltip.function-" .. (function_name or modifier_name)}, " ", {"tooltip.on_modifier", function_modifier}, "." }
    elseif (function_enabled=="not_on_modifier") then
        tooltip_string = {"", "\n", {"tooltip.function-" .. (function_name or modifier_name)}, " ", {"tooltip.if_not_modifier", function_modifier}, "." }
    else
        tooltip_string =  ""
    end
    return tooltip_string
end

function lrm.gui.bring_to_front()
    for index, count in pairs(global["bring_to_front"]) do
        local player = game.players[index] or nil
        if player and count then
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
    
    player.set_shortcut_available("shortcut-LRM-input-toggle-gui", true)
    lrm.gui.build_toggle_button(player)
    lrm.gui.build_gui(player)
end

function lrm.gui.force_rebuild(player)
    -- local button_flow = mod_gui.get_button_flow(player)
    -- local button=false

    -- if button_flow[lrm.defines.gui.toggle_button] then
    --     button=true
    -- end

    local frame_flow    = player.gui.screen
    local master        = frame_flow and frame_flow[lrm.defines.gui.master] or nil
    local frame         = lrm.gui.get_gui_frame(player, lrm.defines.gui.frame)
    local export_frame  = lrm.gui.get_gui_frame(player, lrm.defines.gui.export_frame)
    local import_frame  = lrm.gui.get_gui_frame(player, lrm.defines.gui.import_frame)

    local visible_master        = master       and master.visible       or false
    local visible_frame         = frame        and frame.visible        or false
    local visible_export_frame  = export_frame and export_frame.visible or false
    local visible_import_frame  = import_frame and import_frame.visible or false

    lrm.gui.destroy(player)

    if lrm.check_logistics_available(player) then
        lrm.gui.build(player)

        master       = frame_flow and frame_flow[lrm.defines.gui.master] or nil
        frame        = lrm.gui.get_gui_frame(player, lrm.defines.gui.frame)
        export_frame = lrm.gui.get_gui_frame(player, lrm.defines.gui.export_frame)
        import_frame = lrm.gui.get_gui_frame(player, lrm.defines.gui.import_frame)
        
        if master       then master       .visible = visible_master       end
        if frame        then frame        .visible = visible_frame        end
        if export_frame then export_frame .visible = visible_export_frame end
        if import_frame then import_frame .visible = visible_import_frame end
    -- elseif button then
    --     lrm.gui.build_toggle_button(player) 
    end
end

function lrm.gui.get_save_as_name(player, parent_frame)
    local toolbar   = parent_frame and parent_frame[lrm.defines.gui.toolbar]
    local textfield = toolbar and toolbar[lrm.defines.gui.save_as_textfield]

    return textfield and textfield.text
end
function lrm.gui.clear_save_as_name(player, parent_frame)
    local toolbar   = parent_frame and parent_frame[lrm.defines.gui.toolbar]
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

    local last_preset = 0

    for _, preset in pairs(preset_list.children) do
        if preset.name == button_to_select then
            preset.style = lrm.defines.gui.preset_button_selected
            preset_list.scroll_to_element(preset, "top-third")
        else
            preset.style = lrm.defines.gui.preset_button
        end
        last_preset = tonumber( string.match(preset.name, string.gsub(lrm.defines.gui.preset_button, "-", "%%-") .. "(%d+)") ) or _
    end

    local right = body  and body[lrm.defines.gui.body_right] or nil
    local target_menu = right  and right[lrm.defines.gui.target_menu] or nil
    local up = target_menu and target_menu[lrm.defines.gui.preset_button_up] or nil
    local down = target_menu and target_menu[lrm.defines.gui.preset_button_down] or nil
    local protected = ( preset_selected <= lrm.defines.protected_presets )
    local is_first_preset = ( preset_selected == ( lrm.defines.protected_presets + 1 ) )
    local is_last_preset = ( preset_selected == last_preset )
    if protected then
        lrm.gui.set_gui_element ( up,   false, {"tooltip.protected_preset_move"} )
        lrm.gui.set_gui_element ( down, false, {"tooltip.protected_preset_move"} )
    else
        if ( is_first_preset ) then
            lrm.gui.set_gui_element ( up,   false, {"tooltip.first-preset"} )
        else
            lrm.gui.set_gui_element ( up,   true, {"tooltip.move-preset-up"} )
        end
        if ( is_last_preset ) then
            lrm.gui.set_gui_element ( down, false, {"tooltip.last-preset"} )
        else
            lrm.gui.set_gui_element ( down, true, {"tooltip.move-preset-down"} )
        end
    end
end

function lrm.gui.display_preset(player, preset_data, request_window)
    local slots = preset_data and table_size(preset_data)
    if slots == nil then return end
    -- there is nothing to display...
    
    if not request_window then
        local frame      = lrm.gui.get_gui_frame(player, lrm.defines.gui.frame)
        local body       = frame and frame[lrm.defines.gui.body]
        local body_right = body  and body[lrm.defines.gui.body_right]
        
        request_window = body_right and body_right[lrm.defines.gui.request_window]
        if not request_window then return end
    end
    
    local notice_flow = request_window[lrm.defines.gui.request_notice] or nil
    local notice_frame = notice_flow and notice_flow[lrm.defines.gui.request_notice] or nil
    if (preset_data.notice) then
        if notice_frame then 
            notice_frame.caption = preset_data.notice
---@diagnostic disable-next-line: inject-field
            notice_flow.visible = true
        end
        preset_data.notice = nil
        slots = slots - 1
    else
        if notice_frame then 
            notice_frame.caption = ""
---@diagnostic disable-next-line: inject-field
            notice_flow.visible = false
        end
    end
    
    lrm.gui.build_slots(player, slots, request_window)
    
    local request_table = request_window[lrm.defines.gui.request_table]
    if request_table then
        request_table.visible = true
    end
    local increment, ticks
    increment = math.ceil(player.mod_settings["LogisticRequestManager-display_slots_by_tick_ratio"].value)
    ticks     = math.ceil(1 / player.mod_settings["LogisticRequestManager-display_slots_by_tick_ratio"].value)
    
    global["data_to_view"][player.index] = {data=table.deepcopy(preset_data), position=1, parent_table=request_table, increment=increment, ticks=ticks }
    
    lrm.gui.display_preset_junk (player.index)
end

function lrm.gui.display_preset_junk (index)
    if not index then return end
    
    local preset_data, position, request_table, increment 
    preset_data   = global["data_to_view"][index].data or {}
    position      = global["data_to_view"][index].position or 1
    request_table = global["data_to_view"][index].parent_table or nil
    increment     = ( global["data_to_view"][index].increment or 1 ) - 1
    
    if not request_table then return end
    if increment > 1 then increment = increment - 1 end
    
    local preset_size = #preset_data
    local slots = position + increment
    if increment < 0 or slots > preset_size then 
        slots = preset_size
    end
    
    local row =  math.floor ( ( position - 1 ) / 10 )
    local row_empty = global["data_to_view"][index].row_empty
    if row_empty == nil then
        row_empty = true
    end
    
    local unlock_clear = slots > 10
    local unlock_add = slots < 1000
    
    for i = position, slots do
        local slot = i + row
        local item = preset_data and preset_data[i] or nil
        if item and item.name then
            row_empty = false
            -- TODO see if there's a way to detect prototype name changes
            local valid_prototype = true
            if (item.type == "item") and game.item_prototypes[item.name] then
                request_table.children[slot].sprite = "item." .. item.name
                request_table.children[slot].tooltip = item.name
                --request_table.children[i].elem_value = {name=item.name, type="item"}
            elseif (item.type == "fluid") and game.fluid_prototypes[item.name] then
                request_table.children[slot].sprite = "fluid." .. item.name
                request_table.children[slot].tooltip = item.name
                --request_table.children[i].elem_value = {name=item.name, type="fluid"}
            elseif (item.type == "virtual" or item.type == "virtual-signal") and game.virtual_signal_prototypes[item.name] then
                request_table.children[slot].sprite = "virtual-signal." .. item.name
                request_table.children[slot].tooltip = item.name
                --request_table.children[i].elem_value = {name=item.name, type="virtual"}
            else
                valid_prototype = false
            end
            
            if (valid_prototype) then
                -- min should always be there, but we make sure...
                if ( request_table.children[slot].children[1] ) then
                    if item.min then
                        request_table.children[slot].children[1].caption = util.format_number(item.min, true)
                    else
                        request_table.children[slot].children[1].caption = ""
                    end
                    if ( request_table.children[slot].children[2] ) then
                        if not (global.feature_level == "1.0") and ( ( item.max == "" ) or (item.min==item.max) ) then
                            request_table.children[slot].children[1].style.bottom_padding = 0
                            request_table.children[slot].children[2] = nil
                        elseif ( not item.max or item.max == 0xFFFFFFFF ) then
                            request_table.children[slot].children[1].style.bottom_padding = 10
                            request_table.children[slot].children[2].style = lrm.defines.gui.request_infinit
                            request_table.children[slot].children[2].caption = "∞" -- replace by icon?
                        else
                            request_table.children[slot].children[1].style.bottom_padding = 10
                            request_table.children[slot].children[2].style = lrm.defines.gui.request_count
                            request_table.children[slot].children[2].caption = util.format_number(item.max, true)
                        end
                    end
                end
            else
                request_table.children[slot].sprite = "item.LRM-dummy-item"
                -- request_table.children[i].elem_value = {name="LRM-dummy-item", type="item"}
                if (item.type == "item") or (item.type == "fluid") or (item.type == "virtual") then
                    request_table.children[slot].tooltip = {"tooltip.missing-object", { ( "common.The-" .. item.type ) or ""}, item.name}
                else
                    request_table.children[slot].tooltip = {"tooltip.invalid-type", item.type or "", item.name}
                end
            end
        else
            -- as the table was just created, there is nothing to clear
        end
        
        if ( ( i % 10 ) == 0 ) then
            row = row + 1
            if ( row_empty ) then
                request_table.children[slot + 1].name = lrm.defines.gui.preset_clear_row .. row
                request_table.children[slot + 1].sprite = "utility/trash"
                request_table.children[slot + 1].tooltip = {"tooltip.clear-empty-row"}
                request_table.children[slot + 1].enabled = unlock_clear
            else
                request_table.children[slot + 1].name = lrm.defines.gui.preset_add_row .. row
                request_table.children[slot + 1].sprite = "utility/add"
                request_table.children[slot + 1].tooltip = {"tooltip.add-empty-row"}
                request_table.children[slot + 1].enabled = unlock_add
            end
            row_empty = true
        end
    end
    
    if slots < preset_size then
        global["data_to_view"][index].position = slots + 1
        global["data_to_view"][index].row_empty = row_empty
    else
        global["data_to_view"][index] = nil
    end
end

function lrm.gui.delete_preset(player, preset)
    if not player or not preset then
        return
    end

    local frame = lrm.gui.get_gui_frame(player, lrm.defines.gui.frame)
    local body = frame and frame[lrm.defines.gui.body]
    local preset_list = body and body[lrm.defines.gui.preset_list]
    if preset_list and preset_list[lrm.defines.gui.preset_button .. preset] then
        preset_list[lrm.defines.gui.preset_button .. preset].destroy()
    end

    -- clear the request-table to make it clear that no template is selected
    local body_right = body and body[lrm.defines.gui.body_right]
    local request_window = body_right and body_right[lrm.defines.gui.request_window]

    if request_window then
        if request_window[lrm.defines.gui.request_notice] then
            request_window[lrm.defines.gui.request_notice].visible =  false
        end
        if request_window[lrm.defines.gui.request_table] then
            request_window[lrm.defines.gui.request_table].visible = false
        end
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

    if not gui_frame or not code_textbox then return end

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

    local gui_frame = gui_master and gui_master.add {
        type = "frame",
        name = lrm.defines.gui.import_preview_frame,
        style = lrm.defines.gui.import_preview_frame,
        direction = "vertical",
    }
    if gui_frame then
        gui_frame.visible = false
        
        lrm.gui.build_title_bar(player, gui_frame, {"gui.import-preview-title"})
        
        local gui_toolbar = gui_frame.add {
            type = "flow",
            name = lrm.defines.gui.toolbar,
            direction = "horizontal"
        }
        if gui_toolbar then
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
                tooltip = {"tooltip.save_as", {"tooltip.imported-string"}}
            }
            save_as_button.style.padding = 2
        end

        local request_window = gui_frame.add {
            type = "scroll-pane",
            name = lrm.defines.gui.request_window,
            style = lrm.defines.gui.request_window
        }
        if request_window then
            request_window.vertical_scroll_policy = "auto-and-reserve-space"
        end
    end
end

function lrm.gui.show_imported_preset(player, preset_data)
    local frame             = lrm.gui.get_gui_frame(player, lrm.defines.gui.import_preview_frame)
    local request_window    = frame   and frame[lrm.defines.gui.request_window] or nil
    local toolbar           = frame   and frame[lrm.defines.gui.toolbar] or nil
    local preset_name_field = toolbar and toolbar[lrm.defines.gui.save_as_textfield] or nil


    if not request_window then
        return
    end

    if not preset_data or preset_data == {} then
        return
    end

    if not preset_name_field then
        return
    end

    local last_slot = table_size(preset_data)
    if (last_slot and preset_data[last_slot].LRM_preset_name) then
        preset_name_field.text = preset_data[last_slot].LRM_preset_name.translated or preset_data[last_slot].LRM_preset_name
        preset_data[last_slot] = nil
    end

    frame.visible = true
    lrm.gui.display_preset (player, preset_data, request_window)
end

function lrm.gui.get_gui_frame(player, frame_name)
    if frame_name == nil then 
        return nil
    end
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

function lrm.gui.build_autotrash_frame (player)
    local frame_flow = player.gui.screen
    local gui_master = frame_flow and frame_flow[lrm.defines.gui.master]

    if gui_master and gui_master[lrm.defines.gui.autotrash_frame] then 
        return
    end

    local autotrash_frame = gui_master.add {
        type = "frame",
        name = lrm.defines.gui.autotrash_frame,
        parent = "inner_frame_in_outer_frame",
        direction = "vertical",
    }
    autotrash_frame.style.height = 354
    autotrash_frame.visible = false

    lrm.gui.build_title_bar(player, autotrash_frame, {"gui.autotrash-title"})
    
    local empty = autotrash_frame.add {
        type = "empty-widget",
        name = lrm.defines.gui.empty
    }
    empty.style.vertically_stretchable = "on"

    local autotrash_flow = autotrash_frame.add {
        type = "flow",
        name = lrm.defines.gui.autotrash_flow,
        direction = "horizontal"
    }
    lrm.gui.add_setting_checkbox(player, autotrash_flow, "autotrash")
    lrm.gui.add_setting_checkbox(player, autotrash_flow, "autotrash_automatic", true)

    local line = autotrash_frame.add {
        type = "line",
        name = lrm.defines.guiprefix .. "line"
    }
    lrm.gui.add_setting_checkbox(player, autotrash_frame, "trash_gridded_items", true)
    lrm.gui.add_setting_checkbox(player, autotrash_frame, "trash_remotes", true)
    lrm.gui.add_setting_checkbox(player, autotrash_frame, "trash_blueprints")
    lrm.gui.add_setting_checkbox(player, autotrash_frame, "trash_blueprint_books")
    lrm.gui.add_setting_checkbox(player, autotrash_frame, "trash_deconstruction_planers")
    lrm.gui.add_setting_checkbox(player, autotrash_frame, "trash_upgrade_planers")
    lrm.gui.add_setting_checkbox(player, autotrash_frame, "trash_copy_paste_tools")
    lrm.gui.add_setting_checkbox(player, autotrash_frame, "trash_selection_tools")
    lrm.gui.add_setting_checkbox(player, autotrash_frame, "trash_hidden_items", true)
end

function lrm.gui.add_setting_checkbox (player, base_frame, flag, tooltip)
    if not base_frame and player and player.valid then
        return
    end

    local checkbox = base_frame.add {
        type = "checkbox",
        -- ref = {"options", "trash_unrequested"},
        name = lrm.defines.guiprefix .. "flag-" .. flag,
        caption = {"flags." .. flag},
        state = global["flags"][player.index][flag] or false,
        --actions = toggle_action,
    }
    if tooltip then
        checkbox.tooltip = {"flag-tooltips." .. flag}
    end

end