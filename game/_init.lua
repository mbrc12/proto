---@class Game : Screen
local Game = {
    ---@type Physics
    physics = nil,
    player = {}
}

Game.__index = Game

function Game.new()
    local self = setmetatable({}, Game)
    self.physics = Physics.new(0, 0)
    self.player = {}
    self.physics:addRect(self.player, { type = "kinematic", category = 1 }, 10, 10)

    return self
end

function Game:enter()
end

function Game:leave()
end

function Game:update(dt)
    local dir = Input:direction()
    local speed = dir * 200
    self.physics:setVelocity(self.player, speed.x, speed.y)

    self.physics:update(dt)
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
        local x, y = self.physics:getPosition(self.player)
        Draw:sprite("player", x, y)
    
        self.physics:draw()
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
