function client_start(framework)
    framework:set_global_system_value("Biomes_BiomeName_Biome", {})
    framework:set_global_system_value("Biomes_Plrid_UnlockedBiomes", {})
    framework:set_global_system_value("Biomes_Plrid_NewUnlockedBiomes", {})
    framework:set_global_system_value("Biomes_Groups", {})
end

function client_update(framework)

end

function client_render(framework)
end

function server_start(framework)
    framework:set_global_system_value("Biomes_StarterBiomes", {"VanillaPlains"})
    framework:set_global_system_value("Biomes_BiomeName_Biome", {})
    framework:set_global_system_value("Biomes_Plrid_UnlockedBiomes", {})
    framework:set_global_system_value("Biomes_Plrid_NewUnlockedBiomes", {})
    framework:set_global_system_value("Biomes_Groups", {})
end

function server_update(framework)
    local players = framework:get_global_system_value("PlayerManagerIDs")
    for _,id in pairs(players) do
        local new_biomes = framework:get_global_system_value("Biomes_" .. id .. "_NewUnlockedBiomes")
        if new_biomes == nil then
            new_biomes = {}
        end

        local unlocked_biomes = framework:get_global_system_value("Biomes_" .. id .. "_UnlockedBiomes")
        if unlocked_biomes == nil then
            unlocked_biomes = {}
            for _,starter_biome in pairs(framework:get_global_system_value("Biomes_StarterBiomes")) do
                table.insert(unlocked_biomes, starter_biome)
            end
        end

        for _,new_biome_id in pairs(new_biomes) do
            print("Player (" .. id .. ") unlocked a new biome (" .. new_biome_id .. ")!")
            table.insert(unlocked_biomes, new_biome_id)
        end

        framework:set_global_system_value("Biomes_" .. id .. "_NewUnlockedBiomes", {})
        framework:set_global_system_value("Biomes_" .. id .. "_UnlockedBiomes", unlocked_biomes)
    end
end


function reg_message(message, framework)
end
