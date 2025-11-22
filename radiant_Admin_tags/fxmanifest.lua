fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'radiant_Admin_tags'
author 'Radiant Development'
description 'Radiant Overhead Tags System (Solid + LR Gradient)'
version '1.0.0'

--------------------------------------------------------------------
-- ESCROW IGNORE — ONLY CONFIG IS EDITABLE
--------------------------------------------------------------------
escrow_ignore {
    'config.lua',
}

--------------------------------------------------------------------
-- FILES
--------------------------------------------------------------------
files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

ui_page 'html/index.html'

--------------------------------------------------------------------
-- SERVER SCRIPTS
--------------------------------------------------------------------
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',      -- must load BEFORE server.lua
    'version.lua',
    'server.lua'
}

--------------------------------------------------------------------
-- CLIENT SCRIPTS
--------------------------------------------------------------------
client_scripts {
    'config.lua',
    'client.lua'
}
