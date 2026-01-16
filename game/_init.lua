---@class Game : Screen
local Game = {
    ---@type Physics
    physics = nil,
    grounded = false,
    player = {},
    wall = {},
    elevator = {},
}

Game.__index = Game

function Game.new()
    local self = setmetatable({}, Game)
    self.physics = Physics.new(0, 1e4)
    self.player = {}
    self.wall = {}
    self.elevator = {}

    self.physics:addCircle(self.player, { type = "dynamic", category = 1 }, 6)

    self.physics:addRect(self.elevator, { type = "kinematic", category = 3 }, 40, 6)

    self.physics:addRect(self.wall, { type = "static", category = 2 }, 200, 10)
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

    local function periodic(t, period)
        local phase = (t % period) / period
        if phase < 0.5 then
            return -1
        else
            return 1
        end
    end

    self.physics:setVelocity(self.elevator, 0, 30 * periodic(love.timer.getTime(), 2))

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

        local ex, ey = self.physics:getPosition(self.elevator, true)
        Ninepatch:draw("wall", ex - 20, ey - 3, 40, 6)

        local wx, wy = self.physics:getPosition(self.wall, true)
        Ninepatch:draw("wall", wx - 100, wy - 5, 200, 10)

        -- self.physics:draw()
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
