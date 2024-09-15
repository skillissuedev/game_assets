function client_start()
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
