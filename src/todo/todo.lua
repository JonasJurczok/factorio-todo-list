if not todo then todo = {} end

require "todo/helper"
require "todo/UI"
todo.json = require "todo/json"
todo.base64 = require "todo/base64"

function todo.mod_init()
    todo.log("setting up mod data.")

    if not global.todo then
        global.todo = {["open"] = {}, ["done"] = {}, ["settings"] = {}}
    else
        for _, task in ipairs(global.todo.open) do
            todo.init_ensure_task_fields(task)
        end

        for _, task in ipairs(global.todo.done) do
            todo.init_ensure_task_fields(task)
        end
    end

    for _, player in pairs(game.players) do
        todo.create_minimized_button(player)
    end
end

function todo.init_ensure_task_fields(task)
    if not task.id then
        task.id = todo.generate_id()
    end

    if not task.title then
        task.title = string.match(task.task, "[^\r\n]+")
    end
end

function todo.toggle_ui(player)
  if todo.get_main_frame(player) then
    todo.minimize(player)
  else
    todo.maximize(player)
    todo.refresh_task_table(player)
  end
end

function todo.minimize(player)
    todo.log("Minimizing UI for player " .. player.name)

    local frame = todo.get_main_frame(player)
    if frame then
        frame.destroy()
        return true
    end
    return false
end

function todo.maximize(player)
    todo.log("Maximizing UI for player " .. player.name)

    if not todo.get_main_frame(player) then
        todo.create_maximized_frame(player)
        return true
    end
    return false
end

function todo.save_task(task, should_add_to_top)
    local add_index = #global.todo.open + 1
    if should_add_to_top then
        add_index = 1
    end

    table.insert(global.todo.open, add_index, task)

    todo.update_export_dialog_button_state()

    return task
end

function todo.update_export_dialog_button_state()
    local task_count = #global.todo.open + #global.todo.done

    for _, player in pairs(game.players) do
        local main_frame = todo.get_main_frame(player)
        if (main_frame) then
            main_frame.todo_main_button_flow.todo_export_dialog_button.enabled = task_count > 0
        end

    end
end

function todo.generate_and_show_export_string(player)
    local dialog = todo.get_export_dialog(player)

    local tasks_table = dialog.todo_export_dialog_scroll_pane.todo_export_dialog_table

    local tasks = {}

    for i, checkbox in ipairs(tasks_table.children) do
        -- every uneven child is a textbox (lists start at 1)
        if (i % 2 == 1 and checkbox.state) then
            local id = todo.get_task_id_from_element_name(checkbox.name, "todo_export_select_")
            local task = todo.get_task_by_id(id)
            -- TODO: created by/last modified by and others
            -- Not sure you wana export the created by and stuff as the cretor may not be in the game at all...
            table.insert(tasks, { ["task"] = task.task, ["title"] = task.title })
        end
    end

    -- if no tasks are selected, remove the textbox
    if (#tasks == 0) then
        if (dialog.todo_export_dialog_string_flow.todo_export_string_textbox) then
            dialog.todo_export_dialog_string_flow.todo_export_string_textbox.destroy()
        end
        return
    end

    -- generate string
    local encoded = todo.base64.encode(todo.json:encode(tasks))

    if (dialog.todo_export_dialog_string_flow.todo_export_string_textbox) then
        dialog.todo_export_dialog_string_flow.todo_export_string_textbox.text = encoded
    else
        local textbox = dialog.todo_export_dialog_string_flow.add({
            type = "text-box",
            style = "todo_base64_textbox",
            name = "todo_export_string_textbox",
            text = encoded
        })
        textbox.word_wrap = true
    end
end

function todo.import_tasks(dialog, player)
    local encoded = dialog.todo_import_string_textbox.text

    local tasks = todo.json:decode(todo.base64.decode(encoded))

    todo.log("Importing tasks:")
    todo.log(tasks)

    for _, task_to_import in pairs(tasks) do
        local task = todo.create_task(task_to_import, player)
        todo.log(task)
        todo.save_task(task)
    end

    todo.log("Imported " .. #tasks .. " tasks.")

    todo.update_task_table()
end

function todo.persist(element, player)
    local frame = element.parent.parent

    local task_spec, should_add_to_top = todo.get_task_from_add_frame(frame)
    local task = todo.create_task(task_spec, player)

    -- Set the creator as last updator too
    task.updated_by = task.created_by
    todo.log("Saving task: " .. serpent.block(task))
    todo.save_task(task, should_add_to_top)

    todo.log(serpent.block(global.todo))
    frame.destroy()
end

function todo.update(element, index, player)
    local frame = element.parent.parent
    local task, _ = todo.get_task_from_add_frame(frame)

    local original = todo.get_task_by_id(index)

    original.title = task.title
    original.task = task.task
    if (task.assignee) then
        original.assignee = task.assignee
    else
        original.assignee = nil
    end

    -- Set the last updater
    original.updated_by = player.name
    todo.log("Current player is: " .. original.updated_by)

    frame.destroy()
end

function todo.get_task_from_add_frame(frame)
    local taskText = frame.todo_add_task_table["todo_new_task_textbox"].text
    local taskTitle = frame.todo_add_task_table["todo_new_task_title"].text

    local assignees = frame.todo_add_task_table["todo_add_assignee_drop_down"]
    local assignee
    if (assignees.selected_index > 1) then
        assignee = assignees.items[assignees.selected_index]
    end

    local should_add_to_top = false
    -- 'Add to Top' control won't exist in an edit dialog
    local add_top_control = frame.todo_add_task_table["todo_add_top"]
    if add_top_control and add_top_control.state then
        should_add_to_top = true
    end

    local task = {["title"] = taskTitle, ["task"] = taskText, ["assignee"] = assignee}

    todo.log("Reading task: " .. serpent.block(task))
    if should_add_to_top then
        todo.log("Adding it at the top.")
    end

    return task, should_add_to_top
end

--[[ Create task from a specification task. Specification task should have:
   - a title
   - a task field with the description
   - an assignee
]]--
function todo.create_task(task_spec, player)
    local task = {}
    task.id = todo.generate_id()
    task.title = task_spec.title
    task.task = task_spec.task
    task.assignee = task_spec.assignee
    task.created_by = player.name
    return task
end

function todo.update_task_table()
    for _, player in pairs(game.players) do
        todo.refresh_task_table(player)
    end
end

function todo.update_current_task_label(player)
    if not todo.get_maximize_button(player) then
        return
    end

    -- we may update the button label
    todo.log("updating button label")
    local count = 0
    for i, task in ipairs(global.todo.open) do
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

    if (global.todo.settings[player.name] and global.todo.settings[player.name].show_completed) then
        for _, task in ipairs(global.todo.done) do
            -- we don't want ordering for completed tasks
            todo.add_task_to_table(table, task, true, true, true)
        end
    end
end

function todo.mark_complete(id)
    todo.log("Marking task [" .. id .. "] as completed.")
    for i, task in ipairs(global.todo.open) do
        if (task.id == id) then
            local t = table.remove(global.todo.open, i)
            todo.log("Removed task from open list.")

            todo.log("Adding task [" .. t.id .. "] to done list.")
            table.insert(global.todo.done, t)
            break
        end
    end
end

function todo.mark_open(id)
    todo.log("Marking task [" .. id .. "] as open.")
    local t
    for i, task in ipairs(global.todo.done) do
        if (task.id == id) then
            t = table.remove(global.todo.done, i)
            todo.log("Removed task from done list.")
            break
        end
    end

    todo.log("Adding task [" .. t.id .. "] to open list.")
    table.insert(global.todo.open, t)
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
        frame.todo_main_button_flow.todo_toggle_done_button.caption = {"todo.hide_done"}
    else
        frame.todo_main_button_flow.todo_toggle_done_button.caption = {"todo.show_done"}
    end
end

function todo.move_up(id)
    todo.move(id, -1)
end

function todo.move_down(id)
    todo.move(id, 1)
end

function todo.move(id, modifier)
    for i, task in pairs(global.todo.open) do
        if (task.id == id) then
            local copy = global.todo.open[i + modifier]
            global.todo.open[i + modifier] = task
            global.todo.open[i] = copy
            break
        end
    end
end

function todo.move_top(id)
    local task = todo.get_task_by_id(id)
    local new_list = {task}
    global.todo.open =  todo.filter_table_by_id(global.todo.open, id, new_list)
end

function todo.move_bottom(id)
    local task = todo.get_task_by_id(id)
    local new_list = todo.filter_table_by_id(global.todo.open, id)
    new_list[#new_list + 1] = task
    global.todo.open = new_list
end

function todo.on_gui_click(event)
    local player = game.players[event.player_index]
    local element = event.element

    if (element.name == "todo_maximize_button") then
        todo.toggle_ui(player)
    elseif (element.name == "todo_minimize_button") then
        todo.minimize(player)
    elseif (element.name == "todo_add_button") then
        todo.create_add_edit_frame(player)
    elseif (element.name == "todo_persist_button") then
        todo.log("Creating task by player " .. player.name)
        todo.persist(element, player)
        todo.update_task_table()
    elseif (string.find(element.name, "todo_item_assign_self_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_item_assign_self_")

        todo.log("Assigning task number " .. id .. " to player " .. player.name)
        local task = todo.get_task_by_id(id)
        task.assignee = player.name
        todo.update_task_table()
    elseif (string.find(element.name, "todo_item_edit_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_item_edit_")
        local task = todo.get_task_by_id(id)
        todo.create_add_edit_frame(player, task)
    elseif (string.find(element.name, "todo_item_task_")) then
        local setting_value = settings.get_player_settings(player)["todolist-click-edit-task"].value
        local setting_button = nil
        if setting_value == "right-button" then
            setting_button = defines.mouse_button_type.right
        elseif setting_value == "middle-button" then
            setting_button = defines.mouse_button_type.middle
        end
        if event.button == setting_button then
            local add_edit_frame = todo.get_add_edit_frame(player)
            if add_edit_frame then
                add_edit_frame.destroy()
            else
                local id = todo.get_task_id_from_element_name(element.name, "todo_item_task_")
                local task = todo.get_task_by_id(id)
                todo.create_add_edit_frame(player, task)
            end
        end
    elseif (string.find(element.name, "todo_update_button_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_update_button_")

        todo.update(element, id, player)
        todo.update_task_table()
    elseif (string.find(element.name, "todo_item_checkbox_done_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_item_checkbox_done_")

        todo.mark_open(id)
        todo.update_task_table()
    elseif (string.find(element.name, "todo_item_checkbox_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_item_checkbox_")

        todo.mark_complete(id)
        todo.update_task_table()
    elseif (element.name == "todo_toggle_done_button") then
        todo.toggle_show_completed(player)
        todo.refresh_task_table(player)
    elseif (element.name == "todo_cancel_button") then
        -- close the edit dialog
        element.parent.parent.destroy()
        todo.refresh_task_table(player)
    elseif (string.find(element.name, "todo_delete_button")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_delete_button_")

        todo.create_delete_confirmation_button(element, id)
    elseif (string.find(element.name, "todo_confirm_deletion_button")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_confirm_deletion_button_")

        todo.delete_task(id)
        -- close the edit dialog
        element.parent.parent.destroy()
        todo.update_export_dialog_button_state()
        todo.update_task_table()
    elseif (string.find(element.name, "todo_item_up_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_item_up_")
        todo.move_up(id)
        todo.update_task_table()
    elseif (string.find(element.name, "todo_item_down_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_item_down_")
        todo.move_down(id)
        todo.update_task_table()
    elseif (string.find(element.name, "todo_item_top_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_item_top_")
        todo.log('Moving task ' .. id .. ' to top.')
        todo.move_top(id)
        todo.update_task_table()
    elseif (string.find(element.name, "todo_item_bottom_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_item_bottom_")
        todo.log('Moving task ' .. id .. ' to bottom.')
        todo.move_bottom(id)
        todo.update_task_table()
    elseif (element.name == "todo_export_dialog_button") then
        todo.create_export_dialog(player)
    elseif (element.name == "todo_export_button") then
        todo.generate_and_show_export_string(player)
    elseif (element.name == "todo_export_cancel_button") then
        -- close the export dialog
        element.parent.parent.destroy()
    elseif (element.name == "todo_import_dialog_button") then
        todo.create_import_dialog(player)
    elseif (element.name == "todo_import_button") then
        local dialog = element.parent.parent
        todo.import_tasks(dialog, player)
        dialog.destroy()
    elseif (element.name == "todo_import_cancel_button") then
        -- close the import dialog
        element.parent.parent.destroy()
    elseif (string.find(element.name, "todo_")) then
        todo.log("Unknown todo element name:" .. element.name)
    end
end

function todo.on_runtime_mod_setting_changed(player, key)
    if (key == "todolist-show-button") then
        todo.on_show_button_changed(player)
    elseif (key == "todolist-show-log") then
        todo.log("Updated logging settings for player " .. player.name)
    elseif (key == "todolist-auto-assign") then
        todo.log("Changed auto-assign...")
    elseif (key == "todolist-click-edit-task") then
        todo.log("Changed button click to open edit frame...")
    end
end

function todo.on_show_button_changed(player)
    if todo.show_button(player) then
        todo.log("Showing minimized button.")
        if not todo.get_maximize_button(player) then
            todo.create_minimized_button(player)
        end
    else
        todo.log("Hiding minimized button.")
        local max_button = todo.get_maximize_button(player)
        if max_button then
            max_button.destroy()
        end
    end
end
