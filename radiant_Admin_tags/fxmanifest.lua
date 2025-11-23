-----------------------------------------
-- R A D I A N T   D E V   M A N I F E S T
-----------------------------------------

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'radiant_admin_tags'
author 'Radiant Development'
description 'Advanced Overhead Tag System with Discord Role Mapping + Sub-messages'
version '1.0.0'

-----------------------------------------
-- FILES
-----------------------------------------
files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

-----------------------------------------
-- NUI PAGE
-----------------------------------------
ui_page 'html/index.html'

-----------------------------------------
-- CLIENT SCRIPTS
-----------------------------------------
client_scripts {
    'config.lua',
    'client.lua'
}

-----------------------------------------
-- SERVER SCRIPTS
-----------------------------------------
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'version.lua',    -- version check file (optional but recommended)
    'server.lua'
}

-----------------------------------------
-- ESCROW IGNORE (Editable Files)
-----------------------------------------
escrow_ignore {
    'config.lua',
    'html/*',
    'tags.sql'
}

-----------------------------------------
-- PROVIDES
-----------------------------------------
provide 'radiant_admin_tags'
