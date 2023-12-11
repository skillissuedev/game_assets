function start()
    new_empty_object("hot")
    new_model_object("cool", "models/knife_test.gltf", nil, nil, nil)
    --call_in_object("cool", "set_position", {"2.0", "0.0", "0.0"})
    set_object_position("cool", 1.0, 0.0, 0.0)
end

function update()
    local rot = get_object_rotation("cool")
    set_object_rotation("cool", rot[1], rot[2] + 0.1, rot[3])
end

function render()

end

function reg_message(message)
    -- message = { message_id: string, message: string }
end
