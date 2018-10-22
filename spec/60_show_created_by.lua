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

    scenario("A task has a creator/modifier", function()
        local player = game.players[1]

        local task = todo.create_task("Test")
        task.by = player.name
        todo.save_task(task)
        todo.refresh_task_table(player)

        todo.create_add_edit_frame(player, task)
        local frame = todo.get_add_edit_frame(player)

        assert(frame["todo_add_task_table"]["todo_by_playername"] == player.name)
        local text = frame["todo_add_task_table"]["todo_by_playername"]
        faketorio.log.info("Last editor: ", {text})
    end)
)