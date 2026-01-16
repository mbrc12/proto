---@class Game : Screen
local Game = {
    ---@type Physics
    physics = nil,
    grounded = false,
    player = {},
    wall = {},
    elevator = {},
    boundaries = {},
}

Game.__index = Game

function Game.new()
    local self = setmetatable({}, Game)
    self.physics = Physics.new(0, 1e4)
    self.player = {}
    self.wall = {}
    self.elevator = {}
    self.boundaries = {}

    local rect, circle = Physics.rect, Physics.circle

    self.physics:addBody(self.player, { type = "dynamic", category = 1 }, { circle(6) })

    self.physics:addBody(self.elevator, { type = "kinematic", category = 3 }, { rect(40, 6) })
    self.physics:setCallback(self.wall, function(other)
        if other == self.player then
            Sounds:sfx("bong")
        end
    end)

    self.physics:addBody(self.wall, { type = "static", category = 2 }, { rect(200, 10) })
    self.physics:setPosition(self.wall, 0, 50)

    self.physics:addBody(self.boundaries, { type = "static", category = 4 }, {
        rect(320, 10, 0, 90),   -- floor
        rect(320, 10, 0, -90),  -- ceiling
        rect(10, 180, -160, 0), -- left wall
        rect(10, 180, 160, 0),  -- right wall
    })

    return self
end

function Game:enter()
end

function Game:leave()
end

function Game:update(dt)
    local dir = Input:direction()
    local speed = dir * 200

    local px, py = self.physics:getPosition(self.player)
    self.physics:rayCast(px, py, px, py + 10, function(item, x, y, xn, yn, fraction)
        if item == self.wall then
            speed.x = math.min(speed.x + 50, 200)
        end
    end)

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
        local x, y = self.physics:getPosition(self.player, true)
        Draw:sprite("player", x, y)

        local ex, ey = self.physics:getPosition(self.elevator, true)
        Ninepatch:draw("elevator", ex - 20, ey - 3, 40, 6)

        local wx, wy = self.physics:getPosition(self.wall, true)
        Ninepatch:draw("wall", wx - 100, wy - 5, 200, 10, nil, -love.timer.getTime() * 20, 0)

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
