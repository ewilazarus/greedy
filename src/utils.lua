local socket = require('socket')

-- Seeds math to prevent same UUID generation on every run (maybe not necessary)
math.randomseed(socket.gettime()*1000)

-- UUID private goodies
local uuid_template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

local function uuid_composer(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
end

-- Color segment generator
local function get_random_color_segment()
    return tonumber(string.format('%.2f', math.random()))
end


-- EXPOSED
return {
    uuid = function()
        return string.gsub(uuid_template, '[xy]', uuid_composer)
    end,

    random_color = function()
        return {
            R = get_random_color_segment(),
            G = get_random_color_segment(),
            B = get_random_color_segment()
        }
    end,

    random_index = function(upper_bound)
        return math.random(1, upper_bound)
    end,

    str_concat = function(ss, separator)
        return table.concat(ss, separator)
    end,

    str_split = function(s, separator)
        rv = {};
        for match in (s .. separator):gmatch("(.-)" .. separator) do
            table.insert(rv, match)
        end
        return rv
    end
}
