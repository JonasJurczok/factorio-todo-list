feature("#58 delete tasks", function()

    before_scenario(function()
        when(todo, "show_button"):then_return(true)
        todo.maximize(game.players[1])
        todo.toggle_show_completed(game.players[1])
    end)

    after_scenario(function()
        todo.show_button:revert()

        -- clear all tasks
        global.todo.open = {}
        global.todo.done = {}
        todo.toggle_show_completed(game.players[1])
    end)

    faketorio.confirm_task_deletion = function(player, id)
        faketorio.click('todo_item_edit_' .. id)

        local label = faketorio.find_element_by_id("todo_delete_label", player)
        assert(label ~= nil)
        assert(label.caption[1] == "todo.delete")

        local button = faketorio.find_element_by_id("todo_delete_button_" .. id, player)
        assert(button ~= nil)
        assert(button.caption[1] == "todo.delete")

        faketorio.click("todo_delete_button_" .. id)

        local confirm_button = faketorio.find_element_by_id("todo_confirm_deletion_button_" .. id, player)
        assert(confirm_button ~= nil)
        assert(confirm_button.caption[1] == "todo.confirm_deletion")

        faketorio.click("todo_confirm_deletion_button_" .. id)

        assert(todo.get_task_by_id(id) == nil)

        local gui = player.gui.center
        local frame = gui.todo_add_frame
        assert(frame == nil, "Expected edit frame to be destroyed but it was found.")
    end

    scenario("delete single open task.", function()
        local player = game.players[1]

        local task = todo.create_task("Test")
        todo.save_task(task)
        todo.refresh_task_table(player)

        faketorio.confirm_task_deletion(player, task.id)

    end)

    scenario("delete second of three open tasks", function()
        local player = game.players[1]

        todo.save_task(todo.create_task("First"))
        local task = todo.save_task(todo.create_task("Second"))
        todo.save_task(todo.create_task("Third"))
        todo.refresh_task_table(player)

        faketorio.confirm_task_deletion(player, task.id)

    end)

    scenario("delete completed task", function()
        local player = game.players[1]

        local task = todo.save_task(todo.create_task("Test"))
        todo.mark_complete(task.id)
        todo.refresh_task_table(player)

        faketorio.confirm_task_deletion(player, task.id)
    end)

    scenario("delete second of three completed tasks.", function()
        local player = game.players[1]

        local first = todo.save_task(todo.create_task("First"))
        local second = todo.save_task(todo.create_task("Second"))
        local third = todo.save_task(todo.create_task("Third"))
        todo.mark_complete(first.id)
        todo.mark_complete(second.id)
        todo.mark_complete(third.id)
        todo.refresh_task_table(player)

        faketorio.confirm_task_deletion(player, second.id)
    end)

    scenario("delete with mixed completed/uncompleted tasks.", function()
        local player = game.players[1]

        todo.save_task(todo.create_task("First"))
        local second = todo.save_task(todo.create_task("Second"))
        local third = todo.save_task(todo.create_task("Third"))
        todo.mark_complete(second.id)
        todo.mark_complete(third.id)
        todo.refresh_task_table(player)

        faketorio.confirm_task_deletion(player, second.id)
    end)
end)
