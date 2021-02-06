local mod_gui = require 'mod-gui'
local util = require 'util'
if not gui then gui = {} end

function gui.destroy(player)
	if frame_flow[lrm.gui.frame] then 
		frame_flow[lrm.gui.frame].destroy()
	end
	local button_flow = mod_gui.get_button_flow(player)
	if button_flow[lrm.gui.toggle_button] then
		button_flow[lrm.gui.toggle_button].destroy()
	end
end

function gui.build_toggle_button(player)
	local button_flow = mod_gui.get_button_flow(player)
	if not button_flow[lrm.gui.toggle_button] then
		button_flow.add {
			type = "sprite-button",
			name = lrm.gui.toggle_button,
			sprite = "item/logistic-robot",
			style = mod_gui.button_style,
			tooltip = {"gui.button-tooltip"}
		}
	end
end

function gui.build_main_frame(player)
	local frame_flow = player.gui.screen
	if frame_flow[lrm.gui.frame] then
		return nil
	end
	
	local gui_frame = frame_flow.add {
		type = "frame",
		name = lrm.gui.frame,
		style = lrm.gui.frame,
		caption = {"gui.title"},
		direction = "vertical"
	}
	local location = global["screen_location"][player.index]
	if (location.x == nil) or (location.y == nil) then location = {200, 100} end
	gui_frame.location = location
	gui_frame.visible = false
	
	local gui_toolbar = gui_frame.add {
		type = "flow",
		name = lrm.gui.toolbar,
		direction = "horizontal"
	}
	gui_toolbar.style.vertical_align = "center"
	
	gui_toolbar.add {
		type = "textfield",
		name = lrm.gui.save_as_textfield,
		style = lrm.gui.save_as_textfield
	}
	
	gui_toolbar.add {
		type = "button",
		name = lrm.gui.save_as_button,
		style = lrm.gui.save_as_button,
		caption = {"gui.save-as"}
	}
	
	gui_toolbar.add {
		type = "sprite-button",
		name = lrm.gui.blueprint_button,
		style = lrm.gui.blueprint_button,
		sprite = "item.blueprint",
		tooltip = {"gui.blueprint-request-tooltip"}
	}
	
	local gui_body = gui_frame.add {
		type = "flow",
		name = lrm.gui.body,
		direction = "horizontal"
	}
	
	local sidebar = gui_body.add {
		type = "flow",
		name = lrm.gui.sidebar,
		style = lrm.gui.sidebar,
		direction = "vertical"
	}
	
	local sidebar_menu = sidebar.add {
		type = "flow",
		name = lrm.gui.sidebar_menu,
		direction = "horizontal"
	}
	
	sidebar_menu.add {
		type = "button",
		name = lrm.gui.save_button,
		style = lrm.gui.sidebar_button,
		caption = {"gui.save"},
		tooltip = {"gui.save-preset-tooltip"}
	}
	
	sidebar_menu.add {
		type = "button",
		name = lrm.gui.load_button,
		style = lrm.gui.sidebar_button,
		caption = {"gui.load"},
		tooltip = {"gui.load-preset-tooltip"}
	}
	
	sidebar_menu.add {
		type = "button",
		name = lrm.gui.delete_button,
		style = lrm.gui.sidebar_button,
		caption = {"gui.delete"},
		tooltip = {"gui.delete-preset-tooltip"}
	}
	
	local preset_list = sidebar.add {
		type = "scroll-pane",
		name = lrm.gui.preset_list,
		style = lrm.gui.preset_list,
	}
	preset_list.vertical_scroll_policy = "always"
	preset_list.horizontal_scroll_policy = "never"
	
	local presets = global["preset-names"][player.index]
	for i,preset in pairs(presets) do
		button = preset_list.add {
			type = "button",
			name = lrm.gui.preset_button .. i,
			style = lrm.gui.sidebar_button,
			caption = preset
		}
	end
	
	local request_window = gui_body.add {
		type = "scroll-pane",
		name = lrm.gui.request_window,
		style = lrm.gui.request_window
	}
	request_window.vertical_scroll_policy = "auto-and-reserve-space"
	
	gui.build_slots(player, nil)	
end

function gui.build_slots(player, preset_slots)
	local request_window = player.gui.screen
		[lrm.gui.frame]
		[lrm.gui.body]
		[lrm.gui.request_window]
	
	if ( request_window[lrm.gui.request_table] ) then
		request_window[lrm.gui.request_table].destroy()
	end
	
	local request_table = request_window.add {
		type = "table",
		name = lrm.gui.request_table,
		style = lrm.gui.request_table,
		column_count = 10
	}

	-- no request-table if nothing is selected
	if ( preset_slots == nil ) then return end
	
	local slots = preset_slots
	for i = 1, slots do
		local request = request_table.add {
			type = "choose-elem-button",
			name = lrm.gui.request_slot .. i,
			elem_type = "item",
			style = lrm.gui.request_slot
		}
		request.locked = true

		
		local min = request.add {
			type = "label",
			name = lrm.gui.request_min .. i,
			style = lrm.gui.request_min
		}
		min.ignored_by_interaction = true
		local max = request.add {
			type = "label",
			name = lrm.gui.request_max .. i,
			style = lrm.gui.request_max
		}
		max.ignored_by_interaction = true
	end
end

function gui.build(player)
	if not player.force.technologies["logistic-robotics"].researched then
		return nil
	end
	
	gui.build_toggle_button(player)
	gui.build_main_frame(player)
end

function gui.force_rebuild(player, open)
	local frame_flow = player.gui.screen
	if frame_flow[lrm.gui.frame] then
		if open == nil then open = frame_flow[lrm.gui.frame].visible end
		frame_flow[lrm.gui.frame].destroy()
	end
	
	gui.build(player)
	if open then frame_flow[lrm.gui.frame].visible = true end
end

function gui.get_save_as_name(player)
	local save_as_field = player.gui.screen
		[lrm.gui.frame]
		[lrm.gui.toolbar]
		[lrm.gui.save_as_textfield]
	return save_as_field.text
end

function gui.select_preset(player, preset_selected)
	preset_selected = lrm.gui.preset_button .. preset_selected
	local preset_list = player.gui.screen
		[lrm.gui.frame]
		[lrm.gui.body]
		[lrm.gui.sidebar]
		[lrm.gui.preset_list]
	for _, preset in pairs(preset_list.children) do
		if preset.name == preset_selected then
			preset.style = lrm.gui.preset_button_selected
			preset_list.scroll_to_element(preset)
		else
			preset.style = lrm.gui.preset_button
		end
	end
end

function gui.display_preset(player, preset_data)
	local slots = preset_data and table_size(preset_data)

	gui.build_slots(player, slots)

	if slots == nil then return end
	-- there is nothing to display...

	local request_table = player.gui.screen
		[lrm.gui.frame]
		[lrm.gui.body]
		[lrm.gui.request_window]
		[lrm.gui.request_table]
	
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
	local preset_list = player.gui.screen
		[lrm.gui.frame]
		[lrm.gui.body]
		[lrm.gui.sidebar]
		[lrm.gui.preset_list]
	preset_list[lrm.gui.preset_button .. preset].destroy()

	-- clear the request-table to make it clear that no template is selected
	local request_window = player.gui.screen
		[lrm.gui.frame]
		[lrm.gui.body]
		[lrm.gui.request_window]

	if ( request_window[lrm.gui.request_table] ) then
		request_window[lrm.gui.request_table].destroy()
	end
end
