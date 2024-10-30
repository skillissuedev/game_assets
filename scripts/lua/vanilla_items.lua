-- client
local previous_current_item = {}
local attack_animation_idx = 2
-- shared
local item_attacks = {} -- { id: { attack_timing, anim1, anim2, ... }, ... }

function client_start(framework)
    framework:new_bind_mouse("Attack", {"Left"})
    framework:new_bind_mouse("AltAttack", {"Right"})
    -- { 'id': {"name", "img", "desc"}, ... }
    local items_list = framework:get_global_system_value("InventoryItemsList")

    table.insert(items_list, "VanillaOldAxe")
    table.insert(items_list, "VanillaWood")
    local vanilla_old_axe = { "Old Axe", "textures/default_texture.png", "It's just an old axe", { "Takable", "Weapon", "Axe" } }
    local vanilla_wood = { "Wood", "textures/default_texture.png", "A common resource", { "Wood", "Building Material", "Material" } }
    item_attacks["VanillaOldAxe"] = { 0.083, "Attack.001", "Attack.002" }
    framework:set_global_system_value("InventoryItem_VanillaOldAxe", vanilla_old_axe)
    framework:set_global_system_value("InventoryItem_VanillaWood", vanilla_wood)

    framework:set_global_system_value("InventoryItemsList", items_list)
end

function client_update(framework)
    local current_item_global = framework:get_global_system_value("InventoryCurrentItemId")
    if #current_item_global == 0 then
        if #previous_current_item > 0 then
            delete_object(previous_current_item[1])
        end
        previous_current_item = current_item_global
    elseif #current_item_global > 0 then
        local current_item = current_item_global[1]

        if #previous_current_item > 0 then
            if current_item ~= previous_current_item[1] then
                delete_object(previous_current_item[1])
                -- spawn object
                if current_item == "VanillaOldAxe" then
                    framework:preload_model_asset("models/viewmodels/vanilla_old_axe_viewmodel.gltf", "models/viewmodels/vanilla_old_axe_viewmodel.gltf")
                    framework:preload_texture_asset("textures/vanilla_old_axe_texture.png", "textures/vanilla_old_axe_texture.png")
                    new_model_object("CurrentItemViewmodel", "models/viewmodels/vanilla_old_axe_viewmodel.gltf", "textures/vanilla_old_axe_texture.png", nil, nil)
                    find_object("CurrentItemViewmodel"):play_animation("Select")
                end
                previous_current_item = current_item_global
                return
            end
        else
            -- spawn object
            if current_item == "VanillaOldAxe" then
                framework:preload_model_asset("models/viewmodels/vanilla_old_axe_viewmodel.gltf", "models/viewmodels/vanilla_old_axe_viewmodel.gltf")
                framework:preload_texture_asset("textures/vanilla_old_axe_texture.png", "textures/vanilla_old_axe_texture.png")
                new_model_object("CurrentItemViewmodel", "models/viewmodels/vanilla_old_axe_viewmodel.gltf", "textures/vanilla_old_axe_texture.png", nil, nil)
                find_object("CurrentItemViewmodel"):play_animation("Select")
            end
            previous_current_item = current_item_global
            return
        end
    end
end

function client_render(framework)
    local camera_position = framework:get_global_system_value("PlayerPosition")
    local camera_rotation = framework:get_global_system_value("PlayerCameraRotation")
    if #previous_current_item > 0 then
        set_object_position("CurrentItemViewmodel", camera_position[1], camera_position[2], camera_position[3])
        set_object_rotation("CurrentItemViewmodel", camera_rotation[1], camera_rotation[2], 0)
        local object = find_object("CurrentItemViewmodel")
        local object_animation = object:current_animation()
        if object_animation == nil then
            object:play_animation("Idle")
        end

        if framework:is_bind_down("Attack") then
            if object_animation ~= nil then
                -- if current animation name contains 'attack' or `select`, don't start the new animation
                local lowercase_object_animation = string.lower(object_animation)
                if string.match(lowercase_object_animation, "attack") ~= nil or string.match(lowercase_object_animation, "select") ~= nil then
                    goto cant_attack_continue
                end
            end
            local item_id = previous_current_item[1]
            local current_item_attacks = item_attacks[item_id]
            if attack_animation_idx >= #current_item_attacks then
                attack_animation_idx = 2
            else
                attack_animation_idx = attack_animation_idx + 1
            end

            print("animation idx: " .. attack_animation_idx)
            print("animation: " .. current_item_attacks[attack_animation_idx])
            object:play_animation(current_item_attacks[attack_animation_idx])
            send_custom_message(true, "Attack", {})

            ::cant_attack_continue::
        end
        print("pos: x = " .. camera_position[1] .. "; z = " .. camera_position[3])
    else
        if does_object_exist("CurrentItemViewmodel") == true then
            delete_object("CurrentItemViewmodel")
        end
    end
end

function server_start(framework)
    -- { 'id': {"name", "img", "desc"}, ... }
    local items_list = framework:get_global_system_value("InventoryItemsList")

    table.insert(items_list, "VanillaOldAxe")
    table.insert(items_list, "VanillaWood")
    local vanilla_old_axe = { "Old Axe", "textures/default_texture.png", "It's just an old axe", { "Takable", "Weapon", "Axe" } }
    local vanilla_wood = { "Wood", "textures/default_texture.png", "A common resource", { "Wood", "Building Material", "Material" } }
    item_attacks["VanillaOldAxe"] = { 0.083, 0.9 } -- attack timing, attack duration
    framework:set_global_system_value("InventoryItem_VanillaOldAxe", vanilla_old_axe)
    framework:set_global_system_value("InventoryItem_VanillaWood", vanilla_wood)

    framework:set_global_system_value("InventoryItemsList", items_list)


    framework:set_global_system_value("ItemsAttackingPlayers", {})
end

function server_update(framework)
    local delta_time = framework:delta_time()
    local attacking_players = framework:get_global_system_value("ItemsAttackingPlayers")
    local new_attacking_players = {}
    local attack_time_players = {}
    for player_idx, player_id in pairs(attacking_players) do
        local player_previous_attack_time = framework:get_global_system_value("ItemsAttackTimePlayer_" .. player_id)[1]
        local player_attack_time = player_previous_attack_time + delta_time

        local player_item_option = framework:get_global_system_value("InventoryPlayerCurrentItemId_" .. player_id)
        if player_item_option ~= nil and #player_item_option > 0 then
            local player_item_id = player_item_option[1]
            if player_attack_time >= item_attacks[player_item_id][1] then -- if past attack timing, create a ray and check if player hit anything
                if does_object_exist("AttackRay") == false then
                    print("Ray inserted")

                    local front = framework:get_global_system_value("PlayerManagerFront_" .. player_id)[1]
                    local position = framework:get_global_system_value("PlayerManagerPosition_" .. player_id)[1]
                    print("player's front value: " .. front[1] .. ";" .. front[2] .. ";" .. front[3])
                    print("ray direction value: " .. front[1] * 3 .. ";" .. front[2] * 3 .. ";" .. front[3] * 3)
                    print("player's position value: " .. position[1] .. ";" .. position[2] .. ";" .. position[3])

                    new_ray("AttackRay", front[1] * 3, front[2] * 3, front[3] * 3, nil)
                    set_object_position("AttackRay", position[1], position[2], position[3])

                    print("Ray **actually** inserted!")
                    print("does_object_exist = " .. tostring(does_object_exist("AttackRay")))

                    local object_name = find_object("AttackRay"):intersection_object_name()
                    local object_groups = find_object("AttackRay"):intersection_object_groups()
                    if object_name == nil then
                        -- attack affected nothing
                        print("intersection_object_name: nil")
                    else
                        -- attack affects something
                        print("intersection_object_name: " .. object_name)
                        for _,group in pairs(object_groups) do
                            if group == "attackable" then
                                -- i need to figure out a way to store all affected objects in a separate group
                                -- because multiple systems can hold props.
                                --
                                -- maybe getting object's system with it's id (via Ray object basically) can help?
                                -- something like a global value that stores systems and which object were hit and by who
                                local damaged_props = framework:get_global_system_value("TileProps_PropsDamage")
                                table.insert(damaged_props, {object_name, 25, player_id}) -- just hardcoding a damage for now. don't you, future me, dare leaving it like this!
                                framework:set_global_system_value("TileProps_PropsDamage", damaged_props)
                                print("attacked!")
                                break
                            end
                        end
                    end
                end
            end
            if player_attack_time < item_attacks[player_item_id][2] then -- if the attack animation isn't finished, keep player in the attacking players/attack time lists
                table.insert(new_attacking_players, player_id)
                attack_time_players[player_id] = player_attack_time
            else
                delete_object("AttackRay")
            end
        else

        end
        framework:set_global_system_value("ItemsAttackingPlayers", new_attacking_players)
        framework:set_global_system_value("ItemsAttackTimePlayer_" .. player_id, {attack_time_players[player_id]})
    end


    -- add attack ray and remove players whose animation is finished
end

function reg_message(message, framework)
    if message:message_id() == "Attack" then
        local player_id = message:message_sender()
        local attacking_players = framework:get_global_system_value("ItemsAttackingPlayers")
        for _, player in pairs(attacking_players) do
            if player_id == player then
                print("Vanilla items: Player" .. player_id .. " is already attacking!!")
                return
            end
        end

        table.insert(attacking_players, player_id)
        framework:set_global_system_value("ItemsAttackingPlayers", attacking_players)
        framework:set_global_system_value("ItemsAttackTimePlayer_" .. player_id, {0})
    elseif message:message_id() == "StopAttackAnimation" then
        local object = find_object("CurrentItemViewmodel")
        local object_animation = object:current_animation()
        object:stop_animation()
    end
end
