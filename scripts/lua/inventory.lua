-- client
inventory = false
inv_ids = {}

player_inventories = {}

function client_start(framework)
    --   items   --
    -- { 'id': {"name", "img", "desc"}, ... }
    framework:set_global_system_value("InventoryItemsList", {})
    -- { 'id': {"tag1", "pickaxe", "tag3"}, ... }
    framework:set_global_system_value("InventoryItemsTags", {})


    framework:new_window("Inventory")
    show_inventory(framework)
    -- show_inventory called => inventory = true
    inventory = true
end

function client_update(framework)
    -- keep the inventory window centered
    local inv_window_pos_x = framework:get_resolution()[1] / 2 - 500
    local inv_window_pos_y = framework:get_resolution()[2] / 2 - 250

    framework:set_window_position("Inventory", {inv_window_pos_x, inv_window_pos_y})
end

function client_render()
end

function server_start(framework)
    --   items   --
    -- { 'id': {"name", "img", "desc"}, ... }
    framework:set_global_system_value("InventoryItemsList", {})
    -- { 'id': {"tag1", "pickaxe", "tag3"}, ... }
    framework:set_global_system_value("InventoryItemsTags", {})

    --   players' items   --
    -- { 'plr_id': {"itmid5", "itmid2"}, ... }
    framework:set_global_system_value("InventoryPlayerItems", {})
    -- { 'plr_id': {"itmid1", "itmid2"}, ... }
    framework:set_global_system_value("InventoryPlayerHotbars", {})
    -- { 'plr_id': {2}, "50": {1} }
    framework:set_global_system_value("InventoryPlayerCurrentHotbarSlot", {})
    -- +InventoryPlayerCurrentItem
end

function server_update(framework)
    local player_current_item = {}
    local ids = framework:get_global_system_value("PlayerManagerIDs")
    for _, id in pairs(ids) do
        local items = framework:get_global_system_value("InventoryPlayerItems_" .. id)
        send_custom_message(true, "InventoryItems", items, "OneClient", id)
        -- TODO set player current item here
    end
    framework:set_global_system_value("InventoryPlayerCurrentItem", player_current_item)
end

function reg_message(message, framework)
    -- client
    if message:message_id() == "InventoryItems" then
        inv_ids = message:custom_contents()
        framework:remove_widget("Inventory", "Inventory")
        show_inventory(framework)
    end
end

function show_inventory(framework)
    framework:add_horizontal("Inventory", "Inventory", {1000, 500}, nil)
    framework:add_vertical("Inventory", "Items List", {500, 500}, "Inventory")
    for index,item_id in pairs(inv_ids) do
        local list = framework:get_global_system_value("InventoryItem_" .. item_id)
        local name = list[1]
        framework:add_button("Inventory", "Item name#" .. index, name, {500, 50}, "Items List")
    end
    framework:add_label("Inventory", "Current Item", "*Current item info*", {500, 500}, "Inventory")
    framework:show_title_bar("Inventory", false)
end
