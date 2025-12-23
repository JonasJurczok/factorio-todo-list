feature("#35 show details view for task", function()

    before_scenario(function()
        when(todo, "should_show_maximize_button"):then_return(true)
        todo.maximize_main_frame(game.players[1])
    end)

    after_scenario(function()
        todo.should_show_maximize_button:revert()

        -- clear all tasks
        storage.todo.open = {}
        storage.todo.done = {}
    end)

    scenario("details header should be displayed", function()
        local player = game.players[1]

        local task_template = { ["task"] = "details view for single task", ["title"] = "single"}
        local task = todo.assemble_task(task_template, player)
        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        local title = faketorio.assert_element_exists("todo_title_details", player)
        assert(title.caption[1] == "todo.title_details")

        local expand_button = faketorio.assert_element_exists("todo_main_open_details_button_" .. task.id, player)
        assert(expand_button.sprite == "__Todo-List__/graphics/expand.png")
        assert(expand_button.tooltip[1] == "todo.title_details")
    end)

    scenario("clicking details button should expand task", function()
        -- also check that the correct button is drawn
        local player = game.players[1]

        local task_template = { ["task"] = "details view for single task", ["title"] = "single"}
        local task = todo.assemble_task(task_template, player)
        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        faketorio.click("todo_main_open_details_button_" .. task.id, player)

        faketorio.assert_element_not_exists("todo_main_open_details_button_" .. task.id, player)

        local close_details_button = faketorio.assert_element_exists("todo_main_close_details_button_" .. task.id, player)
        assert(close_details_button.sprite == "__Todo-List__/graphics/collapse.png")
        assert(close_details_button.tooltip[1] == "todo.title_details")

        local task_field = faketorio.assert_element_exists("todo_main_expanded_task_label_" .. task.id, player)
        assert(task_field.caption == task.task)
    end)

    scenario("clicking details button should expand task for completed task", function()
        -- also check that the correct button is drawn
        local player = game.players[1]

        local task_template = { ["task"] = "details view for single task", ["title"] = "single"}
        local task = todo.assemble_task(task_template, player)
        todo.save_task_to_open_list(task)
        todo.mark_complete(task.id)
        faketorio.click("todo_toggle_show_completed_button", player)
        todo.refresh_task_table(player)

        faketorio.click("todo_main_open_details_button_" .. task.id, player)

        faketorio.assert_element_not_exists("todo_main_open_details_button_" .. task.id, player)

        local close_details_button = faketorio.assert_element_exists("todo_main_close_details_button_" .. task.id, player)
        assert(close_details_button.sprite == "__Todo-List__/graphics/collapse.png")
        assert(close_details_button.tooltip[1] == "todo.title_details")

        local task_field = faketorio.assert_element_exists("todo_main_expanded_task_label_" .. task.id, player)
        assert(task_field.caption == task.task)
    end)

    scenario("multiple details views should be open at the same time", function()
        -- also check that the correct button is drawn
        local player = game.players[1]

        local task_template = { ["task"] = "details view for multiple tasks", ["title"] = "task 1"}
        local task1 = todo.assemble_task(task_template, player)
        todo.save_task_to_open_list(task1)

        task_template.title = "task 2"
        local task2 = todo.assemble_task(task_template, player)
        todo.save_task_to_open_list(task2)

        todo.refresh_task_table(player)

        faketorio.click("todo_main_open_details_button_" .. task1.id, player)
        faketorio.click("todo_main_open_details_button_" .. task2.id, player)

        faketorio.assert_element_not_exists("todo_main_open_details_button_" .. task1.id, player)
        faketorio.assert_element_not_exists("todo_main_open_details_button_" .. task2.id, player)

        local close_details_button_1 = faketorio.assert_element_exists("todo_main_close_details_button_" .. task1.id, player)
        assert(close_details_button_1.sprite == "__Todo-List__/graphics/collapse.png")
        assert(close_details_button_1.tooltip[1] == "todo.title_details")

        local close_details_button_2 = faketorio.assert_element_exists("todo_main_close_details_button_" .. task2.id, player)
        assert(close_details_button_2.sprite == "__Todo-List__/graphics/collapse.png")
        assert(close_details_button_2.tooltip[1] == "todo.title_details")

        local task_field_1 = faketorio.assert_element_exists("todo_main_expanded_task_label_" .. task1.id, player)
        assert(task_field_1.caption == task1.task)

        local task_field_2 = faketorio.assert_element_exists("todo_main_expanded_task_label_" .. task2.id, player)
        assert(task_field_2.caption == task1.task)
    end)

    scenario("closing details view should work", function()
        local player = game.players[1]

        local task_template = { ["task"] = "details view for single task", ["title"] = "single"}
        local task = todo.assemble_task(task_template, player)
        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        faketorio.click("todo_main_open_details_button_" .. task.id, player)
        faketorio.click("todo_main_close_details_button_" .. task.id, player)

        faketorio.assert_element_exists("todo_main_open_details_button_" .. task.id, player)
        faketorio.assert_element_not_exists("todo_main_close_details_button_" .. task.id, player)

        faketorio.assert_element_not_exists("todo_main_expanded_task_label_" .. task.id, player)
    end)
end)
