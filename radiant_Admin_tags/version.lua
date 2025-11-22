--[[
██████   █████  ██████  ██  █████  ███    ██ ████████
██   ██ ██   ██ ██   ██ ██ ██   ██ ████   ██    ██   
██████  ███████ ██   ██ ██ ███████ ██ ██  ██    ██   
██   ██ ██   ██ ██   ██ ██ ██   ██ ██  ██ ██    ██   
██   ██ ██   ██ ██████  ██ ██   ██ ██   ████    ██    
        R A D I A N T   D E V E L O P M E N T
]]

local resourceName = GetCurrentResourceName()
local localVersion = "1.0.0"  -- YOUR SCRIPT VERSION HERE
local startTime = os.time()

---------------------------------------------------------------------
--  CONFIG: YOUR RAW GITHUB URL
---------------------------------------------------------------------
local githubURL = "https://raw.githubusercontent.com/Radiant-Development/radiant_overheadtags/refs/heads/main/radiant_Admin_tags/verson.json"

---------------------------------------------------------------------
--  COLOR HELPERS
---------------------------------------------------------------------
local C = {
    r = "^1", g = "^2", y = "^3", b = "^4",
    p = "^5", c = "^6", w = "^7", reset = "^0"
}

---------------------------------------------------------------------
--  ANIMATED PRINT
---------------------------------------------------------------------
local function slowPrint(text, delay)
    delay = delay or 15
    for i = 1, #text do
        print(text:sub(i,i))
        Wait(delay)
    end
end

---------------------------------------------------------------------
--  LEFT BORDER PRINTER
---------------------------------------------------------------------
local function borderLine()
    print(C.b .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" .. C.reset)
end

---------------------------------------------------------------------
--  UPTIME
---------------------------------------------------------------------
local function getUptime()
    local seconds = os.time() - startTime
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02dh %02dm %02ds", h, m, s)
end

---------------------------------------------------------------------
--  VERSION CHECK
---------------------------------------------------------------------
CreateThread(function()

    Wait(1500)

    -- Fetch GitHub version.json
    PerformHttpRequest(githubURL, function(code, data)
        local latest = "UNKNOWN"
        local status = C.y .. "CHECK FAILED" .. C.reset
        local isOutdated = false

        if code == 200 then
            local decoded = json.decode(data)
            if decoded and decoded.version then
                latest = decoded.version
                if latest ~= localVersion then
                    isOutdated = true
                    status = C.r .. "OUTDATED" .. C.reset
                else
                    status = C.g .. "UP-TO-DATE" .. C.reset
                end
            end
        end

        ------------------------------------------------------------------
        -- GAME BUILD CHECK
        ------------------------------------------------------------------
        local build = tonumber(GetConvar("sv_enforceGameBuild", "0")) or 0
        local buildText = ""
        if build < 2699 then
            buildText = C.r .. "UNSUPPORTED (" .. build .. ")" .. C.reset
        else
            buildText = C.g .. "SUPPORTED (" .. build .. ")" .. C.reset
        end

        ------------------------------------------------------------------
        --  PRINT PANEL
        ------------------------------------------------------------------
        borderLine()
        slowPrint(C.p .. " R A D I A N T   D E V   V E R S I O N   C H E C K " .. C.reset, 5)
        borderLine()

        print(C.w .. "Resource:      " .. C.b .. resourceName .. C.reset)
        print(C.w .. "Installed:     " .. C.c .. localVersion .. C.reset)
        print(C.w .. "Latest:        " .. C.b .. latest .. C.reset)
        print(C.w .. "Status:        " .. status)
        print(C.w .. "Game Build:    " .. buildText)
        print(C.w .. "Uptime:        " .. C.y .. getUptime() .. C.reset)

        if isOutdated then
            print(C.r .. "RECOMMENDED UPDATE AVAILABLE!" .. C.reset)
        end

        borderLine()
        print(C.c .. " Support: https://discord.gg/radiantdev " .. C.reset)
        borderLine()
        print("")
    end)

end)
