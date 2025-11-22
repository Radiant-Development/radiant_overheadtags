-----------------------------------------
-- R A D I A N T   D E V   C O N F I G
-----------------------------------------

Config = {}

-----------------------------------------------------
-- DISCORD BOT SETTINGS
-----------------------------------------------------
Config.Discord = {
    BotToken = "YOUR BOT TOKEN HERE",
    GuildID  = "YOUR GUILD ID HERE",

    RoleMap = {
         ["0000000000000000"] = "god",   -- example role
    }
}






-----------------------------------------------------
-- ACE PERMISSIONS
-----------------------------------------------------
Config.ACE = {
    RequireEntries = true,

    Principals = {
        { identifier = "discord:123456123456", group = "god" },
    }
}

-----------------------------------------------------
-- TAG SYSTEM PERMISSION REQUIREMENTS
-----------------------------------------------------
Config.Permission = {
    RequiredACE = "god",
    RequiredDiscord = "god"
}

-----------------------------------------------------
-- DEBUG SETTINGS
-----------------------------------------------------
Config.Debug = {
    ShowRolePull = true,
    ACE_Enforcement = true,
    Discord_Enforcement = true
}

-----------------------------------------------------
-- TAG LENGTH, COOLDOWN, DISTANCE
-----------------------------------------------------
Config.MaxTagLength = 24
Config.TagChangeCooldown = 5
Config.DrawDistance = 35.0
Config.RequireLineOfSight = true
Config.AllowClientToggle = true

-----------------------------------------------------
-- SQL PERSISTENCE
-----------------------------------------------------
Config.UseSQL = true
Config.SQLTable = "radiant_tags"

-----------------------------------------------------
-- DEFAULT STYLE
-----------------------------------------------------
Config.DefaultTagStyle = "solid"
Config.GlobalStyleLock = false

-----------------------------------------------------
-- DISCORD ROLE → STYLE OVERRIDES
-----------------------------------------------------
Config.DiscordStyleMap = {}

-----------------------------------------------------
-- ACE → STYLE OVERRIDES
-----------------------------------------------------
Config.ACEStyleMap = {}

-----------------------------------------------------
-- DEPARTMENT AUTO-TAGS
-----------------------------------------------------
Config.DepartmentAutoTags = {}

-----------------------------------------------------
-- WEBHOOK LOGGING
-----------------------------------------------------
Config.Webhooks = {
    PlayerJoin = "https://discord.com/api/webhooks/1441712129425277020/cY7qmkY...",
    TagChanged = ""
}
