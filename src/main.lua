
-- package.path = "./vendor/?.lua;" .. package.path
-- socket = require("socket")
-- local mqtt = require("mqtt_library")

-- function mqttcb(topic, message)
--     print(topic .. ": " .. message)
-- end

-- mqtt_client = mqtt.client.create("localhost", 1883, mqttcb)
-- mqtt_client:connect("cliente love")
-- mqtt_client:subscribe({"test1"})

local models = require('models')


function love.load()
    grid = models.grid
    grid:add_crumbs(50)

    player = models.create_player()
    grid:add_player(player)
end

function love.update(dt)
    if models.game_state:is_game_over() then
        love.event.quit(0)
    end
end

function love.draw()
    grid:draw()
end

function love.keypressed(key)
    player:move(key)
end
