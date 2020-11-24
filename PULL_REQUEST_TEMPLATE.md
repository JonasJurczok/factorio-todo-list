## Short title for changes
### Goal
Please describe what the goal of the PR is.

The goal of this PR is to make the mod compatible with the new game version 1.1.

### Questions/Feedback request
Please describe what you want people to think about.

I introduced the global variable `mod-gui` in 'control.lua' with the assignment `mod-gui = require("mod-gui")` while there is already the statement `require "mod-gui"` present. Please consider if the statement-expression is still necessary.

Since this is my first time using lua and updating a mod I would like to recieve your feedback.
