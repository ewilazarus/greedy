local utils = require('utils')

local x_axis_length = 10
local y_axis_length = 10
-- local x_axis_length = 55
-- local y_axis_length = 40
local cell_size = 15


-- Empty model
local Empty = {
    type = 'empty'
}

function Empty:draw(x, y)
    -- empty (pun intended :-])
end


-- Crumb model
local Crumb = {
    type = 'crumb'
}

function Crumb:draw(x, y)
    love.graphics.setColor(1, .3, .3)
    love.graphics.circle(
        'fill',
        (x - 0.5) * cell_size,
        (y - 0.5) * cell_size,
        cell_size/2
    )
end


-- Game state
local GameState = {
    players = {},
    crumbs = 0
}

function GameState:is_game_over()
    return self.crumbs == 0
end


-- Grid model
-- This model is represented by a two dimensional array with some benefits
-- At each i, j position the value can be either:
--      <empty> if it is an empty cell
--      <player> if it hosts a player
--      <crumb> if it hosts a crumb

local Grid = {}
for i = 1, x_axis_length do
    Grid[i] = {}
    for j = 1, y_axis_length do
        Grid[i][j] = Empty
    end
end

function Grid:draw()
    for i = 1, x_axis_length do
        for j = 1, y_axis_length do
            self[i][j]:draw(i, j)
        end
    end
end

function Grid:get_spawnable_coordinates()
    local random_x = utils.random_index(x_axis_length)
    local random_y = utils.random_index(y_axis_length)
    while self[random_x][random_y].type ~= 'empty' do
        random_x = utils.random_index(x_axis_length)
        random_y = utils.random_index(y_axis_length)
    end

    return {
        x = random_x,
        y = random_y
    }
end

function Grid:add_player(player)
    local spawnable_coordinates = self:get_spawnable_coordinates()
    self[spawnable_coordinates.x][spawnable_coordinates.y] = player
    player.coordinates.x = spawnable_coordinates.x
    player.coordinates.y = spawnable_coordinates.y
end

function Grid:update_player(player, x, y)
    if self[x][y].type == 'player' then
        return
    elseif self[x][y].type == 'crumb' then
        GameState.crumbs = GameState.crumbs - 1
    end

    self[player.coordinates.x][player.coordinates.y] = Empty
    self[x][y] = player
    player.coordinates.x = x
    player.coordinates.y = y
end

function Grid:add_crumbs(amount)
    for i = 1, amount do
        local spawnable_coordinates = self:get_spawnable_coordinates()
        self[spawnable_coordinates.x][spawnable_coordinates.y] = Crumb
        GameState.crumbs = GameState.crumbs + 1
    end
end


-- Player model
local function create_player()
    local color = utils.random_color()

    local Player = {
        type = 'player',
        id = utils.uuid(),
        coordinates = {
            x = nil,
            y = nil
        }
    }

    function Player:draw(x, y)
        love.graphics.setColor(color.R, color.G, color.B)
        love.graphics.rectangle(
            'fill',
            (x - 1) * cell_size,
            (y - 1) * cell_size,
            cell_size - 1,
            cell_size - 1
        )
    end

    function Player:move(key)
        local next_x = self.coordinates.x
        local next_y = self.coordinates.y

        if key == 'up' then next_y = next_y - 1
        elseif key == 'down' then next_y = next_y + 1
        elseif key == 'left' then next_x = next_x - 1
        elseif key == 'right' then next_x = next_x + 1
        else return end

        -- makes the canvas "circular"
        if next_x > x_axis_length then next_x = 1
        elseif next_x < 1 then next_x = x_axis_length end

        if next_y > y_axis_length then next_y = 1
        elseif next_y < 1 then next_y = y_axis_length end

        Grid:update_player(player, next_x, next_y)
    end

    return Player
end


-- EXPOSED
return {
    game_state = GameState,
    grid = Grid,
    create_player = create_player
}
