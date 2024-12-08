--[[
  Business logic for the mark task complete feature.
]]--

function todo.on_mark_complete_click(id)
    todo.mark_complete(id)

    todo.update_main_task_list_for_everyone()
end

function todo.mark_complete(id)
    todo.log("Marking task [" .. id .. "] as completed.")
    for i, task in ipairs(storage.todo.open) do
        if (task.id == id) then
            local t = table.remove(storage.todo.open, i)

            todo.log("Adding task [" .. t.id .. "] to done list.")
            table.insert(storage.todo.done, t)
            break
        end
    end
end