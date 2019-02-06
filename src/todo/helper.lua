--[[
  A list of helper functions.
  A helper function is
  - not directly tied to a use case
  - used in multiple places
]]--

function todo.get_player_list(current_player)
    local result = { { todo.translate(current_player, "unassigned") } }

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

--[[
  Retains everything after the pattern.
  If the remaining string contains a _ it will be split at this point.

  @return the task id as a number
  @return the subtask id as a number, if present
]]--
function todo.get_task_id_from_element_name(name, pattern)
    local _, start = string.find(name, pattern)
    local id_text = string.sub(name, start + 1)

    local subtask_delimiter_position = string.find(id_text, "_")

    if (subtask_delimiter_position) then
        local task_id = tonumber(string.sub(id_text, 1, subtask_delimiter_position - 1))
        local subtask_id = tonumber(string.sub(id_text, subtask_delimiter_position + 1))

        return task_id, subtask_id
    else
        return tonumber(id_text)
    end
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

--[[
  Find a subtask in a task by its id.
  @return the subtask if found, nil otherwise
  @return false if subtask is open, true if completed
]]--
function todo.get_subtask_by_id(task, id)
    for _, subtask in pairs(task.subtasks.open) do
        if (subtask.id == id) then
            return subtask, false
        end
    end

    for _, subtask in pairs(task.subtasks.done) do
        if (subtask.id == id) then
            return subtask, true
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

function todo.get_player_translation_mode(player)
    return settings.get_player_settings(player)["todolist-translation-mode"].value
end

function todo.translate(player, input)
    local mode = todo.get_player_translation_mode(player)
    if (mode == "quest") then
        return "todo.quest_"..input
    else
        return "todo."..input
    end
end