local task_num = 1
function add_task(task)
    task = task or 'this is a task ' .. task_num
    task_num = task_num + 1

    return task
end

feature("Testing the UI", function()
    scenario("initially the maximize button should be displayed.", function()
        local player = game.players[1]
        local button = faketorio.find_element_by_id("todo_maximize_button", player)

        assert(button ~= nil, "Maximize button not found!")
    end)

    scenario("The maximize button should persist when the UI is toggled", function()
        -- Ensure the UI is closed
        local player = game.players[1]
        todo.minimize(player)

        -- Mock out the 'show_button' function
        local temp = todo.show_button
        todo.show_button = function()
            return false
        end

        todo.maximize(player)
        todo.minimize(player)

        local button = faketorio.find_element_by_id("todo_maximize_button", player)

        assert(button ~= nil, "Maximize button not found!")

        -- replade the 'show_button' mock
        todo.show_button = temp
    end)

    scenario("Checking 'Add to top' when creating a task should add it to the top of the list", function()
        log('added task ' .. add_task())
        log('added task ' .. add_task())
        log('added task ' .. add_task())
        log('added task ' .. add_task())
        -- Open the todo list
        -- Click 'add new task'
        -- enter some text
        --
    end)
end)
