if not todo then todo = {} end

-- Function to filter tasks based on search term
function todo.filter_tasks_by_search(tasks, search_term)
    if not search_term or search_term == "" then
        return tasks
    end
    
    local filtered_tasks = {}
    search_term = string.lower(search_term)
    
    for _, task in ipairs(tasks) do
        -- Search in task title and task description
        if string.find(string.lower(task.title or ""), search_term) or 
           string.find(string.lower(task.task or ""), search_term) then
            table.insert(filtered_tasks, task)
        end
        
        -- Search in subtasks if they exist
        if task.subtasks then
            for _, subtask in ipairs(task.subtasks) do
                if string.find(string.lower(subtask.title or ""), search_term) then
                    -- Add the parent task if not already added
                    if not todo.task_exists_in_list(filtered_tasks, task) then
                        table.insert(filtered_tasks, task)
                    end
                    break
                end
            end
        end
    end
    
    return filtered_tasks
end

-- Helper function to check if task exists in list
function todo.task_exists_in_list(list, task)
    for _, t in ipairs(list) do
        if t.id == task.id then
            return true
        end
    end
    return false
end
