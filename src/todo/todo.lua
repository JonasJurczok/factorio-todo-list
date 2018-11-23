--[[
  Main entry point for the mod.
  This file holds all general event handlers.
]]--
if not todo then
    todo = {}
end

-- features
require("todo/features/add_task")
require("todo/features/delete_task")
require("todo/features/details_view")
require("todo/features/edit_task")
require("todo/features/export_task")
require("todo/features/import_task")
require("todo/features/main_ui")
require("todo/features/mark_complete")
require("todo/features/mark_open")
require("todo/features/sort_tasks")
require("todo/features/subtasks")
require("todo/features/take_task")

-- UIs
require("todo/ui/add_dialog")
require("todo/ui/edit_dialog")
require("todo/ui/export_dialog")
require("todo/ui/import_dialog")
require("todo/ui/main_frame")

-- convenience
require("todo/helper")
require("todo/logging")
todo.json = require("lib/json")
todo.base64 = require("lib/base64")

function todo.mod_init()
    todo.log("setting up mod data.")

    if not global.todo then
        global.todo = { ["open"] = {}, ["done"] = {}, ["settings"] = {} }
    else
        for _, task in ipairs(global.todo.open) do
            todo.init_ensure_task_fields(task)
        end

        for _, task in ipairs(global.todo.done) do
            todo.init_ensure_task_fields(task)
        end
    end

    for _, player in pairs(game.players) do
        todo.create_maximize_button(player)
    end
end

function todo.init_ensure_task_fields(task)
    if not task.id then
        task.id = todo.next_task_id()
    end

    if not task.title then
        task.title = string.match(task.task, "[^\r\n]+")
    end
end

function todo.on_gui_click(event)
    local player = game.players[event.player_index]
    local element = event.element

    if (element.name == "todo_maximize_button") then
        todo.on_maximize_button_click(player)
    elseif (element.name == "todo_minimize_button") then
        todo.minimize_main_frame(player)
    elseif (element.name == "todo_open_add_dialog_button") then
        todo.create_add_task_dialog(player)
    elseif (element.name == "todo_save_new_task_button") then
        todo.on_save_new_task_click(player)
    elseif (element.name == "todo_add_cancel_button") then
        todo.on_add_cancel_click(player)
    elseif (string.find(element.name, "todo_take_task_button_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_take_task_button_")

        todo.on_take_task_click(player, id)
    elseif (string.find(element.name, "todo_open_edit_dialog_button_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_open_edit_dialog_button_")

        todo.create_edit_task_dialog(player, id)
    elseif (string.find(element.name, "todo_main_task_title_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_main_task_title_")

        todo.on_main_task_title_click(player, id, event.button)
    elseif (string.find(element.name, "todo_edit_save_changes_button_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_edit_save_changes_button_")

        todo.on_edit_save_changes_click(player, id)
    elseif (element.name == "todo_edit_cancel_button") then
        todo.on_edit_cancel_click(player)
    elseif (string.find(element.name, "todo_edit_delete_button")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_edit_delete_button_")

        todo.create_delete_confirmation_button(element, id)
    elseif (string.find(element.name, "todo_edit_confirm_deletion_button")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_edit_confirm_deletion_button_")

        todo.on_edit_confirm_delete_click(player, id)
    elseif (string.find(element.name, "todo_main_task_mark_complete_checkbox_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_main_task_mark_complete_checkbox_")

        todo.on_mark_complete_click(id)
    elseif (string.find(element.name, "todo_main_task_mark_open_checkbox_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_main_task_mark_open_checkbox_")

        todo.on_mark_open_click(id)
    elseif (element.name == "todo_toggle_show_completed_button") then
        todo.on_toggle_show_completed_click(player)
    elseif (string.find(element.name, "todo_main_task_move_up")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_main_task_move_up_")
        todo.on_main_move_up_click(id)
    elseif (string.find(element.name, "todo_main_task_move_down")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_main_task_move_down_")
        todo.on_main_move_down_click(id)
    elseif (string.find(element.name, "todo_main_task_move_top")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_main_task_move_top_")

        todo.on_main_move_top_click(id)
    elseif (string.find(element.name, "todo_main_task_move_bottom")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_main_task_move_bottom_")

        todo.on_main_move_bottom_click(id)
    elseif (element.name == "todo_main_open_export_dialog_button") then
        todo.create_export_dialog(player)
    elseif (element.name == "todo_export_generate_export_string_button") then
        todo.generate_and_show_export_string(player)
    elseif (element.name == "todo_export_cancel_button") then
        todo.on_export_cancel_click(player)
    elseif (element.name == "todo_main_open_import_dialog_button") then
        todo.create_import_dialog(player)
    elseif (element.name == "todo_import_import_tasks_button") then
        todo.on_import_tasks_click(player)
    elseif (element.name == "todo_import_cancel_button") then
        todo.on_import_cancel_click(player)
    elseif (string.find(element.name, "todo_main_open_details_button_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_main_open_details_button_")

        todo.on_show_task_details_click(player, id)
    elseif (string.find(element.name, "todo_main_close_details_button_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_main_close_details_button_")

        todo.on_hide_task_details_click(player, id)
    elseif (string.find(element.name, "todo_main_subtask_save_new_button_")) then
        local id = todo.get_task_id_from_element_name(element.name, "todo_main_subtask_save_new_button_")

        todo.on_save_new_subtask_click(player, id)
    elseif (string.find(element.name, "todo_main_subtask_checkbox_")) then
        local task_id, subtask_id = todo.get_task_id_from_element_name(element.name, "todo_main_subtask_checkbox_")

        todo.on_subtask_checkbox_click(task_id, subtask_id)
    elseif (string.find(element.name, "todo_main_subtask_delete_button_")) then
        local task_id, subtask_id = todo.get_task_id_from_element_name(element.name, "todo_main_subtask_delete_button_")

        todo.on_subtask_delete_click(task_id, subtask_id)
    elseif (string.find(element.name, "todo_")) then
        todo.log("Unknown todo element name:" .. element.name)
    end
end

function todo.on_runtime_mod_setting_changed(player, key)
    if (key == "todolist-show-button") then
        todo.on_show_maximize_button_changed(player)
    elseif (key == "todolist-show-log") then
        todo.log("Updated logging settings for player " .. player.name)
    elseif (key == "todolist-auto-assign") then
        todo.log("Changed auto-assign...")
    elseif (key == "todolist-click-edit-task") then
        todo.log("Changed button click to open edit frame...")
    end
end

-- TODO: is this the right place?
function todo.on_show_maximize_button_changed(player)
    if todo.should_show_maximize_button(player) then
        todo.log("Showing minimized button.")
        if not todo.get_maximize_button(player) then
            todo.create_maximize_button(player)
        end
    else
        todo.log("Hiding minimized button.")
        local max_button = todo.get_maximize_button(player)
        if max_button then
            max_button.destroy()
        end
    end
end
