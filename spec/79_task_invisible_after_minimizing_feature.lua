feature("#79 task invisible after minimizing UI", function()

    before_scenario(function()
        when(todo, "should_show_maximize_button"):then_return(true)
        todo.minimize_main_frame(game.players[1])
    end)

    after_scenario(function()
        todo.should_show_maximize_button:revert()

        -- clear all tasks
        storage.todo.open = {}
        storage.todo.done = {}
    end)

    scenario("Minimizing/maximizing after adding task should show task", function()

        faketorio.click("todo_maximize_button")
        faketorio.click("todo_open_add_dialog_button")
        faketorio.enter_text("todo_new_task_title", "invisible task single")
        faketorio.click("todo_save_new_task_button")

        faketorio.click("todo_minimize_button")
        faketorio.click("todo_maximize_button")

        local task = storage.todo.open[1]

        faketorio.assert_element_exists("todo_main_task_title_" .. task.id, game.players[1])
    end)

    scenario("Minimizing before saving task should show task", function()

        faketorio.click("todo_maximize_button")
        faketorio.click("todo_open_add_dialog_button")

        faketorio.click("todo_minimize_button")

        faketorio.enter_text("todo_new_task_title", "invisible task single")
        faketorio.click("todo_save_new_task_button")

        faketorio.click("todo_maximize_button")

        local task = storage.todo.open[1]

        faketorio.assert_element_exists("todo_main_task_title_" .. task.id, game.players[1])
    end)

end)
