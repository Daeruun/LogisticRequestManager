local mod_gui = require 'mod-gui'
local util = require 'util'
if not gui then gui = {} end

-- [toggle button]

-- main GUI:
-- ------------------------------------------------------------------------------------------------------------
-- - title                          X -  export            X  -  import            X  - preview             X -
-- ------------------------------------------------------------------------------------------------------------
-- - [ textfield - save as ] [S] [BP] - [                   ] - [                   ] - [t-field save as] [S] -
-- - [S][A][X][E][I]                  - [                   ] - [                   ] -                       -
-- ------------------------------------ [      textbox      ] - [      textbox      ] - # # # # # # # # # # I -
-- - presets  - # # # # # # # # # # I - [                   ] - [                   ] - # # # # # # # # # # | -
-- -    .     - # # # # # # # # # # | - [                   ] - [                   ] - # # # # # # # # # # | -
-- -    .     - # # # # # # # # # # | - [                   ] - [                   ] - # # # # # # # # # # | -
-- -    .     - # # # # # # # # # # | - [                   ] - [                   ] - # # # # # # # # # # | -
-- -          - # # # # # # # # # # | -                  [OK] -                  [OK] -                       -
-- ------------------------------------------------------------------------------------------------------------

function gui.build_toggle_button(player)
	local button_flow = mod_gui.get_button_flow(player)
	if not button_flow[lrm.gui.toggle_button] then
		button_flow.add {
			type = "sprite-button",
			name = lrm.gui.toggle_button,
			sprite = "item/logistic-robot",
			style = mod_gui.button_style,
			tooltip = {"tooltip.button"}
		}
	end
end


function gui.build_gui(player)
	local frame_flow = player.gui.screen

	local gui_master = frame_flow[lrm.gui.master] or frame_flow.add {
		type = "frame",
		name = lrm.gui.master,
		style = "invisible_frame",
		direction = "horizontal"
	}

	local location = global["screen_location"][player.index] or {85, 65}
	gui_master.location = location

	gui.build_main_frame (player)
	gui.build_export_frame(player)
	gui.build_import_frame(player)
	gui.build_import_preview_frame(player)
	gui_master.visible = true
end

function gui.build_main_frame (player)
	local frame_flow = player.gui.screen
	local gui_master = frame_flow and frame_flow[lrm.gui.master]
	local gui_frame = gui_master and gui_master[lrm.gui.frame] or nil

	if gui_frame then 
		return
	end

	gui_frame = gui_master.add {
		type = "frame",
		name = lrm.gui.frame,
		style = lrm.gui.frame,
		direction = "vertical"
	}

    gui.build_title_bar(player, gui_frame, {"gui.title"})
	gui.build_tool_bar(player, gui_frame)
	gui.build_preset_menu(player, gui_frame)
	gui.build_body(player, gui_frame)
end

function gui.build_title_bar(player, gui_frame, localized_title)
	if not gui_frame then 
		return 
	end

	local gui_title_flow = gui_frame.add {
		type = "flow",
		name = lrm.gui.title_flow,
		style = lrm.gui.title_flow,
		direction = "horizontal"
	}
	gui_title_flow.drag_target = gui_frame.parent

	local gui_title_frame = gui_title_flow.add {
		type = "frame",
		name = lrm.gui.title_frame,
		style = lrm.gui.title_frame,
		caption = localized_title or "",
		single_line = true
	}
	gui_title_frame.drag_target = gui_frame.parent


	gui_title_flow.add {
		type = "sprite-button",
		name = lrm.gui.close_button,
		style = lrm.gui.close_button,
		sprite = "utility/close_white"	-- hover & clicked ?!?
	}
end

function gui.build_tool_bar(player, gui_frame)
	if not gui_frame then 
		return 
	end

	local inventory_open = (global["inventories-open"][player.index] and global["inventories-open"][player.index].valid) or false

	local gui_toolbar = gui_frame.add {
		type = "flow",
		name = lrm.gui.toolbar,
		direction = "horizontal"
	}
	gui_toolbar.style.vertical_align = "center"

	local save_as_textfield = gui_toolbar.add {
		type = "textfield",
		name = lrm.gui.save_as_textfield,
		style = lrm.gui.save_as_textfield,
		tooltip = {"tooltip.save-as-textfield"}
	}
	save_as_textfield.enabled = inventory_open
	
	local save_as_button = gui_toolbar.add {
		type = "sprite-button",
		name = lrm.gui.save_as_button,
		--style = "tool_button_green",
		style = "shortcut_bar_button_green",
		sprite = "utility/copy",
		tooltip = {"tooltip.save-as"}
	}
	save_as_button.enabled = inventory_open

	blueprint_button = gui_toolbar.add {
		type = "sprite-button",
		name = lrm.gui.blueprint_button,
		style = lrm.gui.blueprint_button,
		--style = "tool_button",
		sprite = "item.blueprint",
		--width = 28,
		--heigth = 28,
		--margin = 0, spacing = 0, padding = 0,
		tooltip = {"tooltip.blueprint-request"}
	}
	blueprint_button.enabled = inventory_open
end

function gui.build_body(player, gui_frame)
	if not gui_frame then 
		return 
	end

	local gui_body_flow = gui_frame.add {
		type = "flow",
		name = lrm.gui.body,
		direction = "horizontal"
	}
	gui.build_preset_list(player, gui_body_flow)

	local request_window = gui_body_flow.add {
		type = "scroll-pane",
		name = lrm.gui.request_window,
		style = lrm.gui.request_window
	}
	request_window.vertical_scroll_policy = "auto-and-reserve-space"
	request_window.style.vertical_align = "bottom"
	--request_window.style.horizontal_align = "bottom"
	
	gui.build_slots(player, nil, request_window)
end
function gui.build_preset_menu(player, gui_frame)
	if not gui_frame then 
		return 
	end
	if not player then 
		return 
	end
	local inventory_open = (global["inventories-open"][player.index] and global["inventories-open"][player.index].valid) or false
	
	local sidebar_menu = gui_frame.add {
		type = "flow",
		name = lrm.gui.sidebar_menu,
		direction = "horizontal"
	}
	
	local save_button = sidebar_menu.add {
		type = "sprite-button",
		name = lrm.gui.save_button,
		--style = lrm.gui.sidebar_button,
		-- style = "shortcut_bar_button_green",
		style = "shortcut_bar_button",
		sprite = "utility/clone",
		-- caption = {"gui.save"},
		tooltip = {"tooltip.save-preset"}
	}
	save_button.enabled = inventory_open
	
	local load_button = sidebar_menu.add {
		type = "sprite-button",
		name = lrm.gui.load_button,
		--style = lrm.gui.sidebar_button,
		-- style = "shortcut_bar_button_blue",
		style = "shortcut_bar_button",
		sprite = "utility/refresh",
		-- caption = {"gui.load"},
		tooltip = {"tooltip.load-preset"}
	}
	load_button.enabled = inventory_open
	
	local export_button = sidebar_menu.add {
		type = "sprite-button",
		name = lrm.gui.export_button,
		--style = lrm.gui.sidebar_button,
		style = "shortcut_bar_button",
		sprite = "utility/export",
		-- caption = {"gui.export"},
		tooltip = {"tooltip.export-preset"}
	}

	local import_button = sidebar_menu.add {
		type = "sprite-button",
		name = lrm.gui.import_button,
		--style = lrm.gui.sidebar_button,
		style = "shortcut_bar_button",
		sprite = "utility/import",
		-- caption = {"gui.import"},
		tooltip = {"tooltip.import-preset"}
	}

	local delete_button = sidebar_menu.add {
		type = "sprite-button",
		name = lrm.gui.delete_button,
		--style = lrm.gui.sidebar_button,
		style = "shortcut_bar_button_red",
		sprite = "utility/trash",
		-- caption = {"gui.delete"},
		tooltip = {"tooltip.delete-preset"}
	}

end
function gui.build_preset_list(player, gui_body_flow)
	if not player then 
		return 
	end
	if not gui_body_flow then 
		local frame 		= gui.get_gui_frame(player, lrm.gui.frame)
		gui_body_flow		= frame and frame[lrm.gui.body] or nil
	end

	local preset_list = gui_body_flow[lrm.gui.preset_list] or gui_body_flow.add {
		type = "scroll-pane",
		name = lrm.gui.preset_list,
		style = lrm.gui.preset_list,
	}
	preset_list.vertical_scroll_policy = "always"
	preset_list.horizontal_scroll_policy = "never"
	
	preset_list.clear()
	
	local presets = global["preset-names"][player.index]
	if #presets < 1 then 
		export_button.enabled = false
		delete_button.enabled = false
	end
	for i,preset in pairs(presets) do
		button = preset_list.add {
			type = "button",
			name = lrm.gui.preset_button .. i,
			style = lrm.gui.preset_button,
			caption = preset,
			tooltip = preset
		}
	end
end

function gui.build_slots(player, preset_slots, parent_to_extend)
	
	local request_table = parent_to_extend[lrm.gui.request_table] or parent_to_extend.add {
		type = "table",
		name = lrm.gui.request_table,
		style = lrm.gui.request_table,
		column_count = 10
	}

	request_table.clear()

	-- no request-table if nothing is selected
	if ( preset_slots == nil ) then return end
	
	local slots = preset_slots
	for i = 1, slots do
		local request = request_table.add {
			type = "choose-elem-button",
			name = lrm.gui.request_slot .. i,
			elem_type = "item",
			style = lrm.gui.request_slot,

			locked = true	-- read only flag
		}
		
		local min = request.add {
			type = "label",
			name = lrm.gui.request_min .. i,
			style = lrm.gui.request_min,
			ignored_by_interaction = true
		}
		
		local max = request.add {
			type = "label",
			name = lrm.gui.request_max .. i,
			style = lrm.gui.request_max,
			ignored_by_interaction = true
		}
		
	end
end

function gui.set_gui_elements_enabled(player)
	-- get states
	local preset_selected 	= global["presets-selected"][player.index] or nil
	preset_selected  		= (preset_selected and preset_selected > 0) or false
	local inventory_open 	= not(global["inventories-open"][player.index] == nil) or false
	local override_inventory= settings.get_player_settings(player)["LRM-default-to-user"].value or false
	inventory_open = inventory_open or override_inventory

	-- tool-bar elements
	local frame				= gui.get_gui_frame(player, lrm.gui.frame)
	local toolbar 			= frame and frame[lrm.gui.toolbar] or nil

	local save_as_textfield = toolbar and toolbar[lrm.gui.save_as_textfield] or nil
	local save_as_button 	= toolbar and toolbar[lrm.gui.save_as_button] or nil
	local blueprint_button 	= toolbar and toolbar[lrm.gui.blueprint_button] or nil
	gui.set_gui_element_enabled ( save_as_textfield, inventory_open, nil, {"tooltip.save-as-textfield"} )
	gui.set_gui_element_enabled ( save_as_button, 	 inventory_open, nil, {"tooltip.save-as"} )
	gui.set_gui_element_enabled ( blueprint_button,  inventory_open, nil, {"tooltip.blueprint-request"} )

	-- side-bar elements
	local sidebar_menu		= frame and frame[lrm.gui.sidebar_menu] or nil

	local save_button 		= sidebar_menu and sidebar_menu[lrm.gui.save_button] or nil
	local load_button 		= sidebar_menu and sidebar_menu[lrm.gui.load_button] or nil
	local delete_button 	= sidebar_menu	and sidebar_menu[lrm.gui.delete_button] or nil
	local export_button 	= sidebar_menu	and sidebar_menu[lrm.gui.export_button] or nil
	gui.set_gui_element_enabled ( save_button, inventory_open, preset_selected, {"tooltip.save-preset"} )
	gui.set_gui_element_enabled ( load_button, inventory_open, preset_selected, {"tooltip.load-preset"} )
	gui.set_gui_element_enabled ( delete_button,		  nil, preset_selected, {"tooltip.delete-preset"} )
	gui.set_gui_element_enabled ( export_button,		  nil, preset_selected, {"tooltip.export-preset"} )

end

function gui.set_gui_element_enabled(gui_element, inventory_open, preset_selected, localized_tooltip)
	if not (gui_element) or (inventory_open == nil and preset_selected == nil) then
		return
	end

	local tooltip = {"messages.no-request-entity-selected", {"messages.source-entity"}, {"messages.save"}, {"messages.preset"}}
	
	local flag = ((inventory_open == nil) or inventory_open==true) and ((preset_selected == nil) or preset_selected==true)

	if gui_element.name == lrm.gui.blueprint_button then
		tooltip = {"messages.no-request-entity-selected", {"messages.target-entity"}, {"messages.append"}, {"messages.blueprint"}}
	elseif gui_element.name == lrm.gui.save_button then
		if not preset_selected then
			tooltip = {"messages.select-preset", {"messages.save"}}
		end
	elseif gui_element.name == lrm.gui.load_button then
		if not preset_selected then
			tooltip = {"messages.select-preset", {"messages.load"}}
		else
			tooltip = {"messages.no-request-entity-selected", {"messages.target-entity"}, {"messages.load"}, {"messages.preset"}}
		end
	elseif gui_element.name == lrm.gui.delete_button then
		tooltip = {"messages.select-preset", {"messages.delete"}}
	elseif gui_element.name == lrm.gui.export_button then
		tooltip = {"messages.select-preset", {"messages.export"}}
	end


	gui_element.enabled = flag
	if flag == true then
		gui_element.tooltip = localized_tooltip
	else
		gui_element.tooltip = tooltip
	end
end

function gui.build(player)
	if not player.force.technologies["logistic-robotics"].researched then
		return nil
	end
	
	gui.build_toggle_button(player)
	gui.build_gui(player)
end

function gui.force_rebuild(player, open)
	local frame_flow = player.gui.screen
	if frame_flow[lrm.gui.master] then
		if open == nil then open = frame_flow[lrm.gui.master].visible end
		frame_flow[lrm.gui.master].destroy()
	end
	
	gui.build(player)
	if open then frame_flow[lrm.gui.master].visible = true end
end

function gui.get_save_as_name(player, parent_frame)
	--local frame =  gui.get_gui_frame (player, parent_frame)
	local toolbar = parent_frame and parent_frame[lrm.gui.toolbar]
	local textfield = toolbar and toolbar[lrm.gui.save_as_textfield]

	return textfield and textfield.text
end

function gui.select_preset(player, preset_selected)
	local button_to_select	= lrm.gui.preset_button .. preset_selected

	local frame 		= gui.get_gui_frame(player, lrm.gui.frame)
	local body 			= frame and frame[lrm.gui.body] or nil
	-- local sidebar 		= body 		and body	[lrm.gui.sidebar] or nil -- removed
	local preset_list 	= body 	and body[lrm.gui.preset_list] or nil

	local enabled_state = not(preset_selected == nil) and preset_selected > 0 or false
	local inventory_open = not(global["inventories-open"][player.index] == nil) or false

	if not preset_list then return end

	for _, preset in pairs(preset_list.children) do
		if preset.name == button_to_select then
			preset.style = lrm.gui.preset_button_selected
			preset_list.scroll_to_element(preset)
		else
			preset.style = lrm.gui.preset_button
		end
	end
end

function gui.display_preset(player, preset_data, request_window)
	local slots = preset_data and table_size(preset_data)

	if not request_window then
		local frame 	= gui.get_gui_frame(player, lrm.gui.frame)
		local body		= frame and frame[lrm.gui.body]
		
		request_window = body and body[lrm.gui.request_window]
		if not request_window then return end
	end

	gui.build_slots(player, slots, request_window)

	if slots == nil then return end
	-- there is nothing to display...

	local request_table = request_window[lrm.gui.request_table]
	
	for i = 1, slots do
		local item = preset_data and preset_data[i] or nil
		if item then
			-- TODO see if there's a way to detect prototype name changes
			if game.item_prototypes[item["name"]] then
				request_table.children[i].elem_value = item["name"]
				if ( item["min"] > 0 ) then
					request_table.children[i].children[1].caption = util.format_number(item["min"], true)
				else
					-- as the table was just created and no min required leave the field empty
				end
				if ( item["max"] == 0xFFFFFFFF ) then
					request_table.children[i].children[2].style = lrm.gui.request_infinit
					request_table.children[i].children[2].caption = "∞"
				else
					request_table.children[i].children[2].style = lrm.gui.request_max
					request_table.children[i].children[2].caption = util.format_number(item["max"], true)
				end
			else
				-- as the table was just created, there is nothing to clear
			end
		else
			-- as the table was just created, there is nothing to clear
		end
	end
end

function gui.delete_preset(player, preset)
	local frame = gui.get_gui_frame(player, lrm.gui.frame)
	local body = frame and frame[lrm.gui.body]
	local preset_list = body and body[lrm.gui.preset_list]
	preset_list[lrm.gui.preset_button .. preset].destroy()

	-- clear the request-table to make it clear that no template is selected
	local request_window = body and body[lrm.gui.request_window]

	if ( request_window[lrm.gui.request_table] ) then
		request_window[lrm.gui.request_table].destroy()
	end
end

function gui.build_export_frame(player)
	local export_frame, code_textbox = gui.build_code_frame(player, lrm.gui.export_frame, {"gui.export-title"}, true)
end

function gui.display_export_code(player, encoded_string)
	local frame_flow = player.gui.screen
	local gui_master = frame_flow and frame_flow[lrm.gui.master]
	local gui_frame = gui_master and gui_master[lrm.gui.export_frame] or nil
	local code_textbox	= gui_frame and gui_frame[lrm.gui.code_textbox] or nil

	code_textbox.text = encoded_string

	gui_frame.visible = true
end

function gui.build_import_frame(player)
	local import_frame, code_textbox = gui.build_code_frame(player, lrm.gui.import_frame, {"gui.import-title"}, false)
end

function gui.build_code_frame(player, frame_name, localized_frame_title, export)
	local frame_flow = player.gui.screen
	local gui_master = frame_flow and frame_flow[lrm.gui.master]	

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

	gui.build_title_bar(player, code_frame, localized_frame_title)


	local code_textbox = code_frame.add {
		type = "text-box",
		name = lrm.gui.code_textbox,
		style = lrm.gui.code_textbox,
	}
	code_textbox.word_wrap = true
	code_textbox.read_only = export

	local gui_toolbar = code_frame.add {
		type = "flow",
		name = lrm.gui.toolbar,
		direction = "horizontal"
	}
	gui_toolbar.style.width = 400
	gui_toolbar.style.vertical_align = "bottom"
	-- manually align buttons with request_window (bottom)
	gui_toolbar.style.height = 43

	-- if ( export and export == true) then
	-- 	local copy_button = gui_toolbar.add {
	-- 		type = "button",
	-- 		name = lrm.gui.copy_button,
	-- 		style = lrm.gui.save_as_button,
	-- 		caption = {"gui.copy"}
	-- 	}
	-- end

	local empty = gui_toolbar.add {
		type = "empty-widget",
		name = lrm.gui.empty,
	}
	empty.style.horizontally_stretchable = "on"

	local confirm_button = gui_toolbar.add {
		type = "button",
		name = lrm.gui.OK_button,
		style = lrm.gui.save_as_button,
		caption = {"gui.ok"}
	}
	
	return code_frame, code_textbox
end


-- function gui.get_export_string(player)
-- 	local frame = gui.get_gui_frame(player, lrm.gui.export_frame)
-- 	local code_textbox	= frame and frame[lrm.gui.code_textbox] or nil

-- 	return (code_textbox and code_textbox.text)
-- end

function gui.get_import_string(player)
	local frame = gui.get_gui_frame(player, lrm.gui.import_frame)
	local code_textbox	= frame and frame[lrm.gui.code_textbox] or nil

	return (code_textbox and code_textbox.text)
end

function gui.build_import_preview_frame (player)
	local frame_flow = player.gui.screen
	local gui_master = frame_flow and frame_flow[lrm.gui.master] or nil
	local gui_frame = gui_master and gui_master[lrm.gui.import_preview_frame] or nil

	if gui_frame then 
		return
	end

	local gui_frame = gui_master.add {
		type = "frame",
		name = lrm.gui.import_preview_frame,
		style = lrm.gui.import_preview_frame,
		direction = "vertical",
	}
	gui_frame.visible = false

	gui.build_title_bar(player, gui_frame, {"gui.import-preview-title"})

	local gui_toolbar = gui_frame.add {
		type = "flow",
		name = lrm.gui.toolbar,
		direction = "horizontal"
	}
	gui_toolbar.style.vertical_align = "center"

	local save_as_textfield = gui_toolbar.add {
		type = "textfield",
		name = lrm.gui.save_as_textfield,
		style = lrm.gui.save_as_textfield
	}
	
	local save_as_button = gui_toolbar.add {
		type = "sprite-button",
		name = lrm.gui.save_as_button,
		--style = "tool_button_green",
		style = "shortcut_bar_button_green",
		sprite = "utility/copy",
		tooltip = {"tooltip.save-as"}
	}

	local request_window = gui_frame.add {
		type = "scroll-pane",
		name = lrm.gui.request_window,
		style = lrm.gui.request_window
	}
	request_window.vertical_scroll_policy = "auto-and-reserve-space"
end

function gui.show_imported_preset(player, preset_data)
	local frame = gui.get_gui_frame(player, lrm.gui.import_preview_frame)
	local request_window = frame and frame[lrm.gui.request_window] or nil
	local toolbar 	= frame and frame[lrm.gui.toolbar] or nil
	local preset_name_field = toolbar and toolbar[lrm.gui.save_as_textfield] or nil


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
	gui.display_preset (player, preset_data, request_window)
end

function gui.get_gui_frame(player, frame_name)
	local frame_flow = player.gui.screen
	local gui_master = frame_flow and frame_flow[lrm.gui.master] or nil
	local gui_frame = gui_master and gui_master[frame_name] or nil
	return gui_frame
end

function gui.show_frame(player, frame_name)
	frame = gui.get_gui_frame(player, frame_name)
	if frame then frame.visible = true end
end
function gui.hide_frame(player, frame_name)
	frame = gui.get_gui_frame(player, frame_name)
	if frame then frame.visible = false end
end