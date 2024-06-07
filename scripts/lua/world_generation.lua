tiles = {} -- pos: system

function client_start()
end

function client_update()

end

function client_render()

end

function server_start()
    set_global_system_value("WorldGeneratorTiles", {})
    seed = get_global_system_value("WorldGeneratorSeed")
    if seed == nil then
        print('seed is nil')
        seed = 0
    else
        print('seed is ' .. seed[1])
        seed = seed[1]
    end
end

function server_update()
    tiles_to_load = {}
    set_global_system_value("PlayerMangerCurrentNearbyPosition", {{0, 0, 0}})
    local player_positions = get_global_system_value("PlayerManagerPositions")
    for _,position in pairs(player_positions) do
        --print("id: " .. id .. "'s position: " .. position[1] .. "; " .. position[2] .. "; " .. position[3])
        local grid_x = to_grid_space(position[1])
        local grid_z = to_grid_space(position[3])

        local grid_left_x = grid_x - 1
        local grid_right_x = grid_x + 1

        local grid_backward_z = grid_z - 1
        local grid_forward_z = grid_z + 1

        table.insert(tiles_to_load, {grid_x, 0, grid_z})
        table.insert(tiles_to_load, {grid_left_x, 0, grid_z})
        table.insert(tiles_to_load, {grid_right_x, 0, grid_z})
        table.insert(tiles_to_load, {grid_x, 0, grid_forward_z})
        table.insert(tiles_to_load, {grid_x, 0, grid_backward_z})
        table.insert(tiles_to_load, {grid_left_x, 0, grid_forward_z})
        table.insert(tiles_to_load, {grid_left_x, 0, grid_backward_z})
        table.insert(tiles_to_load, {grid_right_x, 0, grid_forward_z})
        table.insert(tiles_to_load, {grid_right_x, 0, grid_backward_z})
    end

    --print("\nloaded chunks:")
    --for i,chunk in pairs(tiles_to_load) do
        --print("chunk " .. i .. "'s pos: " .. chunk[1] .. "; " .. chunk[2])
    --end
    --print("\n\n")
    local tile_systems = get_global_system_value("WorldGeneratorTiles")
    for k,v in pairs(tiles) do
        print("tiles[" .. k[1] .. "; " .. k[2] .. "; " .. k[3] .. "] = " .. v)
    end

    systems_tile_positions = {} -- system_name: pos1, pos2, ...
    for _,tile_pos in pairs(tiles_to_load) do
        print("tile_pos[1] = " .. tile_pos[1] .. "; tile_pos[2] = " .. tile_pos[2] .. "; tile_pos[3] = " .. tile_pos[3])
        print(tiles[tile_pos])
        local tile_system = get_tile(tile_pos)
        if tile_system == nil then
            local tile_seed = math.randomseed(seed + tile_pos[1] + tile_pos[3])
            print("new tile seed = " .. seed + tile_pos[1] + tile_pos[3])
            local tile_system_id = math.random(1, #tile_systems)
            local system = tile_systems[tile_system_id]
            print("new tile system = " .. system)
            tiles[tile_pos] = system
            print("tiles[tile_pos] = " .. tiles[tile_pos])
            -- seed - done
            -- choose a random system from a list - done
            -- add it to the tiles list
            -- add it to systems_tile_positions list
        else
            if systems_tile_positions[tile_system] == nil then
                systems_tile_positions[tile_system] = {}
            end

            table.insert(systems_tile_positions[tile_system], tile_pos)
        end
    end

    for system,positions in pairs(systems_tile_positions) do
        set_global_system_value("WorldGenerator_" .. system .. "_Positions", positions)
        print("WorldGenerator_" .. system .. "_Positions", positions)
        for k,pos in pairs(positions) do
            print("position #" .. k .. " = " .. pos[1] .. "; " .. pos[2] .. "; " .. pos[3])
        end
    end
    --set_global_system_value("WorldGeneratorTilesToLoad", tiles_to_load)
end

function to_world_space(val)
    return val * 100
end

function to_grid_space(val)
    return math.floor(val / 100)
end

function get_tile(pos)
    for k,v in pairs(tiles) do
        if k[1] == pos[1] then
            if k[2] == pos[2] then
                if k[3] == pos[3] then
                    return v
                end
            end
        end
    end
end
