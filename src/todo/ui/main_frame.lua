-- This file also contains the maximize button

function todo.create_maximize_button(player)
    todo.log("Creating Basic UI for player " .. player.name)

    if (not todo.get_maximize_button(player)
            and not todo.get_main_frame(player)
            and todo.should_show_maximize_button(player) ) then
        mod_gui.get_button_flow(player).add({
            type = "button",
            style = "todo_button_default",
            name = "todo_maximize_button",
            caption = { "todo.todo_list" },
        })
    end
end

function todo.create_maximized_frame(player)
    local frame = mod_gui.get_frame_flow(player).add({
        type = "frame",
        name = "todo_main_frame",
        caption = { "todo.todo_list" },
        direction = "vertical"
    })

    todo.create_task_table(frame, player)

    local flow = frame.add({
        type = "flow",
        name = "todo_main_button_flow",
        direction = "horizontal"
    })

    flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_open_add_dialog_button",
        caption = { "todo.add" }
    })

    flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_toggle_show_completed_button",
        caption = { "todo.show_done" }
    })

    if todo.should_show_maximize_button(player) then
        flow.add({
            type = "button",
            style = "todo_button_default",
            name = "todo_minimize_button",
            caption = { "todo.minimize" }
        })
    end

    flow.add({
        type = "sprite-button",
        style = "todo_sprite_button_default",
        name = "todo_main_open_export_dialog_button",
        sprite = "utility/export_slot",
        tooltip = { "todo.export" }
    })
    todo.update_export_dialog_button_state()

    flow.add({
        type = "sprite-button",
        style = "todo_sprite_button_default",
        name = "todo_main_open_import_dialog_button",
        sprite = "utility/import_slot",
        tooltip = { "todo.import" }
    })

end

function todo.create_task_table(frame, player)

    local scroll = frame.add({
        type = "scroll-pane",
        name = "todo_scroll_pane"
    })

    scroll.vertical_scroll_policy = "auto"
    scroll.horizontal_scroll_policy = "never"
    scroll.style.maximal_height = todo.get_window_height(player)
    scroll.style.minimal_height = scroll.style.maximal_height

    local table = scroll.add({
        type = "table",
        style = "todo_table_default",
        name = "todo_task_table",
        column_count = 9,
        -- TODO: put this behind an option?
        draw_horizontal_line_after_headers = true
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_done",
        caption = { "", { "todo.title_done" }, "   " }
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_task",
        caption = { "todo.title_task" }
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_assignee",
        caption = { "todo.title_assignee" }
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_top",
        caption = "Sort"
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_up",
        caption = ""
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_down",
        caption = ""
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_bottom",
        caption = ""
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_edit",
        caption = { "todo.title_edit" }
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_details",
        caption = { "todo.title_details" }
    })

    return table
end

function todo.add_task_to_table(table, task, completed, is_first, is_last, expanded)
    local id = task.id

    local checkbox_name
    if (completed) then
        checkbox_name = "todo_main_task_mark_open_checkbox_"
    else
        checkbox_name = "todo_main_task_mark_complete_checkbox_"
    end
    table.add({
        type = "checkbox",
        name = checkbox_name .. id,
        state = completed
    })

    table.add({
        type = "label",
        style = "todo_label_task",
        name = "todo_main_task_title_" .. id,
        caption = task.title
    })

    if (task.assignee) then
        table.add({
            type = "label",
            style = "todo_label_default",
            name = "todo_main_task_assignee_" .. id,
            caption = task.assignee
        })
    else
        table.add({
            type = "button",
            style = "todo_button_default",
            name = "todo_take_task_button_" .. id,
            caption = { "todo.assign_self" }
        })
    end

    if (is_first) then
        table.add({
            type = "label",
            name = "todo_item_firsttop_" .. id,
            caption = ""
        })
        table.add({
            type = "label",
            name = "todo_item_firstup_" .. id,
            caption = ""
        })
    else
        table.add({
            type = "button",
            style = "todo_button_default",
            name = "todo_main_task_move_top_" .. id,
            caption = "↟"
        })
        table.add({
            type = "button",
            style = "todo_button_default",
            name = "todo_main_task_move_up_" .. id,
            caption = "↑"
        })
    end

    if (is_last) then
        table.add({
            type = "label",
            name = "todo_item_lastdown_" .. id,
            caption = ""
        })
        table.add({
            type = "label",
            name = "todo_item_lastbottom_" .. id,
            caption = ""
        })
    else
        table.add({
            type = "button",
            style = "todo_button_default",
            name = "todo_main_task_move_down_" .. id,
            caption = "↓"
        })
        table.add({
            type = "button",
            style = "todo_button_default",
            name = "todo_main_task_move_bottom_" .. id,
            caption = "↡"
        })
    end

    table.add({
        type = "sprite-button",
        style = "todo_sprite_button_default",
        name = "todo_open_edit_dialog_button_" .. id,
        sprite = "utility/rename_icon_normal",
        tooltip = { "todo.title_edit" }
    })

    if (expanded) then
        table.add({
            type = "sprite-button",
            style = "todo_sprite_button_default",
            name = "todo_main_close_details_button_" .. id,
            sprite = "utility/speed_up",
            tooltip = { "todo.title_details" }
        })

        -- details view is a new row
        table.add({
            type = "label",
            style = "todo_label_default",
            name = "todo_main_expanded_1_" .. id,
            caption = ""
        })

        table.add({
            type = "label",
            style = "todo_label_task",
            name = "todo_main_expanded_task_label_" .. id,
            caption = task.task
        })

        -- fill up the row with empty cells
        for _, i in pairs({ 2, 3, 4, 5, 6, 7, 8 }) do
            table.add({
                type = "label",
                style = "todo_label_default",
                name = "todo_main_expanded_" .. i .. "_" .. id,
                caption = ""
            })
        end
    else
        table.add({
            type = "sprite-button",
            style = "todo_sprite_button_default",
            name = "todo_main_open_details_button_" .. id,
            sprite = "utility/speed_down",
            tooltip = { "todo.title_details" }
        })
    end
end

function todo.get_main_frame(player)
    local flow = mod_gui.get_frame_flow(player)
    if flow.todo_main_frame then
        return flow.todo_main_frame
    else
        return nil
    end
end

function todo.get_task_table(player)
    local main_frame = todo.get_main_frame(player)
    if (main_frame.todo_task_table) then
        return main_frame.todo_task_table
    elseif (main_frame.todo_scroll_pane.todo_task_table) then
        return main_frame.todo_scroll_pane.todo_task_table
    end
end