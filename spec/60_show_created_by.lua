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

        local task = todo.create_task("Test", nil, player)
        todo.save_task(task)
        todo.refresh_task_table(player)

        todo.create_add_edit_frame(player, task)
        local frame = todo.get_add_edit_frame(player)
        local created_by = frame["todo_add_task_table"]["todo_created_by_playername"]
        local updated_by = frame["todo_add_task_table"]["todo_updated_by_playername"]
        
        assert(created_by == player.name)
        faketorio.log.info("Creator: ", {created_by})

        assert(todo_updated_by == player.name)
        faketorio.log.info("Last editor: ", {updated_by})
    end)

    scenario("Different player edits task", function()
        local player = game.players[1]
        local player1 = { ["name"] = "Tarrke" }
        local player2 = { ["name"] = "Jonas" }
        
        local task = todo.create_task("Test", nil, player1)
        todo.save_task(task)
        todo.refresh_task_table(player)

        todo.create_add_edit_frame(player, task)
        local frame = todo.get_add_edit_frame(player)
        assert(frame["todo_add_task_table"]["todo_created_by_playername"] == player1.name)

        -- Player2 update the task
        todo.update(frame["todo_add_task_table"]["todo_updated_by_playername"], 1, player2)
        todo.create_add_edit_frame(player, task)
        frame = todo.get_add_edit_frame(player)
        assert(frame["todo_add_task_table"]["todo_updated_by_playername"] == player2.name)
    end)
)