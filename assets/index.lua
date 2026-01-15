-- Assets.fontName = "capitalhill.ttf"
Assets.fontName = "m5x7.ttf"

---@enum (key) Assets.Textures
Assets.textures = {
    ["ss"] = { name = "ss.png" },
}

local function scaled(x, y, w, h)
    w = w or 1
    h = h or 1
    x = x - 1
    y = y - 1
    x = x * CELL_SIZE
    y = y * CELL_SIZE
    w = w * CELL_SIZE
    h = h * CELL_SIZE
    return { texture = "ss", tx = x, ty = y, tw = w, th = h }
end

---@enum (key) Assets.Sprites
Assets.sprites = {
    ["player"] = scaled(1, 1),
    ["bullet"] = scaled(2, 1),
    ["box"] = scaled(3, 1),
}

---@enum (key) Assets.Shaders
Assets.shaders = {
    default = { name = "default.glsl" },
    ninepatch = { name = "ninepatch.glsl" },
}

-- Many sounds from https://firahfabe.itch.io/chiptune-8-bit-sfx-pack

---@enum (key) Assets.Sfxs
Assets.sfxs = {
    ["bong"] = { name = "bong.ogg" },
}

---@enum (key) Assets.SfxGroups
Assets.sfxGroups = {
}

---@enum (key) Assets.Music
Assets.musics = {
}

---@enum (key) Assets.Animations
Assets.animations = {
}

---@enum (key) Assets.Ninepatches
Assets.ninepatches = {
}
