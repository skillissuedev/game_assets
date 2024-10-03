-- server variables
player_positions = {}
connected_players_ids = {}
-- client variables
current_player = nil
current_player_ray = nil
player_model_objects_positions = {}
player_model_objects = {}
falling_movement = 0
player_jump_movement = 0
player_jump_movement_left = 0
is_jumping_up = nil

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
        0.29,
        0.9,
        0.172,
        framework
    )
    new_ray(
        "player_ray",
        0,
        -1,
        0
    )
    set_object_position("player", 0, 20, 0, true)
    current_player = find_object("player")
    current_player_ray = find_object("player_ray")

    --new_model_object("a", "models/character_no_head.gltf", "textures/white.png", nil, nil)
end

function client_update(framework)
    -- syncing other players' character models
    --[[for id, position in pairs(player_model_objects_positions) do
        if player_model_objects[id] == nil then
            print("id: " .. id .. "; pos = " .. position[1] .. ", " .. position[2] .. ", " .. position[3])
            local object_name = "Player#" .. id
            new_model_object(object_name, "models/character_no_head.gltf", "textures/white.png", nil, nil)
            player_model_objects[id] = find_object(object_name)
            print(player_model_objects[id])
        end
        --print(player_model_objects[id])
        player_model_objects[id]:set_position(-position[1], position[2], position[3]) -- -x is just for testing purposes xd
    end]]--

    local position = current_player:get_position()
    current_player_ray:set_position(position[3], position[2], position[1]) -- -0.45 because the ray should be placed at the bottom of the controller
    --print(current_player_ray:is_intersecting())
    -- moving character & camera
    local delta_time = framework:delta_time()

    local camera_rotation = framework:get_camera_rotation()
    local delta = framework:mouse_delta()
    framework:set_camera_rotation(camera_rotation[1] + delta[2] * 50.0 * delta_time, camera_rotation[2] + delta[1] * 50.0 * delta_time, camera_rotation[3]);

    if framework:get_camera_rotation()[1] > 89.0 then
        framework:set_camera_rotation(89.0, camera_rotation[2], camera_rotation[3])
    elseif framework:get_camera_rotation()[1] < -89.0 then
        framework:set_camera_rotation(-89.0, camera_rotation[2], camera_rotation[3])
    end

    current_player:set_rotation(0, camera_rotation[2], 0)

    local movement_x = 0
    local movement_y = 0
    local movement_z = 0
    local speed = 15
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
        if player_jump_movement_left <= 0 then
            player_jump_movement_left = 100
            is_jumping_up = true
        end
    end

    if player_jump_movement_left <= 0 and current_player_ray:is_intersecting() == false then
        is_jumping_up = false
        falling_movement = -2.0
    elseif current_player_ray:is_intersecting() then
        --print("not falling")
        falling_movement = 0
    end

    if is_jumping_up == true then
        movement_y = player_jump_movement + 2.0
        player_jump_movement = movement_y
        player_jump_movement_left = player_jump_movement_left - movement_y
        print("JUMPING UP")
        print(player_jump_movement)
    end

    if falling_movement ~= 0 then
        movement_y = falling_movement - 2.0
        falling_movement = movement_y
        --print("FALLING")
        --print(falling_movement)
    end
    current_player:move_controller(movement_x * delta_time, movement_y * delta_time, movement_z * delta_time)

    framework:set_camera_position(position[1], position[2], position[3])

    -- sending a message to the server
    framework:set_global_system_value("PlayerPosition", position)
    framework:set_global_system_value("PlayerCameraRotation", framework:get_camera_rotation())
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

            framework:set_global_system_value("InventoryPlayerItems_" .. ev["id"], {})

            -- test items xd
            local plr_items_list = { { "VanillaOldAxe", 20 }, { "VanillaOldAxe", 1 }, { "VanillaOldAxe", 52 }, { "VanillaWood", 99 } }
            framework:set_global_system_value("InventoryAddPlayerItems_" .. ev["id"], plr_items_list)
            -- end of test

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
