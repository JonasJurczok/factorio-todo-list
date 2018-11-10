--[[
  Business logic for the main UI.
]]--

function todo.toggle_main_frame(player)
    if todo.get_main_frame(player) then
        todo.minimize_main_frame(player)
    else
        todo.maximize_main_frame(player)
        todo.refresh_task_table(player)
    end
end

function todo.minimize_main_frame(player)
    todo.log("Minimizing UI for player " .. player.name)

    local frame = todo.get_main_frame(player)
    if frame then
        frame.destroy()
        return true
    end
    return false
end

function todo.maximize_main_frame(player)
    todo.log("Maximizing UI for player " .. player.name)

    if not todo.get_main_frame(player) then
        todo.create_maximized_frame(player)
        return true
    end
    return false
end

function todo.update_main_task_list_for_everyone()
    for _, player in pairs(game.players) do
        todo.refresh_task_table(player)
    end
end

function todo.refresh_task_table(player)

    todo.update_current_task_label(player)

    -- if the player has the UI minimized do nothing
    local main_frame = todo.get_main_frame(player)
    if not main_frame then
        return
    end

    local table = todo.get_task_table(player)
    for i, element in ipairs(table.children) do
        if i > table.column_count then
            element.destroy()
        end
    end

    local open_length = #global.todo.open
    for i, task in ipairs(global.todo.open) do
        todo.add_task_to_table(table, task, false, i == 1, i == open_length)
    end

    if (todo.show_completed_tasks(player)) then
        for _, task in ipairs(global.todo.done) do
            -- we don't want ordering for completed tasks
            todo.add_task_to_table(table, task, true, true, true)
        end
    end
end

function todo.update_current_task_label(player)
    if not todo.get_maximize_button(player) then
        return
    end

    -- we may update the button label
    todo.log("updating button label")
    local count = 0
    for _, task in pairs(global.todo.open) do
        if task.assignee == player.name then
            todo.log(serpent.block(task))
            todo.get_maximize_button(player).caption =
            {"",
             {"todo.todo_list"},
             ": ",
             task.title
            }
            return
        end

        -- only count tasks that are assignable
        if (not task.assignee) then
            count = count + 1
        end
    end

    if (count == 0) then
        todo.get_maximize_button(player).caption = {"todo.todo_list"}
    else
        todo.get_maximize_button(player).caption =
        {"", {"todo.todo_list"}, ": ", {"todo.tasks_available", count}}
    end
end

function todo.on_toggle_show_completed_click(player)
    todo.toggle_show_completed(player)
    todo.refresh_task_table(player)
end

function todo.toggle_show_completed(player)
    if not global.todo.settings[player.name] then
        global.todo.settings[player.name] = {}
        global.todo.settings[player.name].show_completed = true
    else
        global.todo.settings[player.name].show_completed = not global.todo.settings[player.name].show_completed
    end

    local frame = todo.get_main_frame(player)
    if (global.todo.settings[player.name].show_completed) then
        frame.todo_main_button_flow.todo_toggle_show_completed_button.caption = {"todo.hide_done"}
    else
        frame.todo_main_button_flow.todo_toggle_show_completed_button.caption = {"todo.show_done"}
    end
end

function todo.get_maximize_button(player)
    local flow = mod_gui.get_button_flow(player)
    if flow.todo_maximize_button then
        return flow.todo_maximize_button
    else
        return nil
    end
end