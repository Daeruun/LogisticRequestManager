require 'defines'
require 'gui'

require 'scripts/globals'
require 'scripts/request-manager'
require 'scripts/blueprint-requests'


function lrm.select_preset(player, preset)
	lrm.gui.select_preset(player, preset)
	local data = global["preset-data"][player.index][preset]
	lrm.gui.display_preset(player, data)
	global["presets-selected"][player.index] = preset
	lrm.gui.set_gui_elements_enabled(player)
end

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end
	local frame_flow = player.gui.screen
	local gui_clicked = event.element.name
	
	if not (player.force.technologies["logistic-robotics"]["researched"]) then
		for _, player in pairs(player.force.players) do
			lrm.gui.destroy(player)
		end
		return
	 end

	if gui_clicked == lrm.defines.gui.toggle_button then
		if (event.control and event.alt and event.shift) then 
			lrm.gui.force_rebuild(player)
			lrm.select_preset(player, global["presets-selected"][player.index])
			return
		end
		lrm.close_or_toggle(event, true, nil)

	elseif gui_clicked == lrm.defines.gui.close_button then
		lrm.close_or_toggle(event, false)
		

	elseif gui_clicked == lrm.defines.gui.save_as_button then
		local parent_frame = event.element.parent and event.element.parent.parent
		if not parent_frame then return end
		local preset_name = lrm.gui.get_save_as_name(player, parent_frame)
		if not preset_name or preset_name == "" then
			lrm.message(player, {"messages.name-needed"})
		else
			local new_preset = nil
			if parent_frame.name == lrm.defines.gui.frame then
				new_preset = lrm.request_manager.save_preset(player, 0, preset_name)
			elseif parent_frame.name == lrm.defines.gui.import_preview_frame then
				new_preset = lrm.request_manager.save_imported_preset(player, preset_name)
				if (new_preset) then
					lrm.gui.hide_frame(player, lrm.defines.gui.import_frame)
					lrm.gui.hide_frame(player, lrm.defines.gui.import_preview_frame)	
				end
			end
			if not (new_preset) then return end
			lrm.gui.build_preset_list(player)
			lrm.select_preset(player, new_preset)
		end
	
	elseif gui_clicked == lrm.defines.gui.blueprint_button then
		lrm.request_manager.request_blueprint(player)
	
	elseif gui_clicked == lrm.defines.gui.save_button then
		local preset_selected = global["presets-selected"][player.index]
		if preset_selected == 0 then
			lrm.message(player, {"messages.select-preset", {"messages.save"}})
		else
			lrm.request_manager.save_preset(player, preset_selected)
			lrm.select_preset(player, preset_selected)
		end
	
	elseif gui_clicked == lrm.defines.gui.load_button then
		local preset_selected = global["presets-selected"][player.index]
		if preset_selected == 0 then
			lrm.message(player, {"messages.select-preset", {"messages.load"}})
		else
			lrm.request_manager.load_preset(player, preset_selected)
		end
	
	elseif gui_clicked == lrm.defines.gui.delete_button then
		local preset_selected = global["presets-selected"][player.index]
		if preset_selected == 0 then
			lrm.message(player, {"messages.select-preset", {"messages.delete"}})
		else
			lrm.request_manager.delete_preset(player, preset_selected)
			lrm.gui.delete_preset(player, preset_selected)
			lrm.select_preset(player, 0)
		end
	
	elseif gui_clicked == lrm.defines.gui.import_button then
		local frame = lrm.gui.get_gui_frame(player, lrm.defines.gui.import_frame)
		if frame and frame.visible then
			lrm.gui.hide_frame(player, lrm.defines.gui.import_frame)
			lrm.gui.hide_frame(player, lrm.defines.gui.import_preview_frame)
		else	
			lrm.gui.show_frame(player, lrm.defines.gui.import_frame)
		end


		
	elseif gui_clicked == lrm.defines.gui.export_button then
		local frame = lrm.gui.get_gui_frame(player, lrm.defines.gui.export_frame)
		if frame and frame.visible then
			lrm.gui.hide_frame(player, lrm.defines.gui.export_frame)
		else
			local preset_selected = global["presets-selected"][player.index]
			if preset_selected == 0 then
				lrm.message(player, {"messages.select-preset", {"messages.export"}})
			else
				local encoded_string = lrm.request_manager.export_preset(player, preset_selected, coded)
				if encoded_string and not (encoded_string == "")  then
					lrm.gui.display_export_code(player, encoded_string)
				end
			end
		end

	elseif gui_clicked == lrm.defines.gui.OK_button then
		local parent_frame = event.element.parent and event.element.parent.parent

		if parent_frame and parent_frame.name == lrm.defines.gui.export_frame then
			lrm.gui.hide_frame(player, lrm.defines.gui.export_frame)
		elseif parent_frame and parent_frame.name == lrm.defines.gui.import_frame then
			local preset_data = lrm.request_manager.import_preset(player)
			lrm.gui.show_imported_preset(player, preset_data)
			lrm.gui.hide_frame(player, lrm.defines.gui.import_frame)
		end

	else
		local gui_parent = event.element.parent
		if gui_parent.name == lrm.defines.gui.preset_list then
			local preset_clicked = string.match(gui_clicked, string.gsub(lrm.defines.gui.preset_button, "-", "%%-") .. "(%d+)")
			if preset_clicked then
				lrm.select_preset(player, tonumber(preset_clicked))
			end
		end
	end
end)

script.on_event(defines.events.on_research_finished, function(event)
	if string.match(event.research.name, "logistic%-robotics") then
		lrm.globals.init()
		
		for _, player in pairs(event.research.force.players) do
			lrm.globals.init_player(player)
			lrm.gui.force_rebuild(player)
			lrm.select_preset(player, global["presets-selected"][player.index])
		end
	end
end)
	
script.on_event(defines.events.on_player_created, function(event)
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end
	
	lrm.globals.init_player(player)
	local request_data = {}
	for i = 1, 40 do
		request_data[i] = { nil }
	end
	global["preset-data"][player.index][1]  = request_data
	global["preset-names"][player.index][1] = {"gui.empty"}
	global["presets-selected"][player.index] = 1
	
	lrm.gui.build(player)
end)

script.on_init(function()
	lrm.globals.init()

	for _, player in pairs(game.players) do
		lrm.globals.init_player(player)
		if (player.force.technologies["logistic-robotics"]["researched"]) then
			lrm.gui.build(player)
		end
	end
end)

script.on_configuration_changed(function(event)
	lrm.globals.init()
	for _, player in pairs(game.players) do
		lrm.globals.init_player(player)

		for preset_index,preset_data in pairs(global["preset-data"][player.index]) do
			local slots = table_size(preset_data)
			for i = 1, slots do
				local item = preset_data[i]
				if item.name then
					if game.item_prototypes[item.name] == nil then
						lrm.message (player, {"messages.error-item-removed", item.name, serpent.line(global["preset-names"][player.index][preset_index])} )
					end
				end
			end
		end

		if not (player.force.technologies["logistic-robotics"]["researched"]) then
			lrm.gui.destroy(player)
		else
			lrm.gui.force_rebuild(player)
			lrm.select_preset(player, global["presets-selected"][player.index])
		end

		if ( event.mod_changes 
		 	and event.mod_changes.LogisticRequestManager 
		 	and event.mod_changes.LogisticRequestManager.old_version )
		 then
			local old_version = util.split (event.mod_changes.LogisticRequestManager.old_version, ".") or nil
			local new_version = {1,1,7}
			if old_version then 
				local print_version_hint = false
				for index, value in pairs(old_version) do
					if tonumber(value) < new_version[index] then print_version_hint = true end
				end
				
				if print_version_hint then 
					lrm.message( player, {"", {"messages.new-feature-export-import"}," [color=yellow]", {"messages.new-gui"}, "[/color] ", {"messages.new-how-to"} })
				end
			end

		end
	end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end
	if not (player.force.technologies["logistic-robotics"]["researched"]) then return end

	lrm.gui.set_gui_elements_enabled(player)
end)

script.on_event("LRM-input-toggle-gui", function(event)
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end
	if not (player.force.technologies["logistic-robotics"]["researched"]) then
		for _, player in pairs(player.force.players) do
			lrm.gui.destroy(player)
		end
		return
	end

	lrm.close_or_toggle(event, true)
end)

script.on_event("LRM-input-close-gui", function(event)
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end
	if not (player.force.technologies["logistic-robotics"]["researched"]) then
		for _, player in pairs(player.force.players) do
			lrm.gui.destroy(player)
		end
		return
	end
	
	local frame_flow = player.gui.screen
	local master_frame = frame_flow and frame_flow[lrm.defines.gui.master] or nil
	
	lrm.close_or_toggle(event, false)
end)

function lrm.close_or_toggle (event, toggle)
	local player = game.players[event.player_index]
	local frame_flow = player.gui.screen
	local master_frame = frame_flow and frame_flow[lrm.defines.gui.master] or nil
	local parent_frame = event.element and event.element.parent.parent or nil
	if not (parent_frame and parent_frame.parent) then
		parent_frame = nil
	end

	if (event.element and event.element.name == "logistic-request-manager-gui-button" and event.shift) then
		global["screen_location"][player.index] = {85, 65}
		if master_frame then
			master_frame.location = {85, 65}
			master_frame.visible = false
		end
	end


	if master_frame and master_frame.visible then
		global["screen_location"][player.index] = master_frame.location
		if not parent_frame or parent_frame.name == lrm.defines.gui.frame then
			master_frame.visible = false
		else
			parent_frame.visible = false
			if parent_frame.name == lrm.defines.gui.import_frame then
				lrm.gui.hide_frame(player, lrm.defines.gui.import_preview_frame)
			end
		end
	elseif toggle then
		lrm.gui.build(player, true)
		lrm.select_preset(player, global["presets-selected"][player.index])
		if master_frame[lrm.defines.gui.frame] then master_frame[lrm.defines.gui.frame].visible = true end
	end
end

function lrm.message (player, localized_string)
	if not ( player and localized_string ) then 
		return
	end

	player.print ({"", "[color=yellow][LRM][/color] ", localized_string})
end

function lrm.error (player, localized_string)
	if not ( player and localized_string ) then 
		return
	end

	player.print ({"", "[color=red][LRM][/color] ", {"messages.Error"}, ": ", localized_string})
end