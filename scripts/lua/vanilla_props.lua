--[[
# System values:
- TileProps_tree1_SpawnPositions - add a position vector to this global value to spawn a new tree1 prop
- TileProps_tree1_DeletePositions - add a position vector to this global value to remove an existing tree1 prop
]]--
spawned_props = {}
tick_counter = 0 -- used to run generation 10 times/sec instead of 60
set_object_positions = {}

function client_start(framework)
    framework:preload_model_asset("models/tree1.gltf", "models/tree1.gltf")
    framework:preload_model_asset("models/rock1.gltf", "models/rock1.gltf")
    framework:preload_texture_asset("textures/comfy52.png", "textures/comfy52.png")
    new_master_instanced_model_object("rock1_master", "models/rock1.gltf", "textures/comfy52.png", nil, nil)
end

function client_update()
end

function client_render()
end

function server_start(framework)
    framework:set_global_system_value("TileProps_tree1_SpawnPositions", {})
    framework:set_global_system_value("TileProps_tree1_DeletePositions", {})
    framework:set_global_system_value("TileProps_rock1_SpawnPositions", {})
    framework:set_global_system_value("TileProps_rock1_DeletePositions", {})
end

function server_update(framework)
    if tick_counter >= 6 then
        local tree1_spawn_positions = framework:get_global_system_value("TileProps_tree1_SpawnPositions")
        for _,position in pairs(tree1_spawn_positions) do
            print("Spawning new tree1: x = " .. position[1] .. "; y = " .. position[2] .. "; z = " .. position[3])
            spawn_tree1(position)
        end
        local tree1_delete_names = framework:get_global_system_value("TileProps_tree1_DeletePositions")
        for _,position in pairs(tree1_delete_names) do
            print("Deleting tree1: x = " .. position[1] .. "; y = " .. position[2] .. "; z = " .. position[3])
            delete_prop("tree1", position)
        end

        local rock1_spawn_positions = framework:get_global_system_value("TileProps_tree1_SpawnPositions")
        for _,position in pairs(rock1_spawn_positions) do
            print("Spawning new rock1: x = " .. position[1] .. "; y = " .. position[2] .. "; z = " .. position[3])
            spawn_rock1(position)
        end
        local rock1_delete_names = framework:get_global_system_value("TileProps_rock1_DeletePositions")
        for _,position in pairs(rock1_delete_names) do
            print("Deleting rock1: x = " .. position[1] .. "; y = " .. position[2] .. "; z = " .. position[3])
            delete_prop("rock1", position)
        end


        framework:set_global_system_value("TileProps_tree1_SpawnPositions", {})
        framework:set_global_system_value("TileProps_tree1_DeletePositions", {})

        framework:set_global_system_value("TileProps_rock1_SpawnPositions", {})
        framework:set_global_system_value("TileProps_rock1_DeletePositions", {})

        tick_counter = 0
    end
    tick_counter = tick_counter + 1
end

function reg_message(message, framework)
    local message_id = message:message_id()
    if message_id == "SpawnTree1" then
        local position = message:sync_object_pos_rot_scale()[1]
        local object_name = message:sync_object_name()
        new_instanced_model_object(object_name, "tree1_master")
        set_object_position(object_name, position[1], position[2], position[3])
    elseif message_id == "SpawnRock1" then
        local position = message:sync_object_pos_rot_scale()[1]
        local object_name = message:sync_object_name()
        new_instanced_model_object(object_name, "rock1_master")
        set_object_position(object_name, position[1], position[2], position[3])
    elseif message_id == "DeleteTree1" then
        local object_name = message:custom_contents()[1]
        delete_object(object_name)
    end
end

-- server-side
function spawn_tree1(position)
    local name = "tree1:" .. position[1] .. ";" .. position[2] .. ";" .. position[3]
    new_empty_object(name)
    local object = find_object(name)
    object:set_position(position[1], position[2], position[3], false)
    send_sync_object_message(true, "SpawnTree1", name, position, {0, 0, 0}, {1, 1, 1}, "Everybody")
    --object:build_object_triangle_mesh_rigid_body("Fixed", "models/test_tile.gltf", "None", 0, 0, 0, 1)
end

function spawn_rock1(position)
    local name = "rock1:" .. position[1] .. ";" .. position[2] .. ";" .. position[3]
    new_empty_object(name)
    local object = find_object(name)
    object:set_position(position[1], position[2], position[3], false)
    send_sync_object_message(true, "SpawnRock1", name, position, {0, 0, 0}, {1, 1, 1}, "Everybody")
    --object:build_object_triangle_mesh_rigid_body("Fixed", "models/test_tile.gltf", "None", 0, 0, 0, 1)
end

function delete_prop(name, position)
    local object_name = name .. ":" .. position[1] .. ";" .. position[2] .. ";" .. position[3]
    delete_object(object_name)
    send_custom_message(true, "DeleteTree1", object_name, "Everybody")
end
