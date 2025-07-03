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
    player.set_shortcut_toggled("todo-toggle-ui-shortcut", false)

    local frame = todo.get_main_frame(player)
    if frame then
        frame.destroy()

        -- just close import/export
        if (todo.get_import_dialog(player)) then
            todo.on_import_cancel_click(player)
        end
        if (todo.get_export_dialog(player)) then
            todo.on_export_cancel_click(player)
        end

        -- Also close the clean / clean confirmation dialogs
        if (todo.get_clean_dialog(player)) then
            todo.destroy_clean_dialog(player)
        end
        if (todo.get_clean_confirm_dialog(player)) then
            todo.destroy_clean_confirm_dialog(player)
        end

        -- if other dialog open, set it to opened
        local dialog = todo.get_add_dialog(player)
        if (dialog) then
            player.opened = dialog
            return true
        end
        dialog = todo.get_edit_dialog(player)
        if (dialog) then
            player.opened = dialog
            return true
        end
        return true
    end
    return false
end

function todo.on_maximize_button_click(player)
    if (todo.get_main_frame(player)) then
        todo.minimize_main_frame(player)
    else
        todo.maximize_main_frame(player)
    end

    todo.refresh_task_table(player)
end

function todo.maximize_main_frame(player)
    todo.log("Maximizing UI for player " .. player.name)
    player.set_shortcut_toggled("todo-toggle-ui-shortcut", true)

    if not todo.get_main_frame(player) then
        frame = todo.create_maximized_frame(player)
        player.opened = frame
        return true
    end
    return false
end

function todo.update_main_task_list_for_everyone()
    for _, player in pairs(game.players) do
        todo.refresh_task_table(player)
    end
end

function todo.refresh_task_table(player, search_term)
    -- Get search term from the UI if it exists and no search_term was provided
    if not search_term then
        local main_frame = todo.get_main_frame(player)
        search_term = ""
        
        -- Error handling for search field
        if main_frame and main_frame.todo_search_flow then
            local search_field = main_frame.todo_search_flow.todo_search_field
            if search_field and search_field.valid then  -- Validity check
                search_term = search_field.text
                
                -- Visual indicator when search is active
                if search_term and search_term ~= "" then
                    search_field.style.font_color = {r=0, g=1, b=0}  -- Green when search is active
                else
                    search_field.style.font_color = {r=1, g=1, b=1}  -- White when no search
                end
            end
        end
    end

    todo.update_current_task_label(player)

    -- if the player has the UI minimized do nothing
    local main_frame = todo.get_main_frame(player)
    if not main_frame then
        return
    end

    local task_table = todo.get_task_table(player)
    for i, element in ipairs(task_table.children) do
        if i > task_table.column_count then
            element.destroy()
        end
    end

    -- Filter and display open tasks
    local filtered_open = {}
    for _, task in ipairs(storage.todo.open) do
        if not search_term or search_term == "" or todo.task_matches_search(task, search_term) then
            table.insert(filtered_open, task)
        end
    end
    
    local open_length = #filtered_open
    for i, task in ipairs(filtered_open) do
        local expanded = todo.should_show_task_details(player, task.id)
        todo.add_task_to_table(player, task_table, task, false, i == 1, i == open_length, expanded)
    end    -- Filter and display completed tasks if enabled
    if (todo.show_completed_tasks(player)) then
        local filtered_done = {}
        for _, task in ipairs(storage.todo.done) do
            if not search_term or search_term == "" or todo.task_matches_search(task, search_term) then
                table.insert(filtered_done, task)
            end
        end
        
        for _, task in ipairs(filtered_done) do
            -- we don't want ordering for completed tasks
            local expanded = todo.should_show_task_details(player, task.id)
            todo.add_task_to_table(player, task_table, task, true, true, true, expanded)
        end
        
        -- Add "No results" message if no tasks found
        if search_term and search_term ~= "" and #filtered_open == 0 and #filtered_done == 0 then
            task_table.add({
                type = "label",
                caption = {"todo.no_results"},
                style = "todo_label_default"
            })
        end
    else
        -- Add "No results" message if no tasks found and completed tasks are hidden
        if search_term and search_term ~= "" and #filtered_open == 0 then
            task_table.add({
                type = "label",
                caption = {"todo.no_results"},
                style = "todo_label_default"
            })
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
    for _, task in pairs(storage.todo.open) do
        if task.assignee == player.name then
            todo.log(serpent.block(task))
            todo.get_maximize_button(player).caption = { "",
                                                         { todo.translate(player, "todo_list") },
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
        todo.get_maximize_button(player).caption = { todo.translate(player, "todo_list") }
    else
        todo.get_maximize_button(player).caption = { "", { todo.translate(player, "todo_list") }, ": ", { todo.translate(player, "tasks_available"), count } }
    end
end

function todo.on_toggle_show_completed_click(player)
    todo.toggle_show_completed(player)
    todo.refresh_task_table(player)
end

function todo.toggle_show_completed(player)
    if not storage.todo.settings[player.name] then
        storage.todo.settings[player.name] = {}
        storage.todo.settings[player.name].show_completed = true
    else
        storage.todo.settings[player.name].show_completed = not storage.todo.settings[player.name].show_completed
    end

    local frame = todo.get_main_frame(player)
    if (storage.todo.settings[player.name].show_completed) then
        frame.todo_main_button_flow.todo_toggle_show_completed_button.caption = { todo.translate(player, "hide_done") }
    else
        frame.todo_main_button_flow.todo_toggle_show_completed_button.caption = { todo.translate(player, "show_done") }
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

function todo.on_search_clear_click(player)
    local frame = todo.get_main_frame(player)
    if frame and frame.todo_search_flow then
        local search_field = frame.todo_search_flow.todo_search_field
        if search_field then
            search_field.text = ""
            todo.refresh_task_table(player, "")
        end
    end
end

-- Helper function to check if a task matches the search term
function todo.task_matches_search(task, search_term)
    if not search_term or search_term == "" then
        return true
    end
    
    search_term = string.lower(search_term)
    return string.find(string.lower(task.title or ""), search_term, 1, true) or 
           string.find(string.lower(task.task or ""), search_term, 1, true) or
           (task.subtasks and todo.subtasks_match_search(task.subtasks, search_term))
end

-- Helper function to check if any subtasks match the search term
function todo.subtasks_match_search(subtasks, search_term)
    if not subtasks then
        return false
    end
    
    -- Check open subtasks
    if subtasks.open then
        for _, subtask in ipairs(subtasks.open) do
            if string.find(string.lower(subtask.task or ""), search_term, 1, true) then
                return true
            end
        end
    end
    
    -- Check completed subtasks
    if subtasks.done then
        for _, subtask in ipairs(subtasks.done) do
            if string.find(string.lower(subtask.task or ""), search_term, 1, true) then
                return true
            end
        end
    end
    
    return false
end
