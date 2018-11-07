--[[
  Business logic for the mark task open feature.
]]--

function todo.on_mark_open_click(id)
    todo.task_mark_open(id)

    todo.update_main_task_list_for_everyone()
end

function todo.task_mark_open(id)
    todo.log("Marking task [" .. id .. "] as open.")

    for i, completed_task in ipairs(global.todo.done) do
        if (completed_task.id == id) then
            local task = table.remove(global.todo.done, i)

            todo.log("Adding task [" .. task.id .. "] to open list.")
            table.insert(global.todo.open, task)
            break
        end
    end
end