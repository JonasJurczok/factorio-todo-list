


describe("UI tests", function() 

    setup(function()
        require "todo"
	require "spec/TestHelper"
	require "spec/mod-gui"
    end)

    before_each(function()
	test_helper.initialize_world()
	todo.mod_init()	
    end)

    it("Editing a completed task should work", function()
        
	-- create task
	local task = {["task"] = "test", ["assignee"] = nil}        
        table.insert(_G.global.todo.done, task)
	
	-- maximize and refresh UI
	local player = _G.game.players[1]
	todo.maximize(player)
	todo.toggle_show_completed(player)
	todo.update_task_table()

        -- edit
	local event = {}
	event.player = player
        local table = player.gui.left.mod_gui_flow.mod_gui_frame_flow.todo_main_frame.todo_task_table

	local pl = require 'pl.pretty'
	pl.dump(_G.global.todo)
	for _, element in pairs(table.children) do
		pl.dump(element.name)
		if (element.name == "todo_item_edit_done_1") then
			event.element = element
		end
	end

        todo.on_gui_click(event)
        -- save
        -- verify changes
    end)

end)
