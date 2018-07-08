socket = require('socket')
local mqtt = require('mqtt_library')
local game = require('game')

mqtt_client = mqtt.client.create(
    os.getenv('MOSQUITTO_HOST'),
    os.getenv('MOSQUITTO_PORT'),
    game.callback)

function love.load()
    player = game.new_player()
    mqtt_client:connect('client#' .. player.id)
    mqtt_client:subscribe({
        'state',
        'players',
        'movements'})
    mqtt_client:publish('players', player:serialize())

    -- Tries to get game state from state subscription
    love.timer.sleep(0.2)
    mqtt_client:handler()
    if not game.ready() then
        game.new()
    end

    -- Unsubscribes from state... we don't need it anymore
    mqtt_client:unsubscribe({'state'})
end

function love.update(dt)
    mqtt_client:handler()

    -- game.state:update(dt)
    if game.over() then
        love.event.quit(0)
    end
end

function love.draw()
    game.draw()
end

local allowedKeys = {
    up = true,
    down = true,
    left = true,
    right = true
}

function love.keypressed(key)
    if allowedKeys[key] ~= nil then
        mqtt_client:publish('movements', player.id .. ':' .. key)
    end
end
