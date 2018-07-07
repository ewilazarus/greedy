function love.load()
    gridXCount = 54
    gridYCount = 40

    function reset()
        availablePositions = {}
        players = {}
        crumbs = {}
        directionQueue = {'right'}
        timer = 0
    end

    reset()

    function computeAvailablePositions()
        availablePositions = {}

        for x = 1, gridXCount do
            for y = 1, gridYCount do
                local isAvailablePosition = true

                for _, player in ipairs(players) do
                    if x == player.x and y == player.y then
                        isAvailablePosition = false
                    end
                end
                
                for _, crumb in ipairs(crumbs) do
                    if x == crumb.x and y == crumb.y then
                        isAvailablePosition = false
                    end
                end

                if isAvailablePosition then
                    table.insert(availablePositions, {x = x, y = y})
                end
            end
        end
    end

    computeAvailablePositions()

    function spawnPlayers()
        local randomIndex = love.math.random(1, #availablePositions)
        table.insert(players, availablePositions[randomIndex])
        table.remove(availablePositions, randomIndex)
    end

    spawnPlayers()

    function spawnCrumbs()
        while #crumbs <= 50 do
            local randomIndex = love.math.random(1, #availablePositions)
            table.insert(crumbs, availablePositions[randomIndex])
            table.remove(availablePositions, randomIndex)
        end
    end

    spawnCrumbs()
end

function love.update(dt)
    timer = timer + dt

    local timerLimit = 0.15
    if timer >= timerLimit then
        timer = timer - timerLimit

        if #directionQueue > 1 then
            table.remove(directionQueue, 1)
        end

        local nextXPosition = players[1].x
        local nextYPosition = players[1].y

        if directionQueue[1] == 'right' then
            nextXPosition = nextXPosition + 1
            if nextXPosition > gridXCount then
                nextXPosition = 1
            end
        elseif directionQueue[1] == 'left' then
            nextXPosition = nextXPosition - 1
            if nextXPosition < 1 then
                nextXPosition = gridXCount
            end
        elseif directionQueue[1] == 'down' then
            nextYPosition = nextYPosition + 1
            if nextYPosition > gridYCount then
                nextYPosition = 1
            end
        elseif directionQueue[1] == 'up' then
            nextYPosition = nextYPosition - 1
            if nextYPosition < 1 then
                nextYPosition = gridYCount
            end
        end

        local canMove = true

        for segmentIndex, segment in ipairs(players) do
            if segmentIndex ~= #players
            and nextXPosition == segment.x 
            and nextYPosition == segment.y then
                canMove = false
            end
        end

        if canMove then
            table.insert(availablePositions, {x = players[1].x, y = players[1].y})
            players[1] = {x = nextXPosition, y = nextYPosition}

            for i, crumb in ipairs(crumbs) do
                if players[1].x == crumb.x and players[1].y == crumb.y then
                    table.remove(crumbs, i)
                    spawnCrumbs()
                end
            end
        end
    end
end

function love.draw()
    local cellSize = 15

    love.graphics.setColor(.28, .28, .28)
    love.graphics.rectangle(
        'fill',
        0,
        0,
        gridXCount * cellSize,
        gridYCount * cellSize
    )

    for _, player in ipairs(players) do
        love.graphics.setColor(.6, 1, .32)
        love.graphics.rectangle(
            'fill',
            (player.x - 1) * cellSize,
            (player.y - 1) * cellSize,
            cellSize - 1,
            cellSize - 1
        )
    end

    for _, crumb in ipairs(crumbs) do
        love.graphics.setColor(1, .3, .3)
        love.graphics.circle(
            'fill',
            (crumb.x - 0.5) * cellSize,
            (crumb.y - 0.5) * cellSize,
            cellSize/2
        )
    end
end

function love.keypressed(key)
    if key == 'right'
    and directionQueue[#directionQueue] ~= 'right'
    and directionQueue[#directionQueue] ~= 'left' then
        table.insert(directionQueue, 'right')

    elseif key == 'left'
    and directionQueue[#directionQueue] ~= 'left'
    and directionQueue[#directionQueue] ~= 'right' then
        table.insert(directionQueue, 'left')

    elseif key == 'up'
    and directionQueue[#directionQueue] ~= 'up'
    and directionQueue[#directionQueue] ~= 'down' then
        table.insert(directionQueue, 'up')

    elseif key == 'down'
    and directionQueue[#directionQueue] ~= 'down'
    and directionQueue[#directionQueue] ~= 'up' then
        table.insert(directionQueue, 'down')
    end
end
