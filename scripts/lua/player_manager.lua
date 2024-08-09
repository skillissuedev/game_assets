-- server variables
player_positions = {}
connected_players_ids = {}
-- client variables
current_player = nil
player_model_objects_positions = {}
player_model_objects = {}

function client_start(framework)
    framework:preload_model_asset("models/character_no_head.gltf", "models/character_no_head.gltf")
    framework:new_bind_keyboard("forward", {"KeyW"})
    framework:new_bind_keyboard("left", {"KeyA"})
    framework:new_bind_keyboard("backward", {"KeyS"})
    framework:new_bind_keyboard("right", {"KeyD"})
    framework:new_bind_keyboard("jump", {"Space"})
    new_character_controller(
        "player",
        "Cuboid",
        nil,
        nil,
        0.597,
        1.8,
        0.344,
        framework
    )
    set_object_position("player", 0, 20, 0, true)
    current_player = find_object("player")
end

function client_update(framework)
    -- syncing other players' character models
    for id, position in pairs(player_model_objects_positions) do
        if player_model_objects[id] == nil then
            local object_name = "Player#" .. id
            new_model_object(object_name, "models/character_no_head.gltf", "textures/white.png", nil, nil)
            player_model_objects[id] = find_object(object_name)
        end
        player_model_objects[id]:set_position(-position[1], position[2], position[3]) -- -x is just for testing purposes xd
    end

    -- moving character & camera
    local delta_time = framework:delta_time()

    local camera_rotation = framework:get_camera_rotation()
    local delta = framework:mouse_delta()
    framework:set_camera_rotation(camera_rotation[1] - delta[2] * 50.0 * delta_time, camera_rotation[2] + delta[1] * 50.0 * delta_time, camera_rotation[3]);

    if framework:get_camera_rotation()[1] > 89.0 then
        framework:set_camera_rotation(89.0, camera_rotation[2], camera_rotation[3])
    elseif framework:get_camera_rotation()[1] < -89.0 then
        framework:set_camera_rotation(-89.0, camera_rotation[2], camera_rotation[3])
    end

    current_player:set_rotation(0, camera_rotation[2], camera_rotation[3])

    local movement_x = 0
    local movement_y = -9.8
    local movement_z = 0
    local speed = 35
    local diagonal_slowdown = 1.414

    if framework:is_bind_down("forward") then
        movement_z = movement_z + speed
    end

    if framework:is_bind_down("backward") then
        movement_z = movement_z - speed
    end

    if framework:is_bind_down("left") then
        movement_x = movement_x - speed
        if movement_z ~= 0 then
            movement_x = movement_x / diagonal_slowdown
            movement_z = movement_z / diagonal_slowdown
        end
    end

    if framework:is_bind_down("right") then
        movement_x = movement_x + speed
        if movement_z ~= 0 then
            movement_x = movement_x / diagonal_slowdown
            movement_z = movement_z / diagonal_slowdown
        end
    end

    if framework:is_bind_pressed("jump") then
        movement_y = movement_y + 10000
    end

    current_player:move_controller(movement_x * delta_time, movement_y * delta_time, movement_z * delta_time)

    local position = current_player:get_position()
    framework:set_camera_position(position[1], position[2], position[3])

    -- sending a message to the server
    framework:set_global_system_value("PlayerPosition", position)
    send_sync_object_message(false, "SyncPlayer", "", position, {0, 0, 0}, {0, 0, 0})
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
            player_positions[ev["id"]] = {0.0, 20.0, 0.0}
            table.insert(connected_players_ids, ev["id"])
        elseif ev["type"] == "ClientDisconnected" then
            print("The player has disconnected! ID: " .. ev["id"])
            print("Removing it from the 'players' table!")
            player_positions[ev["id"]] = nil
        end
    end
    local current_idx = 0
    local system_global_positions = {}

    for _,plr in pairs(player_positions) do
        current_idx = current_idx + 1
        system_global_positions[current_idx] = plr
    end

    for id, position in pairs(system_global_positions) do
        send_sync_object_message(false, "SyncPlayerModel", tostring(id), position, {0, 0, 0}, {0, 0, 0}, "Everybody")
    end

    framework:set_global_system_value("PlayerManagerPositions", system_global_positions)
    framework:set_global_system_value("PlayerManagerIDs", connected_players_ids)
end

function get_value(value_name)
end

function reg_message(message, framework)
    local message_id = message:message_id()
    if message_id == "SyncPlayer" then
        local position_rotation_scale = message:sync_object_pos_rot_scale()
        local position = position_rotation_scale[1]
        local sender = message:message_sender()
        --print("msg from " .. sender .. ": x = " .. position[1] .. "; y = " .. position[2] .. "; z = " .. position[3])
        player_positions[sender] = position
    elseif message_id == "SyncPlayerModel" then
        local position_rotation_scale = message:sync_object_pos_rot_scale()
        local position = position_rotation_scale[1]
        local id = message:sync_object_name()
        player_model_objects_positions[id] = position
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
