-----------------------------------------
-- R A D I A N T   D E V   S E R V E R
-----------------------------------------

local resource     = GetCurrentResourceName()
local localVersion = "1.0.0"
local startTime    = os.time()

local Config = Config
local tags = {}
local cooldowns = {}
local cachedRoles = {}   -- 🔥 Stores Discord roles per player

---------------------------------------------
-- VERSION CHECK (Single Print Only)
---------------------------------------------
CreateThread(function()
    Wait(1200)

    local versionURL = "https://raw.githubusercontent.com/Radiant-Development/radiant_overheadtags/main/version.json"

    PerformHttpRequest(versionURL, function(code, data)
        local latest = "UNKNOWN"

        if code == 200 and data then
            local decoded = json.decode(data)
            if decoded and decoded.version then
                latest = decoded.version
            end
        end

        local status = "^1UNKNOWN^0"
        if latest == localVersion then
            status = "^2UP-TO-DATE ✓^0"
        elseif latest ~= "UNKNOWN" then
            status = "^3OUTDATED ✖^0"
        end

        -- FIXED BUILD READ
        local build = tonumber(GetConvarInt("sv_enforceGameBuild", 0)) or 0
        local buildText =
            (build >= 2699)
            and ("^2SUPPORTED (" .. build .. ") ✓^0")
            or ("^1UNSUPPORTED (must be ≥ 2699)^0")

        local uptime = os.time() - startTime
        local h = math.floor(uptime / 3600)
        local m = math.floor((uptime % 3600) / 60)
        local s = uptime % 60

        print("")
        print("██████████████████████████████████████████████████████")
        print(" 🚀 R A D I A N T   D E V   V E R S I O N   C H E C K")
        print("██████████████████████████████████████████████████████")
        print("  Resource        ➜ " .. resource)
        print("  Installed       ➜ " .. localVersion)
        print("  Latest          ➜ " .. latest)
        print("  Status          ➜ " .. status)
        print("  Game Build      ➜ " .. buildText)
        print(("  Uptime          ➜ %02dh %02dm %02ds"):format(h, m, s))
        if status:find("OUTDATED") then
            print("  ⚠ UPDATE AVAILABLE! PLEASE DOWNLOAD THE LATEST VERSION.")
        end
        print("██████████████████████████████████████████████████████")
        print("  Support ➜ https://discord.gg/radiantdev")
        print("██████████████████████████████████████████████████████")
        print("")
    end)
end)

-----------------------------------------
-- GET LICENSE IDENTIFIER
-----------------------------------------
local function GetLicense(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find("license:") then return id end
    end
    return nil
end

-----------------------------------------
-- DISCORD ROLE CACHE FETCH
-----------------------------------------
local function FetchDiscordRoles(src)
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
            print("^6[DISCORD DEBUG]^0 HTTP:", code)
            print("^6[DISCORD DEBUG]^0 RAW:", data)
        end

        if code ~= 200 then
            cachedRoles[src] = {}
            return p:resolve({})
        end

        local decoded = json.decode(data or "{}")
        local roles = decoded and decoded.roles or {}

        cachedRoles[src] = roles  -- 🔥 Save roles in cache
        p:resolve(roles)
    end, "GET", "", {
        ["Authorization"] = "Bot " .. Config.Discord.BotToken
    })

    return Citizen.Await(p)
end

-----------------------------------------
-- READ ROLES (cached OR fetch)
-----------------------------------------
local function GetDiscordRoles(src)
    if cachedRoles[src] then
        return cachedRoles[src]  -- 🔥 Cached fetch
    end
    return FetchDiscordRoles(src)
end

-----------------------------------------
-- PERMISSION CHECK
-----------------------------------------
local function HasPermissions(src)
    -- ACE
    if IsPlayerAceAllowed(src, "group." .. Config.Permission.RequiredACE) then
        return true
    end

    -- Discord roles
    local roles = GetDiscordRoles(src)
    for _, r in ipairs(roles) do
        if Config.Discord.RoleMap[r] == Config.Permission.RequiredDiscord then
            return true
        end
    end

    return false
end

-----------------------------------------
-- SQL: Load Tag
-----------------------------------------
local function LoadPlayerTag(license)
    if not Config.UseSQL then return nil end

    local q = ("SELECT * FROM `%s` WHERE license = ?"):format(Config.SQLTable)
    local row = MySQL.single.await(q, { license })

    if not row then return nil end

    return {
        text    = row.tag_text or "",
        message = row.tag_message or "",
        color   = { row.color_r, row.color_g, row.color_b },
        color2  = { row.color_r2, row.color_g2, row.color_b2 },
        style   = row.style or "solid"
    }
end

-----------------------------------------
-- SQL: Save Tag
-----------------------------------------
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

-----------------------------------------
-- Player Connecting
-----------------------------------------
AddEventHandler("playerConnecting", function()
    local src = source
    local license = GetLicense(src)

    CreateThread(function()
        Wait(600)

        -- Cache Discord roles now
        GetDiscordRoles(src)

        tags[src] = LoadPlayerTag(license) or {}
        TriggerClientEvent("radiant:tags:updateAll", -1, tags)
    end)
end)

-----------------------------------------
-- /tagmenu
-----------------------------------------
RegisterCommand("tagmenu", function(src)
    if not HasPermissions(src) then
        TriggerClientEvent("chat:addMessage", src, {
            args = {"^1SYSTEM", "You do not have permission."}
        })
        return
    end

    local roles = GetDiscordRoles(src)
    local send = {}

    for _, role in ipairs(roles) do
        if Config.RoleText[role] then
            table.insert(send, {
                value = Config.RoleText[role],
                text  = Config.RoleText[role]
            })
        end
    end

    TriggerClientEvent("radiant:tags:openMenu", src, send)
end)

-----------------------------------------
-- Tag Save
-----------------------------------------
RegisterNetEvent("radiant:tags:setTag", function(data)
    local src = source
    local license = GetLicense(src)

    tags[src] = {
        text    = data.role,
        message = data.message,
        color   = { data.r, data.g, data.b },
        color2  = { data.r2, data.g2, data.b2 },
        style   = data.style
    }

    SavePlayerTag(license, tags[src])
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

-----------------------------------------
-- Cleanup
-----------------------------------------
AddEventHandler("playerDropped", function()
    cachedRoles[source] = nil
    tags[source] = nil
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)
