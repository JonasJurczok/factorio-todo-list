--[[
  Business logic for the import task feature.
]]--

function todo.on_import_tasks_click(player)
    local dialog = todo.get_import_dialog(player)
    if (dialog == nil) then
        return
    end

    todo.import_tasks(dialog, player)

    dialog.destroy()

    todo.update_main_task_list_for_everyone()
end

function todo.import_tasks(dialog, player)
    local encoded = dialog.todo_import_string_textbox.text

    local tasks = todo.json:decode(todo.base64.decode(encoded))

    todo.log("Importing tasks:")
    todo.log(serpent.block(tasks))

    for _, task_to_import in pairs(tasks) do
        local task = todo.assemble_task(task_to_import, player)
        task.created_by = task_to_import.created_by
        todo.log(serpent.block(task))
        todo.save_task_to_open_list(task)
    end

    todo.log("Imported " .. #tasks .. " tasks.")
end

function todo.on_import_cancel_click(player)
    local dialog = todo.get_import_dialog(player)
    if (dialog) then
        dialog.destroy()
    end
end