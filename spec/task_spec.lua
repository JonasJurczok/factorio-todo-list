-- currently disabled thanks to new features in faketorio
describe("task tests", function()

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

  it("Generating an id should create the correct result.", function()
    assert.is_equal(todo.generate_id(), 1)
    assert.is_equal(todo.generate_id(), 2)
    assert.is_equal(todo.generate_id(), 3)
    assert.is_equal(todo.generate_id(), 4)
    assert.is_equal(todo.generate_id(), 5)
    assert.is_equal(todo.generate_id(), 6)
  end)

  it("should generate ids for existing tasks", function()
    table.insert(_G.global.todo.open, {task = "asd", assignee = nil})
    table.insert(_G.global.todo.done, {task = "asd2", assignee = nil})

    todo.mod_init()

    assert.is_equal(1, _G.global.todo.open[1].id)
    assert.is_equal(2, _G.global.todo.done[1].id)
  end)

  it("should create a complete task", function()
    local task = todo.create_task("asd", "def")

    assert.is_equal(1, task.id)
    assert.is_equal("asd", task.task)
    assert.is_equal("def", task.assignee)
  end)

  it("should fetch a task by id", function()
    table.insert(_G.global.todo.open, todo.create_task("asd1", "def1"))
    table.insert(_G.global.todo.open, todo.create_task("asd2", "def2"))    

    table.insert(_G.global.todo.done, todo.create_task("asd3", "def3"))    
    table.insert(_G.global.todo.done, todo.create_task("asd4", "def4"))    

    local task = todo.get_task_by_id(1)
    assert.is_equal("asd1", task.task)

    task = todo.get_task_by_id(4)
    assert.is_equal("asd4", task.task)
  end)
end)
