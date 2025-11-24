-----------------------------------------
-- R A D I A N T   D E V   C O N F I G
-----------------------------------------

Config = {}

-----------------------------------------------------
-- DISCORD BOT SETTINGS
-----------------------------------------------------
Config.Discord = {

    -- Your bot token & guild
    BotToken = "Your_BOT_TOKEN_HERE",
    GuildID  = "YOUR_GUILD_ID",

    -----------------------------------------------------
    -- Discord Role → Permission Group Mapping
    -- This decides who is allowed to open /tagmenu
    -----------------------------------------------------
    RoleMap = {
        ["ROLE_ID"] = "god",        -- Developer
        ["ROLE_ID"] = "admin",      -- USMS
        ["ROLE_ID"] = "sasp",
        ["ROLE_ID"] = "bcso",
        ["ROLE_ID"] = "civ"
    }
}

-----------------------------------------------------
-- DISCORD ROLE → TAG TEXT (UI Dropdown)
-----------------------------------------------------
Config.RoleText = {

    -- Admin / Dev
    ["ROLE_ID"] = "Developer",
    ["ROLE_ID"] = "USMS",

    -- Departments
    ["ROLE_ID"] = "SASP Officer",
    ["ROLE_ID"] = "BCSO Deputy",
    ["ROLE_ID"] = "Civilian",
  
}

-----------------------------------------------------
-- ACE PERMISSIONS (Matches server.cfg)
-----------------------------------------------------
Config.ACE = {

    RequireEntries = true,

    -- These DO NOT create permissions — they only validate identity
    Principals = {
        { identifier = "YOUR_DISCORD_ID", group = "god" },   -- you
    }
}

-----------------------------------------------------
-- TAG MENU PERMISSIONS
-----------------------------------------------------
Config.Permission = {
    RequiredACE     = "god",   -- Must have ACE group.god
    RequiredDiscord = "god"    -- Must have Discord role mapped to god
}

-----------------------------------------------------
-- DEBUG OPTIONS
-----------------------------------------------------
Config.Debug = {
    ShowRolePull        = true,   -- Prints Discord API response
    ACE_Enforcement     = false,
    Discord_Enforcement = false
}

-----------------------------------------------------
-- TAG SETTINGS (LENGTH / VIEW / COOLDOWN)
-----------------------------------------------------
Config.MaxTagLength       = 24
Config.MaxMessageLength   = 48
Config.TagChangeCooldown  = 5
Config.DrawDistance       = 35.0
Config.RequireLineOfSight = true
Config.AllowClientToggle  = true

-----------------------------------------------------
-- SQL SETTINGS
-----------------------------------------------------
Config.UseSQL   = true
Config.SQLTable = "radiant_tags"

-----------------------------------------------------
-- DEFAULT STYLE SETTINGS
-----------------------------------------------------
Config.DefaultTagStyle = "solid"     -- "solid" or "lr"
Config.GlobalStyleLock = false

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
    ["god"]   = "lr",
    ["admin"] = "solid",
}

-----------------------------------------------------
-- AUTO-TAGS: When user joins the server
-----------------------------------------------------
Config.DepartmentAutoTags = {
    ["ROLE_ID"] = "USMS",
    ["ROLE_ID"] = "DHS",
    ["ROLE_ID"] = "OWNER/DEV",
    ["141431100124ROLE_ID7187146"] = "Civilian",
}

-----------------------------------------------------
-- WEBHOOK LOGGING
-----------------------------------------------------
Config.Webhooks = {
    PlayerJoin = "DISCORD_WEBHOOK_LINK",
    TagChanged = "",
}
