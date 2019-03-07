#!/bin/sh

set -eu

luacheck ./src/*.lua
luacheck ./src/todo/*.lua
faketorio package -c .travis/.faketorio -v

# If RELEASE
# get version from info.json
# git tag
# upload artifact