-----------------------------------------
-- R A D I A N T   D E V   C O N F I G
-- FULL-SYSTEM UPGRADE (MODIFIED VERSION)
-----------------------------------------

Config = {}

-----------------------------------------------------
-- DISCORD BOT SETTINGS
-----------------------------------------------------
Config.Discord = {
    BotToken = "PUT_YOUR_BOT_TOKEN_HERE",
    GuildID  = "YOUR_GUILD_ID",

    -- Map Discord Role IDs to permission groups
    RoleMap = {
        -- ["DiscordRoleID"] = "permission_group"
        ["000000000000000000"] = "god",
        -- keep any of your existing entries here
    }
}

-----------------------------------------------------
-- ACE PERMISSIONS
-----------------------------------------------------
Config.ACE = {
    RequireEntries = true,

    Principals = {
        -- { identifier = "license:xxxx", group = "god" },
        -- keep your existing entries
    }
}

-----------------------------------------------------
-- TAG SYSTEM PERMISSION REQUIREMENTS
-----------------------------------------------------
Config.Permission = {
    RequiredACE = "god",        -- ACE group required to open /tagmenu
    RequiredDiscord = "god"     -- Discord group required to access UI
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
-- Maximum tag text length
Config.MaxTagLength = 24

-- Cooldown between tag changes
Config.TagChangeCooldown = 5   -- seconds

-- Maximum draw distance for tags
Config.DrawDistance = 35.0

-- Only show tag when the player is LOOKING at another player
Config.RequireLineOfSight = true

-- Allow player to toggle tags on/off with keybind (F6)
Config.AllowClientToggle = true

-----------------------------------------------------
-- SQL PERSISTENCE (NEW)
-----------------------------------------------------
Config.UseSQL = true     -- will load/save tags across restarts

-- SQL Table name
Config.SQLTable = "radiant_tags"

-----------------------------------------------------
-- DEFAULT STYLE + OVERRIDES
-----------------------------------------------------
-- Default fallback style if no forced/discord/ui choice applies
-- Options: "solid", "lr", "tb", "outline", "pulse"
Config.DefaultTagStyle = "solid"

-- If true: no one can pick their style in the UI
Config.GlobalStyleLock = false

-----------------------------------------------------
-- DISCORD ROLE → STYLE (Priority 2)
-----------------------------------------------------
-- Discord roles that FORCE tag style
-- These override UI but not ACE
Config.DiscordStyleMap = {
    -- ["ROLE_ID"] = "lr",
    -- ["ROLE_ID"] = "tb",
    -- ["ROLE_ID"] = "outline",
    -- ["ROLE_ID"] = "pulse"
}

-----------------------------------------------------
-- ACE → STYLE OVERRIDE (Priority 1 — Highest)
-----------------------------------------------------
-- ACE groups that FORCE a tag style ALWAYS
Config.ACEStyleMap = {
    -- ["god"] = "pulse",
    -- ["owner"] = "lr",
    -- ["admin"] = "outline"
}

-----------------------------------------------------
-- DEPARTMENT AUTO-TAGS (from Discord roles)
-----------------------------------------------------
Config.DepartmentAutoTags = {
    -- ["ROLE_ID"] = "LSPD",
    -- ["ROLE_ID"] = "BCSO",
    -- ["ROLE_ID"] = "SAFR",
    -- ["ROLE_ID"] = "DISPATCH"
}

-----------------------------------------------------
-- WEBHOOK LOGGING
-----------------------------------------------------
Config.Webhooks = {
    PlayerJoin = "https://discord.com/api/webhooks/1441712129425277020/cY7qmkYveEfZrP6Ps5FnRJuNgYloHsB3qITe33y0Ld1crCH5WbbEJjyROdfcOTOFEZJJ",

    -- NEW: Tag Change Logging
    TagChanged = "",   -- <--- fill in optional webhook for tag-edit logs
}

