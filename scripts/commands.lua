require 'defines'
if not lrm.commands then 
	lrm.commands = {} 
end

lrm.commands.commands="force_gui, inject_empty, inject_autotrash"
lrm.commands.help={"", " /lrm help [", {"command.parameter"}, "]\n ", {"command.with_parameters"}, " ", lrm.commands.commands}
lrm.commands.details={"", {"command.details"}, lrm.commands.help}
lrm.commands.usage={"", {"command.usage"}, "  /lrm [", {"command.parameter"}, "]\n ", {"command.with_parameters"}, " help, ", lrm.commands.commands, "\n ", lrm.commands.details}

function lrm.commands.init()
    -- if not commands.oldcommands.commands["lrm"] then
        commands.add_command("lrm", {"", {"command.help"}, "\n ", lrm.commands.usage}, lrm.commands.run)
    -- end
end

function lrm.commands.run(event)
    local player = game.players[event.player_index]
    
    if (event.parameter) then
        local params=util.split(event.parameter, " ")
        if params[1] and params[1]=="help" then
            if not params[2] then 
                player.print ({"", {"command.parameter_missing"},"   ", lrm.commands.usage} )
            elseif params[2] and params[2]=="help" then
                player.print ({"", {"details-help"},"   ", lrm.commands.help} )
            elseif params[2] and params[2]=="inject_empty" then
                player.print ({"", {"details-inject_empty"} })
            elseif params[2] and params[2]=="inject_autotrash" then
                player.print ({"", {"details-inject_autotrash"} })
            elseif params[2] and params[2]=="force_gui" then
                player.print ({"", {"details-force_gui"} })
            else
                player.print ({"", {"command.parameter_invalid"}, "   ", lrm.commands.usage} )
            end
        elseif params[1] and params[1]=="inject_empty" then
            lrm.inject_empty_preset(player)
        elseif params[1] and params[1]=="inject_autotrash" then
            lrm.inject_autotrash_preset(player)
        elseif params[1] and params[1]=="force_gui" then
			lrm.gui.build_toggle_button(player)
        else
            player.print ({"", {"command.parameter_invalid"},"   ", lrm.commands.usage} )
        end
    else
        player.print ({"", {"command.parameter_missing"},"   ", lrm.commands.usage} )
    end
end
