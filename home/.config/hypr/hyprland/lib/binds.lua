local MODIFIERS = { "SHIFT", "CAPS", "CTRL", "ALT", "MOD2", "MOD3", "SUPER", "MOD5" }
local ALIASES = { CONTROL = "CTRL", MOD1 = "ALT", MOD4 = "SUPER", WIN = "SUPER", LOGO = "SUPER" }

local function combo(keys)
    local parts = {}
    for part in string.gmatch(keys, "[^+]+") do
        table.insert(parts, (part:gsub("^%s+", ""):gsub("%s+$", "")))
    end
    local key = string.lower(table.remove(parts) or "")
    local held = {}
    for _, part in ipairs(parts) do
        local name = string.upper(part)
        held[ALIASES[name] or name] = true
    end
    local ordered = {}
    for _, name in ipairs(MODIFIERS) do
        if held[name] then
            table.insert(ordered, name)
        end
    end
    table.insert(ordered, key)
    return table.concat(ordered, " + ")
end

local bound = {}
local orphaned = {}
local serial = 0
local bind = hl.bind

hl.bind = function(keys, action, opts)
    serial = serial + 1
    local entries = bound[combo(keys)] or {}
    table.insert(entries, { keys = keys, action = action, opts = opts, order = serial })
    bound[combo(keys)] = entries
    return bind(keys, action, opts)
end

local function description(entries)
    for _, entry in ipairs(entries) do
        local text = entry.opts and (entry.opts.description or entry.opts.desc)
        if text then
            return text
        end
    end
end

local function release(keys, orphan)
    local entries = bound[combo(keys)] or {}
    local done = {}
    for _, entry in ipairs(entries) do
        if not done[entry.keys] then
            hl.unbind(entry.keys)
            done[entry.keys] = true
        end
    end
    bound[combo(keys)] = nil
    local name = description(entries)
    if orphan and name then
        orphaned[name] = orphaned[name] or {}
        table.insert(orphaned[name], entries)
    end
    return entries
end

function rebind(old, new)
    if combo(old) == combo(new) then
        return
    end
    release(new)
    for _, entry in ipairs(release(old)) do
        hl.bind(new, entry.action, entry.opts)
    end
end

function alsobind(existing, new)
    if combo(existing) == combo(new) then
        return
    end
    release(new)
    for _, entry in ipairs(bound[combo(existing)] or {}) do
        hl.bind(new, entry.action, entry.opts)
    end
end

function unbind(keys)
    release(keys)
end

function shortcut(name, primary, secondary)
    local groups = orphaned[name] or {}
    orphaned[name] = nil
    local owned = {}
    for keys, entries in pairs(bound) do
        if description(entries) == name then
            table.insert(owned, keys)
        end
    end
    for _, keys in ipairs(owned) do
        table.insert(groups, release(keys))
    end
    if #groups == 0 then
        return
    end
    table.sort(groups, function(a, b) return a[1].order < b[1].order end)
    for slot, keys in ipairs({ primary or false, secondary or false }) do
        if keys then
            release(keys, true)
            for _, entry in ipairs(groups[slot] or groups[1]) do
                hl.bind(keys, entry.action, entry.opts)
            end
        end
    end
end
