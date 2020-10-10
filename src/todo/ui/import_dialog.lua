function todo.create_import_dialog(player)
    local old_dialog = todo.get_import_dialog(player)
    if (old_dialog ~= nil) then
        old_dialog.destroy()
    end

    local dialog = todo.create_frame(player, "todo_import_dialog", { todo.translate(player, "import") })

    local textbox = dialog.add({
        type = "text-box",
        style = "todo_base64_textbox",
        name = "todo_import_string_textbox"
    })
    textbox.word_wrap = true

    local flow = dialog.add({
        type = "flow",
        name = "todo_import_dialog_button_flow",
        direction = "horizontal"
    })

    flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_import_cancel_button",
        caption = { todo.translate(player, "cancel") }
    })

    flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_import_import_tasks_button",
        caption = { todo.translate(player, "import") }
    })
   
    dialog.force_auto_center()
end

function todo.get_import_dialog(player)
    local gui = player.gui.screen
    if gui.todo_import_dialog then
        return gui.todo_import_dialog
    else
        return nil
    end
end