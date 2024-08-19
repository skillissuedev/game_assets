-- client
is_showing_inventory = false
inventory_items = {}
selected_item_idx = 0

player_inventories = {}

function client_start(framework)
    framework:new_bind_keyboard("Inventory", { "Escape", "Tab" })
    --   items   --
    -- { 'id': {"name", "img", "desc"}, ... }
    framework:set_global_system_value("InventoryItemsList", {})
    -- { 'id': {"tag1", "pickaxe", "tag3"}, ... }
    framework:set_global_system_value("InventoryItemsTags", {})


    --show_inventory(framework)
    -- show_inventory called => inventory = true
    --show_inventory = true
end

function client_update(framework)
    if framework:is_bind_pressed("Inventory") then
        if is_showing_inventory then
            is_showing_inventory = false
            framework:remove_window("Inventory")
        else
            is_showing_inventory = true
        end
    end

    if is_showing_inventory then
        -- keep the inventory window centered
        local inv_window_pos_x = framework:get_resolution()[1] / 2 - 500
        local inv_window_pos_y = framework:get_resolution()[2] / 2 - 250
        framework:set_window_position("Inventory", {inv_window_pos_x, inv_window_pos_y})

        -- if any item in the list was clicked, set is as selected
        for idx, _ in pairs(inventory_items) do
            if framework:is_widget_left_clicked("Inventory", "Item name#" .. idx) then
                selected_item_idx = idx
                framework:remove_window("Inventory")
                show_inventory(framework)
                break
            end
        end
    end
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
    -- { 'plr_id': { {"itmid5", 5}, {"itmid2", 420} }, ... }
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
        local items_to_add = framework:get_global_system_value("InventoryAddPlayerItems_" .. id)
        local items = framework:get_global_system_value("InventoryPlayerItems_" .. id)

        if items_to_add ~= nil then
            for _, add_item in pairs(items_to_add) do
                local add_item_id = add_item[1]
                local add_item_count = add_item[2]

                local stacked = false
                for _, inventory_item in pairs(items) do
                    local inventory_item_id = inventory_item[1]

                    if inventory_item_id == add_item_id then
                        inventory_item[2] = inventory_item[2] + add_item_count
                        stacked = true
                        break
                    end
                end

                if stacked == false then
                    table.insert(items, {add_item_id, add_item_count})
                end
            end
        end
        framework:set_global_system_value("InventoryAddPlayerItems_" .. id, {})

        framework:set_global_system_value("InventoryPlayerItems_" .. id, items)

        send_custom_message(true, "InventoryItems", items, "OneClient", id)
        -- TODO set player current item here
    end
    framework:set_global_system_value("InventoryPlayerCurrentItem", player_current_item)
end

function reg_message(message, framework)
    -- client
    if message:message_id() == "InventoryItems" then
        inventory_items = message:custom_contents()
        if is_showing_inventory then
            framework:remove_window("Inventory")
            show_inventory(framework)
        end
    end
end

function show_inventory(framework)
    framework:new_window("Inventory")
    framework:show_title_bar("Inventory", false)

    framework:add_horizontal("Inventory", "Inventory", {1000, 500}, nil)
    framework:add_vertical("Inventory", "Items List", {500, 500}, "Inventory")

    for index,value in pairs(inventory_items) do
        local id = value[1]
        local count = value[2]

        local item = framework:get_global_system_value("InventoryItem_" .. id)
        local name = item[1]

        local horizontal_id = "Item#" .. index
        framework:add_horizontal("Inventory", "Item#" .. index, {500, 50}, "Items List")
        framework:add_button("Inventory", "Item name#" .. index, name, {450, 50}, horizontal_id)
        framework:add_label("Inventory", "Item count#" .. index, tostring(count), 20, {50, 50}, horizontal_id)
    end

    framework:add_vertical("Inventory", "Selected Item", {500, 500}, "Inventory")

    if inventory_items[selected_item_idx] ~= nil then
        local inventory_item = inventory_items[selected_item_idx]
        local id = inventory_item[1]

        local item = framework:get_global_system_value("InventoryItem_" .. id)
        local name = item[1]
        local image = item[2]
        local description = item[3]

        framework:add_label("Inventory", "Selected Item Image", image, 14, {500, 300}, "Selected Item")
        framework:add_label("Inventory", "Selected Item Title", name, 20, {500, 50}, "Selected Item")
        framework:add_label("Inventory", "Selected Item Description", description, 14, {500, 150}, "Selected Item")
    else
        framework:add_label("Inventory", "Selected Item Tip", "Select an item from the list", 24, {500, 500}, "Selected Item")
    end
end
