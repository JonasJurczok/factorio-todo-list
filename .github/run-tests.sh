#!/bin/bash

set -eu

luacheck ./src/*.lua
luacheck ./src/todo/*.lua
faketorio package -c .github/.faketorio -v