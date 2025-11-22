--[[
██████   █████  ██████  ██  █████  ███    ██ ████████
██   ██ ██   ██ ██   ██ ██ ██   ██ ████   ██    ██
██████  ███████ ██   ██ ██ ███████ ██ ██  ██    ██
██   ██ ██   ██ ██   ██ ██ ██   ██ ██  ██ ██    ██
██   ██ ██   ██ ██████  ██ ██   ██ ██   ████    ██
        R A D I A N T   D E V E L O P M E N T
]]

local Config = Config
local tags = {}
local cooldowns = {}

---------------------------------------------------------------------
--  GET LICENSE
---------------------------------------------------------------------
local function GetLicense(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find("license:") then return id end
    end
    return nil
end

---------------------------------------------------------------------
--  SQL: LOAD PLAYER TAG
---------------------------------------------------------------------
local function LoadPlayerTag(license)
    if not Config.UseSQL then return nil end

    local result = MySQL.single.await(
        "SELECT * FROM `" .. Config.SQLTable .. "` WHERE license = ?",
        {license}
    )

    if not result then return nil end

    return {
        text  = result.tag_text or "",
        color = { result.color_r, result.color_g, result.color_b },
        color2 = {
            result.color_r2 or result.color_r,
            result.color_g2 or result.color_g,
            result.color_b2 or result.color_b
        },
        style = result.style or "solid"
    }
end

---------------------------------------------------------------------
--  SQL: SAVE PLAYER TAG
---------------------------------------------------------------------
local function SavePlayerTag(license, data)
    if not Config.UseSQL then return end

    MySQL.update.await(
        [[
            INSERT INTO `]] .. Config.SQLTable .. [[`
            (license, tag_text, color_r, color_g, color_b, color_r2, color_g2, color_b2, style)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                tag_text = VALUES(tag_text),
                color_r = VALUES(color_r),
                color_g = VALUES(color_g),
                color_b = VALUES(color_b),
                color_r2 = VALUES(color_r2),
                color_g2 = VALUES(color_g2),
                color_b2 = VALUES(color_b2),
                style = VALUES(style)
        ]],
        {
            license,
            data.text,
            data.color[1], data.color[2], data.color[3],
            data.color2[1], data.color2[2], data.color2[3],
            data.style
        }
    )
end

---------------------------------------------------------------------
--  SQL: AUTO CREATE TABLE
---------------------------------------------------------------------
local function CreateSQLTable()
    if not Config.UseSQL then return end

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `]] .. Config.SQLTable .. [[` (
            id INT NOT NULL AUTO_INCREMENT,
            license VARCHAR(255) NOT NULL,
            tag_text VARCHAR(255) DEFAULT NULL,
            color_r INT DEFAULT 255,
            color_g INT DEFAULT 255,
            color_b INT DEFAULT 255,
            color_r2 INT DEFAULT 255,
            color_g2 INT DEFAULT 255,
            color_b2 INT DEFAULT 255,
            style VARCHAR(50) DEFAULT 'solid',
            PRIMARY KEY (id),
            UNIQUE KEY license_unique (license)
        );
    ]])

    print("^2[RADIANT DEV]^0 SQL table verified/created.")
end
CreateSQLTable()

---------------------------------------------------------------------
--  DISCORD ROLES (SYNCED, FIXED)
---------------------------------------------------------------------
local function GetDiscordRoles(src)
    local discordId = nil
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find("discord:") then
            discordId = id:gsub("discord:", "")
            break
        end
    end

    if not discordId then return {} end

    local p = promise.new()

    PerformHttpRequest(
        ("https://discord.com/api/v10/guilds/%s/members/%s")
            :format(Config.Discord.GuildID, discordId),
        function(code, data)
            if code ~= 200 then
                p:resolve({})
            else
                local parsed = json.decode(data)
                p:resolve(parsed.roles or {})
            end
        end,
        "GET", "",
        { ["Authorization"] = "Bot " .. Config.Discord.BotToken }
    )

    return Citizen.Await(p)
end

---------------------------------------------------------------------
--  STYLE PRIORITY ENGINE
--  ACE > Discord > Department > Default > UI
---------------------------------------------------------------------
local function ResolveStyle(src, uiStyle)
    local roles = GetDiscordRoles(src)

    -- ACE OVERRIDE
    for group, forcedStyle in pairs(Config.ACEStyleMap) do
        if IsPlayerAceAllowed(src, "group." .. group) then
            return forcedStyle
        end
    end

    -- DISCORD OVERRIDE
    for _, role in ipairs(roles) do
        if Config.DiscordStyleMap[role] then
            return Config.DiscordStyleMap[role]
        end
    end

    -- DEPARTMENT AUTO-TAG STYLE
    for _, role in ipairs(roles) do
        if Config.DepartmentAutoTags[role] then
            return "solid"  -- dept tags always solid unless you decide otherwise
        end
    end

    -- SERVER DEFAULT STYLE
    if Config.DefaultTagStyle then
        return Config.DefaultTagStyle
    end

    -- UI-Selected Style
    return uiStyle or "solid"
end

---------------------------------------------------------------------
--  SET DEPARTMENT AUTO-TAG TEXT
---------------------------------------------------------------------
local function ResolveDepartmentText(src)
    local roles = GetDiscordRoles(src)
    for _, role in ipairs(roles) do
        if Config.DepartmentAutoTags[role] then
            return Config.DepartmentAutoTags[role]
        end
    end
    return nil
end

---------------------------------------------------------------------
--  WEBHOOK LOGGING
---------------------------------------------------------------------
local function LogTagChange(src, oldData, newData)
    local url = Config.Webhooks.TagChanged
    if url == "" then return end

    local name = GetPlayerName(src) or ("Player "..src)

    local desc = ("**%s** (`%s`)\nUpdated Tag:\nOld: `%s`\nNew: `%s`\nStyle: **%s**")
        :format(name, src, oldData.text or "none", newData.text, newData.style)

    PerformHttpRequest(url, function() end, "POST",
        json.encode({
            username = "RadiantDev Tags",
            embeds = {{
                title = "Tag Updated",
                description = desc,
                color = 3447003,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }),
        { ["Content-Type"] = "application/json" }
    )
end

---------------------------------------------------------------------
--  PERMISSION CHECK
---------------------------------------------------------------------
local function HasPermissions(src)
    -- ACE check
    if Config.Debug.ACE_Enforcement and
        not IsPlayerAceAllowed(src, "group." .. Config.Permission.RequiredACE) then
        return false
    end

    -- Discord role check
    if Config.Debug.Discord_Enforcement then
        local roles = GetDiscordRoles(src)
        for _, r in ipairs(roles) do
            if Config.Discord.RoleMap[r] == Config.Permission.RequiredDiscord then
                return true
            end
        end
        return false
    end

    return true
end

---------------------------------------------------------------------
--  PLAYER CONNECT: Load Tag + Department Auto-Tag
---------------------------------------------------------------------
AddEventHandler("playerConnecting", function(name)
    local src = source
    local license = GetLicense(src)

    CreateThread(function()
        Wait(1000)

        -- Load SQL Tag
        if Config.UseSQL and license then
            local stored = LoadPlayerTag(license)
            if stored then
                tags[src] = stored
            end
        end

        -- Department Auto-Tag Text
        local dept = ResolveDepartmentText(src)
        if dept then
            tags[src] = tags[src] or {}
            tags[src].text = dept
        end

        TriggerClientEvent("radiant:tags:updateAll", -1, tags)
    end)
end)

---------------------------------------------------------------------
--  TAG MENU COMMAND
---------------------------------------------------------------------
RegisterCommand("tagmenu", function(src)
    if not HasPermissions(src) then
        TriggerClientEvent("chat:addMessage", src,
            { args = {"^1SYSTEM", "No permission."} })
        return
    end
    TriggerClientEvent("radiant:tags:openMenu", src)
end)

---------------------------------------------------------------------
--  SAVE TAG FROM UI
---------------------------------------------------------------------
RegisterNetEvent("radiant:tags:setTag", function(text, r, g, b, r2, g2, b2, uiStyle)
    local src = source
    local license = GetLicense(src)
    local now = os.time()

    -- cooldown
    if cooldowns[src] and (now - cooldowns[src] < Config.TagChangeCooldown) then
        return
    end
    cooldowns[src] = now

    local oldData = tags[src] or {}

    local resolvedStyle = ResolveStyle(src, uiStyle)

    tags[src] = {
        text  = text,
        color = {r, g, b},
        color2 = {r2 or r, g2 or g, b2 or b},
        style = resolvedStyle
    }

    -- Log change
    LogTagChange(src, oldData, tags[src])

    if Config.UseSQL and license then
        SavePlayerTag(license, tags[src])
    end

    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

---------------------------------------------------------------------
--  ADMIN COMMANDS
---------------------------------------------------------------------

-- force text
RegisterCommand("tagforce", function(src, args)
    if not IsPlayerAceAllowed(src, "group.owner") then return end

    local id = tonumber(args[1])
    local txt = table.concat(args, " ", 2)
    if not id or not txt then return end

    tags[id] = tags[id] or {}
    tags[id].text = txt
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

-- force style
RegisterCommand("tagstyle", function(src, args)
    if not IsPlayerAceAllowed(src, "group.owner") then return end

    local id = tonumber(args[1])
    local style = args[2]
    if not id or not style then return end

    tags[id] = tags[id] or {}
    tags[id].style = style
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

-- reload tags
RegisterCommand("tagreload", function(src)
    if not IsPlayerAceAllowed(src, "group.admin") then return end
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

-- reset tag
RegisterCommand("tagreset", function(src, args)
    if not IsPlayerAceAllowed(src, "group.admin") then return end

    local id = tonumber(args[1])
    if not id then return end

    tags[id] = nil
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

-- wipe all
RegisterCommand("tagwipeall", function(src)
    if not IsPlayerAceAllowed(src, "group.owner") then return end

    tags = {}
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

---------------------------------------------------------------------
--  PLAYER DROPPED
---------------------------------------------------------------------
AddEventHandler("playerDropped", function()
    tags[source] = nil
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)
