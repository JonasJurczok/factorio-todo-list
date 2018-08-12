feature("Testing the UI", function()
    scenario("initially the maximize button should be displayed.", function()
        local player = game.players[1]
        local button = faketorio.find_element_by_id("todo_maximize_button", player)

        assert(button ~= nil, "Maximize button not found!")
    end)

    scenario("The maximize button should persist when the UI is toggled", function()
        -- TODO: how to manipulate settings?
        local temp = todo.show_button

        todo.show_button = function()
            return false
        end

        local player = game.players[1]
        todo.maximize(player)
        todo.minimize(player)

        local button = faketorio.find_element_by_id("todo_maximize_button", player)

        assert(button ~= nil, "Maximize button not found!")

        todo.show_button = temp
    end)
end)
