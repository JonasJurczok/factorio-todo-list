
mod_gui = require("mod-gui")
require "todo/todo"

-- when creating a new game, initialize data structure
script.on_init(todo.mod_init)

-- When a player is joining, create the UI for them
script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    todo.create_maximize_button(player)
end)

-- if the version of the mod or any other version changed
script.on_configuration_changed(function(_)
    todo.mod_init()
end)

script.on_event(defines.events.on_gui_click, function(event)
    todo.on_gui_click(event)
end)

script.on_event(defines.events.on_gui_closed, function(event)
    if event.element and event.element.name == "todo_main_frame" then
        local player = game.get_player(event.player_index)
        todo.on_add_cancel_click(player)
        todo.toggle_main_frame(player)
    end
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
    todo.on_lua_shortcut(event)
end)

script.on_event("todolist-toggle-ui", function(event)
    local player = game.players[event.player_index]
    todo.toggle_main_frame(player)
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    -- This can happen if the event was raised by a script.
    -- We don't expect this to affect us so we will just ignore it.
    if (event.player_index) then
      local player = game.players[event.player_index]
      local key = event.setting
      todo.on_runtime_mod_setting_changed(player, key)
    end
end)

