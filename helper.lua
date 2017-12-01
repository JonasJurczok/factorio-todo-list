
function todo.log(message)
    if game then
        for _, p in pairs(game.players) do
            if (todo.show_log(p)) then
                p.print(message)
            end
        end
    else
        error(serpent.dump(message, {compact = false, nocode = true, indent = ' '}))
    end

end

function todo.get_player_list(current_player)
    local result = {{"todo.unassigned"} }

    for _, player in pairs(game.players) do
        table.insert(result, player.name)
    end

    local lookup = {}
    for i, player in ipairs(result) do
        lookup[player] = i
    end

    todo.log("Created Assignee list: " .. serpent.block(result))

    return result, lookup
end

-- Returns the maximize button if it is displayed, nil otherwise
function todo.get_maximize_button(player)
    if not todo.has_mod_gui(player) then
        return nil
    end

    if player.gui.left.mod_gui_flow.mod_gui_button_flow.todo_maximize_button then
        return player.gui.left.mod_gui_flow.mod_gui_button_flow.todo_maximize_button
    else
        return nil
    end
end

function todo.get_main_frame(player)
    if not todo.has_mod_gui(player) then
        return nil
    end

    if player.gui.left.mod_gui_flow.mod_gui_frame_flow.todo_main_frame then
        return player.gui.left.mod_gui_flow.mod_gui_frame_flow.todo_main_frame
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

function todo.has_mod_gui(player)
    return player.gui.left.mod_gui_flow ~= nil and
            player.gui.left.mod_gui_flow.mod_gui_frame_flow ~= nil and
            player.gui.left.mod_gui_flow.mod_gui_button_flow ~= nil
end

function todo.show_minimized(player)
    return settings.get_player_settings(player)["todolist-show-minimized"].value
end

function todo.get_window_height(player)
    return settings.get_player_settings(player)["todolist-window-height"].value
end

function todo.show_log(player)
    return settings.get_player_settings(player)["todolist-show-log"].value
end

function todo.get_task_index_from_element_name(name, pattern)
    local _, start = string.find(name, pattern)
    local index = tonumber(string.sub(name, start + 1))
    return index
end
