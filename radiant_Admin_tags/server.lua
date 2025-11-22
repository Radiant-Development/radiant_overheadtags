-----------------------------------------
-- R A D I A N T   D E V   S E R V E R
-----------------------------------------

local resource = GetCurrentResourceName()
local localVersion = "1.0.0"
local startTime = os.time()

local Config = Config
local tags = {}
local cooldowns = {}

-----------------------------------------------------
-- VERSION CHECK (FIXED & CLEAN)
-----------------------------------------------------
CreateThread(function()
    Wait(1500)

    local versionURL = "https://raw.githubusercontent.com/Radiant-Development/radiant_overheadtags/main/version.json"

    PerformHttpRequest(versionURL, function(code, body)
        local latest = "UNKNOWN"
        if code == 200 and body then
            local decoded = json.decode(body)
            latest = decoded and decoded.version or "UNKNOWN"
        end

        local statusText =
            (latest == "UNKNOWN") and "^3UNKNOWN^0"
            or (latest == localVersion) and "^2UP-TO-DATE ✓^0"
            or "^3OUTDATED → UPDATE AVAILABLE^0"

        local build = GetGameBuildNumber() or 0
        local buildText =
            (build == 0) and "^3UNKNOWN (FiveM returned nil)^0"
            or (build < 2699) and ("^1UNSUPPORTED (must be ≥ 2699)^0")
            or ("^2SUPPORTED (" .. build .. ")^0")

        local uptime = os.time() - startTime
        local h = math.floor(uptime / 3600)
        local m = math.floor((uptime % 3600) / 60)
        local s = uptime % 60

        print("")
        print("^4━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━^0")
        print("^6      🚀 R A D I A N T   D E V   V E R S I O N   C H E C K^0")
        print("^4━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━^0")
        print(("  Resource       ➜  ^7%s^0"):format(resource))
        print(("  Installed      ➜  ^7%s^0"):format(localVersion))
        print(("  Latest         ➜  ^7%s^0"):format(latest))
        print(("  Status         ➜  %s"):format(statusText))
        print(("  Game Build     ➜  %s"):format(buildText))
        print(("  Uptime         ➜  %02dh %02dm %02ds^0"):format(h, m, s))
        print("^4━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━^0")
        print("  Support ➜ ^5https://discord.gg/radiantdev^0")
        print("^4━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━^0")
        print("")
    end)
end)

-----------------------------------------------------
-- GET LICENSE
-----------------------------------------------------
local function GetLicense(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find("license:") then return id end
    end
    return nil
end

-----------------------------------------------------
-- SQL: LOAD TAG
-----------------------------------------------------
local function LoadPlayerTag(license)
    if not Config.UseSQL then return nil end

    local result = MySQL.single.await(
        ("SELECT * FROM `%s` WHERE license = ?"):format(Config.SQLTable),
        { license }
    )

    if not result then return nil end

    return {
        text    = result.tag_text or "",
        message = result.tag_message or "",
        color   = { result.color_r, result.color_g, result.color_b },
        color2  = { result.color_r2, result.color_g2, result.color_b2 },
        style   = result.style or "solid"
    }
end

-----------------------------------------------------
-- SQL: SAVE TAG
-----------------------------------------------------
local function SavePlayerTag(license, data)
    if not Config.UseSQL then return end

    local sql = string.format([[
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

    MySQL.update.await(sql, {
        license,
        data.text,
        data.message,
        data.color[1], data.color[2], data.color[3],
        data.color2[1], data.color2[2], data.color2[3],
        data.style
    })
end

-----------------------------------------------------
-- SQL: CREATE TABLE
-----------------------------------------------------
CreateThread(function()
    if not Config.UseSQL then return end

    local sql = string.format([[
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

    MySQL.query(sql)
    print("^2[RADIANT DEV]^0 SQL table verified.")
end)

-----------------------------------------------------
-- DISCORD ROLE FETCH
-----------------------------------------------------
local function GetDiscordRoles(src)
    local discordId
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find("discord:") then
            discordId = id:gsub("discord:", "")
            break
        end
    end

    if not discordId then return {} end

    local url = ("https://discord.com/api/v10/guilds/%s/members/%s"):
        format(Config.Discord.GuildID, discordId)

    local p = promise.new()

    PerformHttpRequest(url, function(code, data)
        if code ~= 200 then
            p:resolve({})
            return
        end
        local decoded = json.decode(data or "{}")
        p:resolve(decoded and decoded.roles or {})
    end, "GET", "", {
        ["Authorization"] = "Bot " .. Config.Discord.BotToken
    })

    return Citizen.Await(p)
end

-----------------------------------------------------
-- PERMISSION CHECK
-----------------------------------------------------
local function HasPermissions(src)
    local requiredACE = Config.Permission.RequiredACE
    if IsPlayerAceAllowed(src, "group." .. requiredACE) then return true end

    local roles = GetDiscordRoles(src)
    for _, r in ipairs(roles) do
        if Config.Discord.RoleMap[r] == Config.Permission.RequiredDiscord then
            return true
        end
    end

    return false
end

-----------------------------------------------------
-- PLAYER CONNECT
-----------------------------------------------------
AddEventHandler("playerConnecting", function()
    local src = source
    local license = GetLicense(src)

    CreateThread(function()
        Wait(500)

        tags[src] = LoadPlayerTag(license) or {}

        TriggerClientEvent("radiant:tags:updateAll", -1, tags)
    end)
end)

-----------------------------------------------------
-- TAG MENU COMMAND
-----------------------------------------------------
RegisterCommand("tagmenu", function(src)
    if not HasPermissions(src) then
        TriggerClientEvent("chat:addMessage", src, { args = {"^1SYSTEM", "No permission."} })
        return
    end

    TriggerClientEvent("radiant:tags:openMenu", src)
end)

-----------------------------------------------------
-- SAVE TAG FROM UI
-----------------------------------------------------
RegisterNetEvent("radiant:tags:setTag", function(payload)
    local src = source
    local license = GetLicense(src)

    tags[src] = {
        text    = payload.role,
        message = payload.message,
        color   = { payload.r, payload.g, payload.b },
        color2  = { payload.r2, payload.g2, payload.b2 },
        style   = payload.style
    }

    if Config.UseSQL then
        SavePlayerTag(license, tags[src])
    end

    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

-----------------------------------------------------
-- PLAYER DROPPED
-----------------------------------------------------
AddEventHandler("playerDropped", function()
    tags[source] = nil
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)
