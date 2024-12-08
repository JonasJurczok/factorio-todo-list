feature("#60 Show created/updated by", function()
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

    scenario("A task has a creator and a modifier", function()
        local player = game.players[1]

        local task_template = { ["task"] = "Test", ["title"] = "Title", ["assignee"] = "def" }
        local task = todo.assemble_task(task_template, player)
        task.updated_by = player.name

        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        faketorio.click("todo_open_edit_dialog_button_" .. task.id, player)
        local dialog = todo.get_edit_dialog(player)

        local created_by = dialog["todo_edit_task_table"]["todo_edit_created_by_playername"]
        local updated_by = dialog["todo_edit_task_table"]["todo_edit_updated_by_playername"]

        faketorio.log.info("Creator: %s", {created_by.caption})
        assert(created_by.caption == player.name)

        faketorio.log.info("Last editor: %s", {updated_by.caption})
        assert(updated_by.caption == player.name)
    end)

    scenario("Different player edits task", function()
        local player = game.players[1]
        local player1 = { ["name"] = "Tarrke" }
        local player2 = { ["name"] = "Jonas" }

        local task_template = { ["task"] = "Test", ["title"] = "Title", ["assignee"] = "def" }
        local task = todo.assemble_task(task_template, player1)
        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        local original_name = player.name
        player.name = "Wololo"

        faketorio.click("todo_open_edit_dialog_button_" .. task.id, player)
        local dialog = todo.get_edit_dialog(player)
        local name_label = dialog["todo_edit_task_table"]["todo_edit_created_by_playername"]
        assert(name_label.caption == player1.name)

        faketorio.enter_text("todo_edit_task_textbox", "wololo", player)

        faketorio.click("todo_edit_save_changes_button_" .. task.id, player)

        faketorio.click("todo_open_edit_dialog_button_" .. task.id, player)
        dialog = todo.get_edit_dialog(player)
        assert(dialog["todo_edit_task_table"]["todo_edit_updated_by_playername"].caption == "Wololo")

        dialog.destroy()

        player.name = original_name
    end)
end)