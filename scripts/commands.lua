require 'defines'
if not lrm.commands then 
	lrm.commands = {} 
end

function lrm.commands.init()
    -- if not commands.oldcommands.commands["lrm"] then
        commands.add_command("lrm", {"", {"command.help"},"\n ",{"command.usage"},"  /lrm [",{"command.parameter"},"]\n ", {"command.with_parameters"}, " inject_empty, inject_autotrash"}, lrm.commands.run)
    -- end
end

function lrm.commands.run(event)
    local player = game.players[event.player_index]
    
    if (event.parameter) then
        local params=util.split(event.parameter, " ")
        if params[1] and params[1]=="inject_empty" then
            lrm.inject_empty_preset(player)
        elseif params[1] and params[1]=="inject_autotrash" then
            lrm.inject_autotrash_preset(player)
        else
            player.print ({"", {"command.parameter_invalid"},"   ",{"command.usage"},"  /lrm [",{"command.parameter"},"]\n ", {"command.with_parameters"}, " inject_empty, inject_autotrash"})
        end
    else
        player.print ({"", {"command.parameter_missing"},"   ",{"command.usage"},"  /lrm [",{"command.parameter"},"]\n ", {"command.with_parameters"}, " inject_empty, inject_autotrash"})
    end
end
