--[[ 
# Global values

- WorldGeneratorTiles - list of all tiles'(and usually systems' too!) names. 
    Example: WorldGeneratorTiles = {"tile1", "tile2", "someothertile"}

- WorldGeneratorWorldSpaceMultiplier - how much world space units are in one grid space unit?
    Default value: 300 

- WorldGeneratorSeed - the seed number used by the world generator. Loaded from the save file.

- WorldGenerator_{tilename}_Positions - a bunch of vec3 values(in grid space!) for different tiles.
    Used to tell other systems that they need to spawn those tiles.
    Example: WorldGenerator_tile1_Positions = {{1, 0, 1}, {0, 0, 0}, {2, 0, 0}, ...}

--]]



--[[ 
# Basic usage example

- use tile editor(https://github.com/skillissuedev/tile-editor) to generate useful functions for the system
- add a tile name in server_start function(e. g. tile1) by changing WorldGeneratorTiles
- in server_update check WorldGenerator_tile1_Positions
- get the world space multiplier(WorldGeneratorWorldSpaceMultiplier)
- convert received positions from the grid space to world space by multiplying them by world space multiplier
- spawn all of tiles that needed to be spawned and destroy those that are no longer needed

--]]


tiles = {} -- pos: system
world_space_multiplier = 300
frame_counter = 0 -- used to run generation 10 times/sec instead of 60

function client_start()
end

function client_update()

end

function client_render()

end

function server_start()
    set_global_system_value("WorldGeneratorTiles", {})
    set_global_system_value("WorldGeneratorWorldSpaceMultiplier", {300})
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
    if frame_counter == 6 then
        local updated_multiplier = get_global_system_value("WorldGeneratorWorldSpaceMultiplier")
        if updated_multiplier[1] ~= nil then
            world_space_multiplier = updated_multiplier[1]
        end

        local tile_systems = get_global_system_value("WorldGeneratorTiles")
        for _,tile_system in pairs(tile_systems) do
            set_global_system_value("WorldGenerator_" .. tile_system .. "_Positions", {})
        end

        tiles_to_load = {}
        set_global_system_value("PlayerMangerCurrentNearbyPosition", {{0, 0, 0}})
        local player_positions = get_global_system_value("PlayerManagerPositions")
        for _,position in pairs(player_positions) do
            local grid_x = to_grid_space(position[1])
            local grid_z = to_grid_space(position[3])

            local grid_left_x = grid_x - 1
            local grid_left_x_2 = grid_x - 2
            local grid_right_x = grid_x + 1
            local grid_right_x_2 = grid_x + 2

            local grid_backward_z = grid_z - 1
            local grid_backward_z_2 = grid_z - 2
            local grid_forward_z = grid_z + 1
            local grid_forward_z_2 = grid_z + 2

            table.insert(tiles_to_load, {grid_x, 0, grid_z})
            table.insert(tiles_to_load, {grid_left_x, 0, grid_z})
            table.insert(tiles_to_load, {grid_right_x, 0, grid_z})
            table.insert(tiles_to_load, {grid_x, 0, grid_forward_z})
            table.insert(tiles_to_load, {grid_x, 0, grid_backward_z})
            table.insert(tiles_to_load, {grid_left_x, 0, grid_forward_z})
            table.insert(tiles_to_load, {grid_left_x, 0, grid_backward_z})
            table.insert(tiles_to_load, {grid_right_x, 0, grid_forward_z})
            table.insert(tiles_to_load, {grid_right_x, 0, grid_backward_z})
            table.insert(tiles_to_load, {grid_left_x_2, 0, grid_forward_z_2})
            table.insert(tiles_to_load, {grid_left_x, 0, grid_forward_z_2})
            table.insert(tiles_to_load, {grid_x, 0, grid_forward_z_2})
            table.insert(tiles_to_load, {grid_right_x, 0, grid_forward_z_2})
            table.insert(tiles_to_load, {grid_right_x_2, 0, grid_forward_z_2})
            table.insert(tiles_to_load, {grid_left_x_2, 0, grid_backward_z_2})
            table.insert(tiles_to_load, {grid_left_x, 0, grid_backward_z_2})
            table.insert(tiles_to_load, {grid_x, 0, grid_backward_z_2})
            table.insert(tiles_to_load, {grid_right_x, 0, grid_backward_z_2})
            table.insert(tiles_to_load, {grid_right_x_2, 0, grid_backward_z_2})
            table.insert(tiles_to_load, {grid_left_x_2, 0, grid_forward_z})
            table.insert(tiles_to_load, {grid_left_x_2, 0, grid_z})
            table.insert(tiles_to_load, {grid_left_x_2, 0, grid_backward_z})
            table.insert(tiles_to_load, {grid_right_x_2, 0, grid_forward_z})
            table.insert(tiles_to_load, {grid_right_x_2, 0, grid_z})
            table.insert(tiles_to_load, {grid_right_x_2, 0, grid_backward_z})
        end

        systems_tile_positions = {} -- system_name: pos1, pos2, ...
        for _,tile_pos in pairs(tiles_to_load) do
            local tile_system = get_tile(tile_pos)
            if tile_system == nil then
                local tile_seed = tonumber(tostring(seed) .. math.abs(tile_pos[1]) .. math.abs(tile_pos[3]))
                --print(tostring(seed) .. math.abs(tile_pos[1]) .. math.abs(tile_pos[3]))

                if tile_pos[1] < 0 or tile_pos[3] < 0 then
                    tile_seed = -tile_seed
                else
                    tile_seed = tile_seed * 2
                end

                math.randomseed(tile_seed)
                local tile_system_id = math.random(1, #tile_systems)
                local system = tile_systems[tile_system_id]
                tiles[tile_pos] = system
            else
                if systems_tile_positions[tile_system] == nil then
                    systems_tile_positions[tile_system] = {}
                end

                table.insert(systems_tile_positions[tile_system], tile_pos)
            end
        end

        for system,positions in pairs(systems_tile_positions) do
            set_global_system_value("WorldGenerator_" .. system .. "_Positions", positions)
        end

        frame_counter = 0
    end
    frame_counter = frame_counter + 1
end

function to_world_space(val)
    return val * world_space_multiplier
end

function to_grid_space(val)
    return math.floor((val / world_space_multiplier) + 0.5)
    --return tonumber(string.format("%.0f", val))
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
