function todo.should_show_task_details(player, id)
    return global.todo.settings[player.name] and
            global.todo.settings[player.name].expanded_tasks and
            global.todo.settings[player.name].expanded_tasks[id] == true
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
    if not global.todo.settings[player.name] then
        global.todo.settings[player.name] = {}
    end

    if not global.todo.settings[player.name].expanded_tasks then
        global.todo.settings[player.name].expanded_tasks = {}
    end


    global.todo.settings[player.name].expanded_tasks[id] = value
end