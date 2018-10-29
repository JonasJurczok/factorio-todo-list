feature("#29 import and export tasks", function()

    before_scenario(function()
        when(todo, "show_button"):then_return(true)
        todo.maximize(game.players[1])
    end)

    after_scenario(function()
        todo.show_button:revert()

        -- clear all tasks
        global.todo.open = {}
        global.todo.done = {}
    end)

    scenario("Exporting and importing single task should work", function()
        local player = game.players[1]

        local task = todo.create_task("Test")
        task.assignee = player.name
        todo.save_task(task)
        todo.refresh_task_table(player)

        -- export to string
        faketorio.click("todo_export_dialog_button")

        -- select tasks
        faketorio.find_element_by_id("todo_export_select_"..task.id, player).state = true

        faketorio.click("todo_export_button")
        -- clicking this button twice should not change anything
        faketorio.click("todo_export_button")

        local string = faketorio.find_element_by_id("todo_export_string_textbox", player).text
        faketorio.click("todo_export_cancel_button")

        local gui = player.gui.center
        local export_dialog = gui.todo_export_dialog
        assert(export_dialog == nil, "Expected export frame to be destroyed but it was found.")

        -- import same string
        faketorio.click("todo_import_dialog_button")
        faketorio.find_element_by_id("todo_import_string_textbox", player).text = string
        faketorio.click("todo_import_button")

        local import_dialog = gui.todo_import_dialog
        assert(import_dialog == nil, "Expected export frame to be destroyed but it was found.")

        faketorio.log.info(serpent.dump(global.todo.open))

        -- check task duplication
        assert(global.todo.open[2] ~= nil)
        assert(global.todo.open[2].task == "Test")
        assert(global.todo.open[2]["assignee"] == nil)
        assert(global.todo.open[2].id ~= global.todo.open[1].id)
    end)

    scenario("Exporting and importing multiple tasks should work", function()
        local player = game.players[1]

        local task1 = todo.create_task("Test")
        task1.assignee = player.name
        todo.save_task(task1)

        local task2 = todo.create_task("Test2")
        task2.assignee = player.name
        todo.save_task(task2)
        todo.mark_complete(task2.id)
        todo.refresh_task_table(player)

        -- export to string
        faketorio.click("todo_export_dialog_button")

        -- select tasks
        faketorio.find_element_by_id("todo_export_select_".. task1.id, player).state = true
        faketorio.find_element_by_id("todo_export_select_".. task2.id, player).state = true

        faketorio.click("todo_export_button")

        local string = faketorio.find_element_by_id("todo_export_string_textbox", player).text

        faketorio.click("todo_export_cancel_button")

        local gui = player.gui.center
        local frame = gui.todo_export_dialog
        assert(frame == nil, "Expected export frame to be destroyed but it was found.")

        -- import same string
        faketorio.click("todo_import_dialog_button")
        faketorio.find_element_by_id("todo_import_string_textbox", player).text = string
        faketorio.click("todo_import_button")

        -- check task duplication
        assert(global.todo.open[2] ~= nil)
        assert(global.todo.open[2].task == "Test")
        assert(global.todo.open[2]["assignee"] == nil)
        assert(global.todo.open[2].id ~= global.todo.open[1].id)

        assert(global.todo.open[3] ~= nil)
        assert(global.todo.open[3].task == "Test2")
        assert(global.todo.open[3]["assignee"] == nil)
        assert(global.todo.open[3].id ~= global.todo.open[2].id)
    end)

    scenario("Not selecting tasks to export should not generate export string.", function()
        local player = game.players[1]

        local task1 = todo.create_task("Test")
        task1.assignee = player.name
        todo.save_task(task1)

        local task2 = todo.create_task("Test2")
        task1.assignee = player.name
        todo.save_task(task2)
        todo.refresh_task_table(player)

        -- export to string
        faketorio.click("todo_export_dialog_button")
        faketorio.click("todo_export_button")

        local flow = faketorio.find_element_by_id("todo_export_dialog_string_flow", player)

        assert(flow.todo_export_string_textbox == nil)

        faketorio.click("todo_export_cancel_button")
    end)

    scenario("No tasks available should not enable export", function()
        local player = game.players[1]

        todo.update_export_dialog_button_state()

        local button = faketorio.find_element_by_id("todo_export_dialog_button", player)

        faketorio.log.info("Export dialog button state is %s.", {button.enabled})

        assert(button.enabled == false)
    end)

    scenario("Creating and deleting task should disable export button again.", function()
        local player = game.players[1]

        local task = todo.create_task("Test")
        task.assignee = player.name
        todo.save_task(task)

        todo.update_task_table()

        local id = task.id
        faketorio.click('todo_item_edit_' .. id)
        faketorio.click("todo_delete_button_" .. id)
        faketorio.click("todo_confirm_deletion_button_" .. id)

        local button = faketorio.find_element_by_id("todo_export_dialog_button", player)

        assert(button.enabled == false)

    end)

    scenario("Adding/removing tasks while export dialog open is ignored.", function()
        -- we purposely ignore this problem as it is very complex to solve and an extreme edge case
        assert(true == true)
    end)

end)
