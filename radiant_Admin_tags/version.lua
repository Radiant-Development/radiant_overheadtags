--[[
██████   █████  ██████  ██  █████  ███    ██ ████████
██   ██ ██   ██ ██   ██ ██ ██   ██ ████   ██    ██   
██████  ███████ ██   ██ ██ ███████ ██ ██  ██    ██   
██   ██ ██   ██ ██   ██ ██ ██   ██ ██  ██ ██    ██   
██   ██ ██   ██ ██████  ██ ██   ██ ██   ████    ██    
      R A D I A N T   D E V E L O P M E N T — VERSION CHECK
]]

---------------------------------------------
-- CONFIG (SET YOUR GITHUB RAW VERSION.JSON)
---------------------------------------------
local resource     = GetCurrentResourceName()
local localVersion = "1.0.0"

-- ⚠️ IMPORTANT: Replace this with your RAW GitHub link!
local githubURL    = "https://raw.githubusercontent.com/Radiant-Development/radiant_overheadtags/refs/heads/main/radiant_Admin_tags/verson.json"


---------------------------------------------
-- ANIMATED PRINT FUNCTION
---------------------------------------------
local function aprint(text, delay)
    for i = 1, #text do
        Wait(delay or 5)
        io.write(text:sub(i, i))
    end
    print("")
end


---------------------------------------------
-- MULTILINE RADIANT LOGO (GLOW EFFECT)
---------------------------------------------
local radiantLogo = [[
^6██████   █████  ██████  ██  █████  ███    ██ ████████^0
^6██   ██ ██   ██ ██   ██ ██ ██   ██ ████   ██    ██   ^0
^6██████  ███████ ██   ██ ██ ███████ ██ ██  ██    ██   ^0
^6██   ██ ██   ██ ██   ██ ██ ██   ██ ██  ██ ██    ██   ^0
^6██   ██ ██   ██ ██████  ██ ██   ██ ██   ████    ██   ^0
                ^6R A D I A N T   D E V E L O P M E N T^0
]]


---------------------------------------------
-- RESOURCE UPTIME TRACKER
---------------------------------------------
local startTime = os.time()

local function getUptime()
    local seconds = os.time() - startTime
    local mins = math.floor(seconds / 60)
    local hours = math.floor(mins / 60)
    mins = mins % 60
    seconds = seconds % 60

    return string.format("%02dh %02dm %02ds", hours, mins, seconds)
end


---------------------------------------------
-- FINAL RADIANT PANEL PRINTER
---------------------------------------------
local function radiantPanel(localVersion, latest, versionStatus, buildText)
    print("")
    aprint("^6████████████████████████ RADIANT DEV CHECK ████████████████████████^0", 1)
    print(radiantLogo)

    local icon_version = (versionStatus:find("Up%-to%-date") and "^2✔^0") or "^1✖^0"
    local icon_build   = (buildText:find("SUPPORTED") and "^2✔^0") or "^1⚠^0"

    local recommend = ""
    if icon_version == "^1✖^0" then
        recommend = "^1⚠ RECOMMENDED UPDATE AVAILABLE — PLEASE UPDATE SOON ⚠^0"
    end

    aprint("^5█^0  Resource           → ^7" .. resource, 3)
    aprint("^5█^0  Installed Version  → ^7" .. localVersion .. " (" .. icon_version .. " " .. versionStatus .. "^0)", 3)
    aprint("^5█^0  Latest Version     → ^7" .. latest, 3)
    aprint("^5█^0  Game Build         → ^7" .. buildText .. " " .. icon_build, 3)
    aprint("^5█^0  Uptime             → ^7" .. getUptime(), 3)
    aprint("^5█^0  Support Hub        → ^7discord.gg/radiantdev", 3)

    if recommend ~= "" then
        aprint("^5█^0  " .. recommend, 2)
    end

    aprint("^6████████████████████████ END OF STATUS ███████████████████████████^0", 1)
    print("")
end


---------------------------------------------
-- VERSION CHECK THREAD
---------------------------------------------
CreateThread(function()
    PerformHttpRequest(githubURL, function(code, data)
        local build = tonumber(GetConvarInt("sv_enforceGameBuild", 0))
        local supported = build >= 2699

        local buildText = supported
            and ("^2SUPPORTED^0 (Build " .. build .. ")")
            or ("^1UNSUPPORTED^0 (Build " .. build .. ")")

        if code ~= 200 then
            radiantPanel(localVersion, "UNKNOWN", "^1UNKNOWN^0", buildText)
            return
        end

        local decoded = json.decode(data)
        local latest = decoded.version or "UNKNOWN"

        local versionStatus =
            (localVersion == latest and "^2Up-to-date^0")
            or "^1Outdated^0"

        radiantPanel(localVersion, latest, versionStatus, buildText)
    end)
end)
