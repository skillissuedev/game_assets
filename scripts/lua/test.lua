function client_start()
    --new_empty_object("hot")
    new_model_object("cool", "models/knife_test.gltf", nil, nil, nil)
    --call_in_object("cool", "set_position", {"2.0", "0.0", "0.0"})
    set_object_position("cool", 69.0, 0.0, 0.0)
    object = find_object("cool")
    object:build_object_rigid_body("Fixed", "Cuboid", "Cuboid", 69, 69, 42, 1)
    object:set_position(42.0, 0.0, 0.0, true)
    object:set_rotation(69, 69, 69, true)
    object:add_to_group("gud grup")
    object:remove_from_group("gud grup")
    print(object:children_list())
    set_current_parent("cool")
    new_empty_object("hot")
    clear_current_parent()
    new_empty_object("nice")
end

function client_update()
    --local rot = get_object_rotation("cool")
    --set_object_rotation("cool", rot[1], rot[2] + 0.1, rot[3])
end

function client_render()
end

function server_start()
    new_empty_object("cool")
    object = find_object("cool")
    object:build_object_rigid_body("Fixed", "Cuboid", "Cuboid", 69, 69, 42, 1)
    print(object:name() .. "'s id is " .. object:object_id())
end

function server_update()
    send_custom_message(false, "some_id", "some_contents", "Everybody")
end

function reg_message(message)
    contents = message:custom_contents()[1]
    message_id = message:message_id()
    print("message '" .. message_id .. "' contents = " .. contents)
end
