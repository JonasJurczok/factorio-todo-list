--[[
  Business logic for the add task feature.
]]--

function todo.on_save_new_task_click(player)
    todo.log("Creating task by player " .. player.name)

    local dialog = todo.get_add_dialog(player)
    if (dialog == nil) then
        return
    end

    local task_data, should_add_to_top = todo.get_task_from_add_dialog(dialog)
    local task = todo.assemble_task(task_data, player)

    todo.save_task_to_open_list(task, should_add_to_top)

    dialog.destroy()

    todo.update_main_task_list_for_everyone()
end

function todo.get_task_from_add_dialog(dialog)
    local text = dialog.todo_add_task_table["todo_new_task_textbox"].text
    local title = dialog.todo_add_task_table["todo_new_task_title"].text

    local assignees = dialog.todo_add_task_table["todo_add_assignee_drop_down"]
    local assignee
    if (assignees.selected_index > 1) then
        assignee = assignees.items[assignees.selected_index]
    end

    local add_top_checkbox = dialog.todo_add_task_table["todo_add_top"]
    local should_add_to_top = add_top_checkbox.state

    local task = { ["title"] = title, ["task"] = text, ["assignee"] = assignee }

    todo.log("Reading task: " .. serpent.block(task))
    if should_add_to_top then
        todo.log("Adding it at the top.")
    end

    return task, should_add_to_top
end

function todo.assemble_task(input, player)
    local task = {}
    task.id = todo.next_task_id()
    task.title = input.title
    task.task = input.task
    task.assignee = input.assignee
    task.created_by = player.name
    task.updated_by = player.name
    return task
end

function todo.next_task_id()
    if not global.todo.next_id then
        global.todo.next_id = 1
    end

    global.todo.next_id = global.todo.next_id + 1
    return global.todo.next_id - 1
end

function todo.save_task_to_open_list(task, should_add_to_top)
    todo.log("Saving task: " .. serpent.block(task))

    local add_index = 1
    if not should_add_to_top then
        add_index = #global.todo.open + 1
    end

    table.insert(global.todo.open, add_index, task)

    todo.update_export_dialog_button_state()

    return task
end

function todo.on_add_cancel_click(player)
    local dialog = todo.get_add_dialog(player)
    if (dialog) then
        dialog.destroy()
    end
end
