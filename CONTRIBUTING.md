## How to contribute?

If you want to contribute feel free to create a [pull request](https://github.com/JonasJurczok/factorio-todo-list/pulls) (with new translations for example).

Otherwise you can [create an issue](https://github.com/JonasJurczok/factorio-todo-list/issue) if you find a bug or have
an idea for a feature.

If you don't have a github account feel free to contact us via mail at `jonasjurczok+factorio@gmail.com`.

## Changelog format

`changelog.txt` must follow the [Factorio changelog format](https://wiki.factorio.com/Tutorial:Mod_changelog_format) exactly, otherwise the mod portal will not display it.

Each entry:
```
---------------------------------------------------------------------------------------------------
Version: X.Y.Z
Date: YYYY-MM-DD
  <Category>:
    - Description of change.
```

**Valid category names** (anything else breaks the parser):
- `Features`
- `Minor Features`
- `Bugfixes`
- `Changes`
- `Optimizations`
- `Locale`
- `Graphics`
- `Control`
- `Scripting`
- `Major Features`

Common mistakes to avoid:
- `Improvements` → use `Changes`
- `Fix` → use `Bugfixes`
- `Feature` (singular) → use `Features`
- Inline text on the category line (e.g. `Feature: foo`) → put text as a `    - ` bullet on the next line
- Non-zero-padded dates (e.g. `2020-03-7`) → use `2020-03-07`

## Factorio API gotchas

### Sprites in GUI elements

`sprite-button.sprite` (and `sprite` elements) at **runtime** require a registered sprite prototype name — **not** a raw file path.

❌ Wrong — crashes with `Unknown sprite` at runtime:
```lua
{ type = "sprite-button", sprite = "__Todo-List__/graphics/close.png" }
```

✅ Correct — register the sprite in `data.lua` first:
```lua
-- in data.lua (data stage)
data:extend({{
    type = "sprite",
    name = "todo-close",
    filename = "__Todo-List__/graphics/close.png",
    size = 32,
    flags = {"gui-icon"},
}})

-- then in runtime Lua
{ type = "sprite-button", sprite = "todo-close" }
```

**Exception**: data-stage prototype fields (`shortcut.icon`, `sprite.filename`, `item.icon`, etc.) do accept raw `__ModName__/...` file paths. Only GUI runtime elements require the registered name.

Built-in Factorio sprites like `utility/close`, `utility/rename_icon` etc. are always valid in GUI elements without registration.
