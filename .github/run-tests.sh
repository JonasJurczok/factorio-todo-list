#!/bin/sh

set -eu

luacheck ./src/*.lua
luacheck ./src/todo/*.lua
pwd
faketorio package -c ./.github/.faketorio -v