feature("#54 #57 button text behaviour", function()

    before_scenario(function()
        when(todo, "should_show_maximize_button"):then_return(true)
    end)

    after_scenario(function()
        todo.should_show_maximize_button:revert()

        -- clear all tasks
        global.todo.open = {}
        global.todo.done = {}
    end)

    scenario("Single line text should show up fully.", function()
        local player = game.players[1]

        local task_template = { ["task"] = "Single line", ["title"] = "first"}
        local task = todo.assemble_task(task_template, player)
        task.assignee = player.name
        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        local button = todo.get_maximize_button(player)
        assert(button.caption[1] == "")
        assert(button.caption[2] == "")
        assert(button.caption[3][1] == "todo.todo_list")
        assert(button.caption[4] == ": ")

        local text = button.caption[5]

        faketorio.log.info("Found text %s.", {text})

        assert(text == task.title)
    end)

    scenario("None assigned but tasks available", function()
        local player = game.players[1]

        local task_template = { ["task"] = "Single line", ["title"] = "first"}
        local task = todo.assemble_task(task_template, player)
        todo.save_task_to_open_list(task)
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
