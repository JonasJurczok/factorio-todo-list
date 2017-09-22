require "todo"

-- when creating a new game, initialize data structure
script.on_init(todo.mod_init)

-- When a player is joining, create the UI for them
script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    todo.create_ui(player)
end)

-- if the version of the mod or any other version changed
script.on_configuration_changed(todo.mod_init)

script.on_event(defines.events.on_gui_click, function(event)
    todo.on_gui_click(event)
end)

script.on_event(defines.events.on_tick, function(event)
    if (event.tick % 30 == 0) then
        todo.update_task_table()
    end
end)

script.on_event("todolist-toggle-ui", function(event)
    local player = game.players[event.player_index]
    if player.gui.left.mod_gui_flow.mod_gui_frame_flow.todo_main_frame then
        todo.minimize(player)
    else
        todo.maximize(player)
    end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    local player = game.players[event.player_index]
    if settings.get_player_settings(player)["todolist-show-minimized"].value then
        if not player.gui.left.mod_gui_flow.mod_gui_button_flow.todo_maximize_button then
            todo.create_ui(player)
        end
    else
        if player.gui.left.mod_gui_flow.mod_gui_button_flow.todo_maximize_button then
            player.gui.left.mod_gui_flow.mod_gui_button_flow.todo_maximize_button.destroy()
        end
    end
end)
