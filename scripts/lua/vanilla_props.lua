--[[
# System values:
- TileProps_tree1_SpawnPositions - add a position vector to this global value to spawn a new tree1 prop
- TileProps_tree1_DeletePositions - add a position vector to this global value to remove an existing tree1 prop
]]--
spawned_props = {}
tick_counter = 0 -- used to run generation 10 times/sec instead of 60
set_object_positions = {}

function client_start(framework)
    framework:preload_model_asset("models/tree1.gltf", "models/tree1.gltf")
    framework:preload_model_asset("models/rock1.gltf", "models/rock1.gltf")
    framework:preload_texture_asset("textures/comfy52.png", "textures/comfy52.png")
    new_master_instanced_model_object("tree1_master", "models/tree1.gltf", "textures/comfy52.png", nil, nil)
    new_master_instanced_model_object("rock1_master", "models/rock1.gltf", "textures/comfy52.png", nil, nil)
end

function client_update()
end

function client_render()
end

function server_start(framework)
    framework:set_global_system_value("TileProps_PropsHP", {}) -- {{object_name, hp}}
    framework:set_global_system_value("TileProps_tree1_Damage", {}) -- {{object_name, damage, attacker}}
    framework:set_global_system_value("TileProps_rock1_Damage", {}) -- {{object_name, damage, attacker}}

    framework:set_global_system_value("TileProps_tree1_PropsPosition", {}) -- {{object_name, position}}
    framework:set_global_system_value("TileProps_rock1_PropsPosition", {}) -- {{object_name, position}}
end

function server_update(framework)
    local props_hp = framework:get_global_system_value("TileProps_PropsHP")
    local damaged_tree1_props = framework:get_global_system_value("TileProps_tree1_Damage")

    local tree1_props_position = framework:get_global_system_value("TileProps_tree1_PropsPosition")
    local rock1_props_position = framework:get_global_system_value("TileProps_rock1_PropsPosition")


    for _, prop_damage in pairs(damaged_tree1_props) do
        local object_name = prop_damage[1]
        local damage = prop_damage[2]
        local attacker = prop_damage[3]
        print("tree1 '" .. object_name .. "' is attacked by player w/ id " .. attacker)

        for props_hp_idx, current_prop_values in pairs(props_hp) do
            for idx, val in pairs(current_prop_values) do
                print("prop_hp #" .. idx .. " = " .. val)
            end
            local current_prop_name = current_prop_values[1]
            local current_prop_health = current_prop_values[2]
            if current_prop_name == object_name then
                print("damage = " .. damage .. "; old hp =" .. current_prop_health .. "; new hp = " .. current_prop_health - damage)
                current_prop_health = current_prop_health - damage
                current_prop_values[2] = current_prop_health
                local player_items = framework:get_global_system_value("InventoryAddPlayerItems_" .. attacker)
                local player_xp = framework:get_global_system_value("Experience_PlayerAddXP_" .. attacker)[1]
                for idx,prop_name_and_position in pairs(tree1_props_position) do
                    local prop_name = prop_name_and_position[1]
                    if prop_name == current_prop_name then -- probably should move everything to a separate function
                        table.remove(tree1_props_position, idx)
                        break
                    end
                end
                table.insert(player_items, {"VanillaWood", clamp(damage, 0, 150)})
                player_xp = player_xp + clamp(damage, 0, 150)

                if current_prop_health <= 0 then
                    -- please, future me, figure this out
                    -- UPDATE: i kind of did it

                    table.remove(props_hp, props_hp_idx)
                    delete_prop_by_full_name(current_prop_name)
                    print("the prop is dead")
                end

                framework:set_global_system_value("InventoryAddPlayerItems_" .. attacker, player_items)
                framework:set_global_system_value("Experience_PlayerAddXP_" .. attacker, {player_xp})
                break
            end
        end
    end


    for _, ev in pairs(get_network_events()) do
        if ev["type"] == "ClientConnected" then
            local player_id = ev["id"]
            send_custom_message(true, "SpawnMultipleTree1", framework:get_global_system_value("TileProps_tree1_PropsPosition"), "OneClient", player_id)
        end
    end

    if tick_counter >= 6 then
        local tree1_spawn_positions = framework:get_global_system_value("TileProps_tree1_SpawnPositions")
        if tree1_spawn_positions == nil then
            tree1_spawn_positions = {}
        end

        for _, position in pairs(tree1_spawn_positions) do
            print("Spawning new tree1: x = " .. position[1] .. "; y = " .. position[2] .. "; z = " .. position[3])
            local name = "tree1:" .. position[1] .. ";" .. position[2] .. ";" .. position[3]
            spawn_tree1(position)
            table.insert(tree1_props_position, {name, position})
            table.insert(props_hp, {name, 100})
        end

        local tree1_delete_names = framework:get_global_system_value("TileProps_tree1_DeletePositions")
        if tree1_delete_names == nil then
            tree1_delete_names = {}
        end
        for _, position in pairs(tree1_delete_names) do
            print("Deleting tree1: x = " .. position[1] .. "; y = " .. position[2] .. "; z = " .. position[3])
            local name = "tree1:" .. position[1] .. ";" .. position[2] .. ";" .. position[3]
            delete_prop("tree1", position)
            for idx, value in pairs(props_hp) do
                if value[1] == name then
                    table.remove(props_hp, idx)
                    break
                end
            end

            for idx, value in pairs(tree1_props_position) do
                if value[1] == name then
                    table.remove(tree1_props_position, idx)
                    break
                end
            end
        end

        local rock1_spawn_positions = framework:get_global_system_value("TileProps_rock1_SpawnPositions")
        if rock1_spawn_positions == nil then
            rock1_spawn_positions = {}
        end

        for _, position in pairs(rock1_spawn_positions) do
            print("Spawning new rock1: x = " .. position[1] .. "; y = " .. position[2] .. "; z = " .. position[3])
            local name = "rock1:" .. position[1] .. ";" .. position[2] .. ";" .. position[3]
            spawn_rock1(position)
            table.insert(rock1_props_position, {name, position})
            table.insert(props_hp, {name, 100})
        end

        local rock1_delete_names = framework:get_global_system_value("TileProps_rock1_DeletePositions")
        if rock1_delete_names == nil then
            rock1_delete_names = {}
        end
        for _, position in pairs(rock1_delete_names) do
            print("Deleting rock1: x = " .. position[1] .. "; y = " .. position[2] .. "; z = " .. position[3])
            delete_prop("rock1", position)
            local name = "tree1:" .. position[1] .. ";" .. position[2] .. ";" .. position[3]
            for idx, value in pairs(props_hp) do
                if value[1] == name then
                    table.remove(props_hp, idx)
                    break
                end
            end

            for idx, value in pairs(rock1_props_position) do
                if value[1] == name then
                    table.remove(rock1_props_position, idx)
                    break
                end
            end
        end


        framework:set_global_system_value("TileProps_tree1_SpawnPositions", {})
        framework:set_global_system_value("TileProps_tree1_DeletePositions", {})

        framework:set_global_system_value("TileProps_rock1_SpawnPositions", {})
        framework:set_global_system_value("TileProps_rock1_DeletePositions", {})


        tick_counter = 0
    end
    tick_counter = tick_counter + 1
    framework:set_global_system_value("TileProps_tree1_PropsPosition", tree1_props_position)
    framework:set_global_system_value("TileProps_rock1_PropsPosition", rock1_props_position)
    framework:set_global_system_value("TileProps_tree1_Damage", {})
    framework:set_global_system_value("TileProps_rock1_Damage", {})
    framework:set_global_system_value("TileProps_PropsHP", props_hp)
end

function reg_message(message, framework)
    print(message_id)
    local message_id = message:message_id()
    if message_id == "SpawnTree1" then
        local position = message:sync_object_pos_rot_scale()[1]
        local object_name = message:sync_object_name()
        new_instanced_model_object(object_name, "tree1_master")
        set_object_position(object_name, position[1], position[2], position[3])
    elseif message_id == "SpawnMultipleTree1" then
        print("SpawnMultipleTree1")
        for _, value in pairs(message:custom_contents()) do
            local name = value[1]
            local position = value[2]
            print(name .. ": " .. position[1] .. "; " .. position[2] .. "; " .. position[3])

            new_instanced_model_object(name, "tree1_master")
            set_object_position(name, position[1], position[2], position[3])
        end
    elseif message_id == "SpawnRock1" then
        local position = message:sync_object_pos_rot_scale()[1]
        local object_name = message:sync_object_name()
        new_instanced_model_object(object_name, "rock1_master")
        set_object_position(object_name, position[1], position[2], position[3])
    elseif message_id == "DeleteProp" then
        local object_name = message:custom_contents()[1]
        delete_object(object_name)
    end
end

-- server-side
function spawn_tree1(position)
    local name = "tree1:" .. position[1] .. ";" .. position[2] .. ";" .. position[3]
    new_empty_object(name)

    send_sync_object_message(true, "SpawnTree1", name, position, {0, 0, 0}, {1, 1, 1}, "Everybody")

    local object = find_object(name)
    object:add_to_group("attackable")
    object:build_object_rigid_body("Fixed", "Cuboid", "None", 0.5, 8, 0.5, 1)
    object:set_position(position[1], position[2], position[3], true)

    local properties = {["ParentSystem"] = {"TileProps"}, ["AttackableType"] = {"tree1"}}
    object:set_object_properties(properties)
end

function spawn_rock1(position)
    local name = "rock1:" .. position[1] .. ";" .. position[2] .. ";" .. position[3]
    new_empty_object(name)

    send_sync_object_message(true, "SpawnRock1", name, position, {0, 0, 0}, {1, 1, 1}, "Everybody")

    local object = find_object(name)
    object:add_to_group("attackable")
    object:build_object_rigid_body("Fixed", "Cuboid", "None", 1, 1, 1, 1)
    object:set_position(position[1], position[2], position[3], true)

    local properties = {["ParentSystem"] = {"TileProps"}, ["AttackableType"] = {"rock1"}}
    object:set_object_properties(properties)
end

function delete_prop(name, position)
    local object_name = name .. ":" .. position[1] .. ";" .. position[2] .. ";" .. position[3]
    delete_object(object_name)
    send_custom_message(true, "DeleteProp", {object_name}, "Everybody")
end

function delete_prop_by_full_name(name)
    delete_object(name)
    send_custom_message(true, "DeleteProp", {name}, "Everybody")
end

function clamp(value, min, max)
    local result = value
    if value < min then
        result = min
    elseif value > max then
        result = max
    end

    return result
end
