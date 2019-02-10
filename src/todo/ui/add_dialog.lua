function todo.create_add_task_dialog(player)
    local gui = player.gui.center

    local old_dialog = todo.get_add_dialog(player)
    if (old_dialog ~= nil) then
        old_dialog.destroy()
    end

    local dialog = gui.add({
        type = "frame",
        name = "todo_add_dialog",
        caption = { todo.translate(player, "add_title") },
        direction = "vertical"
    })

    local table = dialog.add({
        type = "table",
        style = "todo_table_default",
        name = "todo_add_task_table",
        column_count = 2
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_add_task_title_label",
        caption = { todo.translate(player, "add_task_title") }
    })

    table.add({
        type = "textfield",
        style = "todo_textfield_default",
        name = "todo_new_task_title"
    })

    -- Task description field
    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_add_task_label",
        caption = { todo.translate(player, "add_task") }
    })

    table.add({
        type = "text-box",
        style = "todo_textbox_default",
        name = "todo_new_task_textbox"
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_add_assignee_label",
        caption = { todo.translate(player, "add_assignee") }
    })

    local players, lookup, c = todo.get_player_list(player)

    local assign_index = 1
    if todo.is_auto_assign(player) and c == 1 then
        assign_index = lookup[player.name]
    end
    table.add({
        type = "drop-down",
        style = "todo_dropdown_default",
        name = "todo_add_assignee_drop_down",
        items = players,
        selected_index = assign_index
    })

    table.add({
        type = "checkbox",
        style = "todo_checkbox_default",
        name = "todo_add_top",
        state = false,
        caption = { "todo.add_top" }
    })

    local button_flow = dialog.add({
        type = "flow",
        name = "todo_add_dialog_button_flow",
        direction = "horizontal"
    })

    button_flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_add_cancel_button",
        caption = { todo.translate(player, "cancel") }
    })

    button_flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_save_new_task_button",
        caption = { todo.translate(player, "persist") }
    })
end

function todo.get_add_dialog(player)
    local gui = player.gui.center
    if gui.todo_add_dialog then
        return gui.todo_add_dialog
    else
        return nil
    end
end
