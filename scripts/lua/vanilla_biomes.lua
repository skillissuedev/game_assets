function client_start(framework)
    reg_biomes(framework)
end

function client_update(framework)
end

function client_render(framework)
end

function server_start(framework)
    reg_biomes(framework)
end

function server_update(framework)
end

function reg_message(message, framework)
end

function reg_biomes(framework)
    local biome_groups = framework:get_global_system_value("Biomes_Groups")
    if biome_groups == nil then
        biome_groups = {}
    end

    table.insert(biome_groups, {"0-Starter_Group", {"VanillaPlain"}, ""})
    table.insert(biome_groups, {"1-Basic_Group", {"VanillaForest", "VanillaDesert"}, "VanillaPlain"})
    table.insert(biome_groups, {"1-Basic_Group2", {"VanillaForest2", "VanillaTundra", "VanillaSnowy"}, "VanillaPlain"})
    --table.insert(biome_groups, {"VanillaForest", "Forest", {"1-Basic"}})
    framework:set_global_system_value("Biomes_Groups", biome_groups)
    framework:set_global_system_value("Biomes_VanillaPlain_Biome",
        {"VanillaPlainLand1", "VanillaPlainLand2", "VanillaPlainLand2", "VanillaPlainWild1", "VanillaPlainWild2", "VanillaPlainExp1"}
    )
    framework:set_global_system_value("Biomes_VanillaForest_Biome", {"VanillaForest1", "VanillaForest2", "VanillaForest2"})
    framework:set_global_system_value("Biomes_VanillaDesert_Biome", {"VanillaDesertExp1", "VanillaDesertLand1", "VanillaDesertLand2", "VanillaDesertLand3", "VanillaDesertWild1"})
    framework:set_global_system_value("Biomes_VanillaTundra_Biome", {})
    framework:set_global_system_value("Biomes_VanillaSnowy_Biome", {})
    framework:set_global_system_value("Biomes_VanillaForest2_Biome", {})
end
