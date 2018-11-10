--[[
  Business logic for the delete task feature.
]]--

function todo.on_edit_confirm_delete_click(player, id)
    todo.delete_task(id)

    local dialog = todo.get_edit_dialog(player)
    if (dialog) then
        dialog.destroy()
    end

    todo.update_export_dialog_button_state()

    todo.update_main_task_list_for_everyone()
end

function todo.delete_task(id)
    for i, task in pairs(global.todo.open) do
        if (task.id == id) then
            table.remove(global.todo.open, i)
            return
        end
    end

    for i, task in pairs(global.todo.done) do
        if (task.id == id) then
            table.remove(global.todo.done, i)
            return
        end
    end
end

function todo.create_delete_confirmation_button(element, id)
    local table = element.parent
    element.destroy()

    table.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_edit_confirm_deletion_button_" .. id,
        caption = { "todo.confirm_deletion" }
    })
end
