#!/bin/bash
# DISCLAIMER: make sure you run this script from within the game folder
PWD=$(pwd)

# Adds vendor dir into lua path
export LUA_PATH="$PWD/vendor/?.lua;$LUA_PATH"

# Calls love executable
love src
