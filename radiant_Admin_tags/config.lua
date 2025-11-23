-----------------------------------------
-- R A D I A N T   D E V   C O N F I G
-----------------------------------------

Config = {}

-----------------------------------------------------
-- DISCORD BOT SETTINGS
-----------------------------------------------------
Config.Discord = {
    BotToken = "YOUR_BOT_TOKEN_HERE",
    GuildID  = "YOUR_GUILD_ID_HERE",

    -- Discord Role → Permission Group Mapping
    RoleMap = {
        -- ["ROLE_ID"] = "god",
        -- ["ROLE_ID"] = "admin",
    },
}

-----------------------------------------------------
-- ACE PERMISSIONS (SERVER.CFG SUPPORT)
-----------------------------------------------------
Config.ACE = {
    RequireEntries = true,

    -- These do NOT assign perms — they help scripts check identity
    Principals = {
        -- { identifier = "discord:654859497373827073", group = "god" },
    }
}

-----------------------------------------------------
-- TAG SYSTEM PERMISSION REQUIREMENTS
-----------------------------------------------------
Config.Permission = {
    RequiredACE     = "god",    -- Must have group.god
    RequiredDiscord = "god"     -- Discord RoleMap must give "god"
}

-----------------------------------------------------
-- DEBUG SETTINGS
-----------------------------------------------------
Config.Debug = {
    ShowRolePull        = true,   -- Prints Discord API responses
    ACE_Enforcement     = true,   -- Require ACE group
    Discord_Enforcement = true,   -- Require Discord role
}

-----------------------------------------------------
-- TAG SETTINGS: LENGTH, DISTANCE, COOLDOWN
-----------------------------------------------------
Config.MaxTagLength      = 24       -- Max characters for main tag
Config.MaxMessageLength  = 48       -- Max length for sub-message
Config.TagChangeCooldown = 5        -- Seconds between tag edits
Config.DrawDistance      = 35.0     -- Max view distance
Config.RequireLineOfSight = true    -- Hide through walls
Config.AllowClientToggle = true     -- F6 hide/show

-----------------------------------------------------
-- SQL SETTINGS
-----------------------------------------------------
Config.UseSQL   = true
Config.SQLTable = "radiant_tags"

-----------------------------------------------------
-- DEFAULT TAG STYLE
-----------------------------------------------------
Config.DefaultTagStyle = "solid"   -- "solid" or "lr"
Config.GlobalStyleLock = false     -- true = UI cannot change style

-----------------------------------------------------
-- DISCORD ROLE → STYLE OVERRIDES
-----------------------------------------------------
Config.DiscordStyleMap = {
    -- ["ROLE_ID"] = "solid",
    -- ["ROLE_ID"] = "lr",
}

-----------------------------------------------------
-- ACE GROUP → STYLE OVERRIDES
-----------------------------------------------------
Config.ACEStyleMap = {
    -- ["god"] = "lr",
    -- ["admin"] = "solid",
}

-----------------------------------------------------
-- DISCORD DEPARTMENT AUTO-TAGS
-----------------------------------------------------
-- Auto sets tag text when joining the server
Config.DepartmentAutoTags = {
    -- ["ROLE_ID"] = "LSPD",
    -- ["ROLE_ID"] = "BCSO",
    -- ["ROLE_ID"] = "SASP",
    -- ["ROLE_ID"] = "SAFR",
}

-----------------------------------------------------
-- WEBHOOK LOGGING
-----------------------------------------------------
Config.Webhooks = {
    PlayerJoin = "",
    TagChanged = "",
}

-----------------------------------------------------
-- UI ROLE TEXT MAP (Dropdown Display)
-----------------------------------------------------
Config.RoleText = {
    -- ["ROLE_ID"] = "DEV",
    -- ["ROLE_ID"] = "LSPD Officer",
    -- ["ROLE_ID"] = "BCSO Deputy",
    -- ["ROLE_ID"] = "Civilian",
}
