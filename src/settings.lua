data:extend({
	{
		name = "todolist-show-button",
		setting_type = "runtime-per-user",
		type = "bool-setting",
		default_value = true,
		per_user = true,
	},
	{
		name = "todolist-show-log",
		setting_type = "runtime-per-user",
		type = "bool-setting",
		default_value = false,
		per_user = true,
	},
	{
		name = "todolist-window-height",
		setting_type = "runtime-per-user",
		type = "int-setting",
		default_value = 600,
		per_user = true,
	},
	{
		name = "todolist-auto-assign",
		setting_type = "runtime-per-user",
		type = "bool-setting",
		default_value = false,
		per_user = true,
	},
	{
		name = "todolist-click-edit-task",
		setting_type = "runtime-per-user",
		type = "string-setting",
		allowed_values = {"right-button", "middle-button"},
		default_value = "right-button",
		per_user = true,
	}
})
