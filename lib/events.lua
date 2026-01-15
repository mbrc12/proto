---@enum (key) EventName
local EventName = {
}

--- There are two kinds of events:
--- - Instant events are fired immediately when triggered.
--- - Queued events are fired later when `Events:fire` is called.

---@type table<EventName, { instant: boolean }>
local EventProperties = {
}

---@alias Callback function(...):boolean return true to unregister

_G.Events = {
    ---@type table<EventName, Callback[]>
    callbacks = {},

    ---@type table<EventName, { data: any }>
    fireQueued = {},
}

---@param eventName EventName
---@param callback function
function Events:register(eventName, callback)
    if not self.callbacks[eventName] then
        self.callbacks[eventName] = {}
    end
    table.insert(self.callbacks[eventName], callback)
end

function Events:_fire(eventName, data)
    local cbs = self.callbacks[eventName]
    if cbs then
        Util.arrayEraseIf(cbs, function(cb)
            return cb(table.unpack(data)) == true
        end)
    end
end

---@param eventName EventName
function Events:trigger(eventName, ...)
    local props = EventProperties[eventName]
    local data = { ... }
    if props and props.instant then
        self:_fire(eventName, data)
    else
        self.fireQueued[eventName] = { data = data }
    end
end

---@param eventName EventName
function Events:fire(eventName)
    local queued = self.fireQueued[eventName]
    if queued then
        self:_fire(eventName, table.unpack(queued.data))
        self.fireQueued[eventName] = nil
    end
end
