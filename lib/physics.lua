--- Abstracted interface over underlying physics layer

---@class PhysicsEntity
---@field body love.physics.Body

---@class Physics
_G.Physics = {
    ---@type love.physics.World
    world = nil,
    ---@type table<any, PhysicsEntity>
    entities = {}
}
Physics.__index = Physics

---@param gx number gravity x
---@param gy number gravity y
function Physics.new(gx, gy)
    local self = setmetatable({}, Physics)
    self.world = love.physics.newWorld(gx or 0, gy or 0, true)
    self.entities = {}
    return self
end

function Physics:update(dt)
    self.world:update(dt)
end

---@class BodyConfig
local defaultBodySettings = {
    ---@type love.physics.BodyType?
    type = "kinematic",
    ---@type number?
    density = 0,
    ---@type number?
    category = 1,
    ---@type number[]? do not collide with these categories
    mask = {},
    ---@type boolean?
    sensor = false,
}

---@param item any
---@param cfg BodyConfig
---@param shape love.physics.Shape
function Physics:_addShape(item, cfg, shape)
    local body = love.physics.newBody(self.world, 0, 0, cfg.type or defaultBodySettings.type)
    body:setUserData(item)
    local fixture = love.physics.newFixture(body, shape, cfg.density or defaultBodySettings.density)
    fixture:setCategory(cfg.category or defaultBodySettings.category)
    fixture:setMask(table.unpack(cfg.mask or defaultBodySettings.mask or {}))
    fixture:setSensor(cfg.sensor or defaultBodySettings.sensor or false)
    self.entities[item] = { body = body }
end

---@param item any
---@param cfg BodyConfig
---@param w number
---@param h number
function Physics:addRect(item, cfg, w, h)
    local shape = love.physics.newRectangleShape(w, h)
    self:_addShape(item, cfg, shape)
end

---@param item any
---@param cfg BodyConfig
---@param radius number
function Physics:addCircle(item, cfg, radius)
    local shape = love.physics.newCircleShape(radius)
    self:_addShape(item, cfg, shape)
end

---@param item any
function Physics:remove(item)
    local entity = self.entities[item]
    if entity then
        entity.body:destroy()
        self.entities[item] = nil
    end
end

---@param item any
---@param x number
---@param y number
function Physics:setPosition(item, x, y)
    local entity = self.entities[item]
    entity.body:setPosition(x, y)
    entity.body:setAwake(true)
end

---@param item any
---@param vx number
---@param vy number
function Physics:setVelocity(item, vx, vy)
    local entity = self.entities[item]
    entity.body:setLinearVelocity(vx, vy)
    entity.body:setAwake(true)
end

---@param item any
---@return number, number
function Physics:getPosition(item)
    local entity = self.entities[item]
    local x, y = entity.body:getPosition()
    return x, y
end

function Physics:draw()
    for _, entity in pairs(self.entities) do
        local body = entity.body
        for _, fixture in pairs(body:getFixtures()) do
            local shape = fixture:getShape()
            love.graphics.setColor(1, 0, 0, 0.5)
            if shape:typeOf("CircleShape") then
                ---@cast shape love.physics.CircleShape
                local x, y = body:getPosition()
                local radius = shape:getRadius()
                love.graphics.circle("fill", x, y, radius)
            elseif shape:typeOf("PolygonShape") then
                ---@cast shape love.physics.PolygonShape
                love.graphics.polygon("fill", body:getWorldPoints(shape:getPoints()))
            end
        end
    end
end
