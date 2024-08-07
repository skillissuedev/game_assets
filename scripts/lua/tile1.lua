spawned_tiles = {}
tiles_props = {}
frame_counter = 0 -- used to run generation 10 times/sec instead of 60

function client_start(framework)
    framework:preload_model_asset("models/test_tile.gltf", "models/test_tile.gltf")
    new_master_instanced_model_object("tile1_master", "models/test_tile.gltf", "textures/comfy52.png", nil, nil)
end

function client_update()
end

function client_render()
end

function server_start(framework)
    framework:preload_model_asset("models/test_tile.gltf", "models/test_tile.gltf")
    local tiles = framework:get_global_system_value("WorldGeneratorTiles")
    table.insert(tiles, "tile1")
    framework:set_global_system_value("WorldGeneratorTiles", tiles)
end

function server_update(framework)
    if frame_counter == 6 then
        local positions_to_spawn = framework:get_global_system_value("WorldGenerator_tile1_Positions")
        local world_space_multiplier = framework:get_global_system_value("WorldGeneratorWorldSpaceMultiplier")[1]

        for key,spawned_position in pairs(spawned_tiles) do
            for _,position in pairs(positions_to_spawn) do
                if are_positions_equal(position, spawned_position) == true then
                    goto continue1
                end
            end
            table.remove(spawned_tiles, key)
            local tile_name = "tile1:" .. spawned_position[1] .. ";" .. spawned_position[2] .. ";" .. spawned_position[3]
            print("Deleting object '" .. tile_name .. "'")
            delete_object(tile_name)
            send_custom_message(true, "Delete", tile_name, "Everybody")

            ::continue1::
        end

        for _,position in pairs(positions_to_spawn) do
            for _,spawned_position in pairs(spawned_tiles) do
                if are_positions_equal(position, spawned_position) == true then
                    goto continue2
                end
            end
            table.insert(spawned_tiles, position)
            local tile_name = "tile1:" .. position[1] .. ";" .. position[2] .. ";" .. position[3]
            print("Spawning object '" .. tile_name .. "'")
            -- Spawn the tile!
            local tile_world_position = {position[1] * world_space_multiplier, position[2] * world_space_multiplier, position[3] * world_space_multiplier}
            spawn_tile_server(tile_name, tile_world_position, framework)
            send_sync_object_message(true, "Spawn", tile_name, tile_world_position, {0, 0, 0}, {1, 1, 1}, "Everybody")

            ::continue2::
        end

        frame_counter = 0
    end
    frame_counter = frame_counter + 1
end

function reg_message(message, framework)
    local message_id = message:message_id()
    if message_id == "Spawn" then
        local world_position = message:sync_object_pos_rot_scale()[1]
        local tile_name = message:sync_object_name()
        spawn_tile_client(tile_name, world_position)
    elseif message_id == "Delete" then
        local tile_name = message:custom_contents()
        delete_object(tile_name)
    end
end

function get_spawned_prop(pos)
    for k,v in pairs(spawned_tiles) do
        if k[1] == pos[1] then
            if k[2] == pos[2] then
                if k[3] == pos[3] then
                    return v
                end
            end
        end
    end
end

function are_positions_equal(position1, position2)
    if position1[1] == position2[1] then
        if position1[2] == position2[2] then
            if position1[3] == position2[3] then
                return true
            end
        end
    end

    return false
end



function spawn_tile_client(name, position)
    new_instanced_model_object(name, "tile1_master")
    set_object_position(name, position[1], position[2], position[3])
    local object = find_object(name)
    object:build_object_triangle_mesh_rigid_body("Fixed", "models/test_tile.gltf", "None", 0, 0, 0, 1, nil, nil)
    -- maybe build a body here?
    -- and spawn props
end

function spawn_tile_server(name, position, framework)
    new_empty_object(name)
    local object = find_object(name)
    object:set_position(position[1], position[2], position[3], false)
    object:build_object_triangle_mesh_rigid_body("Fixed", "models/test_tile.gltf", "None", 0, 0, 0, 1)

    local tree1_spawn_positions = framework:get_global_system_value("TileProps_tree1_SpawnPositions")
    table.insert(tree1_spawn_positions, {position[1], position[2] + 50, position[3]})
    framework:set_global_system_value("TileProps_tree1_SpawnPositions", tree1_spawn_positions)
end
