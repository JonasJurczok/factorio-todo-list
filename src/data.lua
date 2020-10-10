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
    icon = {
        filename = '__Todo-List__/graphics/' .. 'toggle-ui.png',
        width = 104,
        height = 144,
        scale = 1,
        flags = {'icon'}
    },
    small_icon = {
        filename = '__Todo-List__/graphics/' .. 'toggle-ui.png',
        width = 104,
        height = 144,
        scale = 1,
        flags = {'icon'}
    },
    disabled_small_icon = {
        filename = '__Todo-List__/graphics/' .. 'toggle-ui-disabled.png',
        width = 104,
        height = 144,
        scale = 1,
        flags = {'icon'}
    }
}

local add_task_shortcut = {
    type = 'shortcut',
    name = 'todo-add-task-shortcut',
    order = 'a[alt-mode]-b[copy]',
    action = 'lua',
    localised_name = {'todo.shortcut_add_task'},
    icon = {
        filename = '__Todo-List__/graphics/' .. 'add-task.png',
        width = 104,
        height = 144,
        scale = 1,
        flags = {'icon'}
    },
    small_icon = {
        filename = '__Todo-List__/graphics/' .. 'add-task.png',
        width = 104,
        height = 144,
        scale = 1,
        flags = {'icon'}
    },
    disabled_small_icon = {
        filename = '__Todo-List__/graphics/' .. 'add-task-disabled.png',
        width = 104,
        height = 144,
        scale = 1,
        flags = {'icon'}
    }
}

data:extend({hotkey, toggle_ui_shortcut, add_task_shortcut})
