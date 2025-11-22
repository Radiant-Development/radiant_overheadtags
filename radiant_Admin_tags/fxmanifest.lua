fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'radiant_overheadtags'
author 'Radiant Development'
description 'Standalone Overhead Tag System with Discord Roles + ACE + RadiantDev Version Panel'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    'config.lua',
    'version.lua',
    'server.lua'
}

escrow_ignore {
    "config.lua",
    "version.lua",
    "*.json",
    "html/**",
    "docs/**"
}
