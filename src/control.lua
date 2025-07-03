
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
        todo.on_edit_cancel_click(player)
        todo.on_import_cancel_click(player)
        todo.on_export_cancel_click(player)
        todo.destroy_clean_dialog(player)
        todo.destroy_clean_confirm_dialog(player)
        todo.minimize_main_frame(player)
    elseif event.element and event.element.name == "todo_add_dialog" then
        local player = game.get_player(event.player_index)
        todo.on_add_cancel_click(player)
    elseif event.element and event.element.name == "todo_edit_dialog" then
        local player = game.get_player(event.player_index)
        todo.on_edit_cancel_click(player)
    end
end)

script.on_event(defines.events.on_gui_confirmed, function(event)
    todo.on_gui_confirmed(event)
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

-- For the search field changes
script.on_event(defines.events.on_gui_text_changed, function(event)
    local element = event.element
    if element.name == "todo_search_field" then
        local player = game.players[event.player_index]
        local search_term = element.text
        todo.refresh_task_table(player, search_term)
    end
end)

-- Clear search on ESC when search field is focused
script.on_event(defines.events.on_gui_confirmed, function(event)
    local element = event.element
    if element.name == "todo_search_field" then
        local player = game.players[event.player_index]
        element.text = ""
        todo.refresh_task_table(player, "")
    end
end)

-- For Ctrl+F shortcut
script.on_event("todo-search-shortcut", function(event)
    local player = game.players[event.player_index]
    local frame = todo.get_main_frame(player)

    -- If UI is minimized, maximize it first
    if not frame then
        todo.maximize_main_frame(player)
        frame = todo.get_main_frame(player)
    end

    if frame then
        local search_field = frame.todo_search_flow.todo_search_field
        if search_field then
            search_field.focus()
        end
    end
end)
