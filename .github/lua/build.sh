#!/bin/sh

set -eu

luacheck ./src/*.lua
luacheck ./src/todo/*.lua
faketorio package -c .travis/.faketorio -v