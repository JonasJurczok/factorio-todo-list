feature("Testing the UI", function()
    scenario("initially the maximize button should be displayed.", function()
        local player = game.players[1]
        local button = faketorio.find_element_by_id("todo_maximize_button", player)

        assert(button ~= nil, "Maximize button not found!")
    end)

    scenario("If maximize button should be hidden it should not be displayed.", function()
        -- TODO: how to manipulate settings?
        local temp = todo.show_minimized

        todo.show_minimized = function()
            return false
        end

        local player = game.players[1]
        todo.maximize(player)
        todo.minimize(player)

        local button = faketorio.find_element_by_id("todo_maximize_button", player)

        assert(button == nil, "Maximize button found!")

        todo.show_minimized = temp
    end)
end)