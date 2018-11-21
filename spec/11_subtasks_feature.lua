feature("#11 subtasks", function()

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

    scenario("Adding subtask should work", function()
        local player = game.players[1]

        local task_template = { ["task"] = "Adding subtasks", ["title"] = "single subtask"}
        local task = todo.assemble_task(task_template, player)
        task.assignee = player.name
        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        -- click expand details
        faketorio.click("todo_main_open_details_button_" .. task.id)

        -- add subtasks
        faketorio.enter_text("todo_main_subtask_new_text_" .. task.id, "New Subtask")
        faketorio.click("todo_main_subtask_save_new_button_" .. task.id)

        faketorio.enter_text("todo_main_subtask_new_text_" .. task.id, "New Subtask 2")
        faketorio.click("todo_main_subtask_save_new_button_" .. task.id)

        faketorio.enter_text("todo_main_subtask_new_text_" .. task.id, "New Subtask 3")
        faketorio.click("todo_main_subtask_save_new_button_" .. task.id)

        -- assert subtask exists in task
        assert(task.subtasks ~= nil)
        assert(task.subtasks.open ~= nil)
        assert(#task.subtasks.open == 3)

        assert(task.subtasks.open[1].task == "New Subtask")
        assert(task.subtasks.open[2].task == "New Subtask 2")
        assert(task.subtasks.open[3].task == "New Subtask 3")

        -- assert subtask is shown in UI
        local subtask = task.subtasks.open[1]
        local checkbox = faketorio.assert_element_exists("todo_main_subtask_checkbox_" .. task.id .. "_" .. subtask.id, player)
        assert(checkbox.caption == subtask.task)
        assert(checkbox.state == false)

        faketorio.assert_element_exists("todo_main_subtask_edit_button_" .. task.id .. "_" .. subtask.id, player)
        faketorio.assert_element_exists("todo_main_subtask_delete_button_" .. task.id .. "_" .. subtask.id, player)

        faketorio.assert_element_not_exists("todo_main_subtask_up_button_" .. task.id .. "_" .. subtask.id, player)
        faketorio.assert_element_not_exists("todo_main_subtask_down_button_" .. task.id .. "_" .. subtask.id, player)
    end)

    scenario("Completing subtask should work", function()
        local player = game.players[1]

        local task_template = { ["task"] = "Completing subtasks", ["title"] = "single subtask"}
        local task = todo.assemble_task(task_template, player)
        task.assignee = player.name
        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        -- click expand details
        faketorio.click("todo_main_open_details_button_" .. task.id)

        -- TODO: programmatically create subtasks. Going through the UI all the time is not necessary and confusing.
        faketorio.enter_text("todo_main_subtask_new_text_" .. task.id, "New Subtask")
        faketorio.click("todo_main_subtask_save_new_button_" .. task.id)
        local subtask = task.subtasks.done[1]

        -- because of https://github.com/JonasJurczok/faketorio/issues/66 we click the checkbox after checking it
        faketorio.check("todo_main_subtask_checkbox_" .. task.id .. "_" .. subtask.id)
        faketorio.click("todo_main_subtask_checkbox_" .. task.id .. "_" .. subtask.id)


        assert(#task.subtasks.open == 0)
        assert(#task.subtasks.done == 1)
        assert(subtask.task == "New Subtask")

        todo.refresh_task_table(player)
        faketorio.assert_checked("todo_main_subtask_checkbox_" .. task.id .. "_" .. subtask.id)
    end)

    scenario("Uncompleting subtasks should work", function()
        local player = game.players[1]

        local task_template = { ["task"] = "Uncompleting subtasks", ["title"] = "single subtask"}
        local task = todo.assemble_task(task_template, player)
        task.assignee = player.name
        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        faketorio.click("todo_main_open_details_button_" .. task.id)
        faketorio.enter_text("todo_main_subtask_new_text_" .. task.id, "New Subtask")
        faketorio.click("todo_main_subtask_save_new_button_" .. task.id)
        local subtask = task.subtasks.done[1]

        -- because of https://github.com/JonasJurczok/faketorio/issues/66 we click the checkbox after checking it
        faketorio.check("todo_main_subtask_checkbox_" .. task.id .. "_" .. subtask.id)
        faketorio.click("todo_main_subtask_checkbox_" .. task.id .. "_" .. subtask.id)

        faketorio.assert_checked("todo_main_subtask_checkbox_" .. task.id .. "_" .. subtask.id)

        faketorio.uncheck("todo_main_subtask_checkbox_" .. task.id .. "_" .. subtask.id)
        faketorio.click("todo_main_subtask_checkbox_" .. task.id .. "_" .. subtask.id)

        assert(#task.subtasks.done == 0)
        assert(#task.subtasks.open == 1)
        assert(task.subtasks.open[1] == "New Subtask")

        todo.refresh_task_table(player)
        faketorio.assert_unchecked("todo_main_subtask_checkbox_" .. task.id .. "_" .. subtask.id)
    end)

    scenario("Deleting completed subtasks should work", function()
        local player = game.players[1]

        local task_template = { ["task"] = "Deleting subtasks", ["title"] = "single subtask"}
        local task = todo.assemble_task(task_template, player)
        task.assignee = player.name
        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        -- click expand details
        faketorio.click("todo_main_open_details_button_" .. task.id)
        faketorio.enter_text("todo_main_subtask_new_text_" .. task.id, "New Subtask")
        faketorio.click("todo_main_subtask_save_new_button_" .. task.id)

        -- because of https://github.com/JonasJurczok/faketorio/issues/66 we click the checkbox after checking it
        local subtask = task.subtasks.done[1]
        faketorio.check("todo_main_subtask_checkbox_" .. task.id .. "_" .. subtask.id)
        faketorio.click("todo_main_subtask_checkbox_" .. task.id .. "_" .. subtask.id)

        faketorio.click("todo_main_subtask_delete_button_" .. task.id .. "_" .. subtask.id)

        faketorio.assert_element_not_exists("todo_main_subtask_checkbox_" .. task.id .. "_" .. subtask.id, player)
        assert(#task.subtasks.open == 0)
        assert(#task.subtasks.done == 0)
    end)

    scenario("Exporting and importing subtasks should work", function()
        local player = game.players[1]

        local task_template = { ["task"] = "Deleting subtasks", ["title"] = "single subtask"}
        local task = todo.assemble_task(task_template, player)
        task.assignee = player.name
        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        -- programmatically add subtask
        -- TODO: refactor exporting/importing to be callable from tests
    end)

    -- importing old task without subtasks should work

    -- editing subtasks

    -- sorting subtasks

end)
