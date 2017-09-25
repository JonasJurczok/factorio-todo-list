
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
        table.insert(global.todo.done, task)
      
        -- edit
	local player = {}
	player.gui = {}
	player.gui.center = {}
	player.gui.center.add = function(element)
		element.add = function(child)
			table.insert(element, child)
			return child
		end
		table.insert(player.gui.center, element)
		return element
	end

        todo.edit_task(player , 1)
        -- save
        -- verify changes
    end)

end)
