if not lrm.globals then lrm.globals = {} end

function lrm.globals.init()
	global 						= global or {}
	global["preset-data"]		= global["preset-data"] or {}
	global["preset-names"]		= global["preset-names"] or {}
	global["presets-selected"]	= global["presets-selected"] or {}
	global["inventories-open"]	= global["inventories-open"] or {}
	global["screen_location"]	= global["screen_location"] or {}
	global["bring_to_front"] 	= global["bring_to_front"] or {}
	global.on_tick = global.on_tick or false
end

function lrm.globals.init_player(player)
	local index = player.index
	
	global["preset-data"][index] 		= global["preset-data"][index] or {}
	global["preset-names"][index] 		= global["preset-names"][index] or {}
	global["presets-selected"][index] 	= global["presets-selected"][index] or 0
	global["screen_location"][index] 	= global["screen_location"][index] or nil
end