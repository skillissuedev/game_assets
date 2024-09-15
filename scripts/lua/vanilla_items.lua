function client_start(framework)
    -- { 'id': {"name", "img", "desc"}, ... }
    local items_list = framework:get_global_system_value("InventoryItemsList")

    table.insert(items_list, "VanillaOldAxe")
    local vanilla_old_axe = { "Old Axe", "textures/default_texture.png", "It's just an old axe", { "Takable", "Weapon", "Axe" } }
    framework:set_global_system_value("InventoryItem_VanillaOldAxe", vanilla_old_axe)

    framework:set_global_system_value("InventoryItemsList", items_list)
end

function client_update(framework)
    collectgarbage()
    collectgarbage()
end

function client_render()
end

function server_start(framework)
    -- { 'id': {"name", "img", "desc"}, ... }
    local items_list = framework:get_global_system_value("InventoryItemsList")
    table.insert(items_list, "VanillaOldAxe")

    local vanilla_old_axe = { "Old Axe", "textures/default_texture.png", "It's just an old axe", { "Takable", "Weapon", "Axe" } }
    framework:set_global_system_value("InventoryItem_VanillaOldAxe", vanilla_old_axe)

    framework:set_global_system_value("InventoryItemsList", items_list)
end

function server_update(framework)
end

function reg_message(message, framework)
end
