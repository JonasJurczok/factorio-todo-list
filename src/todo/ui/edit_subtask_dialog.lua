
function todo.create_edit_subtask_dialog(player, task_id, subtask)
    local gui = player.gui.center

    if (not subtask or not task_id) then
        return
    end

    local old_dialog = todo.get_edit_subtask_dialog(player)
    if (old_dialog ~= nil) then
        old_dialog.destroy()
    end

    local dialog = gui.add({
        type = "frame",
        name = "todo_edit_subtask_dialog",
        caption = { todo.translate(player, "edit_subtask") },
        direction = "vertical"
    })

    dialog.add({
        type = "textfield",
        style = "todo_textfield_default",
        name = "todo_edit_subtask_text",
        text = subtask.task
    })

    local flow = dialog.add({
        type = "flow",
        name = "todo_edit_subtask_button_flow",
        direction = "horizontal"
    })

    flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_edit_subtask_cancel_button",
        caption = { todo.translate(player, "cancel") }
    })

    flow.add({
        type = "button",
        style = "todo_button_default",
        name = string.format("todo_edit_subtask_save_button_%i_%i", task_id, subtask.id),
        caption = { todo.translate(player, "update") }
    })
end

function todo.get_edit_subtask_dialog(player)
    local gui = player.gui.center
    if gui.todo_edit_subtask_dialog then
        return gui.todo_edit_subtask_dialog
    else
        return nil
    end
end