local task_num = 1
function add_task(player, text)
    player = player or game.players[1]

    text = text or 'this is a task ' .. task_num
    task_num = task_num + 1
    local task_template = { ["task"] = text, ["title"] = "Title", ["assignee"] = "def" }
    local task = todo.assemble_task(task_template, player)
    todo.save_task_to_open_list(task)

    return task
end

feature("Testing the UI", function()

    before_scenario(function()
        when(todo, "is_show_maximize_button"):then_return(true)
    end)

    after_scenario(function()
        todo.is_show_maximize_button:revert()

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
        todo.minimize_main_frame(player)

        -- Mock out the 'is_show_maximize_button' function
        local temp = todo.is_show_maximize_button
        todo.is_show_maximize_button = function()
            return false
        end

        todo.maximize_main_frame(player)
        todo.minimize_main_frame(player)

        local button = faketorio.find_element_by_id("todo_maximize_button", player)

        assert(button ~= nil, "Maximize button not found!")

        -- replace the 'is_show_maximize_button' mock
        todo.is_show_maximize_button = temp
    end)

    scenario('Clicking the double up button moves that task to the top', function()
        local player = game.players[1]
        add_task()
        middle_task = add_task(player, 'middle')
        bottom_task = add_task(player, 'at the bottom')

        todo.minimize_main_frame(player)
        todo.maximize_main_frame(player)
        todo.refresh_task_table(player)

        faketorio.click('todo_main_task_move_top_' .. bottom_task.id)

        assert(global.todo.open[1].task == 'at the bottom')

        faketorio.click('todo_main_task_move_top_' .. middle_task.id)

        assert(global.todo.open[1].task == 'middle')
        assert(global.todo.open[2].task == 'at the bottom')
    end)

     scenario("Checking 'Add to top' when creating a task should add it to the top of the list", function()
         local player = game.players[1]

         add_task()
         add_task()
         add_task()

         faketorio.click('todo_maximize_button')

         -- Add a task to the bottom
         faketorio.click('todo_open_add_dialog_button')
         faketorio.enter_text('todo_new_task_textbox', 'task for the bottom')
         faketorio.click('todo_save_new_task_button')

         -- Add a task to the top
         faketorio.click('todo_open_add_dialog_button')
         faketorio.enter_text('todo_new_task_textbox', 'task for the top')
         faketorio.check('todo_add_top')
         faketorio.click('todo_save_new_task_button')

         assert(global.todo.open[5].task == 'task for the bottom')
         assert(global.todo.open[1].task == 'task for the top')
     end)
end)
