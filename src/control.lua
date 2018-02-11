
require "mod-gui"
require "todo/todo"

-- when creating a new game, initialize data structure
script.on_init(todo.mod_init)

-- When a player is joining, create the UI for them
script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    todo.create_minimized_button(player)
end)

-- if the version of the mod or any other version changed
script.on_configuration_changed(function(_)
    todo.mod_init()
end)

script.on_event(defines.events.on_gui_click, function(event)
    todo.on_gui_click(event)
end)

script.on_event("todolist-toggle-ui", function(event)
    local player = game.players[event.player_index]
    if todo.get_main_frame(player) then
        todo.minimize(player)
    else
        todo.maximize(player)
        todo.refresh_task_table(player)
    end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    local player = game.players[event.player_index]
    local key = event.setting
    todo.on_runtime_mod_setting_changed(player, key)
end)

require("faketorio/runner")