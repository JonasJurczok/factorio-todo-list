feature("#60 Show created/updated by", function()
    before_scenario(function()
        when(todo, "show_button"):then_return(true)
    end)

    after_scenario(function()
        todo.show_button:revert()

        -- clear all tasks
        global.todo.open = {}
        global.todo.done = {}
    end)

    scenario("A task has a creator and a modifier", function()
        local player = game.players[1]

        local task_template = { ["task"] = "Test", ["title"] = "Title", ["assignee"] = "def" }
        local task = todo.create_task(task_template, player)
        task.updated_by = player.name

        todo.save_task(task)
        todo.refresh_task_table(player)

        todo.create_add_edit_frame(player, task)
        local frame = todo.get_add_edit_frame(player)

        local created_by = frame["todo_add_task_table"]["todo_created_by_playername"]
        local updated_by = frame["todo_add_task_table"]["todo_updated_by_playername"]
        
        faketorio.log.info("Creator: %s", {created_by.caption})
        assert(created_by.caption == player.name)

        faketorio.log.info("Last editor: %s", {updated_by.caption})
        assert(updated_by.caption == player.name)
    end)

    scenario("Different player edits task", function()
        local player = game.players[1]
        local player1 = { ["name"] = "Tarrke" }
        local player2 = { ["name"] = "Jonas" }

        local task_template = { ["task"] = "Test", ["title"] = "Title", ["assignee"] = "def" }
        local task = todo.create_task(task_template, player1)
        todo.save_task(task)
        todo.refresh_task_table(player)

        todo.create_add_edit_frame(player, task)
        local frame = todo.get_add_edit_frame(player)
        local name_label = frame["todo_add_task_table"]["todo_created_by_playername"]
        assert(name_label.caption == player1.name)

        -- Player2 update the task
        todo.update(name_label, task.id, player2)
        todo.create_add_edit_frame(player, task)
        frame = todo.get_add_edit_frame(player)
        assert(frame["todo_add_task_table"]["todo_updated_by_playername"].caption == player2.name)
    end)
end)