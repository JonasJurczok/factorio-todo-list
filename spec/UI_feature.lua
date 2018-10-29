local task_num = 1
function add_task(text)
    text = text or 'this is a task ' .. task_num
    task_num = task_num + 1

    local task = todo.create_task(text)
    todo.save_task(task)

    return task
end

feature("Testing the UI", function()

    before_scenario(function()
        when(todo, "show_button"):then_return(true)
    end)

    after_scenario(function()
        todo.show_button:revert()

        -- clear all tasks
        global.todo.open = {}
        global.todo.done = {}
    end)

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

        -- replace the 'show_button' mock
        todo.show_button = temp
    end)

    scenario('Clicking the double up button moves that task to the top', function()
        local player = game.players[1]
        add_task()
        middle_task = add_task('middle')
        bottom_task = add_task('at the bottom')

        todo.minimize(player)
        todo.maximize(player)
        todo.refresh_task_table(player)

        faketorio.click('todo_item_top_' .. bottom_task.id)

        assert(global.todo.open[1].task == 'at the bottom')

        faketorio.click('todo_item_top_' .. middle_task.id)

        assert(global.todo.open[1].task == 'middle')
        assert(global.todo.open[2].task == 'at the bottom')
    end)
    -- scenario("Checking 'Add to top' when creating a task should add it to the top of the list", function()
    --     add_task()
    --     add_task()
    --     add_task()

    --     faketorio.click('todo_maximize_button')

    --     -- Add a task to the bottom
    --     faketorio.click('todo_add_button')
    --     faketorio.enter_text('todo_new_task_textbox', 'task for the bottom')
    --     faketorio.click('todo_persist_button')

    --     -- Add a task to the top
    --     faketorio.click('todo_add_button')
    --     faketorio.enter_text('todo_new_task_textbox', 'task for the top')
    --     faketorio.click('todo_add_top')
    --     -- faketorio.click('todo_persist_button')

    --     assert(global.todo.open[5].task == 'task for the bottom')
    --     assert(global.todo.open[1].task == 'task for the top')

    -- end)
end)
