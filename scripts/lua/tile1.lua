spawned_tiles = {}

function client_start()
end

function client_update()
end

function client_render()
end

function server_start()
    local tiles = get_global_system_value("WorldGeneratorTiles")
    table.insert(tiles, "tile1")
    set_global_system_value("WorldGeneratorTiles", tiles)
end

function server_update()
    local positions = get_global_system_value("WorldGenerator_tile1_Positions")
end

function reg_message(message)
end

function get_spawned_tile(pos)
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
