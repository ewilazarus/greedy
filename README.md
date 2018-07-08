# Greedy

A distributed game, written in Lua.

This game was desinged as part of the distributed systems class at Puc-Rio.


# Pre-requisites

To run this game you must have Lua 5.3+ installed, the luasocket findable on your LUA_PATH and acess to a Mosquitto server.


# Instructions

* clone the project `git clone https://github.com/ewilazarus/greedy.git`
* `cd` into `greedy`
* `./run.sh`

Then you control your square by using the arrow keys.

Optionally, you can also provide the host and port for the Mosquitto server by running

* `MOSQUITTO_HOST=<hostname> MOSQUITTO_PORT=<port> ./run.sh`
