local default_gui = data.raw["gui-style"].default

data:extend({
    {
        type = "font",
        name = "todo_font_default",
        from = "default",
        size = 14
    },
})

data:extend({
    {
        type = "font",
        name = "todo_font_subheading",
        from = "default",
        size = 18
    }
})

default_gui["todo_table_default"] = {
    type = "table_style",
}

default_gui["todo_button_default"] = {
    type = "button_style",
    font = "todo_font_default",
    align = "center",
    vertical_align = "center"
}

default_gui["todo_sprite_button_default"] = {
    type = "button_style",
    parent = "icon_button",
    font = "todo_font_default",
    align = "center",
    vertical_align = "center",
    height = 36
}

default_gui["todo_label_default"] = {
    type = "label_style",
    font = "todo_font_default",
}

default_gui["todo_label_task"] = {
    type = "label_style",
    font = "todo_font_default",
    single_line = false
}

default_gui["todo_textbox_default"] = {
    type = "textbox_style",
    font = "todo_font_default",
    minimal_width = 300,
    minimal_height = 100,
}

default_gui["todo_textfield_default"] = {
    type = "textfield_style",
    font = "todo_font_default",
    minimal_width = 300
}

default_gui["todo_base64_textbox"] = {
    type = "textbox_style",
    font = "todo_font_default",
    minimal_width = 300,
    minimal_height = 100,
    maximal_width = 500
}

default_gui["todo_dropdown_default"] = {
    type = "dropdown_style",
    font = "todo_font_default",
}

default_gui["todo_frame_add_where"] = {
    type = "frame_style",
    font = "todo_font_subheading"
}

default_gui["todo_checkbox_default"] = {
    type = "checkbox_style",
    font = "todo_font_default"
}

default_gui["todo_radiobutton_default"] = {
    type = "radiobutton_style",
    font = "todo_font_default"
}
