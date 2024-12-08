feature("#58 delete tasks", function()

    before_scenario(function()
        when(todo, "should_show_maximize_button"):then_return(true)
        when(todo, "show_completed_tasks"):then_return(true)

        todo.maximize_main_frame(game.players[1])
    end)

    after_scenario(function()
        todo.should_show_maximize_button:revert()
        todo.show_completed_tasks:revert()

        -- clear all tasks
        storage.todo.open = {}
        storage.todo.done = {}
    end)

    faketorio.confirm_task_deletion = function(player, id)
        faketorio.click('todo_open_edit_dialog_button_' .. id)

        local label = faketorio.find_element_by_id("todo_edit_delete_label", player)
        assert(label ~= nil)
        assert(label.caption[1] == "todo.delete")

        local button = faketorio.find_element_by_id("todo_edit_delete_button_" .. id, player)
        assert(button ~= nil)
        assert(button.caption[1] == "todo.delete")

        faketorio.click("todo_edit_delete_button_" .. id)

        local confirm_button = faketorio.find_element_by_id("todo_edit_confirm_deletion_button_" .. id, player)
        assert(confirm_button ~= nil)
        assert(confirm_button.caption[1] == "todo.confirm_deletion")

        faketorio.click("todo_edit_confirm_deletion_button_" .. id)

        assert(todo.get_task_by_id(id) == nil)

        local frame = todo.get_edit_dialog(player)
        assert(frame == nil, "Expected edit frame to be destroyed but it was found.")
    end

    scenario("delete single open task.", function()
        local player = game.players[1]

        local task_template = { ["task"] = "delete single open task", ["title"] = "single"}
        local task = todo.assemble_task(task_template, player)
        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        faketorio.confirm_task_deletion(player, task.id)

    end)

    scenario("delete second of three open tasks", function()
        local player = game.players[1]

        local task_template = { ["task"] = "delete second of three open task", ["title"] = "first"}

        todo.save_task_to_open_list(todo.assemble_task(task_template, player))

        task_template.title = "second"
        local task = todo.save_task_to_open_list(todo.assemble_task(task_template, player))

        task_template.title = "third"
        todo.save_task_to_open_list(todo.assemble_task(task_template, player))
        todo.refresh_task_table(player)

        faketorio.confirm_task_deletion(player, task.id)
    end)

    scenario("delete completed task", function()
        local player = game.players[1]

        local task_template = { ["task"] = "delete completed task", ["title"] = "completed"}
        local task = todo.save_task_to_open_list(todo.assemble_task(task_template, player))
        todo.mark_complete(task.id)
        todo.refresh_task_table(player)

        faketorio.confirm_task_deletion(player, task.id)
    end)

    scenario("delete second of three completed tasks.", function()
        local player = game.players[1]

        local task_template = { ["task"] = "delete second of three completed task", ["title"] = "first"}
        local first = todo.save_task_to_open_list(todo.assemble_task(task_template, player))

        task_template.title = "second"
        local second = todo.save_task_to_open_list(todo.assemble_task(task_template, player))

        task_template.title = "third"
        local third = todo.save_task_to_open_list(todo.assemble_task(task_template, player))

        todo.mark_complete(first.id)
        todo.mark_complete(second.id)
        todo.mark_complete(third.id)
        todo.refresh_task_table(player)

        faketorio.confirm_task_deletion(player, second.id)
    end)

    scenario("delete with mixed completed/uncompleted tasks.", function()
        local player = game.players[1]

        local task_template = { ["task"] = "delete mixed open/completed task", ["title"] = "first"}
        todo.save_task_to_open_list(todo.assemble_task(task_template, player))

        task_template.title = "second"
        local second = todo.save_task_to_open_list(todo.assemble_task(task_template, player))

        task_template.title = "third"
        local third = todo.save_task_to_open_list(todo.assemble_task(task_template, player))

        todo.mark_complete(second.id)
        todo.mark_complete(third.id)
        todo.refresh_task_table(player)

        faketorio.confirm_task_deletion(player, second.id)
    end)
end)
