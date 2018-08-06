require('todo.style')

local hotkey = {
    type = "custom-input",
    name = "todolist-toggle-ui",
    key_sequence = "SHIFT + T",
    consuming = "none",
}
data:extend({hotkey})
