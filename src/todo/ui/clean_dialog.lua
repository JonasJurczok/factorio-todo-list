local option_done = "todo_clean_option_completed"
local option_todo = "todo_clean_option_open"


function todo.create_clean_dialog(player)
    local old_dialog = todo.get_clean_dialog(player)
    if (old_dialog ~= nil) then
        old_dialog.destroy()
    end

    local dialog = todo.create_frame(player, "todo_clean_dialog", { todo.translate(player, "clean_title") }, "todo_minimize_clean")

    local table = dialog.add({
        type = "table",
        style = "todo_table_default",
        name = "todo_clean_table",
        column_count = 1
    })

    table.add({
        type = "checkbox",
        style = "todo_checkbox_default",
        name = option_done,
        state = false,
        caption = { todo.translate(player, "clean_option_completed") }
    })

    table.add({
        type = "checkbox",
        style = "todo_checkbox_default",
        name = option_todo,
        state = false,
        caption = { todo.translate(player, "clean_option_open") }
    })

    
    local button_flow = dialog.add({
        type = "flow",
        name = "todo_add_dialog_button_flow",
        direction = "horizontal"
    })

    button_flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_clean_cancel_button",
        caption = { todo.translate(player, "cancel") }
    })

    button_flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_clean_confirm_button",
        caption = { todo.translate(player, "clean") }
    })

    dialog.force_auto_center()
    
    -- if main frame is not active, set this to player.opened
    if not todo.get_main_frame(player) then
        player.opened = dialog
    end
end

function todo.get_clean_dialog(player)
    local gui = player.gui.screen

    if gui.todo_clean_dialog then
        return gui.todo_clean_dialog
    else
        return nil
    end
end

function todo.destroy_clean_dialog(player)
    local dialog = todo.get_clean_dialog(player)

    if (dialog) then
        dialog.destroy()
    end
end
