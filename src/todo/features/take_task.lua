--[[
  Business logic for the take task feature.
]]--

function todo.on_take_task_click(player, id)
    todo.log("Assigning task " .. id .. " to player " .. player.name)

    local task = todo.get_task_by_id(id)
    task.assignee = player.name

    todo.update_main_task_list_for_everyone()
end