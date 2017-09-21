require "mod-gui"

if not todo then todo = {} end

function todo.mod_init()
    todo.log("setting up mod data.")

    if not global.todo then
        global.todo = {["open"] = {}, ["done"] = {}, ["settings"] = {}}
    end

    for _, player in pairs(game.players) do
        todo.create_ui(player)
    end
end

function todo.create_ui(player)
    todo.log("Creating Basic UI for player " .. player.name)

    if not player.gui.left.mod_gui_flow.mod_gui_button_flow.todo_maximize_button and not player.gui.left.mod_gui_flow.mod_gui_frame_flow.todo_main_frame and settings.get_player_settings(player)["todolist-show-minimized"].value then
        mod_gui.get_button_flow(player).add({
            type = "button",
            name = "todo_maximize_button",
            caption = "Todo List"
        })
    end
end

function todo.minimize(player)
    todo.log("Minimizing UI for player " .. player.name)

    player.gui.left.mod_gui_flow.mod_gui_frame_flow.todo_main_frame.destroy()
    todo.create_ui(player)
end

function todo.maximize(player)
    todo.log("Maximizing UI for player " .. player.name)

    if player.gui.left.mod_gui_flow.mod_gui_button_flow.todo_maximize_button then
      player.gui.left.mod_gui_flow.mod_gui_button_flow.todo_maximize_button.destroy()
    end

    local frame = mod_gui.get_frame_flow(player).add({
        type = "frame",
        name = "todo_main_frame",
        caption = "Todo List",
        direction = "vertical"
    })

    todo.create_task_table(frame)

    local flow = frame.add({
        type = "flow",
        name = "todo_main_button_flow",
        direction = "horizontal"
    })

    flow.add({
        type = "button",
        name = "todo_add_button",
        caption = {"todo.add"}
    })

    flow.add({
        type = "button",
        name = "todo_toggle_done_button",
        caption = {"todo.show_done"}
    })

    flow.add({
        type = "button",
        name = "todo_minimize_button",
        caption = {"todo.minimize"}
    })

end

function todo.create_task_table(frame)
    local table = frame.add({
        type = "table",
        name = "todo_task_table",
        colspan = 4
    })

    table.add({
        type = "label",
        name = "todo_title_done",
        caption = {"", {"todo.title_done"}, "   "}
    })

    table.add({
        type = "label",
        name = "todo_title_task",
        caption = {"todo.title_task"}
    })
    table.add({
        type = "label",
        name = "todo_title_assignee",
        caption = {"todo.title_assignee"}
    })
    table.add({
        type = "label",
        name = "todo_title_edit",
        caption = ""
    })

    return table
end

function todo.add_new(player)
    local gui = player.gui.center

    local frame = gui.add({
        type = "frame",
        name = "todo_add_frame",
        caption = {"todo.add_title"},
        direction = "vertical"
    })

    local table = frame.add({
        type = "table",
        name = "todo_add_task_table",
        colspan = 2
    })

    table.add({
        type = "label",
        name = "todo_add_task_label",
        caption = {"todo.add_task"}
    })

    local textbox = table.add({
        type = "text-box",
        name = "todo_new_task_textbox"
    })
    textbox.style.minimal_width = 300
    textbox.style.minimal_height = 100

    table.add({
        type = "label",
        name = "todo_add_assignee_label",
        caption = {"todo.add_assignee"}
    })


    local players, _ = todo.get_player_list()
    table.add({
        type = "drop-down",
        name = "todo_add_assignee_drop_down",
        items = players,
        selected_index = 1
    })

    local flow = frame.add({
        type = "flow",
        name = "todo_add_button_flow",
        direction = "horizontal"
    })

    flow.add({
        type = "button",
        name = "todo_cancel_button",
        caption = {"todo.cancel"}
    })

    flow.add({
        type = "button",
        name = "todo_persist_button",
        caption = {"todo.persist"}
    })
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
    todo.add_new(player)

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
    if not player.gui.left.mod_gui_flow.mod_gui_frame_flow.todo_main_frame then
        return
    end

    local table = player.gui.left.mod_gui_flow.mod_gui_frame_flow.todo_main_frame.todo_task_table
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

function todo.add_task_to_table(table, task, index, prefix, completed)
    table.add({
        type = "checkbox",
        name = "todo_item_checkbox_" .. prefix .. index,
        state = completed
    })

    table.add({
        type = "label",
        name = "todo_item_task_" .. prefix .. index,
        caption = task.task,
        single_line = false
    })

    if (task.assignee) then
        table.add({
            type = "label",
            name = "todo_item_assignee_" .. prefix .. index,
            caption = task.assignee
        })
    else
        table.add({
            type = "button",
            name = "todo_item_assign_self_" .. prefix .. index,
            caption = {"todo.assign_self"}
        })
    end

    table.add({
        type = "button",
        name = "todo_item_edit_" .. prefix .. index,
        caption = {"todo.title_edit"}
    })

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

    if (global.todo.settings[player.name].show_completed) then
        player.gui.left.mod_gui_flow.mod_gui_frame_flow.todo_main_frame.todo_main_button_flow.todo_toggle_done_button.caption = {"todo.hide_done"}
    else
        player.gui.left.mod_gui_flow.mod_gui_frame_flow.todo_main_frame.todo_main_button_flow.todo_toggle_done_button.caption = {"todo.show_done"}
    end

end

function todo.on_gui_click(event)
    local player = game.players[event.player_index]
    local element = event.element

    if (element.name == "todo_maximize_button") then
        todo.maximize(player)
    elseif (element.name == "todo_minimize_button") then
        todo.minimize(player)
    elseif (element.name == "todo_add_button") then
        todo.add_new(player)
    elseif (element.name == "todo_persist_button") then
        todo.persist(element)
    elseif (string.find(element.name, "todo_item_assign_self_")) then
        local index = todo.get_task_index_from_element_name(element.name, "todo_item_assign_self_")

        todo.log("Assigning task number " .. index .. " to player " .. player.name)
        global.todo.open[index].assignee = player.name
    elseif (string.find(element.name, "todo_item_edit_")) then
        local index = todo.get_task_index_from_element_name(element.name, "todo_item_edit_")

        todo.edit_task(player, index)
    elseif (string.find(element.name, "todo_update_button_")) then
        todo.update(element)
    elseif (string.find(element.name, "todo_item_checkbox_done_")) then
        local index = todo.get_task_index_from_element_name(element.name, "todo_item_checkbox_done_")

        todo.mark_open(index)
    elseif (string.find(element.name, "todo_item_checkbox_")) then
        local index = todo.get_task_index_from_element_name(element.name, "todo_item_checkbox_")

        todo.mark_complete(index)
    elseif (element.name == "todo_toggle_done_button") then
        todo.toggle_show_completed(player)
    elseif (element.name == "todo_cancel_button") then
        element.parent.parent.destroy()
    else
        todo.log("Unknown element name:" .. element.name)
    end
end

function todo.get_task_index_from_element_name(name, pattern)
    local _, start = string.find(name, pattern)
    local index = tonumber(string.sub(name, start + 1))
    return index
end

function todo.log(message)
    return
    -- TODO: add settings to enable logging per player
    --[[if game then
        for _, p in pairs(game.players) do
            p.print(message)
        end
    else
        error(serpent.dump(message, {compact = false, nocode = true, indent = ' '}))
    end
    ]]--
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

