-----------------------------------------
-- R A D I A N T   D E V   C O N F I G
-----------------------------------------

Config = {}

-----------------------------------------------------
-- ⚙️ DISCORD BOT SETTINGS
-----------------------------------------------------
Config.Discord = {
    BotToken = "YOUR_BOT_TOKEN_HERE",
    GuildID  = "YOUR_GUILD_ID_HERE",

    -- Map Discord Role IDs → Permission Groups
    RoleMap = {
        ["000000000000000000"] = "god",   -- Example
    }
}

-----------------------------------------------------
-- 🔐 ACE PERMISSIONS
-----------------------------------------------------
Config.ACE = {
    RequireEntries = true,

    Principals = {
        { identifier = "discord:123456123456", group = "god" },
    }
}

-----------------------------------------------------
-- 🛡️ TAG MENU PERMISSION REQUIREMENTS
-----------------------------------------------------
Config.Permission = {
    RequiredACE = "god",
    RequiredDiscord = "god"
}

-----------------------------------------------------
-- 🧪 DEBUG SETTINGS
-----------------------------------------------------
Config.Debug = {
    ShowRolePull = true,
    ACE_Enforcement = true,
    Discord_Enforcement = true
}

-----------------------------------------------------
-- 📝 TAG RULES & VISIBILITY SETTINGS
-----------------------------------------------------
Config.MaxTagLength       = 24
Config.TagChangeCooldown  = 5
Config.DrawDistance       = 35.0
Config.RequireLineOfSight = true
Config.AllowClientToggle  = true

-----------------------------------------------------
-- 💾 SQL DATABASE SETTINGS
-----------------------------------------------------
Config.UseSQL   = true
Config.SQLTable = "radiant_tags"

-----------------------------------------------------
-- 🎨 DEFAULT TAG STYLE CONFIG
-----------------------------------------------------
Config.DefaultTagStyle = "solid"
Config.GlobalStyleLock = false

-----------------------------------------------------
-- 🎨 DISCORD → STYLE OVERRIDES
-----------------------------------------------------
Config.DiscordStyleMap = {
    -- ["ROLE_ID"] = "pulse",
}

-----------------------------------------------------
-- 🎨 ACE → STYLE OVERRIDES
-----------------------------------------------------
Config.ACEStyleMap = {
    -- ["god"] = "outline",
}

-----------------------------------------------------
-- 🚔 DEPARTMENT AUTO-TAGS
-----------------------------------------------------
Config.DepartmentAutoTags = {
    -- ["ROLE_ID"] = "LSPD",
}

-----------------------------------------------------
-- 🌐 WEBHOOKS
-----------------------------------------------------
Config.Webhooks = {
    PlayerJoin = "",
    TagChanged = ""
}
