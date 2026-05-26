feature("#34 map-pin tasks", function()

    before_scenario(function()
        when(todo, "should_show_maximize_button"):then_return(true)
        when(todo, "show_completed_tasks"):then_return(true)
        when(todo, "is_auto_chart_tag"):then_return(true)

        todo.maximize_main_frame(game.players[1])
    end)

    after_scenario(function()
        todo.should_show_maximize_button:revert()
        todo.show_completed_tasks:revert()
        todo.is_auto_chart_tag:revert()

        storage.todo.open = {}
        storage.todo.done = {}
    end)

    -- Scenario 1: storage migration safe
    scenario("legacy task without location field survives mod_init without crash", function()
        local legacy = { id = 99, task = "old task", title = "legacy", created_by = "someone", updated_by = "someone" }
        table.insert(storage.todo.open, legacy)

        todo.mod_init()

        local task = todo.get_task_by_id(99)
        assert(task ~= nil, "legacy task should still exist")
        assert(task.location == nil, "location should remain nil for legacy tasks")
    end)

    -- Scenario 2: add task with location
    scenario("saving add dialog with pending_location attaches location to task", function()
        local player = game.players[1]

        faketorio.click("todo_open_add_dialog_button")

        local dialog = todo.get_add_dialog(player)
        assert(dialog ~= nil, "add dialog should be open")

        local loc = { x = 42.5, y = -10.0, surface_index = 1 }
        dialog.tags = { pending_location = loc }

        faketorio.enter_text("todo_new_task_title", "pinned task")
        faketorio.enter_text("todo_new_task_textbox", "task body")

        local chart_tag_called = false
        local orig_create = todo.create_chart_tag_for_task
        todo.create_chart_tag_for_task = function(t, p)
            chart_tag_called = true
        end

        faketorio.click("todo_save_new_task_button")

        todo.create_chart_tag_for_task = orig_create

        local task = storage.todo.open[#storage.todo.open]
        assert(task ~= nil)
        assert(task.location ~= nil, "task should have location")
        assert(task.location.x == loc.x, "x should match")
        assert(task.location.y == loc.y, "y should match")
        assert(task.location.surface_index == loc.surface_index, "surface_index should match")
        assert(chart_tag_called, "create_chart_tag_for_task should have been called")
    end)

    -- Scenario 3: add task with auto-chart-tag setting off
    scenario("add task with location but auto-chart-tag off does not create chart tag", function()
        local player = game.players[1]

        when(todo, "is_auto_chart_tag"):then_return(false)

        faketorio.click("todo_open_add_dialog_button")

        local dialog = todo.get_add_dialog(player)
        local loc = { x = 10.0, y = 20.0, surface_index = 1 }
        dialog.tags = { pending_location = loc }

        faketorio.enter_text("todo_new_task_title", "no-tag task")
        faketorio.enter_text("todo_new_task_textbox", "body")

        local chart_tag_called = false
        local orig_create = todo.create_chart_tag_for_task
        todo.create_chart_tag_for_task = function(t, p)
            chart_tag_called = true
        end

        faketorio.click("todo_save_new_task_button")

        todo.create_chart_tag_for_task = orig_create

        local task = storage.todo.open[#storage.todo.open]
        assert(task ~= nil)
        assert(task.location ~= nil, "task should still have location")
        assert(task.location.chart_tag_number == nil, "chart_tag_number should be nil")
        assert(not chart_tag_called, "create_chart_tag_for_task should NOT have been called")
    end)

    -- Scenario 4: edit task to add location
    scenario("editing task to add location persists location and creates chart tag", function()
        local player = game.players[1]

        local task_template = { ["task"] = "edit to pin", ["title"] = "edit-pin" }
        local task = todo.assemble_task(task_template, player)
        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        faketorio.click("todo_open_edit_dialog_button_" .. task.id)

        local dialog = todo.get_edit_dialog(player)
        assert(dialog ~= nil)

        local loc = { x = 55.0, y = -30.0, surface_index = 1 }
        dialog.tags = { pending_location = loc }

        local chart_tag_called = false
        local orig_create = todo.create_chart_tag_for_task
        todo.create_chart_tag_for_task = function(t, p)
            chart_tag_called = true
        end

        faketorio.click("todo_edit_save_changes_button_" .. task.id)

        todo.create_chart_tag_for_task = orig_create

        local updated = todo.get_task_by_id(task.id)
        assert(updated ~= nil)
        assert(updated.location ~= nil, "location should be set after edit")
        assert(updated.location.x == loc.x)
        assert(updated.location.y == loc.y)
        assert(chart_tag_called, "chart tag should have been created")
    end)

    -- Scenario 5: edit task to clear location
    scenario("editing task to clear location destroys chart tag and nils location", function()
        local player = game.players[1]

        local task_template = { ["task"] = "clear pin", ["title"] = "clear-pin" }
        local task = todo.assemble_task(task_template, player)
        task.location = { x = 5, y = 5, surface_index = 1, chart_tag_number = 7, chart_tag_force = "player" }
        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        faketorio.click("todo_open_edit_dialog_button_" .. task.id)

        local dialog = todo.get_edit_dialog(player)
        assert(dialog ~= nil)

        -- pending_location = nil means "clear"
        dialog.tags = {}

        local destroy_called = false
        local orig_destroy = todo.destroy_chart_tag_for_task
        todo.destroy_chart_tag_for_task = function(t)
            destroy_called = true
        end

        faketorio.click("todo_edit_save_changes_button_" .. task.id)

        todo.destroy_chart_tag_for_task = orig_destroy

        local updated = todo.get_task_by_id(task.id)
        assert(updated ~= nil)
        assert(updated.location == nil, "location should be cleared")
        assert(destroy_called, "destroy_chart_tag_for_task should have been called")
    end)

    -- Scenario 6: delete task removes chart_tag
    scenario("deleting task with chart tag calls destroy", function()
        local player = game.players[1]

        local task_template = { ["task"] = "delete with tag", ["title"] = "delete-tag" }
        local task = todo.assemble_task(task_template, player)
        task.location = { x = 1, y = 2, surface_index = 1, chart_tag_number = 42, chart_tag_force = "player" }
        todo.save_task_to_open_list(task)
        todo.refresh_task_table(player)

        local destroy_count = 0
        local orig_destroy = todo.destroy_chart_tag_for_task
        todo.destroy_chart_tag_for_task = function(t)
            destroy_count = destroy_count + 1
        end

        todo.delete_task(task.id)

        todo.destroy_chart_tag_for_task = orig_destroy

        assert(destroy_count == 1, "destroy should be called exactly once")
        assert(todo.get_task_by_id(task.id) == nil, "task should be gone")
    end)

    -- Scenario 7: mark complete removes chart_tag
    scenario("completing task with chart tag calls destroy", function()
        local player = game.players[1]

        local task_template = { ["task"] = "complete with tag", ["title"] = "complete-tag" }
        local task = todo.assemble_task(task_template, player)
        task.location = { x = 3, y = 4, surface_index = 1, chart_tag_number = 43, chart_tag_force = "player" }
        todo.save_task_to_open_list(task)

        local destroy_called = false
        local orig_destroy = todo.destroy_chart_tag_for_task
        todo.destroy_chart_tag_for_task = function(t)
            destroy_called = true
        end

        todo.mark_complete(task.id)

        todo.destroy_chart_tag_for_task = orig_destroy

        assert(destroy_called, "destroy should be called on complete")
        assert(#storage.todo.done > 0, "task should be in done list")
    end)

    -- Scenario 8: clean removes chart_tags for all tasks
    scenario("cleaning open tasks with chart tags calls destroy for each", function()
        local player = game.players[1]

        local t1 = todo.assemble_task({ task = "t1", title = "T1" }, player)
        t1.location = { x = 1, y = 1, surface_index = 1, chart_tag_number = 100, chart_tag_force = "player" }
        todo.save_task_to_open_list(t1)

        local t2 = todo.assemble_task({ task = "t2", title = "T2" }, player)
        t2.location = { x = 2, y = 2, surface_index = 1, chart_tag_number = 101, chart_tag_force = "player" }
        todo.save_task_to_open_list(t2)

        when(todo, "get_clean_checkboxes"):then_return({ state = false }, { state = true })
        when(todo, "destroy_clean_confirm_dialog"):then_return(nil)
        when(todo, "destroy_clean_dialog"):then_return(nil)
        when(todo, "update_export_dialog_button_state"):then_return(nil)
        when(todo, "update_main_task_list_for_everyone"):then_return(nil)

        local destroy_count = 0
        local orig_destroy = todo.destroy_chart_tag_for_task
        todo.destroy_chart_tag_for_task = function(t)
            destroy_count = destroy_count + 1
        end

        todo.on_clean_confirm(player)

        todo.destroy_chart_tag_for_task = orig_destroy
        todo.get_clean_checkboxes:revert()
        todo.destroy_clean_confirm_dialog:revert()
        todo.destroy_clean_dialog:revert()
        todo.update_export_dialog_button_state:revert()
        todo.update_main_task_list_for_everyone:revert()

        assert(destroy_count == 2, "destroy should be called for each task with a tag, got: " .. destroy_count)
    end)

    -- Scenario 9: import/export round-trip
    scenario("export strips runtime fields, import recreates chart tag", function()
        local player = game.players[1]

        local task_template = { ["task"] = "round trip", ["title"] = "round-trip" }
        local task = todo.assemble_task(task_template, player)
        task.location = { x = 7, y = 8, surface_index = 1, chart_tag_number = 200, chart_tag_force = "player" }
        todo.save_task_to_open_list(task)

        local encoded = todo.encode_task_list_for_export({ task })

        -- verify encoded JSON has location but no runtime fields
        local decoded_str = helpers.decode_string(encoded)
        local decoded = helpers.json_to_table(decoded_str)
        local exported_task = decoded[1]

        assert(exported_task.location ~= nil, "location should be in export")
        assert(exported_task.location.x == 7)
        assert(exported_task.location.surface_index == 1)
        assert(exported_task.location.chart_tag_number == nil, "chart_tag_number should be stripped")
        assert(exported_task.location.chart_tag_force == nil, "chart_tag_force should be stripped")

        -- import and verify chart tag created
        local chart_tag_called = false
        local orig_create = todo.create_chart_tag_for_task
        todo.create_chart_tag_for_task = function(t, p)
            chart_tag_called = true
        end

        todo.import_tasks(encoded, player)

        todo.create_chart_tag_for_task = orig_create

        local imported = storage.todo.open[#storage.todo.open]
        assert(imported ~= nil)
        assert(imported.location ~= nil, "imported task should have location")
        assert(imported.location.x == 7)
        assert(imported.location.chart_tag_number == nil, "chart_tag_number should be nil before create")
        assert(chart_tag_called, "create_chart_tag_for_task should be called on import")
    end)

    -- Scenario 10: surface invalid on zoom
    scenario("clicking pin when surface is gone prints error and does not zoom", function()
        local player = game.players[1]

        local task_template = { ["task"] = "bad surface", ["title"] = "bad-surf" }
        local task = todo.assemble_task(task_template, player)
        task.location = { x = 0, y = 0, surface_index = 9999 }
        todo.save_task_to_open_list(task)

        local printed = nil
        local orig_print = player.print
        player.print = function(msg)
            printed = msg
        end

        local zoom_called = false
        local orig_zoom = player.zoom_to_world
        player.zoom_to_world = function(...)
            zoom_called = true
        end

        todo.zoom_to_task_location(player, task)

        player.print = orig_print
        player.zoom_to_world = orig_zoom

        assert(printed ~= nil, "player.print should have been called")
        assert(not zoom_called, "zoom_to_world should NOT have been called")
    end)

    -- Scenario 11: destroy is a no-op for already-destroyed tag
    scenario("destroy_chart_tag_for_task with missing tag is a silent no-op", function()
        local task_template = { ["task"] = "orphan tag", ["title"] = "orphan" }
        local player = game.players[1]
        local task = todo.assemble_task(task_template, player)
        task.location = { x = 0, y = 0, surface_index = 1, chart_tag_number = 9999, chart_tag_force = "player" }

        -- should not error
        todo.destroy_chart_tag_for_task(task)

        assert(task.location.chart_tag_number == nil, "chart_tag_number should be cleared")
        assert(task.location.chart_tag_force == nil, "chart_tag_force should be cleared")
    end)

end)
