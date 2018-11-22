--[[
  Business logic for the export task feature.
]]--

function todo.update_export_dialog_button_state()
    local task_count = #global.todo.open + #global.todo.done

    for _, player in pairs(game.players) do
        local main_frame = todo.get_main_frame(player)
        if (main_frame) then
            main_frame.todo_main_button_flow.todo_main_open_export_dialog_button.enabled = task_count > 0
        end
    end
end

function todo.generate_and_show_export_string(player)
    local dialog = todo.get_export_dialog(player)

    local tasks_table = dialog.todo_export_dialog_scroll_pane.todo_export_dialog_table

    local tasks = {}

    for i, checkbox in ipairs(tasks_table.children) do
        -- every uneven child is a textbox (lists start at 1)
        if (i % 2 == 1 and checkbox.state) then
            local id = todo.get_task_id_from_element_name(checkbox.name, "todo_export_select_task_checkbox_")
            local task = todo.get_task_by_id(id)
            table.insert(tasks, task)
        end
    end

    -- if no tasks are selected, remove the textbox
    if (#tasks == 0) then
        if (dialog.todo_export_dialog_string_flow.todo_export_string_textbox) then
            dialog.todo_export_dialog_string_flow.todo_export_string_textbox.destroy()
        end
        return
    end

    -- generate string
    local encoded = todo.encode_task_list_for_export(tasks)

    if (dialog.todo_export_dialog_string_flow.todo_export_string_textbox) then
        dialog.todo_export_dialog_string_flow.todo_export_string_textbox.text = encoded
    else
        local textbox = dialog.todo_export_dialog_string_flow.add({
            type = "text-box",
            style = "todo_base64_textbox",
            name = "todo_export_string_textbox",
            text = encoded
        })
        textbox.word_wrap = true
    end
end

--[[ expects a list of tasks.
    Will clean up the tasks and prepare them for export.
    @return encoded string
]]--
function todo.encode_task_list_for_export(tasks)

    local to_encode = {}

    for _, task in pairs(tasks) do
    table.insert(to_encode, { ["task"] = task.task,
                          ["title"] = task.title ,
                          ["created_by"] = task.created_by})

    end
    return todo.base64.encode(todo.json:encode(to_encode))
end

function todo.on_export_cancel_click(player)
    local dialog = todo.get_export_dialog(player)
    if (dialog) then
        dialog.destroy()
    end
end