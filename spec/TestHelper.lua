
if not test_helper then test_helper = {} end

function test_helper.initialize_world()
  _G.game = {}
  _G.script = {}
  _G.global = {}
  _G.serpent = require("serpent")

  _G.game.players = {}
  table.insert(_G.game.players, test_helper.create_player("Player_1"))
  table.insert(_G.game.players, test_helper.create_player("Player_2"))

  _G.settings = test_helper.create_settings()
  test_helper.add_default_setting("todolist-show-minimized", true)
  test_helper.add_default_setting("todolist-show-log", false)
end

function test_helper.create_player(name)
  local player = {}
  player.name = name

  player.gui = {}

  player.gui.center = test_helper.create_base_gui()
  player.gui.left = test_helper.create_base_gui()
  player.gui.right = test_helper.create_base_gui()

  return player
end

function test_helper.create_base_gui()
  local gui = {}
  gui.add = test_helper.create_add_function(gui)
  gui.children = {}
  return gui
end

function test_helper.create_add_function(element)
  return function(child)

    element[child.name] = child
    table.insert(element.children, child)

    child.add = test_helper.create_add_function(child)
    child.destroy = test_helper.create_destroy_function(child)
    child.style = {}
    child.parent = element
    child.children = {}
    return child
  end
end

function test_helper.create_destroy_function(element)
  return function()
    local parent = element.parent
    
    for i, child in ipairs(parent.children) do
      if (child.name == element.name) then
        table.remove(parent.children, i)
        break
      end
    end

    parent[element.name] = nil
    element.parent = nil
  end
end

function test_helper.create_settings()
  local settings = {}

  for _, player in pairs(_G.game.players) do
    settings[player.name] = {}
  end

  settings.get_player_settings = function(player)
    return settings[player.name]
  end

  return settings
end

function test_helper.add_default_setting(key, value)

  for _, player in pairs(_G.game.players) do
    _G.settings[player.name][key] = {["key"] = key, ["value"] = value}
  end
end
