player_inventories = {}

function client_start(framework)
    framework:new_window("Inventory", false)
    show_inventory(framework)
end

function client_update(framework)
    local pos_x = framework:get_resolution()[1] / 2 - 500
    local pos_y = framework:get_resolution()[2] / 2 - 250

    framework:set_window_position("Inventory", {pos_x, pos_y})
end

function client_render()
end

function server_start(framework)
end

function server_update(framework)
end

function reg_message(message, framework)
    -- client
    if message:message_id() == "InventoryData" then
        framework:remove_widget("Inventory", "Inventory")
        show_inventory(framework)
    end
end

function show_inventory(framework)
    framework:add_horizontal("Inventory", "Inventory", {1000, 500}, nil)
    framework:add_vertical("Inventory", "Items List", {500, 500}, "Inventory")
    framework:add_button("Inventory", "Item 1", "Item 1", {500, 50}, "Items List")
    framework:add_button("Inventory", "Item 2", "Item 2", {500, 50}, "Items List")
    framework:add_button("Inventory", "Item 3", "Item 3", {500, 50}, "Items List")
    framework:add_label("Inventory", "Current Item", "*Current item info*", {500, 500}, "Inventory")
    framework:show_title_bar("Inventory", false)
end
