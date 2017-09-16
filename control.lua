require "todo"

-- when creating a new game, initialize data structure
script.on_init(todo.mod_init)

-- When a player is joining, create the UI for them
script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    todo.create_ui(player)
end)

-- TODO: on configuration changed

script.on_event(defines.events.on_gui_click, function(event)
    todo.on_gui_click(event)
end)