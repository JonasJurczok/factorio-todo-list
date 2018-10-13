-- currently disabled thanks to new features in faketorio
describe("UI tests", function()

  setup(function()
    require "todo"
	require "faketorio_busted"
	require "spec/mod-gui"
  end)

  before_each(function()
	faketorio.initialize_world_busted()
    faketorio.add_default_setting("todolist-show-button", true)
    faketorio.add_default_setting("todolist-show-log", false)
	todo.mod_init()	
  end)

  it("Editing a completed task should work", function()
    
    -- create task
    local task = _G.todo.create_task("test", nil)
    table.insert(_G.global.todo.done, task)
	
    -- maximize and refresh UI
    local player = _G.game.players[1]
    todo.maximize(player)
    todo.toggle_show_completed(player)
    todo.update_task_table()

    -- click edit
    local event = {}
    event.player_index = 1
    local table = player.gui.left.mod_gui_flow.mod_gui_frame_flow.todo_main_frame.todo_task_table

    for _, element in pairs(table.children) do
      if (element.name == "todo_item_edit_1") then
        event.element = element
      end
    end

    todo.on_gui_click(event)

    -- change text
    local textbox = player.gui.center.todo_add_frame.todo_add_task_table.children[2]
    assert.is_equal("test", textbox.text)
    textbox.text = "bestanden"

    -- save
    event = {}
    event.player_index = 1
    event.element = textbox.parent.parent.todo_add_button_flow.children[2]
    todo.on_gui_click(event)

    -- verify
    local task = todo.get_task_by_id(1)
    assert.is_equal("bestanden", task.task)

  end)

  it("should create UI elements with the proper ids", function()
    table.insert(_G.global.todo.open, todo.create_task("asd", "def"))
    local player = _G.game.players[1]
    todo.maximize(player)
    todo.update_task_table()

    local elements = player.gui.left.mod_gui_flow.mod_gui_frame_flow.todo_main_frame.todo_task_table.children

    for name, child in pairs(elements) do
--      require"pl.pretty".dump(child.name..":"..child.caption)
      if (child.name == "todo_item_task_1") then
        assert.is_equal("asd", child.caption)
        return
      end
    end

    assert.is_equal("No element with the corret name or content found", "")
  end)

  pending("assign task to yourself", function()
  end)

  pending("assign completed task to yourself", function()
  end)

end)
