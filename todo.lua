require "mod-gui"

if not todo then todo = {} end

function todo.mod_init()
    game.print("setting up mod data.")
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

    local table = frame.add({
        type = "table",
        name = "todo_main_table",
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

    table.add({
        type = "checkbox",
        name = "todo_item_test1",
        state = false
    })
    table.add({
        type = "label",
        name = "todo_item_test2",
        caption = "This is some longer text as it should be when we are properly describing stuff."
    })
    table.add({
        type = "drop-down",
        name = "todo_item_test3",
        items = {"Test", "Test2"}
    })

    frame.add({
        type = "button",
        name = "todo_minimize_button",
        caption = {"todo.minimize"}
    })

end

function todo.on_gui_click(event)
    local player = game.players[event.player_index]
    local element = event.element

    if (element.name == "todo_maximize_button") then
        todo.maximize(player)
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