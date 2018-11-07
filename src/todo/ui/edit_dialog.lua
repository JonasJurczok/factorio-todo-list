function todo.create_edit_task_dialog(player, id)
    local gui = player.gui.center
    local task = todo.get_task_by_id(id)
    if (not task) then
        return
    end

    local old_dialog = todo.get_edit_dialog(player)
    if (old_dialog ~= nil) then
        old_dialog.destroy()
    end

    local dialog = gui.add({
        type = "frame",
        name = "todo_edit_dialog",
        caption = { "todo.edit_title" },
        direction = "vertical"
    })

    local table = dialog.add({
        type = "table",
        style = "todo_table_default",
        name = "todo_edit_task_table",
        column_count = 2
    })

    -- Task title field
    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_edit_task_title_label",
        -- we are reusing the add translations. As soon as they diverge we will change that.
        caption = { "todo.add_task_title" }
    })

    table.add({
        type = "textfield",
        style = "todo_textfield_default",
        name = "todo_edit_task_title",
        text = task.title
    })

    -- Task description field
    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_edit_task_label",
        caption = { "todo.add_task" }
    })

    table.add({
        type = "text-box",
        style = "todo_textbox_default",
        name = "todo_edit_task_textbox",
        text = task.text
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_edit_assignee_label",
        caption = { "todo.add_assignee" }
    })

    local players, lookup, c = todo.get_player_list()

    local assign_index = 1
    if task and task.assignee then
        assign_index = lookup[task.assignee]
    elseif todo.is_auto_assign(player) and c == 1 then
        assign_index = lookup[player.name]
    end
    table.add({
        type = "drop-down",
        style = "todo_dropdown_default",
        name = "todo_edit_assignee_drop_down",
        items = players,
        selected_index = assign_index
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_edit_created_by_label",
        caption = { "todo.created_by" }
    })
    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_edit_created_by_playername",
        caption = task.created_by or { "todo.noone" }
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_edit_updated_by_label",
        caption = { "todo.updated_by" }
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_edit_updated_by_playername",
        caption = task.updated_by or { "todo.noone" }
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_edit_delete_label",
        caption = { "todo.delete" }
    })

    table.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_edit_delete_button_" .. task.id,
        caption = { "todo.delete" }
    })

    local flow = dialog.add({
        type = "flow",
        name = "todo_edit_button_flow",
        direction = "horizontal"
    })

    flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_edit_cancel_button",
        caption = { "todo.cancel" }
    })

    flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_edit_save_changes_button_" .. task.id,
        caption = { "todo.update" }
    })
end

function todo.get_edit_dialog(player)
    local gui = player.gui.center
    if gui.todo_edit_dialog then
        return gui.todo_edit_dialog
    else
        return nil
    end
end
