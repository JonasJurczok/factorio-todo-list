--[[
  Location / map-pin feature.
  Pure location logic: capture, format, zoom, chart-tag lifecycle.
]]--

function todo.capture_player_location(player)
    return {
        x = player.position.x,
        y = player.position.y,
        surface_index = player.surface.index,
    }
end

function todo.format_location_caption(location)
    if not location then
        return { "todo.pin_none" }
    end
    local surface = game.get_surface(location.surface_index)
    local surface_name = surface and surface.valid and surface.name or "?"
    return { "todo.pin_caption",
        math.floor(location.x),
        math.floor(location.y),
        surface_name }
end

function todo.zoom_to_task_location(player, task)
    if not (task.location) then
        return
    end
    local location = task.location
    local surface = game.get_surface(location.surface_index)
    if not (surface and surface.valid) then
        player.print({ "todo.pin_surface_missing" })
        return
    end
    player.zoom_to_world({ x = location.x, y = location.y }, 1, surface)
end

function todo.on_pin_set_click(player, dialog_kind)
    local dialog
    if dialog_kind == "add" then
        dialog = todo.get_add_dialog(player)
    else
        dialog = todo.get_edit_dialog(player)
    end
    if not dialog then return end

    local loc = todo.capture_player_location(player)
    dialog.tags = { pending_location = loc }

    local table_name = dialog_kind == "add" and "todo_add_task_table" or "todo_edit_task_table"
    local caption_name = dialog_kind == "add" and "todo_add_pin_caption_label" or "todo_edit_pin_caption_label"
    local t = dialog[table_name]
    if t and t[caption_name] then
        t[caption_name].caption = todo.format_location_caption(loc)
    end
end

function todo.on_pin_clear_click(player, dialog_kind)
    local dialog
    if dialog_kind == "add" then
        dialog = todo.get_add_dialog(player)
    else
        dialog = todo.get_edit_dialog(player)
    end
    if not dialog then return end

    dialog.tags = {}

    local table_name = dialog_kind == "add" and "todo_add_task_table" or "todo_edit_task_table"
    local caption_name = dialog_kind == "add" and "todo_add_pin_caption_label" or "todo_edit_pin_caption_label"
    local t = dialog[table_name]
    if t and t[caption_name] then
        t[caption_name].caption = { "todo.pin_none" }
    end
end

function todo.on_main_task_pin_click(player, id)
    local task = todo.get_task_by_id(id)
    if not task then return end
    todo.zoom_to_task_location(player, task)
end

function todo.create_chart_tag_for_task(task, player)
    if not task.location then return end
    local location = task.location

    local surface = game.get_surface(location.surface_index)
    if not (surface and surface.valid) then
        todo.log("Cannot place chart tag: surface missing for task " .. task.id)
        return
    end

    local title = task.title or ""
    if string.find(title, "%[") then
        title = "Todo task"
    else
        title = string.sub(title, 1, 40)
    end

    local chart_tag = player.force.add_chart_tag(surface, {
        position = { location.x, location.y },
        icon = { type = "virtual", name = "signal-info" },
        text = title,
        last_user = player,
    })
    if chart_tag then
        location.chart_tag_number = chart_tag.tag_number
        location.chart_tag_force  = player.force.name
    else
        todo.log("add_chart_tag returned nil for task " .. task.id .. " (unexplored chunk?)")
    end
end

function todo.destroy_chart_tag_for_task(task)
    if not (task.location and task.location.chart_tag_number) then return end
    local loc = task.location
    local force = game.forces[loc.chart_tag_force]
    if not (force and force.valid) then
        loc.chart_tag_number = nil
        loc.chart_tag_force  = nil
        return
    end
    local surface = game.get_surface(loc.surface_index)
    if not (surface and surface.valid) then
        loc.chart_tag_number = nil
        loc.chart_tag_force  = nil
        return
    end
    for _, tag in pairs(force.find_chart_tags(surface)) do
        if tag.valid and tag.tag_number == loc.chart_tag_number then
            tag.destroy()
            break
        end
    end
    loc.chart_tag_number = nil
    loc.chart_tag_force  = nil
end
