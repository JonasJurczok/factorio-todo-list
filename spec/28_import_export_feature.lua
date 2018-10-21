feature("#28 import and export tasks", function()

    before_scenario(function()
        when(todo, "show_button"):then_return(true)
    end)

    after_scenario(function()
        todo.show_button:revert()

        -- clear all tasks
        global.todo.open = {}
        global.todo.done = {}
    end)

    scenario("Exporting and importing should work", function()

        -- create task
        -- assign self
        -- save
        -- export to string
        -- import same string
        -- check task duplication
        -- check second task has no assignee
    end)

end)
