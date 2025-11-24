-----------------------------------------
-- R A D I A N T   D E V   S E R V E R
-----------------------------------------

local resource     = GetCurrentResourceName()
local localVersion = "1.0.0"
local startTime    = os.time()

local Config = Config
local tags   = {}
local cooldowns = {}

---------------------------------------------------------------------
-- UTIL: FORMAT UPTIME
---------------------------------------------------------------------
local function getUptime()
    local sec = os.time() - startTime
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = sec % 60
    return string.format("%02dh %02dm %02ds", h, m, s)
end

---------------------------------------------------------------------
-- VERSION CHECK (CLEAN FINAL)
---------------------------------------------------------------------
CreateThread(function()
    Wait(1400)

    local versionURL = "https://raw.githubusercontent.com/Radiant-Development/radiant_overheadtags/main/version.json"

    PerformHttpRequest(versionURL, function(code, body)
        local latest = "UNKNOWN"

        if code == 200 and body then
            local decoded = json.decode(body)
            if decoded and decoded.version then
                latest = decoded.version
            end
        end

        local status =
            (latest == "UNKNOWN") and "^3UNKNOWN^0"
            or (latest == localVersion) and "^2UP-TO-DATE ✓^0"
            or "^1OUTDATED ✖^0"

        local build = tonumber(GetConvarInt("sv_enforceGameBuild", 0))
        local buildText =
            (build == 0) and "^3UNKNOWN (sv_enforceGameBuild missing)^0"
            or (build >= 2699) and ("^2SUPPORTED (" .. build .. ") ✓^0")
            or ("^1UNSUPPORTED (" .. build .. ") ✖^0")

        print("")
        print("^4█████████████████████████████████████████████████^0")
        print("^6      🚀 R A D I A N T   D E V   V E R S I O N   C H E C K^0")
        print("^4█████████████████████████████████████████████████^0")
        print(("  Resource     ➜  ^7%s^0"):format(resource))
        print(("  Installed    ➜  ^7%s^0"):format(localVersion))
        print(("  Latest       ➜  ^7%s^0"):format(latest))
        print(("  Status       ➜  %s"):format(status))
        print(("  Game Build   ➜  %s"):format(buildText))
        print(("  Uptime       ➜  %s^0"):format(getUptime()))
        print("^4█████████████████████████████████████████████████^0")
        print("  Support ➜ ^5https://discord.gg/radiantdev^0")
        print("^4█████████████████████████████████████████████████^0")
        print("")
    end)
end)

---------------------------------------------------------------------
-- GET LICENSE
---------------------------------------------------------------------
local function GetLicense(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find("license:") then return id end
    end
    return nil
end

---------------------------------------------------------------------
-- SQL LOAD
---------------------------------------------------------------------
local function LoadPlayerTag(license)
    if not Config.UseSQL then return nil end

    local q = ("SELECT * FROM `%s` WHERE license = ?"):format(Config.SQLTable)
    local r = MySQL.single.await(q, { license })

    if not r then return nil end

    return {
        text    = r.tag_text or "",
        message = r.tag_message or "",
        color   = { r.color_r,  r.color_g,  r.color_b },
        color2  = { r.color_r2, r.color_g2, r.color_b2 },
        style   = r.style or "solid"
    }
end

---------------------------------------------------------------------
-- SQL SAVE
---------------------------------------------------------------------
local function SavePlayerTag(license, data)
    if not Config.UseSQL then return end

    local q = string.format([[
        INSERT INTO `%s`
        (license, tag_text, tag_message, color_r, color_g, color_b, color_r2, color_g2, color_b2, style)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            tag_text    = VALUES(tag_text),
            tag_message = VALUES(tag_message),
            color_r     = VALUES(color_r),
            color_g     = VALUES(color_g),
            color_b     = VALUES(color_b),
            color_r2    = VALUES(color_r2),
            color_g2    = VALUES(color_g2),
            color_b2    = VALUES(color_b2),
            style       = VALUES(style)
    ]], Config.SQLTable)

    MySQL.update.await(q, {
        license,
        data.text,
        data.message,
        data.color[1], data.color[2], data.color[3],
        data.color2[1], data.color2[2], data.color2[3],
        data.style
    })
end

---------------------------------------------------------------------
-- SQL INIT
---------------------------------------------------------------------
CreateThread(function()
    if not Config.UseSQL then return end

    local q = string.format([[
        CREATE TABLE IF NOT EXISTS `%s` (
            id INT AUTO_INCREMENT PRIMARY KEY,
            license VARCHAR(255) NOT NULL UNIQUE,
            tag_text VARCHAR(64),
            tag_message VARCHAR(128),
            color_r INT DEFAULT 255,
            color_g INT DEFAULT 255,
            color_b INT DEFAULT 255,
            color_r2 INT DEFAULT 255,
            color_g2 INT DEFAULT 255,
            color_b2 INT DEFAULT 255,
            style VARCHAR(32) DEFAULT 'solid'
        );
    ]], Config.SQLTable)

    MySQL.query(q)
    print("^2[RADIANT DEV]^0 SQL table verified.")
end)

---------------------------------------------------------------------
-- DISCORD ROLE FETCH
---------------------------------------------------------------------
local function GetDiscordRoles(src)
    local discordId

    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find("discord:") then
            discordId = id:gsub("discord:", "")
            break
        end
    end

    if not discordId then return {} end

    local url = ("https://discord.com/api/v10/guilds/%s/members/%s")
        :format(Config.Discord.GuildID, discordId)

    local p = promise.new()

    PerformHttpRequest(url, function(code, data)
        if Config.Debug.ShowRolePull then
            print("^6[ROLE DEBUG]^0 CODE:", code)
        end

        if code ~= 200 then return p:resolve({}) end

        local decoded = json.decode(data or "{}")
        p:resolve(decoded and decoded.roles or {})
    end, "GET", "", {
        ["Authorization"] = "Bot " .. Config.Discord.BotToken
    })

    return Citizen.Await(p)
end

---------------------------------------------------------------------
-- PERMISSION CHECK
---------------------------------------------------------------------
local function HasPermissions(src)
    if IsPlayerAceAllowed(src, "group." .. Config.Permission.RequiredACE) then
        return true
    end

    local roles = GetDiscordRoles(src)
    for _, role in ipairs(roles) do
        if Config.Discord.RoleMap[role] == Config.Permission.RequiredDiscord then
            return true
        end
    end

    return false
end

---------------------------------------------------------------------
-- PLAYER CONNECT
---------------------------------------------------------------------
AddEventHandler("playerJoining", function()
    local src = source
    local lic = GetLicense(src)

    CreateThread(function()
        Wait(350)

        tags[src] = LoadPlayerTag(lic) or {}

        TriggerClientEvent("radiant:tags:updateAll", -1, tags)
    end)
end)

---------------------------------------------------------------------
-- /tagmenu
---------------------------------------------------------------------
RegisterCommand("tagmenu", function(src)
    if not HasPermissions(src) then
        TriggerClientEvent("chat:addMessage", src, {
            args = {"^1SYSTEM", "You do not have permission."}
        })
        return
    end

    TriggerClientEvent("radiant:tags:openMenu", src)
end)

---------------------------------------------------------------------
-- SAVE TAG FROM UI
---------------------------------------------------------------------
RegisterNetEvent("radiant:tags:setTag", function(data)
    local src = source
    local lic = GetLicense(src)

    tags[src] = {
        text    = data.role,
        message = data.message,
        color   = { data.r, data.g, data.b },
        color2  = { data.r2, data.g2, data.b2 },
        style   = data.style
    }

    if lic then
        SavePlayerTag(lic, tags[src])
    end

    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

---------------------------------------------------------------------
-- CLEANUP ON LEAVE
---------------------------------------------------------------------
AddEventHandler("playerDropped", function()
    tags[source] = nil
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)
