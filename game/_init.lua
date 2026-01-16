---@class Game : Screen
local Game = {
    ---@type Physics
    physics = nil,
    grounded = false,
    player = {},
    wall = {},
}

Game.__index = Game

function Game.new()
    local self = setmetatable({}, Game)
    self.physics = Physics.new(0, 0)
    self.player = {}
    self.wall = {}
    self.physics:addRect(self.player, { type = "dynamic", category = 1 }, 10, 10)
    -- self.physics:setCallback(self.player, function(other)
    --     if other == self.wall then
    --         self.grounded = true
    --     end
    -- end)

    self.physics:addRect(self.wall, { type = "static", category = 2 }, 200, 5)
    self.physics:setPosition(self.wall, 0, 70)

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
        local x, y = self.physics:getPosition(self.player, true)
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
