function todo.create_frame(player, name, caption, close_name)
    local frame = player.gui.screen.add({
        type = "frame",
        name = name,
        direction = "vertical"
    })

    -- Add title bar
    local title_bar = frame.add({
        type = "flow"
    })
    local title = title_bar.add({
        type = "label",
        caption = caption,
        style = "frame_title"
    })
    title.drag_target = frame

    -- Add 'dragger' (filler) between title and (close) buttons
    local dragger = title_bar.add({
        type = "empty-widget",
        style = "draggable_space_header"
    })
    dragger.style.vertically_stretchable = true
    dragger.style.horizontally_stretchable = true
    dragger.drag_target = frame

    if close_name ~= nil then
        title_bar.add({
            type = "sprite-button",
            style = "frame_action_button",
            sprite = "utility/close_white",
            name = close_name
        })
    end

    return frame
end