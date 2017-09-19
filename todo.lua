require "mod-gui"

if not todo then todo = {} end

function todo.mod_init()
    game.print("setting up mod data.")

    if not global.todo then
        global.todo = {["open"] = {}, ["done"] = {}}
    end
end

function todo.create_ui(player)
    todo.log("Creating Basic UI for player " .. player.name)

    mod_gui.get_button_flow(player).add({
        type = "button",
        name = "todo_maximize_button",
        caption = "Todo List"
    })
end

function todo.minimize(player)
    todo.log("Minimizing UI for player " .. player.name)

    player.gui.left.mod_gui_flow.mod_gui_frame_flow.todo_main_frame.destroy()
    todo.create_ui(player)
end

function todo.maximize(player)
    todo.log("Maximizing UI for player " .. player.name)

    player.gui.left.mod_gui_flow.mod_gui_button_flow.todo_maximize_button.destroy()

    local frame = mod_gui.get_frame_flow(player).add({
        type = "frame",
        name = "todo_main_frame",
        caption = "Todo List",
        direction = "vertical"
    })

    todo.create_task_table(frame)

    local flow = frame.add({
        type = "flow",
        name = "todo.main_button_flow",
        direction = "horizontal"
    })

    flow.add({
        type = "button",
        name = "todo_add_button",
        caption = {"todo.add"}
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
        colspan = 3
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

    return table
end

function todo.add_new(player)
    local gui = player.gui.center

    local frame = gui.add({
        type = "frame",
        name = "todo_main_frame",
        caption = {"todo.add_title"},
        direction = "vertical"
    })

    local textbox = frame.add({
        type = "text-box",
        name = "todo_new_task_textbox"
    })
    textbox.style.minimal_width = 300
    textbox.style.minimal_height = 100

    frame.add({
        type = "button",
        name = "todo_persist_button",
        caption = {"todo.persist"}
    })
end

function todo.persist(element)
    local frame = element.parent

    local task = frame.todo_new_task_textbox.text

    todo.log("Persisting task:" .. task)

    table.insert(global.todo.open, {["task"] = task, ["assignee"] = nil, ["completed"] = false})

    todo.log(serpent.block(global.todo))
    frame.destroy()
end

function todo.update_task_table()
    for _, player in pairs(game.players) do
        todo.refresh_task_table(player)
    end
end

function todo.refresh_task_table(player)

    todo.log("Refreshing table...")

    -- if the player has the UI minimized do nothing
    if not player.gui.left.mod_gui_flow.mod_gui_frame_flow.todo_main_frame then
        todo.log("GUI minimized. Skipping.")
        return
    end

    local table = player.gui.left.mod_gui_flow.mod_gui_frame_flow.todo_main_frame.todo_task_table
    for i, element in ipairs(table.children) do
        if i > 3 then
            element.destroy()
        end
    end

    local players, lookup = todo.get_player_list(player)

    for i, task in ipairs(global.todo.open) do
        table.add({
            type = "checkbox",
            name = "todo_item_checkbox_" .. i,
            state = task.completed
        })

        table.add({
            type = "label",
            name = "todo_item_task_" .. i,
            caption = task.task,
            single_line = false
        })

        if (task.assignee) then
            table.add({
                type = "label",
                name = "todo_item_assignee_" .. i,
                caption = task.assignee
            })
        else
            table.add({
                type = "button",
                name = "todo_item_assign_self_" .. i,
                caption = {"todo.assign_self"}
            })
        end
    end

    todo.log("Refreshing table done.")
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
        local _, start = string.find(element.name, "todo_item_assign_self_")
        local index = tonumber(string.sub(element.name, start + 1))
        todo.log("Assigning task number " .. index .. " to player " .. player.name)
        global.todo.open[index].assignee = player.name
    else
        todo.log("Unknown element name:" .. element.name)
    end
end

function todo.log(message)
    if game then
        for _, p in pairs(game.players) do
            p.print(message)
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

