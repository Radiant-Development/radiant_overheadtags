--[[
██████   █████  ██████  ██  █████  ███    ██ ████████
██   ██ ██   ██ ██   ██ ██ ██   ██ ████   ██    ██   
██████  ███████ ██   ██ ██ ███████ ██ ██  ██    ██   
██   ██ ██   ██ ██   ██ ██ ██   ██ ██  ██ ██    ██   
██   ██ ██   ██ ██████  ██ ██   ██ ██   ████    ██    
        R A D I A N T   D E V E L O P M E N T
]]

local tags = {}
local Config = Config

-----------------------------------------
-- DISCORD ROLE CHECK FUNCTION
-----------------------------------------
local function GetDiscordRoles(src)
    local identifier = nil
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find("discord:") then
            identifier = id:gsub("discord:", "")
            break
        end
    end

    if not identifier then return {} end

    local roles = {}
    local endpoint = ("https://discord.com/api/v10/guilds/%s/members/%s"):format(Config.Discord.GuildID, identifier)

    PerformHttpRequest(endpoint, function(code, data)
        if code == 200 then
            local jsonData = json.decode(data)
            roles = jsonData.roles or {}
        end
    end, "GET", "", {
        ["Authorization"] = "Bot " .. Config.Discord.BotToken
    })

    return roles
end
------------------------------------------------------------------
--  R A D I A N T   D E V  — PLAYER ROLE SYNC LOGGING SYSTEM
------------------------------------------------------------------
local JoinWebhook = "https://discord.com/api/webhooks/1441712129425277020/cY7qmkYveEfZrP6Ps5FnRJuNgYloHsB3qITe33y0Ld1crCH5WbbEJjyROdfcOTOFEZJJ"


------------------------------------------------------------------
-- DISCORD WEBHOOK SEND
------------------------------------------------------------------
local function SendToWebhook(title, description, color)
    local embed = {
        {
            ["title"] = title,
            ["description"] = description,
            ["color"] = color or 16711680,
            ["footer"] = { ["text"] = "Radiant Development • Discord Sync" },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(JoinWebhook, function(err, text, headers) end, "POST", json.encode({
        username = "RadiantDev Sync Bot",
        embeds = embed
    }), { ["Content-Type"] = "application/json" })
end


------------------------------------------------------------------
-- BEAUTIFUL RADIANT BANNER LOG
------------------------------------------------------------------
local function RadiantBannerLog(src, name, mappedRoles)
    print("^6━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━^0")
    print("^5        R A D I A N T   D E V   D I S C O R D   S Y N C^0")
    print("^6━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━^0")
    print(("^7Player:^0 %s (^2%s^0)"):format(name, src))

    if mappedRoles == "" then
        print("^7Mapped Roles:^0 ^1None (No matching config roles)^0")
    else
        print("^7Mapped Roles:^0 ^3" .. mappedRoles .. "^0")
    end

    print("^6━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━^0\n")
end


------------------------------------------------------------------
-- RAW CONSOLE LOG
------------------------------------------------------------------
local function BasicConsoleLog(src, name, roleList)
    print(("[RADIANT DEV] %s (%s) connected with roles: %s"):format(
        name, src, roleList ~= "" and roleList or "NONE"
    ))
end


------------------------------------------------------------------
-- PLAYER CONNECT EVENT — FULL ROLE SYNC SYSTEM
------------------------------------------------------------------
AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local src = source

    CreateThread(function()
        Wait(1500)  -- ensure identifiers are loaded

        local roles = GetDiscordRoles(src)
        if not roles then
            BasicConsoleLog(src, name, "")
            RadiantBannerLog(src, name, "")
            SendToWebhook(
                "**Player Connected (No Roles Found)**",
                ("Player: **%s** (`%s`)\nDiscord roles: **None Available**"):format(name, src),
                16734464
            )
            return
        end

        local mapped = {}

        for _, role in ipairs(roles) do
            local mappedGroup = Config.Discord.RoleMap[role]
            if mappedGroup then
                table.insert(mapped, mappedGroup)
            end
        end

        local mappedStr = table.concat(mapped, ", ")

        ------------------------------------------------------
        -- PRINT OUTPUTS
        ------------------------------------------------------
        BasicConsoleLog(src, name, mappedStr)
        RadiantBannerLog(src, name, mappedStr)

        ------------------------------------------------------
        -- SEND DISCORD WEBHOOK
        ------------------------------------------------------
        SendToWebhook(
            "Player Connected — Discord Role Sync",
            ("Player: **%s** (`%s`)\nMapped Permissions: **%s**\nDiscord Role IDs: `%s`"):format(
                name,
                src,
                mappedStr ~= "" and mappedStr or "None",
                table.concat(roles, ", ")
            ),
            65280 -- green
        )
    end)
end)

-----------------------------------------
-- PERMISSION CHECK
-----------------------------------------
local function HasPermissions(src)
    local requiredACE = Config.Permission.RequiredACE
    local requiredDiscord = Config.Permission.RequiredDiscord

    -- ACE CHECK
    if Config.ACE_Enforcement and not IsPlayerAceAllowed(src, "group." .. requiredACE) then
        return false
    end

    -- DISCORD ROLE CHECK
    if Config.Discord_Enforcement then
        local roles = GetDiscordRoles(src)
        for _, role in ipairs(roles) do
            if Config.Discord.RoleMap[role] == requiredDiscord then
                return true
            end
        end
        return false
    end

    return true
end

-----------------------------------------
-- TAG MENU COMMAND
-----------------------------------------
RegisterCommand("tagmenu", function(source)
    if not HasPermissions(source) then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'No permission.' } })
        return
    end
    TriggerClientEvent("radiant:tags:openMenu", source)
end)

-----------------------------------------
-- SETTING TAGS
-----------------------------------------
RegisterNetEvent("radiant:tags:setTag", function(text, r, g, b)
    local src = source
    tags[src] = {
        text = text,
        color = {r, g, b}
    }
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)

AddEventHandler("playerDropped", function()
    tags[source] = nil
    TriggerClientEvent("radiant:tags:updateAll", -1, tags)
end)
