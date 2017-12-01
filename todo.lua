if not todo then todo = {} end

require "mod-gui"
require "helper"
require "UI"

function todo.mod_init()
    todo.log("setting up mod data.")

    if not global.todo then
        global.todo = {["open"] = {}, ["done"] = {}, ["settings"] = {}}
    end

    for _, player in pairs(game.players) do
        todo.create_minimized_button(player)
    end
end

function todo.minimize(player)
    todo.log("Minimizing UI for player " .. player.name)

    todo.get_main_frame(player).destroy()
    todo.create_minimized_button(player)
end

function todo.maximize(player)
    todo.log("Maximizing UI for player " .. player.name)

    local max_button = todo.get_maximize_button(player)
    if max_button then
        max_button.destroy()
    end

    todo.create_maximized_frame(player)
end

function todo.persist(element)
    local frame = element.parent.parent

    local task = todo.get_task_from_add_frame(frame)

    table.insert(global.todo.open, task)

    todo.log(serpent.block(global.todo))
    frame.destroy()
end

function todo.update(element)
    local frame = element.parent.parent
    local _, start = string.find(element.name, "todo_update_button_")
    local index = tonumber(string.sub(element.name, start + 1))

    local task = todo.get_task_from_add_frame(frame)

    local original = global.todo.open[index]

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
    local assignee
    if (assignees.selected_index > 1) then
        assignee = assignees.items[assignees.selected_index]
    end

    local task = {["task"] = taskText, ["assignee"] = assignee}

    todo.log("Reading task " .. serpent.block(task))

    return task
end

function todo.edit_task(player, index)
    todo.create_add_edit_frame(player)

    local task = global.todo.open[index]
    local players, lookup = todo.get_player_list()
    local table = player.gui.center.todo_add_frame.todo_add_task_table

    table.children[2].text = task.task

    table.children[4].items = players
    if (task.assignee) then
        table.children[4].selected_index = lookup[task.assignee]
    else
        table.children[4].selected_index = 0
    end

    local flow = table.parent.todo_add_button_flow
    flow.todo_persist_button.destroy()

    flow.add({
        type = "button",
        name = "todo_update_button_" .. index,
        caption = {"todo.update"}
    })
end

function todo.update_task_table()
    for _, player in pairs(game.players) do
        todo.refresh_task_table(player)
    end
end

function todo.refresh_task_table(player)

    -- if the player has the UI minimized do nothing
    local main_frame = todo.get_main_frame(player)
    if not main_frame then
        return
    end

    local table = todo.get_task_table(player)
    for i, element in ipairs(table.children) do
        if i > 4 then
            element.destroy()
        end
    end

    for i, task in ipairs(global.todo.open) do
        todo.add_task_to_table(table, task, i, "", false)
    end

    if (global.todo.settings[player.name] and global.todo.settings[player.name].show_completed) then
        for i, task in ipairs(global.todo.done) do
            todo.add_task_to_table(table, task, i, "done_", true)
        end
    end
end

function todo.mark_complete(index)
    table.insert(global.todo.done, table.remove(global.todo.open, index))
end

function todo.mark_open(index)
    table.insert(global.todo.open, table.remove(global.todo.done, index))
end

function todo.toggle_show_completed(player)
    if not global.todo.settings[player.name] then
        global.todo.settings[player.name] = {}
        global.todo.settings[player.name].show_completed = false
    end

    global.todo.settings[player.name].show_completed = not global.todo.settings[player.name].show_completed

    local frame = todo.get_main_frame(player)
    if (global.todo.settings[player.name].show_completed) then
        frame.todo_main_button_flow.todo_toggle_done_button.caption = {"todo.hide_done"}
    else
        frame.todo_main_button_flow.todo_toggle_done_button.caption = {"todo.show_done"}
    end
end

function todo.on_gui_click(event)
    local player = game.players[event.player_index]
    local element = event.element

    if (element.name == "todo_maximize_button") then
        todo.maximize(player)
        todo.refresh_task_table(player)
    elseif (element.name == "todo_minimize_button") then
        todo.minimize(player)
    elseif (element.name == "todo_add_button") then
        todo.create_add_edit_frame(player)
    elseif (element.name == "todo_persist_button") then
        todo.persist(element)
        todo.update_task_table()
    elseif (string.find(element.name, "todo_item_assign_self_")) then
        local index = todo.get_task_index_from_element_name(element.name, "todo_item_assign_self_")

        todo.log("Assigning task number " .. index .. " to player " .. player.name)
        global.todo.open[index].assignee = player.name
        todo.update_task_table()
    elseif (string.find(element.name, "todo_item_edit_")) then
        local index = todo.get_task_index_from_element_name(element.name, "todo_item_edit_")

        todo.edit_task(player, index)
    elseif (string.find(element.name, "todo_update_button_")) then
        todo.update(element)
        todo.update_task_table()
    elseif (string.find(element.name, "todo_item_checkbox_done_")) then
        local index = todo.get_task_index_from_element_name(element.name, "todo_item_checkbox_done_")

        todo.mark_open(index)
        todo.update_task_table()
    elseif (string.find(element.name, "todo_item_checkbox_")) then
        local index = todo.get_task_index_from_element_name(element.name, "todo_item_checkbox_")

        todo.mark_complete(index)
        todo.update_task_table()
    elseif (element.name == "todo_toggle_done_button") then
        todo.toggle_show_completed(player)
        todo.refresh_task_table(player)
    elseif (element.name == "todo_cancel_button") then
        element.parent.parent.destroy()
        todo.refresh_task_table(player)
    else
        todo.log("Unknown element name:" .. element.name)
    end
end

function todo.on_runtime_mod_setting_changed(player, key)
    if (key == "todolist-show-minimized") then
        todo.on_show_minimized_changed(player)
    elseif (key == "todolist-show-log") then
        todo.log("Updated logging settings for player " .. player.name)
    end
end

function todo.on_show_minimized_changed(player)
    if todo.show_minimized(player) then
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