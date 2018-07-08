socket = require("socket")
local mqtt = require("mqtt_library")
local callback = require('callback')
local game = require('game')

local mqtt_client = mqtt.client.create(
    os.getenv("MOSQUITTO_HOST"),
    os.getenv("MOSQUITTO_PORT"),
    callback)

function love.load()
    player = game.new_player()
    mqtt_client:connect("client#" .. player.id)
    mqtt_client:subscribe({"test1"})

    game.new()
end

function love.update(dt)
    -- game.state:update(dt)
    if game.over() then
        love.event.quit(0)
    end
end

function love.draw()
    game.draw()
end

function love.keypressed(key)
    player:move(key)
end
