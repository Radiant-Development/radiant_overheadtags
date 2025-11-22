# 🌟 RadiantDev Overhead Tags  
**Solid Color + Left→Right Gradient • SQL Persistence • Discord Sync • ACE Permissions**

Welcome to the official **Radiant Development Overhead Tag System**.  
This script provides a safe, stylish, and highly optimized overhead tag solution for FiveM servers.

---

## 🚀 Features

### 🎨 Tag Styles
- **Solid mode**
- **Left → Right gradient mode**
- Dual-color gradient support
- Smooth 3D rendering
- Line-of-sight visibility
- Distance fade-out
- F6 Toggle visibility

### 🔐 Permission System
- ACE group requirement  
- Discord role requirement  
- Server owners can adjust ONLY `config.lua`

### 🧠 Smart Logic
- ACE → Discord → Department → Default → UI priority  
- Department auto-tags  
- Cooldown per player  
- Dynamic tag updating  
- Server-wide instant refresh

### 💾 SQL Support
- Permanent tag storage  
- Style + color + gradient saved  
- Auto-table creation

### 🌐 Discord Integration
- Role-based permissions  
- Role sync logging  
- Tag change webhook logging

---

## 📂 Resource Structure


---

## ⚙️ Installation

1. Drag folder into your server resources.  
2. Add to **server.cfg**:


3. Configure `config.lua` (ONLY editable file).  
4. Import `radiant_tags.sql` into your database.  
5. Restart your server.

---

## 🛂 Permissions

### **ACE Example**

### **Discord Role Map**
Inside `config.lua`:
```lua
Config.Discord.RoleMap = {
    ["123456789012345678"] = "god",
}
/tagmenu
exports['radiant_Admin_tags']:SetPlayerTag(id, data)

---

# 📙 **2. INSTALLATION.md**

```md
# Installation Guide — RadiantDev Overhead Tags

## 1. Drag & Drop
Place the entire `radiant_Admin_tags` folder into your server's resources directory.

## 2. Start the Resource
Add to server.cfg:

## 3. Configure Your Bot
Inside `config.lua`:
```lua
Config.Discord.BotToken = "YOUR_BOT_TOKEN"
Config.Discord.GuildID = "YOUR_DISCORD_ID"
