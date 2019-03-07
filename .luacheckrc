globals = {"todo", "mod_gui", "script", "game", "defines", "data", "serpent", "settings", "global"}
read_globals = {
    os = {
        fields = {
            execute = {
                fields = {
                    revert = {},
                    calls = {}
                }
            }
        }
    }
}
files['spec/*_spec.lua'].std = 'max+busted'
files['spec/*_IGNORED_.lua'].std = 'max+busted'