#!/bin/sh

set -eu

luacheck ./src/*.lua
luacheck ./src/todo/*.lua
ls -al
ls -al .github
faketorio package -c .faketorio -v