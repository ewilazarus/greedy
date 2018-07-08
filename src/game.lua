local utils = require('utils')


local Player = { type = 'player' }
local Crumb = { type = 'crumb' }

-------------------------------------------------------------------------------
--------------------------------- DIMENSIONS ----------------------------------
-------------------------------------------------------------------------------
local x_axis_length = 53
local y_axis_length = 40
local cell_size = 15


-------------------------------------------------------------------------------
--------------------------------- GAME STATE ----------------------------------
-------------------------------------------------------------------------------

-------------------------------- State ----------------------------------------
-- Represents the state itself

local State = {
    t = 0,
    players = {},
    crumbs = {},
    crumb_count = 0,
}

function State:serialize()
    -- Serializes time
    local s = {tostring(self.t)}

    -- Serializes players
    local splayers = {}
    for _, player in pairs(self.players) do
        table.insert(splayers, player:serialize())
    end
    table.insert(s, utils.str_concat(splayers, ';'))

    -- Serializes crumbs
    local scrumbs = {}
    for _, crumb in pairs(self.crumbs) do
        table.insert(scrumbs, crumb:serialize())
    end
    table.insert(s, utils.str_concat(scrumbs, ';'))

    return utils.str_concat(s, '|')
end

function State:deserialize(s)
    local ss = utils.str_split(s, '|')

    -- Deserializes time
    self.t = tonumber(ss[1])

    -- Deserializes players
    for _, splayer in utils.str_split(ss[2], ';') do
        local player = Player:deserialize(splayer)
        self.players[player.id] = player
    end

    -- Deserializes crumbs
    for _, scrub in utils.str_split(ss[3], ';') do
        local crumb = Crumb:deserialize(scrumb)
        self.crumbs[crumb.id] = crumb
        self.crumb_count = self.crumb_count + 1
    end
end


----------------------------------- Grid --------------------------------------
-- Represents the grid in a matrix-like fashion

local Grid = {}
for i = 1, x_axis_length do
    Grid[i] = {}
    for j = 1, y_axis_length do
        Grid[i][j] = nil
    end
end

function Grid:draw()
    for i = 1, x_axis_length do
        for j = 1, y_axis_length do
            if self[i][j] ~= nil then
                self[i][j]:draw(i, j)
            end
        end
    end
end

function Grid:get_spawnable_coordinates()
    local random_x = utils.random_index(x_axis_length)
    local random_y = utils.random_index(y_axis_length)
    while self[random_x][random_y] ~= nil do
        random_x = utils.random_index(x_axis_length)
        random_y = utils.random_index(y_axis_length)
    end
    return { x = random_x, y = random_y }
end

function Grid:update_player(player, x, y)
    if self[x][y] ~= nil then
        if self[x][y].type == 'player' then return end
        State.crumbs[self[x][y].id] = nil
        State.crumb_count = State.crumb_count - 1
    end

    self[player.coordinates.x][player.coordinates.y] = nil
    self[x][y] = player
    player.coordinates.x = x
    player.coordinates.y = y
end


-------------------------------------------------------------------------------
----------------------------------- MODELS ------------------------------------
-------------------------------------------------------------------------------

----------------------------------- Crumb -------------------------------------
-- Represents the crumb on the board

function Crumb:new()
    local crumb = utils.copy(self, {
        id = utils.uuid()
    })

    crumb.coordinates = Grid:get_spawnable_coordinates()
    Grid[crumb.coordinates.x][crumb.coordinates.y] = crumb
    State.crumbs[crumb.id] = crumb
    State.crumb_count = State.crumb_count + 1

    return crumb
end

function Crumb:draw(x, y)
    love.graphics.setColor(1, .3, .3)
    love.graphics.circle(
        'fill',
        (x - 0.5) * cell_size,
        (y - 0.5) * cell_size,
        cell_size/2
    )
end

function Crumb:serialize()
    local s = {self.id}
    table.insert(s, tostring(self.coordinates.x))
    table.insert(s, tostring(self.coordinates.y))
    return utils.str_concat(s, ',')
end

function Crumb:deserialize(s)
    local crumb = utils.copy(self, {})

    local ss = utils.str_split(s, ',')
    crumb.id = ss[1]
    crumb.coordinates = {
        x = tonumber(ss[2]),
        y = tonumber(ss[3])
    }
    return crumb
end



------------------------------------ Player -----------------------------------
-- Represents the player on the board

function Player:new()
    local player = utils.copy(self, {
        id = utils.uuid(),
        color = utils.random_color()
    })

    player.coordinates = Grid:get_spawnable_coordinates()
    Grid[player.coordinates.x][player.coordinates.y] = player
    State.players[player.id] = player

    return player
end

function Player:draw(x, y)
    love.graphics.setColor(self.color.R, self.color.G, self.color.B)
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

function Player:serialize()
    local s = {self.id}
    table.insert(s, tostring(self.coordinates.x))
    table.insert(s, tostring(self.coordinates.y))
    table.insert(s, tostring(self.color.R))
    table.insert(s, tostring(self.color.G))
    table.insert(s, tostring(self.color.B))
    return utils.str_concat(s, ',')
end

function Player:deserialize(s)
    local player = utils.copy(self, {})

    local ss = utils.str_split(s, ',')
    player.id = ss[1]
    player.coordinates = {
        x = tonumber(ss[2]),
        y = tonumber(ss[3])
    }
    player.color = {
        R = tonumber(ss[4]),
        G = tonumber(ss[5]),
        B = tonumber(ss[6])
    }
    return player
end


-------------------------------------------------------------------------------
---------------------------------- EXPOSED ------------------------------------
-------------------------------------------------------------------------------

return {
    -- Just adds new crumbs to the board
    new = function()
        for i = 1, 50 do
            Crumb:new()
        end
    end,

    -- Deserializes and loads given game state
    load = function(state)
        State:deserialize(state)

        -- Adds deserialized players to grid
        for _, player in ipairs(State.players) do
            Grid[player.coordinates.x][player.coordinates.y] = player
        end

        -- Adds deserialized crumbs to grid
        for _, crumb in ipairs(State.crumbs) do
            Grid[crumb.coordinates.x][crumb.coordinates.y] = crumb
        end
    end,

    -- Tests if there are still available crumbs
    over = function()
        return State.crumb_count == 0
    end,

    -- Draws the game
    draw = function()
        Grid:draw()
    end,

    -- Returns a new player
    new_player = function()
        return Player:new()
    end,

    state = function()
        return State:serialize()
    end,

    callback = function(topic, message)
        print(topic .. ": " .. message)
    end
}

