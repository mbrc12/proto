_G.Ninepatch = {}

---@class NinePatchConfig
---@field texture Assets.Textures
---@field tiledX? boolean
---@field tiledY? boolean
---@field region? { x : number, y : number, w : number, h : number }
---@field padding { left : number, right : number, top : number, bottom : number }

---@param cfg NinePatchConfig | Assets.Ninepatches
---@param x number anchor x top-left
---@param y number anchor y top-left
---@param w number
---@param h number
---@param r? number rotation in degrees
---@param offsetX? number offset for tiling
---@param offsetY? number offset for tiling
function Ninepatch:draw(cfg, x, y, w, h, r, offsetX, offsetY)
    if type(cfg) == "string" then
        cfg = Assets.ninepatches[cfg]
    end

    r = r or 0
    r = math.rad(r % 360)

    local img = Assets.texture(cfg.texture)
    local iw, ih = img:getDimensions()

    if not cfg.region then
        cfg.region = { x = 0, y = 0, w = iw, h = ih }
    end

    local tw, th = cfg.region.w, cfg.region.h
    local tx, ty = cfg.region.x, cfg.region.y
    local pl, pr = cfg.padding.left, cfg.padding.right
    local pt, pb = cfg.padding.top, cfg.padding.bottom

    local scalex = w / tw
    local scaley = h / th

    Draw:withShader("ninepatch", {
        pl = pl,
        pr = pr,
        pt = pt,
        pb = pb,
        portionSize = { tw, th },
        portionPos = { tx, ty },
        scale = { scalex, scaley },
        texSize = { iw, ih },
        tiledX = cfg.tiledX and 1 or 0,
        tiledY = cfg.tiledY and 1 or 0,
        offsetX = offsetX or 0,
        offsetY = offsetY or 0,
    }, function()
        local quad = love.graphics.newQuad(tx, ty, tw, th, iw, ih)
        love.graphics.draw(img, quad, x, y, r, scalex, scaley)
    end)
end

function Ninepatch:centerToCenter(cfg, x1, y1, x2, y2, height)
    local rot = math.atan2(y2 - y1, x2 - x1)
    local width = math.sqrt((y2 - y1) ^ 2 + (x2 - x1) ^ 2)
    self:draw(cfg, x1 + height / 2 * math.sin(rot), y1 - height / 2 * math.cos(rot), width, height, math.deg(rot))
    -- love.graphics.line(x1 + height/2 * math.sin(rot), y1 - height/2 * math.cos(rot), x2 + height/2 * math.sin(rot), y2 - height/2 * math.cos(rot))
    -- love.graphics.line(x1 - height/2 * math.sin(rot), y1 + height/2 * math.cos(rot), x2 - height/2 * math.sin(rot), y2 + height/2 * math.cos(rot))
end
