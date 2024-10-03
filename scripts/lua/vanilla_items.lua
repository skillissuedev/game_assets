-- client
local previous_current_item = {}
local item_attack_animations = {}
local attack_animation_idx = 1

function client_start(framework)
    framework:new_bind_mouse("Attack", {"Left"})
    framework:new_bind_mouse("AltAttack", {"Right"})
    -- { 'id': {"name", "img", "desc"}, ... }
    local items_list = framework:get_global_system_value("InventoryItemsList")

    table.insert(items_list, "VanillaOldAxe")
    table.insert(items_list, "VanillaWood")
    local vanilla_old_axe = { "Old Axe", "textures/default_texture.png", "It's just an old axe", { "Takable", "Weapon", "Axe" } }
    local vanilla_wood = { "Wood", "textures/default_texture.png", "A common resource", { "Wood", "Building Material", "Material" } }
    item_attack_animations["VanillaOldAxe"] = {"Attack.001", "Attack.002"}
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
        if framework:is_bind_down("Attack") then
            local object = find_object("CurrentItemViewmodel")
            local object_animation = object:current_animation()
            if object_animation ~= nil then
                if string.match(string.lower(object_animation), "attack") ~= nil then -- if current animation name contains 'attack', don't start the new animation
                    goto cant_attack_continue
                end
            end
            local item_id = previous_current_item[1]
            local attack_animations = item_attack_animations[item_id]
            if attack_animation_idx >= #attack_animations then
                attack_animation_idx = 1
            else
                attack_animation_idx = attack_animation_idx + 1
            end

            print("animation idx: " .. attack_animation_idx)
            print("animation: " .. attack_animations[attack_animation_idx])
            object:play_animation(attack_animations[attack_animation_idx])

            ::cant_attack_continue::
        end
        print("pos: x = " .. camera_position[1] .. "; z = " .. camera_position[3])
    end
end

function server_start(framework)
    -- { 'id': {"name", "img", "desc"}, ... }
    local items_list = framework:get_global_system_value("InventoryItemsList")

    table.insert(items_list, "VanillaOldAxe")
    table.insert(items_list, "VanillaWood")
    local vanilla_old_axe = { "Old Axe", "textures/default_texture.png", "It's just an old axe", { "Takable", "Weapon", "Axe" } }
    local vanilla_wood = { "Wood", "textures/default_texture.png", "A common resource", { "Wood", "Building Material", "Material" } }
    framework:set_global_system_value("InventoryItem_VanillaOldAxe", vanilla_old_axe)
    framework:set_global_system_value("InventoryItem_VanillaWood", vanilla_wood)

    framework:set_global_system_value("InventoryItemsList", items_list)
end

function server_update(framework)
end

function reg_message(message, framework)
end
