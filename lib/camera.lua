---@class Camera
_G.Camera = {
    offset = Vec2.new(VIEW_WIDTH / 2, VIEW_HEIGHT / 2),
    position = Vec2.new(0, 0),
    transform = love.math.newTransform(),
    limits = { left = -INFINITY, right = INFINITY, top = -INFINITY, bottom = INFINITY },
}

function Camera:reset()
    self.position = Vec2.new(0, 0)
    self.source = Vec2.new(0, 0)
    self.target = Vec2.new(0, 0)
    self.transform = love.math.newTransform()

    self.limits = { left = -INFINITY, right = INFINITY, top = -INFINITY, bottom = INFINITY }
end

function Camera:matrix()
    return { self.transform:getMatrix() }
end

function Camera:matrixInv()
    return { self.transform:inverse():getMatrix() }
end

---@return number[] {x, y, width, height}
function Camera:viewRect()
    return {
        self.position.x - self.offset.x,
        self.position.y - self.offset.y,
        VIEW_WIDTH,
        VIEW_HEIGHT
    }
end

function Camera:apply()
    love.graphics.push()
    self.transform:reset()
    local pos = self.position:copy():inplaceRound()
    self.transform:translate(-pos.x + self.offset.x, -pos.y + self.offset.y)
    love.graphics.applyTransform(self.transform)
end

function Camera:unapply()
    love.graphics.pop()
end

---@param pos Vec2
---@return Vec2
function Camera:clampCenterToEnsureLimits(pos)
    assert(self.limits.right - self.limits.left >= VIEW_WIDTH, "Camera limits width is less than view width")
    assert(self.limits.bottom - self.limits.top >= VIEW_HEIGHT, "Camera limits height is less than view height")

    local pos_ = pos:copy()
    pos_.x = Util.clamp(pos_.x, self.limits.left + VIEW_WIDTH / 2, self.limits.right - VIEW_WIDTH / 2)
    pos_.y = Util.clamp(pos_.y, self.limits.top + VIEW_HEIGHT / 2, self.limits.bottom - VIEW_HEIGHT / 2)

    return pos_
end

---@param pos Vec2
function Camera:instant(pos)
    local pos_ = self:clampCenterToEnsureLimits(pos)
    self.position = pos_
end
