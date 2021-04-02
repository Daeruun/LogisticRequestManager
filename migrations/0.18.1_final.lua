local mod_gui = require 'mod-gui'

for _, player in pairs(game.players) do
    -- remove interim-version of floating screen - should never have been created for anybody but during testing (just playing it save as the old version was on github...)
    if player.gui.screen["logistic-request-manager-gui-frame"] then
        player.gui.screen["logistic-request-manager-gui-frame"].destroy()
    end

    -- remove old static gui from gui.left
    local frame_flow = mod_gui.get_frame_flow(player)
    if frame_flow["logistic-request-manager-gui-frame"] then
        frame_flow["logistic-request-manager-gui-frame"].destroy()
    end

    -- remove old unused frame from gui.left
    if frame_flow["logistic-request-manager-gui"] then
        frame_flow["logistic-request-manager-gui"].destroy()
    end
    
    -- remove old unused button
    local button_flow = mod_gui.get_button_flow(player)
    if button_flow["logistic-request-manager-button"] then
        button_flow["logistic-request-manager-button"].destroy()
    end

--    player.print("[LRM] Migration to 0.18.1 complete.")
end