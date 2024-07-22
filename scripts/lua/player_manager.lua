players = {}

function client_start(framework)
    new_character_controller(
        "a",
        "Cuboid",
        nil,
        nil,
        1.0,
        1.0,
        1.0,
        framework
    )
    new_empty_object("test")
    framework:preload_model_asset("test", "models/mushroom.gltf")
    new_model_object("model", "test", nil, nil, nil)

end

function client_update(framework)
    local player_position = framework:get_global_system_value("PlayerPosition")
    send_sync_object_message(false, "SyncPlayer", "", player_position[1], {0, 0, 0}, {0, 0, 0})
end

function client_render()
end

function server_start(framework)
end

function server_update(framework)
  for _, ev in pairs(get_network_events()) do
        if ev["type"] == "ClientConnected" then
            print("New player connected! ID: " .. ev["id"])
            print("Adding it to the 'players' table!")
            players[ev["id"]] = {0.0, 20.0, 0.0}
        elseif ev["type"] == "ClientDisconnected" then
            print("The player has disconnected! ID: " .. ev["id"])
            print("Removing it from the 'players' table!")
            players[ev["id"]] = nil
        end
    end
    local current_idx = 0
    local system_global_positions = {}

    for _,plr in pairs(players) do
        current_idx = current_idx + 1
        system_global_positions[current_idx] = plr
    end

    framework:set_global_system_value("PlayerManagerPositions", system_global_positions)
end

function get_value(value_name)
end

function reg_message(message)
    local message_id = message:message_id()
    if message_id == "SyncPlayer" then
        local position_rotation_scale = message:sync_object_pos_rot_scale()
        local position = position_rotation_scale[1]
        local sender = message:message_sender()
        --print("msg from " .. sender .. ": x = " .. position[1] .. "; y = " .. position[2] .. "; z = " .. position[3])
        players[sender] = position
    end
end
--[[
function client_start()

end

function client_update()
end

function client_render()

end

function server_start()
    --register_save_value("PlayerManagerPositions")
end
]]--
--[[
function server_update()
end

function get_value(value_name)
    if value_name == "is_there_a_player_nearby" then
        local position = get_global_system_value("PlayerMangerCurrentNearbyPosition")[1]
        local max_distance = get_global_system_value("PlayerMangerCurrentNearbyDistance")[1]
        print('PlayerMangerPosition = ' .. position[1])
        print('PlayerMangerDistance = ' .. max_distance)
        for _, plr in pairs(players) do
            local distance = distance(plr[1], plr[2], plr[3], position[1], position[2], position[3])
            print('distance = ' .. distance)
            if distance <= max_distance then
                return true
            end
        end
        return false
    end
end

function reg_message(message)
    local message_id = message:message_id()
    if message_id == "SyncPlayer" then
        local position_rotation_scale = message:sync_object_pos_rot_scale()
        local position = position_rotation_scale[1]
        local sender = message:message_sender()
        --print("msg from " .. sender .. ": x = " .. position[1] .. "; y = " .. position[2] .. "; z = " .. position[3])
        players[sender] = position
    end
end

function distance(x1, y1, z1, x2, y2, z2)
    local dx = x1 - x2
    local dy = y1 - y2
    local dz = z1 - z2
    return math.sqrt (dx * dx + dy * dy + dz * dz)
end
]]--
