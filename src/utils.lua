local socket = require('socket')

-- Seeds math to prevent same UUID generation on every run (maybe not necessary)
math.randomseed(socket.gettime()*1000)

-- UUID private goodies
local uuid_template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

local function uuid_composer(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
end


-- EXPOSED
return {
    uuid = function()
        return string.gsub(uuid_template, '[xy]', uuid_composer)
    end
}
