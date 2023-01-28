function todo.create_clean_confirm_dialog(player)
    local old_dialog = todo.get_clean_confirm_dialog(player)
    if (old_dialog ~= nil) then
        old_dialog.destroy()
    end


    local dialog = todo.create_frame(player, "todo_clean_confirm_dialog", { todo.translate(player, "clean_confirm_title") }, "todo_minimize_clean_confirm")

    local text_table = dialog.add({
        type = "table",
        style = "todo_table_default",
        name = "todo_clean_confirm_table",
        column_count = 1
    })

    local warning_message = ""
    local completed_checkbox, in_progress_checkbox = todo.get_clean_checkboxes(player)
    if completed_checkbox and in_progress_checkbox then
        if completed_checkbox.state and in_progress_checkbox.state then
            warning_message = todo.translate(player, "clean_confirm_message_clean_all")
        elseif completed_checkbox.state then
            warning_message = todo.translate(player, "clean_confirm_message_clean_completed")
        elseif in_progress_checkbox.state then
            warning_message = todo.translate(player, "clean_confirm_message_clean_in_progress")
        end
    end

    text_table.add({
        type = "label",
        style = "todo_clean_confirm_text_label",
        caption = { warning_message }
    })

    local button_flow = dialog.add({
        type = "flow",
        name = "todo_clean_confirm_flow",
        direction = "horizontal"
    })

    button_flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_clean_confirm_cancel_button",
        caption = { todo.translate(player, "cancel") }
    })

    button_flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_clean_confirm_button",
        caption = { todo.translate(player, "clean_confirm") }
    })

    

    dialog.force_auto_center()
    
    -- if main frame is not active, set this to player.opened
    if not todo.get_main_frame(player) then
        player.opened = dialog
    end
end

function todo.get_clean_confirm_dialog(player)
    local gui = player.gui.screen
    local confirm_dialog = gui.todo_clean_confirm_dialog

    if confirm_dialog then
        return confirm_dialog
    else
        return nil
    end
end

function todo.destroy_clean_confirm_dialog(player)
    local dialog = todo.get_clean_confirm_dialog(player)

    if dialog then
        dialog.destroy()
    end
end
