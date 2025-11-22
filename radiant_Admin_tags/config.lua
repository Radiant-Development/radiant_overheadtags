-----------------------------------------
-- R A D I A N T   D E V   C O N F I G
-- CLEAN FIXED VERSION
-----------------------------------------

Config = {}

-----------------------------------------------------
-- 1. DISCORD BOT SETTINGS
-----------------------------------------------------
Config.Discord = {
    BotToken = "PUT_YOUR_DISCORD_BOT_TOKEN_HERE",
    GuildID  = "YOUR_GUILD_ID",

    -- Map Discord Role IDs to permission groups
    RoleMap = {
        -- ["ROLE_ID"] = "groupname",
        -- Example:
        -- ["123456789012345678"] = "god",
        -- ["987654321987654321"] = "admin",
    }
}

-----------------------------------------------------
-- 2. ACE PERMISSION SETTINGS
-----------------------------------------------------
Config.ACE = {
    RequireEntries = true,

    -- Add player license identifiers here
    Principals = {
        -- { identifier = "license:xxxxxx", group = "god" },
        -- { identifier = "license:yyyyyy", group = "owner" },
    }
}

-----------------------------------------------------
-- 3. TAG PERMISSION REQUIREMENTS
-----------------------------------------------------
Config.Permission = {
    RequiredACE = "god",        -- ACE group required to use /tagmenu
    RequiredDiscord = "god"     -- Discord role required to use the menu
}

-----------------------------------------------------
-- 4. DEBUG OPTIONS
-----------------------------------------------------
Config.Debug = {
    ShowRolePull = false,
    ACE_Enforcement = true,
    Discord_Enforcement = true
}

-----------------------------------------------------
-- 5. UPCOMING ADVANCED TAG SYSTEM SETTINGS
-- (These will be used when we install the full upgrade)
-----------------------------------------------------

-- Max characters allowed for a tag
Config.MaxTagLength = 24

-- Cooldown for how often players may change tags
Config.TagChangeCooldown = 5   -- seconds

-- Draw distance for 3D rendering
Config.DrawDistance = 35.0

-- Default style if no Discord / ACE override is applied
-- Options will include: "solid", "lr", "tb", "outline", "pulse"
Config.DefaultTagStyle = "solid"

-- Server-wide enforcement (if true, player UI cannot change style)
Config.GlobalStyleLock = false

-- Discord-based auto styles (used in upgrade)
Config.DiscordStyleMap = {
    -- ["ROLE_ID"] = "lr",
    -- ["ROLE_ID"] = "tb",
    -- ["ROLE_ID"] = "outline",
    -- ["ROLE_ID"] = "pulse"
}

-- ACE-based forced st
