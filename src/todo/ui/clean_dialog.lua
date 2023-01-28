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
        name = "todo_clean_option_completed",
        state = false,
        caption = { todo.translate(player, "clean_option_completed") }
    })

    table.add({
        type = "checkbox",
        style = "todo_checkbox_default",
        name = "todo_clean_option_open",
        state = false,
        caption = { todo.translate(player, "clean_option_open") }
    })

    local button_flow = dialog.add({
        type = "flow",
        name = "todo_clean_dialog_button_flow",
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
        name = "todo_clean_button",
        enabled = false,
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

    if dialog then
        dialog.destroy()
    end

    -- Also close the clean confirmation dialog in case it is open.
    -- The clean confirmation dialog needs the checkboxes, so if this dialog is closed the confirmation
    -- dialog will only no-op.
    todo.destroy_clean_confirm_dialog(player)
end

function todo.get_clean_button(player)
    local dialog = todo.get_clean_dialog(player)

    if dialog then
        for _, child in ipairs(dialog.children) do
            if child.name == "todo_clean_dialog_button_flow" then
                for _, elem in ipairs(child.children) do
                    if elem.name == "todo_clean_button" then
                        return elem
                    end
                end
            end
        end
    end

    return nil
end

function todo.enable_clean_button(player)
    local clean_button = todo.get_clean_button(player)

    if clean_button then
        clean_button.enabled = true
    end
end

function todo.disable_clean_button(player)
    local clean_button = todo.get_clean_button(player)

    if clean_button then
        clean_button.enabled = false
    end
end

function todo.get_clean_checkboxes(player)
    local dialog = todo.get_clean_dialog(player)

    local done_checkbox = nil
    local in_progress_checkbox = nil

    if dialog then
        for _, child in pairs(dialog.children) do
            if child.name == "todo_clean_table" then
                for _, elem in pairs(child.children) do
                    if elem.name == "todo_clean_option_completed" then
                        done_checkbox = elem
                    elseif elem.name == "todo_clean_option_open" then
                        in_progress_checkbox = elem
                    end
                end
            end
        end
    end

    return done_checkbox, in_progress_checkbox
end

function todo.on_clean_checkbox_change(player)
local clean_button = todo.get_clean_button(player)
local done_checkbox, in_progress_checkbox = todo.get_clean_checkboxes(player)
    if clean_button and done_checkbox and in_progress_checkbox then
        if done_checkbox.state or in_progress_checkbox.state then
            todo.enable_clean_button(player)
        else
            todo.disable_clean_button(player)
        end
    end
end
