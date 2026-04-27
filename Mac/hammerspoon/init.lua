local json = require("hs.json")
local hotkeys = json.read(hs.configdir .. "/config/hotkeys.json")
local modules = {}

-- Load all modules in modules/ (robust to errors and temp files)
local modulesDir = hs.configdir .. "/modules"
for file in io.popen('ls "'..modulesDir..'"'):lines() do
    -- Ignore hidden, backup, and non-lua files
    if file:match("^[^%.~].*%.lua$") then
        local modName = file:gsub("%.lua$", "")
        local ok, mod = pcall(dofile, modulesDir .. "/" .. file)
        if ok and type(mod) == "table" then
            modules[modName] = mod
        else
            hs.alert.show("Modulo non caricato: " .. file .. "\n" .. (mod or "Errore sconosciuto"))
        end
    end
end

-- Map shortcuts to functions
for name, conf in pairs(hotkeys) do
    local mod = modules[conf.module]
    local fn = mod and mod[conf["function"]]  -- 👈 fix qui
    if mod and fn then
        hs.hotkey.bind(conf.modifiers, conf.key, fn)
    else
        hs.alert.show("ERROR: function or module not found for " .. name)
    end
end
