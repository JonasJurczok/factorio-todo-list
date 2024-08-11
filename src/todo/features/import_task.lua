--[[
  Business logic for the import task feature.
]]--

function todo.on_import_tasks_click(player)
    local dialog = todo.get_import_dialog(player)
    if (dialog == nil) then
        return
    end

    local encoded = dialog.todo_import_string_textbox.text
    todo.import_tasks(encoded, player)

    dialog.destroy()

    todo.update_main_task_list_for_everyone()
end

function todo.import_tasks(encoded, player)
    local status, result = pcall(todo.base64.decode, encoded)
    if (not status) then
        local message = "Importing tasks failed for input %s. Result was %s. Please contact the mod author."
        todo.log(string.format(message, encoded, result))
        if (not todo.show_log(player)) then
            player.print("Import failed. Please enable debug output and contact the author.")
        end
        return
    end

    local tasks = game.json_to_table(result)

    todo.log("Importing tasks:")
    todo.log(serpent.block(tasks))

    if (type(tasks) ~= "table") then
        local message = "Importing tasks failed for input %s. Table expected but got %s. Please contact the mod author."
        todo.log(string.format(message, encoded, tasks))
        return
    end

    for _, task_to_import in pairs(tasks) do
        local task = todo.assemble_task(task_to_import, player)
        task.created_by = task_to_import.created_by

        if (task_to_import.subtasks) then
            task.subtasks = task_to_import.subtasks

            for _, subtask in pairs(task.subtasks.done) do
                todo.mark_subtask_open(task, subtask.id)
            end
        end

        todo.log(serpent.block(task))
        todo.save_task_to_open_list(task)
    end

    todo.log("Imported " .. #tasks .. " tasks.")
end

function todo.on_import_blueprint_click(player)
    local dialog = todo.get_import_dialog(player)
    if (dialog == nil) then
        return
    end

    local encoded = dialog.todo_import_string_textbox.text
    todo.import_blueprint(encoded, player)

    dialog.destroy()

    todo.update_main_task_list_for_everyone()
end

function todo.import_blueprint(encoded, player)
    local decoded = game.decode_string(string.sub(encoded, 2))

    if (decoded == nil) then
        local message = "Importing blueprint failed for input %s. Please contact the mod author."
        todo.log(string.format(message, encoded))
        if (not todo.show_log(player)) then
            player.print("Import failed. Please enable debug output and contact the author.")
        end
        return
    end

    local blueprint = game.json_to_table(decoded)

    todo.log("Importing tasks:")
    todo.log(serpent.block(blueprint))

    if (type(blueprint) ~= "table") then
        local message = "Importing blueprint failed for input %s. Table expected but got %s. Please contact the mod author."
        todo.log(string.format(message, encoded, blueprint))
        return
    end

    for _, blueprint_to_import in pairs(blueprint) do
        local task = {}
        task.id = todo.next_task_id()
        task.title = blueprint_to_import.label
        task.task = blueprint_to_import.description
        task.assignee = player.name
        task.created_by = player.name
        task.updated_by = player.name

        if (blueprint_to_import.entities) then
            local entities = {}
            for _, blueprint_entity in pairs(blueprint_to_import.entities) do
                local entity = entities[blueprint_entity.name]

                if (entity == nil) then
                    entity = {
                        name = blueprint_entity.name,
                        count = 0
                    }
                end

                entity.count = entity.count + 1
                entities[blueprint_entity.name] = entity
            end

            for _, entity in pairs(entities) do
                local entity_name = entity.name -- TODO: Lookup the friendly name of the entity instead of the code name
                todo.save_subtask_to_task(task, entity.count .. "x " .. entity_name)
            end
        end

        todo.log(serpent.block(task))
        todo.save_task_to_open_list(task)
    end

    todo.log("Imported " .. #blueprint .. " blueprint.")
end

function todo.on_import_cancel_click(player)
    local dialog = todo.get_import_dialog(player)
    if (dialog) then
        dialog.destroy()
    end
end