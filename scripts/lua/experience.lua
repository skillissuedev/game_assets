local tick_counter = 0
local window_exists = false

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
    local player_ids = framework:get_global_system_value("PlayerManagerIDs")
    for _, player_id in pairs(player_ids) do
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
        framework:set_global_system_value("Experience_PlayerAddXP_" .. player_id, {0})
        framework:set_global_system_value("Experience_PlayerRemoveXP_" .. player_id, {0})
    end

    if tick_counter >= 6 then
        for _, player_id in pairs(player_ids) do
            local player_xp = framework:get_global_system_value("Experience_PlayerXP_" .. player_id)[1]
            send_custom_message(true, "SyncXP", {player_xp}, "OneClient", player_id)
        end
        tick_counter = 0
    else
        tick_counter = tick_counter + 1
    end
end

function reg_message(message, framework)
    local message_id = message:message_id()
    if message_id == "SyncXP" then
        local xp = message:custom_contents()[1]
        --print("current xp value: " .. xp)
        if framework:get_global_system_value("InventoryIsUIOpen")[1] == true then
            window_exists = true
            framework:remove_window("Experience Window")
            framework:new_window("Experience Window", true)
            local window_pos_x = framework:get_resolution()[1] - 100
            local window_pos_y = framework:get_resolution()[2] - 18
            framework:add_label("Experience Window", "Experience Count", tostring(xp), 36, {200, 36}, nil)
            framework:set_window_position("Experience Window", {window_pos_x, window_pos_y})
        else
            if window_exists == true then
                framework:remove_window("Experience Window")
                window_exists = false
            end
        end
    end
end
