function todo.create_import_dialog(player, import_type)
    local old_dialog = todo.get_import_dialog(player)
    if (old_dialog ~= nil) then
        old_dialog.destroy()
    end

    local title
    local import_button

    if (import_type == 1) then
        title = "import_tasks"
        import_button = "todo_import_import_tasks_button"
    elseif (import_type == 2) then
        title = "import_blueprint"
        import_button = "todo_import_import_blueprint_button"
    else
        return nil
    end

    local dialog = todo.create_frame(player, "todo_import_dialog", { todo.translate(player, title) }, "todo_import_cancel_button")

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
        name = import_button,
        caption = { todo.translate(player, "import") }
    })

    dialog.force_auto_center()
    textbox.focus()
end

function todo.get_import_dialog(player)
    local gui = player.gui.screen
    if gui.todo_import_dialog then
        return gui.todo_import_dialog
    else
        return nil
    end
end