--[[
  Business logic for the sort task feature.
]]--

function todo.on_main_move_up_click(id)
    todo.move(id, -1)
    todo.update_main_task_list_for_everyone()
end

function todo.on_main_move_down_click(id)
    todo.move(id, 1)
    todo.update_main_task_list_for_everyone()
end

function todo.move(id, modifier)
    for i, task in pairs(storage.todo.open) do
        if (task.id == id) then
            local copy = storage.todo.open[i + modifier]
            storage.todo.open[i + modifier] = task
            storage.todo.open[i] = copy
            break
        end
    end
end

function todo.on_main_move_top_click(id)
    todo.log('Moving task ' .. id .. ' to top.')

    todo.move_top(id)

    todo.update_main_task_list_for_everyone()
end

function todo.move_top(id)
    for i, current in ipairs(storage.todo.open) do
        if (current.id == id) then
            local temp = table.remove(storage.todo.open, i)
            table.insert(storage.todo.open, 1, temp)
            break
        end
    end
end

function todo.on_main_move_bottom_click(id)
    todo.log('Moving task ' .. id .. ' to bottom.')

    todo.move_bottom(id)

    todo.update_main_task_list_for_everyone()
end

function todo.move_bottom(id)
    for i, current in ipairs(storage.todo.open) do
        if (current.id == id) then
            local temp = table.remove(storage.todo.open, i)
            table.insert(storage.todo.open, #storage.todo.open + 1, temp)
            break
        end
    end
end
