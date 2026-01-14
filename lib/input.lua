local JOYSTICK_CHECK_INTERVAL = 1 -- seconds

--- Previously, self.next was used to queue inputs between frames.
--- Now, we keep only the check at the start of update, for simplicity

---@enum (key) Actions
local Actions = {
    UP = 0,
    DOWN = 1,
    LEFT = 2,
    RIGHT = 3,
    INTERACT = 4,
    BACK = 5,
}

---@type table<Actions, {keyboard: string[], joystick: string[]}>
local keymap = {
    UP = { keyboard = {'w', 'up'}, joystick = {'dpup', 'lup', 'rup'} },
    DOWN = { keyboard = {'s', 'down'}, joystick = {'dpdown', 'ldown', 'rdown'} },
    LEFT = { keyboard = {'a', 'left'}, joystick = {'dpleft', 'lleft', 'rleft'} },
    RIGHT = { keyboard = {'d', 'right'}, joystick = {'dpright', 'lright', 'rright'} },
    INTERACT = { keyboard = {'e', 'space', 'return'}, joystick = {'a'} },
    BACK = { keyboard = {'escape', 'backspace'}, joystick = {'b'} },
}

---@type table<string, fun(love.Joystick):boolean>
local joystickChecker = {
    a = function(joy) return joy:isGamepadDown("a") end,
    b = function(joy) return joy:isGamepadDown("b") end,
    x = function(joy) return joy:isGamepadDown("x") end,
    y = function(joy) return joy:isGamepadDown("y") end,
    dpleft = function(joy) return joy:isGamepadDown("dpleft") end,
    dpright = function(joy) return joy:isGamepadDown("dpright") end,
    dpup = function(joy) return joy:isGamepadDown("dpup") end,
    dpdown = function(joy) return joy:isGamepadDown("dpdown") end,
    ltrigger = function(joy) return joy:getGamepadAxis("triggerleft") > 0.5 end,
    rtrigger = function(joy) return joy:getGamepadAxis("triggerright") > 0.5 end,
    lbutton = function(joy) return joy:isGamepadDown("leftshoulder") end,
    rbutton = function(joy) return joy:isGamepadDown("rightshoulder") end,
    lup = function(joy) return joy:getGamepadAxis("lefty") < -0.5 end,
    ldown = function(joy) return joy:getGamepadAxis("lefty") > 0.5 end,
    lleft = function(joy) return joy:getGamepadAxis("leftx") < -0.5 end,
    lright = function(joy) return joy:getGamepadAxis("leftx") > 0.5 end,
    rup = function(joy) return joy:getGamepadAxis("righty") < -0.5 end,
    rdown = function(joy) return joy:getGamepadAxis("righty") > 0.5 end,
    rleft = function(joy) return joy:getGamepadAxis("rightx") < -0.5 end,
    rright = function(joy) return joy:getGamepadAxis("rightx") > 0.5 end,
}

---@class Input
_G.Input = {
    ---@type table<number, table<Actions, boolean>>
    history = {},

    ---@type table<Actions, boolean>
    next = {},

    ---@type love.Joystick
    joystick = nil,

    lastJoystickCheck = 0,

    releasedInTheInterim = false,
}

local function new_state()
    local state = {}
    for action, _ in pairs(Actions) do
        state[action] = false
    end
    return state
end

local INPUT_HISTORY = 10

function Input:init()
    for i = 1, INPUT_HISTORY do
        table.insert(self.history, new_state())
    end
    self.next = new_state()
    self:checkJoystick()
end

-- Check for joystick connection every JOYSTICK_CHECK_INTERVAL seconds
function Input:checkJoystick()
    if self.joystick and self.joystick:isConnected() then
        return
    else
        self.joystick = nil
    end

    if self.lastJoystickCheck + JOYSTICK_CHECK_INTERVAL > love.timer.getTime() then
        return
    end

    self.jastJoystickCheck = love.timer.getTime()

    local joysticks = love.joystick.getJoysticks()
    if #joysticks > 0 then
        self.joystick = joysticks[1]
        Log("Joystick connected: " .. self.joystick:getName())
    end
end

---@param dt number
function Input:update(dt)
    self:checkJoystick()
    table.remove(self.history)

    table.insert(self.history, 1, self.next)
    local current = self.history[1]

    for action, mappings in pairs(keymap) do
        for _, key in ipairs(mappings.keyboard) do
            if love.keyboard.isDown(key) then
               current[action] = true
            end
        end
        if self.joystick then
            for _, button in ipairs(mappings.joystick) do
                local checker = joystickChecker[button]
                if checker and checker(self.joystick) then
                    current[action] = true
                end
            end
        end
    end

    self.next = new_state()
end

---@param action Actions
---@return boolean
function Input:isPressed(action)
    local current = self.history[1]
    return current[action]
end

---@param action Actions
---@param leniency? number
---@return boolean
function Input:isJustPressed(action, leniency)
    leniency = leniency or 1
    for i = 1, #self.history - 1 do
        local state = self.history[i]
        local prev = self.history[i + 1]
        if state[action] and not prev[action] then
            return i <= leniency
        end
    end
    return false
end

---@return boolean
function Input:holding()
    for action, _ in pairs(Actions) do
        if self.history[1][action] ~= self.history[2][action] then
            return false
        end
    end
    return true
end

---@return boolean
function Input:isNothingPressed()
    for action, _ in pairs(Actions) do
        if self.history[1][action] then
            return false
        end
    end
    return true
end

---@return Vec2
function Input:direction()
    local dir = Vec2.new(0, 0)
    if self:isPressed("UP") then
        dir.y = dir.y - 1
    end
    if self:isPressed("DOWN") then
        dir.y = dir.y + 1
    end
    if self:isPressed("LEFT") then
        dir.x = dir.x - 1
    end
    if self:isPressed("RIGHT") then
        dir.x = dir.x + 1
    end
    return dir:normalized()
end

---@param frames? number
---@return string
function Input:debugString(frames)
    frames = frames or 1
    local s = ""
    for i = 1, frames do
        s = s .. (i > 1 and " | " or "")
        for action, _ in pairs(Actions) do
            if self.history[i][action] then
                s = s .. action .. " "
            end
        end
    end
    return s
end
