
require "spec/mod-gui"


describe("UI tests", function() 

    global = {}

    setup(function()
        require "todo"
    end)

    before_each(function()
        global.todo = {["open"] = {}, ["done"] = {}}
    end)

    it("Editing a completed task should work", function()
        -- create task
	local task = {["task"] = "test", ["assignee"] = nil}        
        table.insert(global.todo.open, task)

	-- mark complete
        todo.mark_complete(1)        
        -- edit
        -- save
        -- verify changes
    end)

end)
