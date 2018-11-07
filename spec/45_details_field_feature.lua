feature("#45 details field", function()

    before_scenario(function()
        when(todo, "is_show_maximize_button"):then_return(true)
        todo.maximize_main_frame(game.players[1])
    end)

    after_scenario(function()
        todo.is_show_maximize_button:revert()

        -- clear all tasks
        global.todo.open = {}
        global.todo.done = {}
    end)

    scenario("Exporting a task without details should work", function()
        local player = game.players[1]

        local task_template = {["title"] = "single"}
        local task = todo.assemble_task(task_template, player)
        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        faketorio.click("todo_take_task_button_" .. task.id)

        todo.refresh_task_table(player)

        assert(todo.get_task_by_id(task.id).assignee == player.name)

        -- export to string
        faketorio.click("todo_main_open_export_dialog_button")

        -- select tasks
        faketorio.find_element_by_id("todo_export_select_task_checkbox_"..task.id, player).state = true

        faketorio.click("todo_export_generate_export_string_button")
        -- clicking this button twice should not change anything
        faketorio.click("todo_export_generate_export_string_button")

        local string = faketorio.find_element_by_id("todo_export_string_textbox", player).text
        faketorio.click("todo_export_cancel_button")

        local gui = player.gui.center
        local export_dialog = gui.todo_export_dialog
        assert(export_dialog == nil, "Expected export frame to be destroyed but it was found.")

        -- import same string
        faketorio.click("todo_main_open_import_dialog_button")
        faketorio.find_element_by_id("todo_import_string_textbox", player).text = string
        faketorio.click("todo_import_import_tasks_button")

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
        local task = todo.assemble_task(task_template, player)
        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        faketorio.click("todo_take_task_button_" .. task.id)

        todo.refresh_task_table(player)

        faketorio.click("todo_open_edit_dialog_button_" .. task.id)

        faketorio.assert_element_exists("todo_edit_dialog", player)

        faketorio.enter_text("todo_edit_task_textbox", "Test", player)

        faketorio.click("todo_edit_save_changes_button_" .. task.id, player)

        local updated_task = todo.get_task_by_id(task.id)

        assert(updated_task.task == "Test")
    end)

end)
