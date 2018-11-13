feature("#81 minimize main frame", function()

    before_scenario(function()
        when(todo, "should_show_maximize_button"):then_return(true)
        todo.maximize_main_frame(game.players[1])
    end)

    after_scenario(function()
        todo.should_show_maximize_button:revert()
        todo.minimize_main_frame(game.players[1])

        -- clear all tasks
        global.todo.open = {}
        global.todo.done = {}
    end)

    scenario("Minimize by main button click", function()

        faketorio.assert_element_exists("todo_main_frame", game.players[1])

        faketorio.click("todo_maximize_button")
        faketorio.assert_element_not_exists("todo_main_frame", game.players[1])

    end)

    scenario("Minimize by minimize button click", function()

        faketorio.click("todo_minimize_button")

        faketorio.assert_element_not_exists("todo_main_frame", game.players[1])
    end)

end)
