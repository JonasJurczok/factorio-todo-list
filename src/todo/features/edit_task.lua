--[[
  Business logic for the edit task feature.
]]--

function todo.on_main_task_title_click(player, id, button)
    local button_type = todo.get_click_to_edit_mouse_button(player)
    if (button == button_type) then
        local edit_dialog = todo.get_edit_dialog(player)
        if (edit_dialog ~= nil) then
            edit_dialog.destroy()
        else
            todo.create_edit_task_dialog(player, id)
        end
    end
end

function todo.get_click_to_edit_mouse_button(player)
    local value = settings.get_player_settings(player)["todolist-click-edit-task"].value
    if value == "right-button" then
        return defines.mouse_button_type.right
    elseif value == "middle-button" then
        return defines.mouse_button_type.middle
    end
end

function todo.on_edit_save_changes_click(player, id)

    todo.edit_persist_task_changes(player, id)

    todo.get_edit_dialog(player).destroy()

    todo.update_main_task_list_for_everyone()
end

function todo.edit_persist_task_changes(player, id)
    local dialog = todo.get_edit_dialog(player)
    if (dialog == nil) then
        return
    end
    todo.log("Player " .. player.name .. " updates task " .. id)

    local original = todo.get_task_by_id(id)

    original.title = dialog.todo_edit_task_table["todo_edit_task_title"].text
    original.task = dialog.todo_edit_task_table["todo_edit_task_textbox"].text

    local assignees = dialog.todo_edit_task_table["todo_edit_assignee_drop_down"]
    if (assignees.selected_index > 1) then
        original.assignee = assignees.items[assignees.selected_index]
    else
        original.assignee = nil
    end

    original.updated_by = player.name
end

function todo.on_edit_cancel_click(player)
    local dialog = todo.get_edit_dialog(player)
    if (dialog) then
        dialog.destroy()
    end
end
