--[[
    Business logic for manipulating subtasks
]]--

function todo.on_save_new_subtask_click(player, task_id)

    local task = todo.get_task_by_id(task_id)

    if (not task.subtasks) then
        task.subtasks = {}
        task.subtasks.open = {}
        task.subtasks.done = {}
        task.subtasks.next_id = 1
    end

    local task_table = todo.get_task_table(player)
    local textfield = task_table["todo_main_subtask_new_text_" .. task_id]

    todo.save_subtask_to_task(task, textfield.text)

    todo.update_main_task_list_for_everyone()
end

function todo.save_subtask_to_task(task, text)
    local subtask = {}
    subtask.id = task.next_id
    task.next_id = task.next_id + 1

    table.insert(task.subtasks.open, subtask)
end

function todo.on_subtask_checkbox_click(player, task_id, subtask_id)
    local task = todo.get_task_by_id(task_id)
    local _, is_completed = todo.get_subtask_by_id(task, subtask_id)

    if (is_completed) then
        todo.mark_subtask_open(task, subtask_id)
    else
        todo.mark_subtask_complete(task, subtask_id)
    end
end

function todo.mark_subtask_complete(task, subtask_id)
    todo.log("Marking subtask [" .. subtask_id .. "] as completed.")
    for i, subtask in ipairs(task.subtasks.open) do
        if (subtask.id == id) then
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
        if (subtask.id == id) then
            local t = table.remove(task.subtasks.done, i)

            todo.log("Adding task [" .. t.id .. "] to open list.")
            table.insert(task.subtasks.open, t)
            break
        end
    end
end