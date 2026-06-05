--[[
    Business logic for manipulating subtasks
]]--

function todo.on_save_new_subtask_click(player, task_id)

    local task = todo.get_task_by_id(task_id)
    if not task then
        player.print({"todo.error_task_deleted"})
        todo.update_main_task_list_for_everyone()
        return
    end

    local task_table = todo.get_task_table(player)
    local textfield = task_table["todo_main_subtask_new_text_" .. task_id]

    todo.save_subtask_to_task(task, textfield.text)

    todo.update_main_task_list_for_everyone()
end

function todo.save_subtask_to_task(task, text)
    if (not task.subtasks) then
        task.subtasks = {}
        task.subtasks.open = {}
        task.subtasks.done = {}
        task.subtasks.next_id = 1
    end

    local subtask = {}
    subtask.id = task.subtasks.next_id
    task.subtasks.next_id = task.subtasks.next_id + 1

    subtask.task = text

    table.insert(task.subtasks.open, subtask)

    return subtask
end

function todo.on_edit_subtask_click(player, task_id, subtask_id)
    local task = todo.get_task_by_id(task_id)
    if not task then
        player.print({"todo.error_task_deleted"})
        todo.update_main_task_list_for_everyone()
        return
    end
    local subtask = todo.get_subtask_by_id(task, subtask_id)
    if not subtask then
        player.print({"todo.error_subtask_deleted"})
        todo.update_main_task_list_for_everyone()
        return
    end

    todo.create_edit_subtask_dialog(player, task.id, subtask)
end

function todo.on_edit_subtask_cancel_click(player)
    local dialog = todo.get_edit_subtask_dialog(player)
    if (dialog) then
        dialog.destroy()
    end
end

function todo.on_edit_subtask_save_click(player, task_id, subtask_id)
    local dialog = todo.get_edit_subtask_dialog(player)

    local new_text = dialog.todo_edit_subtask_text.text

    local task = todo.get_task_by_id(task_id)
    if not task then
        player.print({"todo.error_task_deleted"})
        dialog.destroy()
        todo.update_main_task_list_for_everyone()
        return
    end

    local ok = todo.update_subtask(task_id, subtask_id, new_text)
    if not ok then
        player.print({"todo.error_subtask_deleted"})
    end

    dialog.destroy()

    todo.update_main_task_list_for_everyone()
end

function todo.update_subtask(task_id, subtask_id, new_text)
    local task = todo.get_task_by_id(task_id)
    if not task then return false end
    local subtask = todo.get_subtask_by_id(task, subtask_id)
    if not subtask then return false end

    subtask.task = new_text
    return true
end

function todo.on_subtask_checkbox_click(task_id, subtask_id)
    local task = todo.get_task_by_id(task_id)
    if not task then
        todo.update_main_task_list_for_everyone()
        return
    end
    local subtask, is_completed = todo.get_subtask_by_id(task, subtask_id)
    if not subtask then
        todo.update_main_task_list_for_everyone()
        return
    end

    if (is_completed) then
        todo.mark_subtask_open(task, subtask_id)
    else
        todo.mark_subtask_complete(task, subtask_id)
    end

    todo.update_main_task_list_for_everyone()
end

function todo.mark_subtask_complete(task, subtask_id)
    todo.log("Marking subtask [" .. subtask_id .. "] as completed.")
    for i, subtask in ipairs(task.subtasks.open) do
        if (subtask.id == subtask_id) then
            local t = table.remove(task.subtasks.open, i)

            todo.log("Adding task [" .. t.id .. "] to done list.")
            table.insert(task.subtasks.done, t)
            break
        end
    end
end

function todo.mark_subtask_open(task, subtask_id)
    todo.log("Marking subtask [" .. subtask_id .. "] as open.")
    for i, subtask in ipairs(task.subtasks.done) do
        if (subtask.id == subtask_id) then
            local t = table.remove(task.subtasks.done, i)

            todo.log("Adding task [" .. t.id .. "] to open list.")
            table.insert(task.subtasks.open, t)
            break
        end
    end
end

function todo.on_main_subtask_move_up_click(task_id, subtask_id)
    todo.move_subtask(task_id, subtask_id, -1)

    todo.update_main_task_list_for_everyone()
end

function todo.on_main_subtask_move_down_click(task_id, subtask_id)
    todo.move_subtask(task_id, subtask_id, 1)

    todo.update_main_task_list_for_everyone()
end

function todo.move_subtask(task_id, subtask_id, modifier)
    local task = todo.get_task_by_id(task_id)
    if not task then return end
    for i, subtask in pairs(task.subtasks.open) do
        if (subtask.id == subtask_id) then
            local copy = task.subtasks.open[i + modifier]
            task.subtasks.open[i + modifier] = subtask
            task.subtasks.open[i] = copy
            break
        end
    end
end

function todo.on_subtask_delete_click(task_id, subtask_id)

    local task = todo.get_task_by_id(task_id)
    if not task then
        todo.update_main_task_list_for_everyone()
        return
    end
    local subtask, is_completed = todo.get_subtask_by_id(task, subtask_id)
    if not subtask then
        todo.update_main_task_list_for_everyone()
        return
    end

    if (is_completed) then
        todo.delete_subtask(task.subtasks.done, subtask_id)
    else
        todo.delete_subtask(task.subtasks.open, subtask_id)
    end

    todo.update_main_task_list_for_everyone()
end

function todo.delete_subtask(list, id)
    for i, subtask in ipairs(list) do
        if (subtask.id == id) then
            table.remove(list, i)
            break
        end
    end
end