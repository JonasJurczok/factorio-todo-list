function todo.should_show_task_details(player, id)
    return storage.todo.settings[player.name] and
            storage.todo.settings[player.name].expanded_tasks and
            storage.todo.settings[player.name].expanded_tasks[id] == true
end

function todo.on_show_task_details_click(player, id)
    todo.set_show_task_details(player, id, true)

    todo.refresh_task_table(player)
end

function todo.on_hide_task_details_click(player, id)
    todo.set_show_task_details(player, id, nil)

    todo.refresh_task_table(player)
end

function todo.set_show_task_details(player, id, value)
    if not storage.todo.settings[player.name] then
        storage.todo.settings[player.name] = {}
    end

    if not storage.todo.settings[player.name].expanded_tasks then
        storage.todo.settings[player.name].expanded_tasks = {}
    end


    storage.todo.settings[player.name].expanded_tasks[id] = value
end