-- client
is_showing_inventory = false
inventory_items = {}
hotbar_items = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
current_hotbar_slot = 1
selected_item_idx = 0
current_cursor_item = nil

function client_start(framework)
    framework:new_bind_keyboard("Inventory", { "Escape", "Tab" })

    --   items   --
    -- { 'id': {"name", "img", "desc", {"tag1", "tag2", ...}}, ... }
    framework:set_global_system_value("InventoryItemsList", {})
    framework:set_global_system_value("InventoryCurrentHotbarSlot", {0})

    -- Hotbar UI --
    framework:new_window("Hotbar", true)
    framework:add_horizontal("Hotbar", "Slots", {500, 50}, nil)

    for i = 1, 10 do
        framework:add_image("Hotbar", "Slot " .. i, "textures/ui/hotbar_slot_" .. i .. ".png", {50, 50}, "Slots")
        framework:set_widget_spacing("Hotbar", "Slot " .. i, 2)

        framework:new_window("Hotbar Slot " .. i, true)
        framework:add_image("Hotbar Slot " .. i, "Icon", "textures/transparent.png", {30, 30}, nil)
        framework:new_bind_keyboard("HotbarSlot" .. i, { "Digit" .. i })
    end
    framework:new_bind_keyboard("HotbarSlot10", { "Digit0" })
end

function client_update(framework)
    for slot_idx = 1, 10 do
        if framework:is_bind_pressed("HotbarSlot" .. slot_idx) then
            send_custom_message(true, "SetHotbarSlot", {slot_idx})
        end
    end

    if framework:is_bind_pressed("Inventory") then
        if is_showing_inventory then
            is_showing_inventory = false
            framework:remove_window("Inventory")
        else
            is_showing_inventory = true
        end
    end

    local hotbar_window_pos_x = framework:get_resolution()[1] / 2 - 250
    local hotbar_window_pos_y = framework:get_resolution()[2] - 52
    framework:set_window_position("Hotbar", {hotbar_window_pos_x, hotbar_window_pos_y})

    for i = 1, 10 do
        local slot_window_position_x = hotbar_window_pos_x + (i - 1) * 52 + 10
        framework:set_window_position("Hotbar Slot " .. i, {slot_window_position_x, hotbar_window_pos_y + 10})
        framework:set_window_on_top("Hotbar Slot " .. i, true)
    end

    if is_showing_inventory then
        -- keep the inventory window centered
        local inv_window_pos_x = framework:get_resolution()[1] / 2 - 500
        local inv_window_pos_y = framework:get_resolution()[2] / 2 - 250
        framework:set_window_position("Inventory", {inv_window_pos_x, inv_window_pos_y})
    end

    local current_item_inventory = inventory_items[hotbar_items[current_hotbar_slot]]
    if current_item_inventory ~= nil then
        framework:set_global_system_value("InventoryCurrentItemId", {current_item_inventory[1]})
    else
        framework:set_global_system_value("InventoryCurrentItemId", {})
    end
end

function client_render(framework)
    if current_cursor_item ~= nil then
        local resolution = framework:get_resolution()
        local cursor_item_x = framework:mouse_position()[1] * resolution[1] + 26
        local cursor_item_y = framework:mouse_position()[2] * (-resolution[2]) - 26
        framework:set_window_position("CursorItem", {cursor_item_x, cursor_item_y})
    end

    if is_showing_inventory then
        for idx, _ in pairs(inventory_items) do
            if framework:is_widget_left_clicked("Inventory", "Item name#" .. idx) then
                send_custom_message(true, "SetCurrentCursorItem", {idx})
                break
            end
            if framework:is_widget_right_clicked("Inventory", "Item name#" .. idx) then
                selected_item_idx = idx
                break
            end
        end
    end

    for i = 1, 10 do
        if framework:is_widget_left_clicked("Hotbar", "Slot " .. i) then
            print("Player clicked the slot #" .. i)
            send_custom_message(true, "HotbarSlotClicked", {i})
            break
        end
        if framework:is_widget_left_clicked("Hotbar Slot " .. i, "Icon") then
            print("Player clicked the slot image #" .. i)
            send_custom_message(true, "HotbarSlotClicked", {i})
            break
        end
    end
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
    -- { 'plr_id': {"inventory item idx1", "inventory item idx2", ...}, ... }
    framework:set_global_system_value("InventoryPlayerHotbars", {})
    -- { 'plr_id': {2}, "50": {1} }
    framework:set_global_system_value("InventoryPlayerCurrentHotbarSlot", {})

    -- { 'plr_id': {"itmid1", 420}, "50": {"pickaxe", 1} }
    framework:set_global_system_value("InventoryPlayerCurrentCursorItem", {})


    -- +InventoryPlayerCurrentItem
end

function server_update(framework)
    local player_current_item = {}
    local ids = framework:get_global_system_value("PlayerManagerIDs")
    for _, id in pairs(ids) do
        ::player_inventory_update::

        local items_to_add = framework:get_global_system_value("InventoryAddPlayerItems_" .. id)
        local hotbar = framework:get_global_system_value("InventoryPlayerHotbar_" .. id)
        local hotbar_slot = framework:get_global_system_value("InventoryPlayerCurrentHotbarSlot_" .. id)
        if hotbar_slot == nil or hotbar == nil then
            local player_hotbar = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
            framework:set_global_system_value("InventoryPlayerHotbar_" .. id, player_hotbar)
            framework:set_global_system_value("InventoryPlayerCurrentHotbarSlot_" .. id, {1})

            goto player_inventory_update
        end
        --print("InventoryPlayerCurrentHotbarSlot_" .. id)
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

        if hotbar ~= nil then
            local current_item_inventory = items[hotbar[hotbar_slot[1]]]
            if current_item_inventory ~= nil then
                framework:set_global_system_value("InventoryPlayerCurrentItemId_" .. id, {current_item_inventory[1]})
            else
                framework:set_global_system_value("InventoryPlayerCurrentItemId_" .. id, {})
            end
        else
            framework:set_global_system_value("InventoryPlayerCurrentItemId_" .. id, {})
        end

        framework:set_global_system_value("InventoryAddPlayerItems_" .. id, {})
        framework:set_global_system_value("InventoryPlayerItems_" .. id, items)
        send_custom_message(true, "InventoryItems", items, "OneClient", id)
        -- TODO set player current item here
    end
end

function reg_message(message, framework)
    -- client
    if message:message_id() == "InventoryItems" then
        inventory_items = message:custom_contents()
        if is_showing_inventory then
            framework:remove_window("Inventory")
            show_inventory(framework)
        end

    elseif message:message_id() == "SetDisplayCursorItem" then
        local inventory_item_idx = message:custom_contents()[1]
        local item_id = inventory_items[inventory_item_idx][1]
        local item = framework:get_global_system_value("InventoryItem_" .. item_id)

        current_cursor_item = inventory_item_idx
        framework:new_window("CursorItem", true)
        framework:add_image("CursorItem", "Image", item[2], {50, 50})
        framework:set_window_on_top("CursorItem", true)

    elseif message:message_id() == "SetHotbarDisplayItem" then
        local slot_id = message:custom_contents()[1]
        local inventory_item_idx = message:custom_contents()[2]
        local item_id = inventory_items[inventory_item_idx][1]
        local item = framework:get_global_system_value("InventoryItem_" .. item_id)
        local image_path = item[2]
        framework:remove_window("Hotbar Slot " .. slot_id)
        framework:new_window("Hotbar Slot " .. slot_id, true)
        framework:add_image("Hotbar Slot " .. slot_id, "Icon", item[2], {30, 30})
        hotbar_items[slot_id] = inventory_item_idx

    elseif message:message_id() == "NullDisplayCursorItem" then
        current_cursor_item = nil
        framework:remove_window("CursorItem")

    elseif message:message_id() == "NullHotbarDisplayItem" then
        local slot_id = message:custom_contents()[1]
        framework:remove_window("Hotbar Slot " .. slot_id)
        framework:new_window("Hotbar Slot " .. slot_id, true)
        framework:add_image("Hotbar Slot " .. slot_id, "Icon", "textures/transparent.png", {30, 30}, nil)
        hotbar_items[slot_id] = 0

    elseif message:message_id() == "SetCurrentItem" then
        local hotbar_slot_idx = message:custom_contents()[1]
        current_hotbar_slot = hotbar_slot_idx
        framework:set_global_system_value("InventoryCurrentHotbarSlot", {hotbar_slot_idx})

    -- server
    elseif message:message_id() == "SetCurrentCursorItem" then
        local required_index = message:custom_contents()[1]
        local player_id = message:message_sender()
        local items = framework:get_global_system_value("InventoryPlayerItems_" .. player_id)
        local current_cursor_items = framework:get_global_system_value("InventoryPlayerCurrentCursorItem_" .. player_id)

        if current_cursor_items == nil then
            if items ~= nil then
                if items[required_index] ~= nil then
                    current_cursor_items = {required_index}

                    framework:set_global_system_value("InventoryPlayerCurrentCursorItem_" .. player_id, current_cursor_items)
                    framework:set_global_system_value("InventoryPlayerItems_" .. player_id, items)
                    send_custom_message(true, "SetDisplayCursorItem", {required_index}, "OneClient", player_id)
                end
            end
        else
            send_custom_message(true, "NullDisplayCursorItem", {}, "OneClient", player_id)
            framework:remove_global_system_value("InventoryPlayerCurrentCursorItem_" .. player_id)
        end

    elseif message:message_id() == "HotbarSlotClicked" then
        local player_id = message:message_sender()
        local slot_id = message:custom_contents()[1]
        local current_cursor_item = framework:get_global_system_value("InventoryPlayerCurrentCursorItem_" .. player_id)
        local player_hotbar = framework:get_global_system_value("InventoryPlayerHotbar_" .. player_id)
        if player_hotbar == nil then
            player_hotbar = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
            framework:set_global_system_value("InventoryPlayerHotbar_" .. player_id, player_hotbar)
        end

        if current_cursor_item == nil then
            if player_hotbar[slot_id] ~= 0 then
                local hotbar_item = player_hotbar[slot_id]
                framework:set_global_system_value("InventoryPlayerCurrentCursorItem_" .. player_id, {hotbar_item})
                player_hotbar[slot_id] = 0
                send_custom_message(true, "SetDisplayCursorItem", {hotbar_item}, "OneClient", player_id)
                send_custom_message(true, "NullHotbarDisplayItem", {slot_id}, "OneClient", player_id)
            end
        else
            if player_hotbar[slot_id] == 0 then
                player_hotbar[slot_id] = current_cursor_item[1]
                send_custom_message(true, "SetHotbarDisplayItem", {slot_id, current_cursor_item[1]}, "OneClient", player_id)
                framework:remove_global_system_value("InventoryPlayerCurrentCursorItem_" .. player_id)
                send_custom_message(true, "NullDisplayCursorItem", {}, "OneClient", player_id)
            end
        end
        framework:set_global_system_value("InventoryPlayerHotbar_" .. player_id, player_hotbar)
    elseif message:message_id() == "SetHotbarSlot" then
        local player_id = message:message_sender()
        local slot_id = message:custom_contents()[1]
        framework:set_global_system_value("InventoryPlayerCurrentHotbarSlot_" .. player_id, {slot_id})
        send_custom_message(true, "SetCurrentItem", {slot_id}, "OneClient", player_id)
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
        if index == current_cursor_item then
            framework:add_horizontal("Inventory", "Item#" .. index, {500, 50}, "Items List")
            framework:add_button("Inventory", "Item name#" .. index, name, {410, 50}, horizontal_id)
            framework:add_label("Inventory", "Item count#" .. index, tostring(count), 20, {50, 50}, horizontal_id)
            framework:add_vertical("Inventory", "Current cursor item icon container", {40, 50}, horizontal_id)
            framework:add_image("Inventory", "Current cursor item icon", "textures/ui/cursor.png", {40, 40}, "Current cursor item icon container")
        else
            framework:add_horizontal("Inventory", "Item#" .. index, {500, 50}, "Items List")
            framework:add_button("Inventory", "Item name#" .. index, name, {450, 50}, horizontal_id)
            framework:add_label("Inventory", "Item count#" .. index, tostring(count), 20, {50, 50}, horizontal_id)
        end
    end

    framework:add_vertical("Inventory", "Selected Item", {500, 500}, "Inventory")

    if inventory_items[selected_item_idx] ~= nil then
        local inventory_item = inventory_items[selected_item_idx]
        local id = inventory_item[1]

        local item = framework:get_global_system_value("InventoryItem_" .. id)
        local name = item[1]
        local image = item[2]
        local description = item[3]

        framework:add_image("Inventory", "Selected Item Image", image, {500, 300}, "Selected Item")
        framework:add_label("Inventory", "Selected Item Title", name, 20, {500, 50}, "Selected Item")
        framework:add_label("Inventory", "Selected Item Description", description, 14, {500, 150}, "Selected Item")
    else
        framework:add_label("Inventory", "Selected Item Tip", "Select an item from the list", 24, {500, 500}, "Selected Item")
    end
end
