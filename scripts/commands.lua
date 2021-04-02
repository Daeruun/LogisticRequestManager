require 'defines'
if not lrm.commands then 
    lrm.commands = {}
end

lrm.commands.commands="force_gui, renew_empty, renew_autotrash"
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
        local parameters=util.split(event.parameter, " ")
        if not parameters[1] then 
            lrm.message(player, {"", {"command.parameter_missing"}, "   ", lrm.commands.usage} )
        elseif parameters[1]=="debug" then
            lrm.commands.debug(player, parameters)
            
        elseif parameters[1]=="help" then
            lrm.commands.help(player, parameters)
            
        elseif parameters[1]=="renew_empty" then
            lrm.recreate_empty_preset(player)

        elseif parameters[1]=="renew_autotrash" then
            lrm.recreate_autotrash_preset(player)

        elseif parameters[1]=="force_gui" then
            lrm.gui.build_toggle_button(player)
        else
            lrm.message(player, {"", {"command.parameter_invalid"}, "   ", lrm.commands.usage} )
        end
    else
        lrm.message(player, {"", {"command.parameter_missing"}, "   ", lrm.commands.usage} )
    end
end

function lrm.commands.help(player, parameters)
    if not parameters[2] then 
        lrm.message(player, {"", {"command.parameter_missing"}, "   ", lrm.commands.usage} )
    elseif parameters[2]=="help" then
        lrm.message(player, {"", {"details-help"}, "   ", lrm.commands.help} )
    elseif parameters[2]=="renew_empty" then
        lrm.message(player, {"", {"details-renew_empty"} })
    elseif parameters[2]=="renew_autotrash" then
        lrm.message(player, {"", {"details-renew_autotrash"} })
    elseif parameters[2]=="force_gui" then
        lrm.message(player, {"", {"details-force_gui"} })
    else
        lrm.message(player, {"", {"command.parameter_invalid"}, "   ", lrm.commands.usage} )
    end
end

function lrm.commands.debug(player, parameters)
    if not parameters[2] then 
        lrm.message(player, {"", {"command.parameter_missing"}, "   ", lrm.commands.usage} )
    elseif parameters[2]=="check_logistics_available" then
        lrm.message(player, {"", "checking availablility of logistics per player",} )
        for _, player in pairs(game.players) do
            game.print (player.name .. ": " .. tostring(lrm.check_logistics_available and lrm.check_logistics_available(player) or "nil") ) 
        end
        
    elseif parameters[2]=="feature_level" then
        lrm.message(player, "feature_level: " .. tostring(global.feature_level))

    else
        lrm.message(player, {"", {"command.parameter_invalid"}, "   ", lrm.commands.usage} )
    end
end