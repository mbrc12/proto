require("constants")
require("lib._init")
require("assets.index")
local manual_gc = require("deps.manual_gc")

local Game = require("game._init")

Globals = {
    ---@type Screen
    screen = nil,
}

---@param newScreen Screen
function _G.switchScreen(newScreen)
    if Globals.screen and Globals.screen.leave then
        Globals.screen:leave()
    end
    Globals.screen = newScreen
    if Globals.screen.enter then
        Globals.screen:enter()
    end
end

function love.load()
    --- I do not want to see physics deprecation warnings
    -- love.setDeprecationOutput(false)

    love.joystick.loadGamepadMappings("assets/extra/mappings.txt")

    Log({ love.graphics.getRendererInfo() })

    love.graphics.setDefaultFilter("nearest", "nearest")
    -- love.audio.setVolume(0.5)

    Camera:reset()
    Assets:load()
    Input:init()
    Mouse:init()
    Draw:init()

    switchScreen(Game.new())
end

function love.update(dt)
    Input:update(dt)
    Mouse:update()

    Globals.screen:update(dt)

    manual_gc(1e-3, 64)
end

local lastTime = 0

function love.draw()
    Draw:begin()

    Globals.screen:draw()

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

function love.quit()
    Globals.screen:leave()
end
