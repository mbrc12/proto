local Loaders = {}

local TEXTURES_ROOT = "assets/textures/"

local SHADERS_ROOT = "assets/shaders/"
local COMMON_SHADER_NAME = "common.glsl"

local SFXS_ROOT = "assets/sfx/"
local MUSIC_ROOT = "assets/music/"

local FONTS_ROOT = "assets/fonts/"

---@param name string
---@return love.Image
function Loaders.loadTexture(name)
    local path = TEXTURES_ROOT .. name
    local image = love.graphics.newImage(path)
    Log("Loaded texture: " .. path)

    return image
end

---@param name string
---@return love.Shader
function Loaders.loadShader(name)
    Log("Loading shader: " .. name)
    local common = love.filesystem.read(SHADERS_ROOT .. COMMON_SHADER_NAME)

    common = "\n" .. common .. "\n"

    local path = SHADERS_ROOT .. name
    local shader = love.filesystem.read(path)
    local full_shader = string.gsub(shader, "#COMMON", common)
    local valid, message = love.graphics.validateShader(true, full_shader)
    if not valid then
        error("Shader " .. name .. " is invalid: " .. message)
    end
    print("Shader " .. name .. " is valid.")
    local shaderObj = love.graphics.newShader(full_shader)
    print("Loaded shader: " .. path)

    return shaderObj
end

---@param name string Name with extension
---@return love.Source
function Loaders.loadSfx(name)
    local path = SFXS_ROOT .. name
    local sound = love.audio.newSource(path, "static")
    Log("Loaded sfx: " .. path)

    return sound
end

function Loaders.loadMusic(name)
    local path = MUSIC_ROOT .. name
    local music = love.audio.newSource(path, "stream")
    Log("Loaded music: " .. path)

    return music
end

---@param name string
---@param size number
---@return love.Font
function Loaders.loadFont(name, size)
    local path = FONTS_ROOT .. name
    local font = love.graphics.newFont(path, size)
    Log("Loaded font: " .. path)
    font:setFilter("nearest", "nearest")

    return font
end

return Loaders
