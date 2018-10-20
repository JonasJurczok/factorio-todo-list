feature("#54 #57 button text behaviour", function()

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
        assert(button.caption[1] == "")
        assert(button.caption[2] == "")
        assert(button.caption[3][1] == "todo.todo_list")
        assert(button.caption[4] == ": ")

        local text = button.caption[5]

        faketorio.log.info("Found text %s.", {text})

        assert(string.find(text, task.task))
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
        assert(button.caption[1] == "")
        assert(button.caption[2] == "")
        assert(button.caption[3][1] == "todo.todo_list")
        assert(button.caption[4] == ": ")

        local text = button.caption[5]

        faketorio.log.info("Found text %s.", {text})

        assert(string.find(text, "Test"))
        assert(not string.find(text, "two"))
    end)

    scenario("None assigned but tasks available", function()
        local player = game.players[1]

        local task = todo.create_task("Test")
        todo.save_task(task)
        todo.refresh_task_table(player)

        local button = todo.get_maximize_button(player)
        faketorio.log.info("Found button %s", {serpent.dump(button.caption)})

        assert(button.caption[1] == "")
        assert(button.caption[2] == "")
        assert(button.caption[3][1] == "todo.todo_list")
        assert(button.caption[4] == ": ")
        assert(button.caption[5][1] == "todo.tasks_available")
    end)

    scenario("No tasks available", function()
        local player = game.players[1]
        todo.refresh_task_table(player)

        local button = todo.get_maximize_button(player)
        faketorio.log.info("Found button %s", {serpent.dump(button.caption)})

        assert(button.caption[1] == "todo.todo_list")
        assert(button.caption[2] == nil)
        assert(button.caption[3] == nil)
    end)
end)
