local task_num = 1
function add_search_task(player, title, task_text)
    player = player or game.players[1]
    title = title or 'Task ' .. task_num
    task_text = task_text or 'this is task description ' .. task_num
    task_num = task_num + 1
    
    local task_template = { ["task"] = task_text, ["title"] = title }
    local task = todo.assemble_task(task_template, player)
    todo.save_task_to_open_list(task)
    
    return task
end

feature("Search/Filter functionality", function()

    before_scenario(function()
        when(todo, "should_show_maximize_button"):then_return(true)
        todo.maximize_main_frame(game.players[1])
    end)

    after_scenario(function()
        todo.should_show_maximize_button:revert()
        todo.minimize_main_frame(game.players[1])

        -- clear all tasks
        storage.todo.open = {}
        storage.todo.done = {}
    end)

    scenario("Search field should exist in the UI", function()
        local player = game.players[1]
        local frame = todo.get_main_frame(player)
        
        assert(frame ~= nil, "Main frame not found!")
        assert(frame.todo_search_flow ~= nil, "Search flow not found!")
        assert(frame.todo_search_flow.todo_search_field ~= nil, "Search field not found!")
    end)

    scenario("Search should filter tasks by title", function()
        local player = game.players[1]
        
        -- Add some test tasks
        add_search_task(player, "Important Meeting", "Discuss project status")
        add_search_task(player, "Bug Fix", "Fix login issue")
        add_search_task(player, "Code Review", "Review pull request")
        
        -- Get the search field and enter search term
        local frame = todo.get_main_frame(player)
        local search_field = frame.todo_search_flow.todo_search_field
        
        -- Simulate typing "meeting" in the search field
        search_field.text = "meeting"
        todo.refresh_task_table(player, "meeting")
        
        -- Check that only the matching task is displayed
        local task_table = todo.get_task_table(player)
        local task_labels = {}
        for _, child in pairs(task_table.children) do
            if child.name and string.match(child.name, "todo_main_task_title_") then
                table.insert(task_labels, child.caption)
            end
        end
        
        assert(#task_labels == 1, "Expected 1 task, found " .. #task_labels)
        assert(string.find(string.lower(task_labels[1]), "meeting"), "Expected task with 'meeting' in title")
    end)

    scenario("Search should filter tasks by description", function()
        local player = game.players[1]
        
        -- Clear previous tasks
        storage.todo.open = {}
        
        -- Add test tasks
        add_search_task(player, "Task A", "Database optimization work")
        add_search_task(player, "Task B", "Frontend styling")
        add_search_task(player, "Task C", "Database migration scripts")
        
        -- Search for "database"
        local frame = todo.get_main_frame(player)
        local search_field = frame.todo_search_flow.todo_search_field
        search_field.text = "database"
        todo.refresh_task_table(player, "database")
        
        -- Check results
        local task_table = todo.get_task_table(player)
        local task_labels = {}
        for _, child in pairs(task_table.children) do
            if child.name and string.match(child.name, "todo_main_task_title_") then
                table.insert(task_labels, child.caption)
            end
        end
        
        assert(#task_labels == 2, "Expected 2 tasks with 'database', found " .. #task_labels)
    end)

    scenario("Search should show 'no results' message when no matches", function()
        local player = game.players[1]
        
        -- Clear previous tasks
        storage.todo.open = {}
        
        -- Add a task that won't match
        add_search_task(player, "Unrelated Task", "Some other work")
        
        -- Search for something that doesn't exist
        todo.refresh_task_table(player, "nonexistent")
        
        -- Check for no results message
        local task_table = todo.get_task_table(player)
        local found_no_results = false
        for _, child in pairs(task_table.children) do
            if child.caption and type(child.caption) == "table" and child.caption[1] == "todo.no_results" then
                found_no_results = true
                break
            end
        end
        
        assert(found_no_results, "Expected 'no results' message")
    end)

    scenario("Empty search should show all tasks", function()
        local player = game.players[1]
        
        -- Clear previous tasks
        storage.todo.open = {}
        
        -- Add multiple tasks
        add_search_task(player, "Task 1", "Description 1")
        add_search_task(player, "Task 2", "Description 2")
        add_search_task(player, "Task 3", "Description 3")
        
        -- Clear search and refresh
        todo.refresh_task_table(player, "")
        
        -- Check that all tasks are shown
        local task_table = todo.get_task_table(player)
        local task_labels = {}
        for _, child in pairs(task_table.children) do
            if child.name and string.match(child.name, "todo_main_task_title_") then
                table.insert(task_labels, child.caption)
            end
        end
        
        assert(#task_labels == 3, "Expected 3 tasks, found " .. #task_labels)
    end)
end)
