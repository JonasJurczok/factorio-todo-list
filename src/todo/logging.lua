-- TODO: String format support missing
function todo.log(message)
    if type(message) == 'table' then
        message = serpent.dump(message) .. ' [' .. #message .. ']'
    end
    message = "" .. message or '<nil>'

    if game then
        for _, p in pairs(game.players) do
            if (todo.show_log(p)) then
                p.print(message)
            end
        end
    else
        error(serpent.dump(message, { compact = false, nocode = true, indent = ' ' }))
    end
end

function todo.show_log(player)
    return settings.get_player_settings(player)["todolist-show-log"].value
end
