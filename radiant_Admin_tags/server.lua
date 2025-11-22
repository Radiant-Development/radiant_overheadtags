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
