-----------------------------------------
-- R A D I A N T   D E V   C O N F I G
-----------------------------------------

Config = {}

-----------------------------------------------------
-- DISCORD BOT SETTINGS
-----------------------------------------------------
Config.Discord = {
    BotToken = "PUT_YOUR_BOT_TOKEN_HERE",
    GuildID  = "YOUR_GUILD_ID",

    RoleMap = {
        -- ["DiscordRoleID"] = "permission_group"
        ["000000000000000000"] = "god",
        ["000000000000000000"] = "owner",
        ["000000000000000000"] = "admin"
    }
}

-----------------------------------------------------
-- ACE MAPPING (USER MUST FILL THESE IN)
-----------------------------------------------------
Config.ACE = {
    RequireEntries = true,
    Principals = {
        -- { identifier = "license:xxxxxx", group = "god" },
        -- { identifier = "license:yyyyyy", group = "owner" }
    }
}

-----------------------------------------------------
-- REQUIRED PERMISSION LEVEL
-----------------------------------------------------
Config.Permission = {
    RequiredACE = "god",
    RequiredDiscord = "god"
}

-----------------------------------------------------
-- DEBUG
-----------------------------------------------------
Config.Debug = {
    ShowRolePull = false,
    ACE_Enforcement = true,
    Discord_Enforcement = true
}
