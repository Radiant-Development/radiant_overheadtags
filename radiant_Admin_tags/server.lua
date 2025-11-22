-----------------------------------------
-- R A D I A N T   D E V   S E R V E R
-----------------------------------------

local Config = Config
local tags = {}
local cooldowns = {}

print(("^3[RADIANT DEBUG]^0 Bot Token (first 6): %s"):format(Config.Discord.BotToken:sub(1, 6)))

-----------------------------------------------------
-- LICENSE IDENTIFIER
-----------------------------------------------------
local function GetLicense(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find("license:") then
            return id
        end
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
        text   = result.tag_text or "",
        color  = { result.color_r,  result.color_g,  result.color_b },
        color2 = { result.color_r2 or result.color_r, result.color_g2 or result.color_g, result.color_b2 or result.color_b },
        style  = result.style or "solid",
        message = result.tag_message or ""
    }
end

-----------------------------------------------------
-- SQL: SAVE TAG
-----------------------------------------------------
local function SavePlayerTag(license, data)
    if not Config.UseSQL then return end

    MySQL.update.await(
        string.format([[
            INSERT INTO `%s` 
            (license, tag_text, tag_message, color_r, color_g, color_b, color_r2, color_g2, color_b2, style)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                tag_text     = VALUES(tag_text),
                tag_message  = VALUES(tag_message),
                color_r      = VALUES(color_r),
                color_g      = VALUES(color_g),
                color_b      = VALUES(color_b),
                color_r2     = VALUES(color_r2),
                color_g2     = VALUES(color_g2),
                color_b2     = VALUES(color_b2),
                style        = VALUES(style)
        ]], Config.SQLTable),
        {
            license,
            data.text,
            data.message,
            data.color[1], data.color[2], data.color[3],
            data.color2[1], data.color2[2], data.color2[3],
            data.style
        }
    )
end

-----------------------------------------------------
-- SQL: CREATE TABLE IF NOT EXISTS
-----------------------------------------------------
local function CreateSQLTable()
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
end
CreateSQLTable()

-----------------------------------------------------
-- DISCORD ROLE FETCH
-----------------------------------------------------
local function GetDiscordRoles(src)
    local discordId = nil

    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find("discord:") then
            discordId = id:gsub("discord:", "")
            break
        end
    end

    if not discordId then
        print("^1[DISCORD]^0 no discord identifier found")
        return {}
    end

    local url = ("https://discord.com/api/v10/guilds/%s/members/%s"):
        format(Config.Discord.GuildID, discordId)

    local p = promise.new()

    PerformHttpRequest(url, function(code, data)
        if Config.Debug.ShowRolePull then
            print("^3[DISCORD]^0 HTTP:", code)
            print("^3[DISCORD]^0 RESP:", data)
        end

        if code ~= 200 then
            p:resolve({})
            return
        end

        local decoded = json.decode(data or "{}")
        if decoded and decoded.roles then
            p:resolve(decoded.roles)
        else
            p:resolve({})
        end
    end, "GET", "", {
        ["Authorization"] = "Bot " .. Config.Discord.BotToken
    })

    return Citizen.Await(p)
end

-----------------------------------------------------
-- STYLE PRIORITY ENGINE
-----------------------------------------------------
local function ResolveStyle(src, uiStyle)
    local roles = GetDiscordRoles(src)

    -- ACE override
    for group, forced in pairs(Config.ACEStyleMap) do
        if IsPlayerAceAllowed(src, "group." .. group) then
            return forced
        end
    end

    -- Discord override
    for _, r in ipairs(roles) do
        if Config.DiscordStyleMap[r] then
            return Config.DiscordStyleMap[r]
        end
    end

    return uiStyle or Config.DefaultTagStyle or "solid"
end

-----------------------------------------------------
-- DEPARTMENT AUTO-TAG TEXT
-----------------------------------------------------
local function ResolveDepartmentTag(src)
    local roles = GetDiscordRoles(src)
    for _, r in ipairs(roles) do
        if Config.DepartmentAutoTags[r] then
            return Config.DepartmentAutoTags[r]
        end
    end
    return nil
end

-----------------------------------------------------
-- PERMISSION CHECK
-----------------------------------------------------
local function HasPermissions(src)
    if Config.Debug.ACE_Enforcement then
        if IsPlayerAceAllowed(src, "group." .. Config.Permission.RequiredACE) then
            return true
        end
    end

    if Config.Debug.Discord_Enforcement then
        local roles = GetDiscordRoles(src)
        for _, r in ipairs(roles) do
            if Config.Discord.RoleMap[r] == Config.Permission.RequiredDiscord then
                return true
            end
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
        Wait(800)

        if Config.UseSQL and license then
            tags[src] = LoadPlayerTag(license) or {}
        end

        -- Auto-tag based on department
        local dept = ResolveDepartmentTag(src)
        if dept then
            tags[src] = tags[src] or {}
            tags[src].text = dept
        end

        TriggerClientEvent("radiant:tags:updateAll", -1, tags)
    end)
end)

-----------------------------------------------------
-- /tagmenu COMMAND
-----------------------------------------------------
RegisterCommand("tagmenu", function(src)
    if not HasPermissions(src) then
        TriggerClientEvent("chat:addMessage", src,
            { args = { "^1SYSTEM", "You do not have permission." } })
        return
    end

    -- send roles → UI
    local roles = GetDiscordRoles(src)
    local send = {}

    for _, r in ipairs(roles) do
        if Config.RoleText and Config.RoleText[r] then
            table.insert(send, {
                value = Config.RoleText[r],
                text = Config.RoleText[r]
            })
        end
    end

    TriggerClientEvent("radiant:tags:openMenu", src, send)
end)

-----------------------------------------------------
-- SAVE TAG
-----------------------------------------------------
RegisterNetEvent("radiant:tags:setTag", function(payload)
    local src = source
    local license = GetLicense(src)
    local now = os.time()

    -- cooldown
    if cooldowns[src] and (now - cooldowns[src] < Config.TagChangeCooldown) then
        return
    end
    cooldowns[src] = now

    local uiStyle = payload.style
    local resolvedStyle = ResolveStyle(src, uiStyle)

    tags[src] = {
        text    = payload.role,         -- selected role text
        message = payload.message or "",-- sub-message
        color   = { payload.r,  payload.g,  payload.b },
        color2  = { payload.r2 or payload.r, payload.g2 or payload.g, payload.b2 or payload.b },
        style   = resolvedStyle
    }

    if Config.UseSQL and license then
        SavePlayerTag(license, tags[src])
    end

    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

-----------------------------------------------------
-- ADMIN COMMANDS
-----------------------------------------------------

-- Force text override
RegisterCommand("tagforce", function(src, args)
    if not IsPlayerAceAllowed(src, "group.owner") then return end

    local id   = tonumber(args[1])
    local text = table.concat(args, " ", 2)

    if not id or not text then return end

    tags[id] = tags[id] or {}
    tags[id].text = text
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

-- Force style
RegisterCommand("tagstyle", function(src, args)
    if not IsPlayerAceAllowed(src, "group.owner") then return end

    local id    = tonumber(args[1])
    local style = args[2]

    if not id or not style then return end

    tags[id] = tags[id] or {}
    tags[id].style = style
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

-- Reload tags
RegisterCommand("tagreload", function(src)
    if not IsPlayerAceAllowed(src, "group.admin") then return end
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

-- Reset tag
RegisterCommand("tagreset", function(src, args)
    if not IsPlayerAceAllowed(src, "group.admin") then return end

    local id = tonumber(args[1])
    if not id then return end

    tags[id] = nil
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

-- Wipe all tags
RegisterCommand("tagwipeall", function(src)
    if not IsPlayerAceAllowed(src, "group.owner") then return end

    tags = {}
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

-----------------------------------------------------
-- PLAYER DROPPED
-----------------------------------------------------
AddEventHandler("playerDropped", function()
    tags[source] = nil
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

   
