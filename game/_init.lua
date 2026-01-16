---@class Game : Screen
local Game = {
    pos = Vec2.new()
}

Game.__index = Game

function Game.new()
    local self = setmetatable({}, Game)
    return self
end

function Game:enter()
end

function Game:leave()
end

function Game:update(dt)
    local dir = Input:direction()
    self.pos = self.pos + dir * 200 * dt
end

function Game:draw()
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
        Draw:sprite("bullet", self.pos.x, self.pos.y)
    end)

    Draw:draw("ui", 2, function()
        love.graphics.setColor(Colors.White)

        local message = string.format("%s, %d fps, %.1fM",
            Input:debugString(),
            love.timer.getFPS(),
            collectgarbage("count") / 1024
        )
        Draw:rightAlignedText(message, -1, 1)
    end)
end

return Game
