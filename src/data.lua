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
    associated_control_input = 'todolist-toggle-ui',
    localised_name = {'todo.shortcut_toggle_ui'},
    icon = '__Todo-List__/graphics/todo-shortcut.png',
    small_icon = '__Todo-List__/graphics/todo-shortcut.png',
    disabled_small_icon = '__Todo-List__/graphics/todo-shortcut-disabled.png',
    icon_size = 32,
    small_icon_size = 32
}

local search_shortcut = {
    type = "custom-input",
    name = "todo-search-shortcut",
    key_sequence = "CONTROL + F",
    alternative_key_sequence = "COMMAND + F",
    consuming = "none",
}

local sprite_names = {
    "close",
    "export",
    "import",
    "edit",
    "collapse",
    "expand",
    "add",
    "delete",
}

local sprites = {}
for _, name in ipairs(sprite_names) do
    table.insert(sprites, {
        type = "sprite",
        name = "todo-" .. name,
        filename = "__Todo-List__/graphics/" .. name .. ".png",
        size = 32,
        flags = {"gui-icon"},
    })
end

data:extend({hotkey, toggle_ui_shortcut, search_shortcut})
data:extend(sprites)
