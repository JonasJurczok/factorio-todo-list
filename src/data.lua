require('todo.style')

local hotkey = {
    type = "custom-input",
    name = "todolist-toggle-ui",
    key_sequence = "SHIFT + T",
    consuming = "none",
}

local toggle_ui_shortcut = {
    type = 'shortcut',
    name = 'todo-toggle-ui-shortcut',
    toggleable = true,
    order = 'a[alt-mode]-b[copy]',
    action = 'lua',
    localised_name = {'todo.shortcut_toggle_ui'},
    icon = '__Todo-List__/graphics/toggle-ui.png',
    small_icon = '__Todo-List__/graphics/' .. 'toggle-ui.png',
    disabled_small_icon = '__Todo-List__/graphics/' .. 'toggle-ui-disabled.png'
}

local add_task_shortcut = {
    type = 'shortcut',
    name = 'todo-add-task-shortcut',
    order = 'a[alt-mode]-b[copy]',
    action = 'lua',
    localised_name = {'todo.shortcut_add_task'},
    icon = '__Todo-List__/graphics/' .. 'add-task.png',
    small_icon = '__Todo-List__/graphics/' .. 'add-task.png',
    disabled_small_icon = '__Todo-List__/graphics/' .. 'add-task-disabled.png',
}

local search_shortcut = {
    type = "custom-input",
    name = "todo-search-shortcut",
    key_sequence = "CTRL + F",
    consuming = "none",
}

data:extend({hotkey, toggle_ui_shortcut, add_task_shortcut, search_shortcut})
