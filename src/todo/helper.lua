--[[
  A list of helper functions.
  A helper function is
  - not directly tied to a use case
  - used in multiple places
]]--

function todo.get_player_list()
    local result = { { "todo.unassigned" } }

    local count = 0
    for _, player in pairs(game.players) do
        table.insert(result, player.name)
        count = count + 1
    end

    local lookup = {}
    for i, player in ipairs(result) do
        lookup[player] = i
    end

    todo.log("Created Assignee list: " .. serpent.block(result))
    todo.log("Players in the game : " .. count)

    return result, lookup, count
end

function todo.get_task_id_from_element_name(name, pattern)
    local _, start = string.find(name, pattern)
    local index = tonumber(string.sub(name, start + 1))
    return index
end

function todo.get_task_by_id(id)
    for _, task in pairs(global.todo.open) do
        if (task.id == id) then
            return task
        end
    end

    for _, task in pairs(global.todo.done) do
        if (task.id == id) then
            return task
        end
    end
end

function todo.should_show_maximize_button(player)
    return settings.get_player_settings(player)["todolist-show-button"].value
end

function todo.is_auto_assign(player)
    return settings.get_player_settings(player)["todolist-auto-assign"].value
end

function todo.get_window_height(player)
    return settings.get_player_settings(player)["todolist-window-height"].value
end

function todo.show_completed_tasks(player)
    return global.todo.settings[player.name] and global.todo.settings[player.name].show_completed
end
