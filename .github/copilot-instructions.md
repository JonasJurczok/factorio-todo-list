# Factorio Todo-List Mod

**ALWAYS follow these instructions completely before using any search commands or bash exploration.** Only use additional search and context gathering if the information in these instructions is incomplete or found to be in error.

Factorio Todo-List is a Lua mod for the Factorio game that provides distributed todo list functionality for multiplayer games. The mod allows players to create, assign, and track tasks collaboratively in their factory.

## Working Effectively

### Environment Setup
- Install Lua and LuaRocks:
  - `sudo apt-get update && sudo apt-get install -y lua5.4 luarocks`
- Install dependencies (takes ~5 seconds total):
  - `luarocks install --local serpent`  (takes ~1.3 seconds)
  - `luarocks install --local busted`   (takes ~1.4 seconds)
  - `luarocks install --local luacheck` (takes ~1.6 seconds)
  - `luarocks install --local faketorio` (takes ~1.0 second)
- Set up local tool access:
  - `export PATH=$PATH:/home/runner/.luarocks/bin`

### Build and Validation
- Lint the code (takes ~0.15 seconds):
  - `luacheck src` - checks all source files for syntax and style issues
  - Currently returns 13 warnings/0 errors - this is the expected baseline
- Create mod package (takes ~0.01 seconds):
  - `cd src && zip -r ../todo-list.zip . -x "*.DS_Store"`
  - This creates a distributable Factorio mod package
- Test structure (has compatibility issues):
  - Tests use busted framework with faketorio but faketorio has Lua 5.1 compatibility issues
  - Test files are in `spec/` directory but may not run properly in current environment

### Manual Validation Scenarios
After making any changes to the codebase, perform these validation steps:

1. **Code Quality Check**: `luacheck src` - Must return no new errors
2. **Package Structure Validation**: 
   - `cd src && zip -r ../test-mod.zip . -x "*.DS_Store"`
   - `unzip -l test-mod.zip | head -20` - Should show control.lua, data.lua, info.json at root
3. **Mod Metadata Check**: `cat src/info.json` - Verify valid JSON with name, version, title fields
4. **Core Files Present**: Verify these essential files exist in src/:
   - `control.lua` (mod runtime logic)
   - `data.lua` (game data definitions)
   - `info.json` (mod metadata)
   - `settings.lua` (mod settings)
5. **Syntax Validation**: The luacheck command validates Lua syntax across all files
6. **File Structure**: Check that src/todo/ contains features/ and ui/ subdirectories

## Validation
- Always run `luacheck src` to check for code issues before making changes
- Verify mod package structure by creating and examining zip contents
- Check that any new Lua files follow the existing code patterns
- Since this is a Factorio mod, full functional testing requires the Factorio game which is not available in this environment
- ALWAYS run linting after making code changes - the CI will fail if linting errors are introduced

## Common Tasks
The following are outputs from frequently run commands. Reference them instead of running bash commands when possible to save time.

### Repository Structure
```
├── .github/                 # GitHub workflows and configuration
├── src/                     # Factorio mod source code
│   ├── control.lua         # Main mod entry point
│   ├── data.lua            # Game data definitions  
│   ├── info.json           # Mod metadata and version
│   ├── settings.lua        # Mod settings
│   ├── graphics/           # Mod icons and images
│   ├── locale/             # Translations
│   └── todo/               # Business logic
│       ├── features/       # Feature implementations
│       ├── ui/             # User interface components
│       ├── todo.lua        # Main todo functionality
│       ├── helper.lua      # Utility functions
│       └── logging.lua     # Debug logging
├── spec/                   # Test files (busted framework)
├── changelog.txt           # Version history
├── release.py              # Release automation script
└── .luacheckrc            # Lua linting configuration
```

### Package Structure Check
```bash
unzip -l todo-list.zip | head -20
# Expected output: graphics/, control.lua, info.json, locale/, data.lua, 
# thumbnail.png, settings.lua, todo/ directory with features/ and ui/ subdirs
```

### Current Linting Status
```bash
luacheck src
# Expected: "Total: 13 warnings / 0 errors in 29 files"
# This baseline should not regress - no new errors should be introduced
```

### Key Files to Understand
- `src/control.lua` - Event handlers and mod initialization
- `src/todo/todo.lua` - Core todo list functionality  
- `src/todo/features/` - Individual feature implementations (add_task.lua, edit_task.lua, etc.)
- `src/todo/ui/` - UI component definitions
- `src/info.json` - Contains mod version and metadata
- `.luacheckrc` - Defines globals and linting rules specific to Factorio modding

### Factorio Mod Conventions
- Mods must have control.lua, data.lua, and info.json in root
- Global variables like `game`, `script`, `defines`, `storage` are provided by Factorio
- UI components use Factorio's GUI API
- Mod lifecycle: data stage (data.lua) -> control stage (control.lua)
- Settings defined in settings.lua appear in game options

### Development Workflow
1. **Set up environment once**: Install Lua 5.4, LuaRocks, and dependencies (~5 seconds)
2. **Before any changes**: Run `export PATH=$PATH:/home/runner/.luarocks/bin`
3. **After making changes**: Run `luacheck src` to verify code quality
4. **Before committing**: Ensure no new linting errors are introduced
5. **Testing mod structure**: Create zip package and verify contents
6. **Release preparation**: Use `release.py` for version management

### Key Reminders
- This is a **Factorio mod**, not a standalone application
- **No build step required** - Lua is interpreted, just lint and package
- **Fast operations** - all commands complete in under 2 seconds
- **CI will fail** if linting introduces new errors beyond the current 13 warnings
- **Essential files**: control.lua, data.lua, info.json, settings.lua must exist in src/
- **Always validate** mod structure after changes to ensure Factorio compatibility