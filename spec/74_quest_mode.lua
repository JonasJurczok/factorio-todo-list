feature("#74 quest mode", function()

    before_scenario(function()
        when(todo, "should_show_maximize_button"):then_return(true)
        when(todo, "get_player_translation_mode"):then_return("quest")
        todo.maximize_main_frame(game.players[1])
    end)

    after_scenario(function()
        todo.should_show_maximize_button:revert()
        todo.get_player_translation_mode:revert()
        todo.minimize_main_frame(game.players[1])

        -- clear all tasks
        global.todo.open = {}
        global.todo.done = {}
    end)

    scenario("Switching translation mode should change texts", function()
        local frame = todo.get_main_frame(game.players[1])
        local caption = frame.caption
        assert(caption[1] == "todo.quest_todo_list")
    end)

end)
