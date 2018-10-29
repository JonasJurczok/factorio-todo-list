function todo.log(message)
    if type(message) == 'table' then
        message = serpent.dump(message) .. ' [' .. #message .. ']'
    end
    message = "" .. message or '<nil>'

    if game then
        for _, p in pairs(game.players) do
            if (todo.show_log(p)) then
                p.print(message)
            end
        end
    else
        error(serpent.dump(message, { compact = false, nocode = true, indent = ' ' }))
    end

end

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

-- Returns the maximize button if it is displayed, nil otherwise
function todo.get_maximize_button(player)
    local flow = mod_gui.get_button_flow(player)
    if flow.todo_maximize_button then
        return flow.todo_maximize_button
    else
        return nil
    end
end

-- Returns the add/edit frame if it is displayed, nil otherwise
function todo.get_add_edit_frame(player)
    local gui = player.gui.center
    if gui.todo_add_frame then
        return gui.todo_add_frame
    else
        return nil
    end
end

function todo.get_main_frame(player)
    local flow = mod_gui.get_frame_flow(player)
    if flow.todo_main_frame then
        return flow.todo_main_frame
    else
        return nil
    end
end

function todo.get_task_table(player)
    local main_frame = todo.get_main_frame(player)
    if (main_frame.todo_task_table) then
        return main_frame.todo_task_table
    elseif (main_frame.todo_scroll_pane.todo_task_table) then
        return main_frame.todo_scroll_pane.todo_task_table
    end
end

function todo.get_export_dialog(player)
    local center = player.gui.center
    if (center.todo_export_dialog) then
        return center.todo_export_dialog
    end
end

function todo.show_button(player)
    return settings.get_player_settings(player)["todolist-show-button"].value
end

function todo.is_auto_assign(player)
    return settings.get_player_settings(player)["todolist-auto-assign"].value
end

function todo.get_window_height(player)
    return settings.get_player_settings(player)["todolist-window-height"].value
end

function todo.show_log(player)
    return settings.get_player_settings(player)["todolist-show-log"].value
end

function todo.get_task_id_from_element_name(name, pattern)
    local _, start = string.find(name, pattern)
    local index = tonumber(string.sub(name, start + 1))
    return index
end

function todo.generate_id()
    if not global.todo.next_id then
        global.todo.next_id = 1
    end

    global.todo.next_id = global.todo.next_id + 1
    return global.todo.next_id - 1
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

function todo.filter_table_by_id(source, exclude_id, destination)
    destination = destination or {}
    local i = #destination

    for _, task in pairs(source) do
        if (task.id ~= exclude_id) then
            i = i + 1
            destination[i] = task
        end
    end

    return destination
end
