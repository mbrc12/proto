require("constants")
require("lib._init")
require("assets.index")

local manual_gc = require("deps.manual_gc")

function love.load()
    love.joystick.loadGamepadMappings("assets/extra/mappings.txt")

    Log({ love.graphics.getRendererInfo() })

    love.graphics.setDefaultFilter("nearest", "nearest")
    -- love.audio.setVolume(0.5)

    Camera:reset()
    Assets:load()
    Input:init()
    Mouse:init()
    Draw:init()
end

pos = Vec2.new()

function love.update(dt)
    Input:update(dt)
    Mouse:update()

    local dir = Input:direction()
    pos = pos + dir * 200 * dt

    manual_gc(1e-3, 64)
end


function love.draw()
    Draw:begin()

    Draw:draw("main", 1, function()
        local color
        if Input:isJustPressed("INTERACT") then
            Sounds:sfx("bong")
        end
        if Input:isPressed("INTERACT") then
            color = Colors.SteamLords.eggplant_purple
        else
            color = Colors.White
        end
        love.graphics.setColor(color)
        Draw:sprite("bullet", pos.x, pos.y)
    end)

    Draw:draw("ui", 2, function()
        love.graphics.setColor(Colors.White)

        local message = string.format("%s, %d fps, %.1fM",
            Input:debugString(),
            love.timer.getFPS(),
            collectgarbage("count")/1024
        )
        Draw:rightAlignedText(message, -1, 1)
    end)

    Draw:finish()

    -- preserve aspect ratio
    love.graphics.clear(Colors.Black)
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    local finalCanvas = Draw:getFinalCanvas()
    local finalCanvas_width, finalCanvas_height = finalCanvas:getDimensions()
    local scale = math.min(window_width / finalCanvas_width, window_height / finalCanvas_height)
    if INTEGER_SCALING then
        scale = math.floor(scale + EPSILON)
    end
    local offset_x = (window_width - scale * finalCanvas_width) / 2
    local offset_y = (window_height - scale * finalCanvas_height) / 2

    love.graphics.draw(finalCanvas, offset_x, offset_y, 0, scale, scale)

    manual_gc(1e-3, 64)
end

