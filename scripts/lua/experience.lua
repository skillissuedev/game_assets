function client_start(framework)
end

function client_update(framework)
end

function client_render(framework)
end



function server_start(framework)
    -- framework:set_global_system_value("Experience_PlayerXP_id", {15}) - players' experience
    -- framework:set_global_system_value("Experience_PlayerAddXP_id", {15}) - how much XP should be added
    -- framework:set_global_system_value("Experience_PlayerRemoveXP_id", {2}) - how much XP should be removed
end

function server_update(framework)
    for _, player_id in pairs(framework:get_global_system_value("PlayerManagerIDs")) do
        local add_xp = framework:get_global_system_value("Experience_PlayerAddXP_" .. player_id)
        if add_xp == nil then
            add_xp = 0
        else
            add_xp = add_xp[1]
        end

        local remove_xp = framework:get_global_system_value("Experience_PlayerRemoveXP_" .. player_id)
        if remove_xp == nil then
            remove_xp = 0
        else
            remove_xp = remove_xp[1]
        end

        local player_xp = framework:get_global_system_value("Experience_PlayerXP_" .. player_id)
        if player_xp == nil then
            player_xp = 0
        else
            player_xp = player_xp[1]
        end

        player_xp = player_xp + add_xp - remove_xp

        if player_xp < 0 then
            player_xp = 0
        end

        framework:set_global_system_value("Experience_PlayerXP_" .. player_id, {player_xp})
        framework:set_global_system_value("Experience_PlayerAddXP_" .. player_xp, {0})
        framework:set_global_system_value("Experience_PlayerRemoveXP_" .. player_xp, {0})
    end
end

function reg_message(message, framework)
end
