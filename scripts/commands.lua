require './defines'

function commands.init()
    if commands.commands["lrm"] then commands.remove_command("lrm") end
    commands.add_command("lrm", "LRM Commands", commands.run )
end

function commands.run(event)
    local player = game.players[event.player_index]
    player.print("command is run")
    if (event.parameter) then
        local param = event.parameter
        if (param == "flush") then
            player.print("flush gui")
            gui.force_rebuild(player)
            select_preset(player, global["presets-selected"][player.index])
        end
    end
end

function commands.parse(event)
    local player = game.players[event.player_index]
    player.print("command is parsed")
end