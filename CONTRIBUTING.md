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
