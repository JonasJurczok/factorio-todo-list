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
    assert.is_equal(todo.next_task_id(), 1)
    assert.is_equal(todo.next_task_id(), 2)
    assert.is_equal(todo.next_task_id(), 3)
    assert.is_equal(todo.next_task_id(), 4)
    assert.is_equal(todo.next_task_id(), 5)
    assert.is_equal(todo.next_task_id(), 6)
  end)

  it("should generate ids for existing tasks", function()
    table.insert(_G.global.todo.open, {task = "asd", title = "Task 1", assignee = nil})
    table.insert(_G.global.todo.done, {task = "asd2", title = "Task 2", assignee = nil})

    todo.mod_init()

    assert.is_equal(1, _G.global.todo.open[1].id)
    assert.is_equal(2, _G.global.todo.done[1].id)
  end)

  it("should create a complete task", function()
    local template_task = { ["task"] = "asd", ["title"] = "Title", ["assignee"] = "def" }
    local task = todo.assemble_task(template_task, "Jonas")

    assert.is_equal(1, task.id)
    assert.is_equal("asd", task.task)
    assert.is_equal("def", task.assignee)
    assert.is_equal("Title", task.title)
    assert.is_equal("Jonas", task.created_by)
  end)

  it("should fetch a task by id", function()
    table.insert(_G.global.todo.open, todo.assemble_task({ ["task"] = "asd1", ["title"] = "Title", ["assignee"] = "def1" }, "Jonas"))
    table.insert(_G.global.todo.open, todo.assemble_task({ ["task"] = "asd2", ["title"] = "Title", ["assignee"] = "def2" }, "Jonas"))

    table.insert(_G.global.todo.done, todo.assemble_task({ ["task"] = "asd3", ["title"] = "Title", ["assignee"] = "def3" }, "Jonas"))
    table.insert(_G.global.todo.done, todo.assemble_task({ ["task"] = "asd4", ["title"] = "Title", ["assignee"] = "def4" }, "Jonas"))

    local task = todo.get_task_by_id(1)
    assert.is_equal("asd1", task.task)

    task = todo.get_task_by_id(4)
    assert.is_equal("asd4", task.task)
  end)
end)
