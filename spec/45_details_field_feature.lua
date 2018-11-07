feature("#45 details field", function()

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

    scenario("Exporting a task without details should work", function()
        local player = game.players[1]

        local task_template = {["title"] = "single"}
        local task = todo.create_task(task_template, player)
        todo.save_task(task)
        todo.refresh_task_table(player)

        faketorio.click("todo_item_assign_self_" .. task.id)

        todo.refresh_task_table(player)

        assert(todo.get_task_by_id(task.id).assignee == player.name)

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
        assert(global.todo.open[2].task == task_template.task)
        assert(global.todo.open[2].title == task_template.title)
        assert(global.todo.open[2]["assignee"] == nil)
        assert(global.todo.open[2].id ~= global.todo.open[1].id)
    end)

    scenario("Editing a task without details should work", function()
        local player = game.players[1]

        local task_template = {["title"] = "single"}
        local task = todo.create_task(task_template, player)
        todo.save_task(task)
        todo.refresh_task_table(player)

        faketorio.click("todo_item_assign_self_" .. task.id)

        todo.refresh_task_table(player)

        faketorio.click("todo_item_edit_" .. task.id)

        faketorio.assert_element_exists("todo_add_frame", player)

        faketorio.enter_text("todo_new_task_textbox", "Test", player)

        faketorio.click("todo_update_button_" .. task.id, player)

        local updated_task = todo.get_task_by_id(task.id)

        assert(updated_task.task == "Test")
    end)

end)
