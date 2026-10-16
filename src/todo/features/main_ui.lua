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
    local main_frame = todo.get_main_frame(player)

    -- Resolve effective search term from UI when not provided
    if not search_term then
        search_term = ""
        if main_frame and main_frame.todo_search_flow then
            local search_field = main_frame.todo_search_flow.todo_search_field
            if search_field and search_field.valid then
                search_term = search_field.text
            end
        end
    end

    if search_term ~= "" then
        search_term = string.lower(search_term)
    end

    if (main_frame) then
        local table = todo.get_task_table(player)
        if table then
            table.clear()

            -- recreate headers
            table.add({
                type = "label",
                style = "todo_label_default",
                name = "todo_title_done",
                caption = { "", { "todo.title_done" }, "   " }
            })

            table.add({
                type = "label",
                style = "todo_label_default",
                name = "todo_title_task",
                caption = { todo.translate(player, "title_task") }
            })

            table.add({
                type = "label",
                style = "todo_label_default",
                name = "todo_title_assignee",
                caption = { todo.translate(player, "title_assignee") }
            })

            table.add({
                type = "label",
                style = "todo_label_default",
                name = "todo_title_top",
                caption = { todo.translate(player, "title_sort") }
            })

            table.add({
                type = "label",
                style = "todo_label_default",
                name = "todo_title_up",
                caption = ""
            })

            table.add({
                type = "label",
                style = "todo_label_default",
                name = "todo_title_down",
                caption = ""
            })

            table.add({
                type = "label",
                style = "todo_label_default",
                name = "todo_title_bottom",
                caption = ""
            })

            table.add({
                type = "label",
                style = "todo_label_default",
                name = "todo_title_edit",
                caption = { todo.translate(player, "title_edit") }
            })

            table.add({
                type = "label",
                style = "todo_label_default",
                name = "todo_title_details",
                caption = { "todo.title_details" }
            })

            -- Filter open tasks by search term
            local filtered_open = {}
            for _, task in ipairs(storage.todo.open) do
                if todo.task_matches_search(task, search_term) then
                    table.insert(filtered_open, task)
                end
            end

            local open_count = #filtered_open
            for i, task in ipairs(filtered_open) do
                todo.add_task_to_table(player, table, task, false, i == 1, i == open_count, task.expanded)
            end

            -- Filter completed tasks by search term
            if (todo.show_completed_tasks(player)) then
                local filtered_done = {}
                for _, task in ipairs(storage.todo.done) do
                    if todo.task_matches_search(task, search_term) then
                        table.insert(filtered_done, task)
                    end
                end

                local done_count = #filtered_done
                for i, task in ipairs(filtered_done) do
                    todo.add_task_to_table(player, table, task, true, i == 1, i == done_count, task.expanded)
                end
            end
        end
    end

    todo.update_current_task_label(player)
end

function todo.task_matches_search(task, search_term)
    if search_term == "" then
        return true
    end

    if string.find(string.lower(task.title), search_term, 1, true) then
        return true
    end

    if string.find(string.lower(task.task), search_term, 1, true) then
        return true
    end

    if task.assignee and string.find(string.lower(task.assignee), search_term, 1, true) then
        return true
    end

    if task.subtasks then
        for _, subtask in ipairs(task.subtasks.open) do
            if string.find(string.lower(subtask.task), search_term, 1, true) then
                return true
            end
        end
        for _, subtask in ipairs(task.subtasks.done) do
            if string.find(string.lower(subtask.task), search_term, 1, true) then
                return true
            end
        end
    end

    return false
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
    local gui = player.gui.top
    if gui.mod_gui_button_flow and gui.mod_gui_button_flow.todo_maximize_button then
        return gui.mod_gui_button_flow.todo_maximize_button
    end
    if gui.mod_gui_top_frame and gui.mod_gui_top_frame.mod_gui_inner_frame and gui.mod_gui_top_frame.mod_gui_inner_frame.todo_maximize_button then
        return gui.mod_gui_top_frame.mod_gui_inner_frame.todo_maximize_button
    end
    return nil
end

function todo.destroy_maximize_button(player)
    local button = todo.get_maximize_button(player)
    if button and button.valid then
        button.destroy()
    end

    local gui = player.gui.top
    if gui.mod_gui_top_frame and gui.mod_gui_top_frame.valid then
        local inner = gui.mod_gui_top_frame.mod_gui_inner_frame
        if inner and inner.valid and #inner.children == 0 then
            gui.mod_gui_top_frame.destroy()
        elseif not inner or not inner.valid then
            gui.mod_gui_top_frame.destroy()
        end
    end
    if gui.mod_gui_button_flow and gui.mod_gui_button_flow.valid and #gui.mod_gui_button_flow.children == 0 then
        gui.mod_gui_button_flow.destroy()
    end
end

function todo.on_search_clear_click(player)
    local frame = todo.get_main_frame(player)
    if frame and frame.todo_search_flow then
        local search_field = frame.todo_search_flow.todo_search_field
        if search_field and search_field.valid then
            search_field.text = ""
            todo.refresh_task_table(player, "")
        end
    end
end

function todo.update_export_dialog_button_state()
    local has_tasks = (#storage.todo.open > 0) or (#storage.todo.done > 0)
    for _, p in pairs(game.players) do
        local frame = todo.get_main_frame(p)
        if frame and frame.todo_main_button_flow and frame.todo_main_button_flow.todo_main_open_export_dialog_button then
            frame.todo_main_button_flow.todo_main_open_export_dialog_button.enabled = has_tasks
        end
    end
end
