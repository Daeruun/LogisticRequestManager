local mod_gui = require 'mod-gui'

require 'defines'
require 'gui'

require 'scripts/globals'
require 'scripts/request-manager'
require 'scripts/blueprint-requests'
require 'scripts/commands'


function select_preset(player, preset)
	gui.select_preset(player, preset)
	local data = global["preset-data"][player.index][preset]
	gui.display_preset(player, data)
	global["presets-selected"][player.index] = preset
	gui.set_gui_elements_enabled(player)
end

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end
	local frame_flow = player.gui.screen
	local gui_clicked = event.element.name
	
	-- if frame_flow[lrm.gui.master] then 
	-- 	global["screen_location"][player.index] = frame_flow[lrm.gui.master].location
	-- end
	
	if gui_clicked == lrm.gui.toggle_button then
		close_or_toggle(event, true, parent)

	elseif gui_clicked == lrm.gui.close_button then
		close_or_toggle(event, false)
		

	elseif gui_clicked == lrm.gui.save_as_button then
		local parent_frame = event.element.parent.parent
		preset_name = gui.get_save_as_name(player, parent_frame)
		if not preset_name or preset_name == "" then
			player.print({"messages.name-needed"})
		else
			local new_preset = nil
			if parent_frame.name == lrm.gui.frame then
				new_preset = request_manager.save_preset(player, 0, preset_name)
			elseif parent_frame.name == lrm.gui.import_preview_frame then
				new_preset = request_manager.save_imported_preset(player, preset_name)
			end
			if not (new_preset) then return end
			-- gui.force_rebuild(player, true)
			gui.build_preset_list(player)
			select_preset(player, new_preset)
		end
	
	elseif gui_clicked == lrm.gui.blueprint_button then
		request_manager.request_blueprint(player)
	
	elseif gui_clicked == lrm.gui.save_button then
		preset_selected = global["presets-selected"][player.index]
		if preset_selected == 0 then
			player.print({"messages.select-preset", {"messages.save"}})
		else
			request_manager.save_preset(player, preset_selected)
			select_preset(player, preset_selected)
		end
	
	elseif gui_clicked == lrm.gui.load_button then
		preset_selected = global["presets-selected"][player.index]
		if preset_selected == 0 then
			player.print({"messages.select-preset", {"messages.load"}})
		else
			request_manager.load_preset(player, preset_selected)
		end
	
	elseif gui_clicked == lrm.gui.delete_button then
		preset_selected = global["presets-selected"][player.index]
		if preset_selected == 0 then
			player.print({"messages.select-preset", {"messages.delete"}})
		else
			request_manager.delete_preset(player, preset_selected)
			gui.delete_preset(player, preset_selected)
			select_preset(player, 0)
		end
	
	elseif gui_clicked == lrm.gui.import_button then
		local frame = gui.get_gui_frame(player, lrm.gui.import_frame)
		if frame and frame.visible then
			gui.hide_frame(player, lrm.gui.import_frame)
			gui.hide_frame(player, lrm.gui.import_preview_frame)
		else	
			gui.show_frame(player, lrm.gui.import_frame)
		end


		
	elseif gui_clicked == lrm.gui.export_button then
		local frame = gui.get_gui_frame(player, lrm.gui.export_frame)
		if frame and frame.visible then
			gui.hide_frame(player, lrm.gui.export_frame)
		else
			preset_selected = global["presets-selected"][player.index]
			if preset_selected == 0 then
				player.print({"messages.select-preset", {"messages.export"}})
			else
				local encoded_string = request_manager.export_preset(player, preset_selected, coded)
				if encoded_string and not (encoded_string == "")  then
					gui.display_export_code(player, encoded_string)
				end
			end
		end

	-- elseif gui_clicked == lrm.gui.copy_button then
	-- 	local parent_frame = event.element.parent.parent

	-- 	if parent_frame and parent_frame.name == lrm.gui.export_frame then
	-- 		gui.get_export_string(player)
			
	-- 	end

	elseif gui_clicked == lrm.gui.OK_button then
		local parent_frame = event.element.parent.parent

		if parent_frame and parent_frame.name == lrm.gui.export_frame then
			gui.hide_frame(player, lrm.gui.export_frame)

		elseif parent_frame and parent_frame.name == lrm.gui.import_frame then
			local preset_data = request_manager.import_preset(player)
			gui.show_imported_preset(player, preset_data)
		end

		
		

	else
		local preset_clicked = string.match(gui_clicked, string.gsub(lrm.gui.preset_button, "-", "%%-") .. "(%d+)")
		if preset_clicked then
			select_preset(player, tonumber(preset_clicked))
		end
	end
end)

script.on_event(defines.events.on_research_finished, function(event)
	if string.match(event.research.name, "logistic-robotics") then
		globals.init()
		
		for _, player in pairs(event.research.force.players) do
			globals.init_player(player)
			gui.force_rebuild(player)
			select_preset(player, global["presets-selected"][player.index])
		end
	end
end)
	
script.on_event(defines.events.on_player_created, function(event)
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end
	
	globals.init_player(player)
	player.print(on_player_created)
	local request_data = {}
	for i = 1, 40 do
		request_data[i] = { nil }
	end
	global["preset-data"][player.index][1]  = request_data
	global["preset-names"][player.index][1] = {"gui.empty"}
	global["presets-selected"][player.index] = 1
	
	gui.build(player)
end)

script.on_init(function()
	globals.init()
	commands.init()

	for _, player in pairs(game.players) do
		player.print(on_init)
		globals.init_player(player)
		-- gui.build(player)
	end
end)

script.on_configuration_changed(function(event)
	commands.init()
	globals.init()
	for _, player in pairs(game.players) do
		globals.init_player(player)

		for preset_index,preset_data in pairs(global["preset-data"][player.index]) do
			local slots = table_size(preset_data)
			for i = 1, slots do
				local item = preset_data[i]
				if item.name then
					if game.item_prototypes[item.name] == nil then
						player.print ("LRM Item \"" .. item.name .. "\", listed in preset " .. serpent.line(global["preset-names"][player.index][preset_index]) .. " seems to be gone.")
					end
				end
			end
		end

	 	gui.force_rebuild(player)
		select_preset(player, global["presets-selected"][player.index])

	end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end
	if not (player.force.technologies["logistic-robotics"]["researched"]) then return end

	gui.set_gui_elements_enabled(player)
end)

script.on_event("LRM-input-toggle-gui", function(event)
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end
	if not (player.force.technologies["logistic-robotics"]["researched"]) then return end

	close_or_toggle(event, true)
end)

function close_or_toggle (event, toggle)
	local player = game.players[event.player_index]
	local frame_flow = player.gui.screen
	local master_frame = frame_flow and frame_flow[lrm.gui.master] or nil
	local parent_frame = event.element and event.element.parent.parent or nil
	if not (parent_frame and parent_frame.parent) then
		parent_frame = nil
	end

	if (event.shift) then
		global["screen_location"][player.index] = {85, 65}
		master_frame.location = {85, 65}
		-- if (master_frame) then master_frame.destroy
	end

	if master_frame and master_frame.visible then
		global["screen_location"][player.index] = master_frame.location
		if not parent_frame or parent_frame.name == lrm.gui.frame then
			master_frame.visible = false
		else
			parent_frame.visible = false
			if parent_frame.name == lrm.gui.import_frame then
				gui.hide_frame(player, lrm.gui.import_preview_frame)
			end
		end
	elseif toggle then
		gui.build(player, true)
		select_preset(player, global["presets-selected"][player.index])
		if master_frame[lrm.gui.frame] then master_frame[lrm.gui.frame].visible = true end
	end
end