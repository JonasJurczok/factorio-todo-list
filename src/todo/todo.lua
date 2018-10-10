if not todo then todo = {} end

require "todo/helper"
require "todo/UI"

function todo.mod_init()
    todo.log("setting up mod data.")

    if not global.todo then
        global.todo = {["open"] = {}, ["done"] = {}, ["settings"] = {}}
    else
        for _, task in ipairs(global.todo.open) do
            if not task.id then
                task.id = todo.generate_id()
            end
        end

        for _, task in ipairs(global.todo.done) do
            if not task.id then
                task.id = todo.generate_id()
            end
        end
    end

    for _, player in pairs(game.players) do
        todo.create_minimized_button(player)
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

    return task
end

function todo.persist(element)
    local frame = element.parent.parent

    local task_spec, should_add_to_top = todo.get_task_from_add_frame(frame)
    local task = todo.create_task(task_spec.task, task_spec.assignee)

    todo.save_task(task, should_add_to_top)

    todo.log(serpent.block(global.todo))
    frame.destroy()
end

function todo.update(element, index)
    local frame = element.parent.parent
    local task, _ = todo.get_task_from_add_frame(frame)

    local original = todo.get_task_by_id(index)

    original.task = task.task
    if (task.assignee) then
        original.assignee = task.assignee
    else
        original.assignee = nil
    end

    frame.destroy()
end

function todo.get_task_from_add_frame(frame)
    local taskText = frame.todo_add_task_table.children[2].text

    local assignees = frame.todo_add_task_table.children[4]
    local assignee = nil
    if (assignees.selected_index > 1) then
        assignee = assignees.items[assignees.selected_index]
    end

    local should_add_to_top = false
    -- 'Add to Top' control won't exist in an edit dialog
    local add_top_control = frame.todo_add_button_flow.todo_add_top
    if add_top_control and add_top_control.state then
        should_add_to_top = true
    end

    local task = {["task"] = taskText, ["assignee"] = assignee}

    todo.log("Reading task " .. serpent.block(task))
    if should_add_to_top then
        todo.log("Adding it at the top.")
    end

    return task, should_add_to_top
end

function todo.create_task(text, assignee)
    local task = {}
    task.id = todo.generate_id()
    task.task = text
    task.assignee = assignee
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
    for _, task in ipairs(global.todo.open) do
        if task.assignee == player.name then
            todo.log(serpent.block(task))
            todo.get_maximize_button(player).caption =
                {"todo.todo_maximize_button_caption", {"todo.todo_list"}, string.gmatch(task.task, "%S+")()}
            return
        end
    end
    todo.get_maximize_button(player).caption =
        {"todo.todo_maximize_button_caption", {"todo.todo_list"}, {"todo.nothing_todo"}}
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
    local t
    for i, task in ipairs(global.todo.open) do
        if (task.id == id) then
            t = table.remove(global.todo.open, i)
            todo.log("Removed task from open list.")
            break
        end
    end

    todo.log("Adding task [" .. t.id .. "] to done list.")
    table.insert(global.todo.done, t)
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
        todo.persist(element)
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

        todo.update(element, id)
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
        element.parent.parent.destroy()
        todo.refresh_task_table(player)
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
