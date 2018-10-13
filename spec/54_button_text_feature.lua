feature("#54 button shows full task text", function()

    before_scenario(function()
        when(todo, "show_button"):then_return(true)
    end)

    after_scenario(function()
        todo.show_button:revert()

        -- clear all tasks
        global.todo.open = {}
        global.todo.done = {}
    end)

    scenario("Single line text should show up fully.", function()
        local player = game.players[1]

        local task = todo.create_task("Test")
        task.assignee = player.name
        todo.save_task(task)
        todo.refresh_task_table(player)

        local button = todo.get_maximize_button(player)
        local text = button.caption[3]

        faketorio.log.info("Found text %s.", {text})

        assert(string.find(text, "Test"))
    end)

    scenario("Multi line text should only show first line.", function()
        local player = game.players[1]

        local task_text = [[Test
        line two]]

        local task = todo.create_task(task_text)
        task.assignee = player.name
        todo.save_task(task)
        todo.refresh_task_table(player)

        local button = todo.get_maximize_button(player)
        local text = button.caption[3]

        faketorio.log.info("Found text %s.", {text})

        assert(string.find(text, "Test"))
        assert(not string.find(text, "two"))
    end)
end)
