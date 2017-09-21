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
