--[[
██████   █████  ██████  ██  █████  ███    ██ ████████
██   ██ ██   ██ ██   ██ ██ ██   ██ ████   ██    ██   
██████  ███████ ██   ██ ██ ███████ ██ ██  ██    ██   
██   ██ ██   ██ ██   ██ ██ ██   ██ ██  ██ ██    ██   
██   ██ ██   ██ ██████  ██ ██   ██ ██   ████    ██    
            R A D I A N T   D E V E L O P M E N T
]]

local resourceName = GetCurrentResourceName()
local localVersion = "1.0.0"
local startTime = os.time()

---------------------------------------------------------------------
--  CONFIG: GITHUB VERSION URL
---------------------------------------------------------------------
local githubURL = "https://raw.githubusercontent.com/Radiant-Development/radiant_overheadtags/refs/heads/main/radiant_Admin_tags/verson.json"

---------------------------------------------------------------------
-- COLOR SHORTCUTS
---------------------------------------------------------------------
local C = {
    r="^1", g="^2", y="^3", b="^4", p="^5", c="^6", w="^7", reset="^0"
}

---------------------------------------------------------------------
-- UPTIME CALC
---------------------------------------------------------------------
local function getUptime()
    local s = os.time() - startTime
    local h = math.floor(s / 3600)
    local m = math.floor((s % 3600) / 60)
    local sec = s % 60
    return string.format("%02dh %02dm %02ds", h, m, sec)
end

---------------------------------------------------------------------
-- PRINT BANNER LINE
---------------------------------------------------------------------
local function bar()
    print(C.b .. "██████████████████████████████████████████████████████" .. C.reset)
end

---------------------------------------------------------------------
-- STYLIZED VERSION CHECK
---------------------------------------------------------------------
CreateThread(function()
    Wait(1100)

    PerformHttpRequest(githubURL, function(code, data)
        local latest = "UNKNOWN"
        local status = C.y .. "CHECK FAILED" .. C.reset
        local outdated = false

        if code == 200 then
            local parsed = json.decode(data)
            if parsed and parsed.version then
                latest = parsed.version
                if latest == localVersion then
                    status = C.g .. "UP-TO-DATE ✓" .. C.reset
                else
                    status = C.r .. "OUTDATED ✖" .. C.reset
                    outdated = true
                end
            end
        end

        -- GAME BUILD CHECK
        local build = tonumber(GetConvar("sv_enforceGameBuild", "0")) or 0
        local buildStatus =
            (build >= 2699)
                and (C.g .. "SUPPORTED ("..build..") ✓" .. C.reset)
                or  (C.r .. "UNSUPPORTED ("..build..") ✖" .. C.reset)

        -----------------------------------------------------------------
        -- PRINT EVERYTHING — STYLIZED, CLEAN, NO BROKEN CHARACTERS
        -----------------------------------------------------------------
        bar()
        print(C.p .. " 🚀 R A D I A N T   D E V   V E R S I O N   C H E C K " .. C.reset)
        bar()

        print(C.c .. " Resource        ➜  " .. C.w .. resourceName)
        print(C.c .. " Installed       ➜  " .. C.w .. localVersion)
        print(C.c .. " Latest          ➜  " .. C.w .. latest)
        print(C.c .. " Status          ➜  " .. status)
        print(C.c .. " Game Build      ➜  " .. buildStatus)
        print(C.c .. " Uptime          ➜  " .. C.y .. getUptime() .. C.reset)

        if outdated then
            print(C.r .. " ⚠ UPDATE AVAILABLE! PLEASE DOWNLOAD THE LATEST VERSION." .. C.reset)
        end

        bar()
        print(C.p .. " Support ➜ https://discord.gg/radiantdev " .. C.reset)
        bar()
        print("")
    end)
end)
