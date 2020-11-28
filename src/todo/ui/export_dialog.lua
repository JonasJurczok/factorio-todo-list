function todo.create_export_dialog(player)
    local old_dialog = todo.get_export_dialog(player)
    if (old_dialog ~= nil) then
        old_dialog.destroy()
    end

    local dialog = todo.create_frame(player, "todo_export_dialog", { todo.translate(player, "export") })
    
    local scroll = dialog.add({
        type = "scroll-pane",
        name = "todo_export_dialog_scroll_pane"
    })

    scroll.vertical_scroll_policy = "auto"
    scroll.horizontal_scroll_policy = "never"
    scroll.style.maximal_height = todo.get_window_height(player) / 2
    scroll.style.minimal_height = scroll.style.maximal_height

    local table = scroll.add({
        type = "table",
        style = "todo_table_default",
        name = "todo_export_dialog_table",
        column_count = 2
    })

    -- fill table
    for _, task_list in pairs({ global.todo.open, global.todo.done}) do
        for _, task in pairs(task_list) do
            table.add({
                type = "checkbox",
                name = "todo_export_select_task_checkbox_".. task.id,
                state = false
            })

            table.add({
                type = "label",
                style = "todo_label_task",
                name = "todo_export_task_title_label_" .. task.id,
                caption = task.title
            })
        end
    end

    dialog.add({
        type = "flow",
        name = "todo_export_dialog_string_flow",
        direction = "horizontal"
    })

    local flow = dialog.add({
        type = "flow",
        name = "todo_export_dialog_button_flow",
        direction = "horizontal"
    })

    flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_export_cancel_button",
        caption = { todo.translate(player, "cancel") }
    })

    flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_export_generate_export_string_button",
        caption = { todo.translate(player, "export") }
    })

    dialog.force_auto_center()
end

function todo.get_export_dialog(player)
    local gui = player.gui.screen
    if gui.todo_export_dialog then
        return gui.todo_export_dialog
    else
        return nil
    end
end