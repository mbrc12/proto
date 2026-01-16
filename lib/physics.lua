--- Abstracted interface over underlying physics layer

---@class PhysicsEntity
---@field body love.physics.Body

---@alias CollisionCallback fun(other: any, nx: number, ny: number, x1: number, y1: number, x2: number, y2: number)

---@class Physics
_G.Physics = {
    ---@type love.physics.World
    world = nil,
    ---@type table<any, PhysicsEntity>
    entities = {},

    ---@type table<any, CollisionCallback>
    collisionCallbacks = {},
}
Physics.__index = Physics

---@param gx number gravity x
---@param gy number gravity y
function Physics.new(gx, gy)
    local self = setmetatable({}, Physics)
    self.world = love.physics.newWorld(gx or 0, gy or 0, true)
    self.entities = {}

    local beginContact = function(a, b, col)
        ---@cast col love.physics.Contact
        local nx, ny = col:getNormal()
        local x1, y1, x2, y2 = col:getPositions()
        local itemA = a:getBody():getUserData()
        local itemB = b:getBody():getUserData()
        local callbackA = self.collisionCallbacks[itemA]
        if callbackA then
            callbackA(itemB, nx, ny, x1, y1, x2, y2)
        end
        local callbackB = self.collisionCallbacks[itemB]
        if callbackB then
            callbackB(itemA, -nx, -ny, x1, y1, x2, y2)
        end
    end

    local endContact = function(a, b, ...)
        -- Currently unused, but could be implemented similarly to beginContact
    end

    local preSolve = function(a, b, ...)
        -- Currently unused
    end

    local postSolve = function(a, b, ...)
        -- Currently unused
    end

    self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    return self
end

function Physics:update(dt)
    self.world:update(dt)
end

---@param item any
---@param callback CollisionCallback
function Physics:setCallback(item, callback)
    self.collisionCallbacks[item] = callback
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
}

---@alias ShapeFunction fun(love.physics.Body):love.physics.Shape

---@param item any
---@param cfg BodyConfig
---@param shapeFns ShapeFunction[]
function Physics:addBody(item, cfg, shapeFns)
    local body = love.physics.newBody(self.world, 0, 0, cfg.type or defaultBodySettings.type)
    body:setUserData(item)
    for _, shapeFn in pairs(shapeFns) do
        local shape = shapeFn(body)
        shape:setCategory(cfg.category or defaultBodySettings.category)
        shape:setMask(table.unpack(cfg.mask or defaultBodySettings.mask or {}))
    end
    self.entities[item] = { body = body }
end

---@param w number
---@param h number
---@param x? number
---@param y? number
---@return ShapeFunction
function Physics.rect(w, h, x, y)
    x = x or 0
    y = y or 0
    return function(body)
        local shape = love.physics.newRectangleShape(body, x, y, w, h)
        return shape
    end
end

---@param radius number
---@param x? number
---@param y? number
---@return ShapeFunction
function Physics.circle(radius, x, y)
    x = x or 0
    y = y or 0
    return function(body)
        local shape = love.physics.newCircleShape(body, x, y, radius)
        return shape
    end
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
---@param rounded boolean|nil
---@return number, number
function Physics:getPosition(item, rounded)
    rounded = rounded or false
    local entity = self.entities[item]
    local x, y = entity.body:getPosition()
    if rounded then
        x = Util.round(x)
        y = Util.round(y)
    end
    return x, y
end

--- The callback is called for each fixture found in the ray cast.
--- If the callback returns false, the ray cast is terminated.
--- The callback parameters are:
--- - item: the user data associated with the body hit
--- - x, y: the point of intersection
--- - xn, yn: the normal vector at the point of intersection
--- - fraction: the fraction along the ray where the intersection occurred (0 to 1)
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param callback fun(item: any, x: number, y: number, xn: number, yn: number, fraction: number):boolean
function Physics:rayCast(x1, y1, x2, y2, callback)
    self.world:rayCast(x1, y1, x2, y2, function(shape, x, y, xn, yn, fraction)
        local body = shape:getBody()
        local item = body:getUserData()
        local continue = callback(item, x, y, xn, yn, fraction)
        if continue == false then
            return 0
        else
            return 1
        end
    end)
end

local drawColors = {
    dynamic = Colors.CC29.brick,
    static = Colors.CC29.storm_gray,
    kinematic = Colors.CC29.azure,
    opacity = 0.5,
}

function Physics:draw()
    for _, entity in pairs(self.entities) do
        local body = entity.body
        for _, shape in pairs(body:getShapes()) do
            local color = drawColors[body:getType()] or Colors.White
            color[4] = drawColors.opacity
            love.graphics.setColor(color)
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
