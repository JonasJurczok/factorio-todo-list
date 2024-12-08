--[[
  Business logic for the clean feature.
]]--

function todo.on_clean_confirm(player)
    local completed_checkbox, in_progress_checkbox = todo.get_clean_checkboxes(player)

    if completed_checkbox and in_progress_checkbox then
        if completed_checkbox.state then
            storage.todo.done = {}
        end
        if in_progress_checkbox.state then
            storage.todo.open = {}
        end
    end

    todo.destroy_clean_confirm_dialog(player)
    todo.destroy_clean_dialog(player)

    todo.update_export_dialog_button_state()

    todo.update_main_task_list_for_everyone()
end
