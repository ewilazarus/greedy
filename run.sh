#!/bin/bash
# DISCLAIMER: make sure you run this script from within the game folder
PWD=$(pwd)

if [ -z "$MOSQUITTO_HOST" ]; then
    export MOSQUITTO_HOST="localhost"
fi

if [ -z "$MOSQUITTO_PORT" ]; then
    export MOSQUITTO_PORT=1883
fi


# Adds vendor dir into lua path
export LUA_PATH="$PWD/vendor/?.lua;$LUA_PATH"

# Calls love executable
love src
