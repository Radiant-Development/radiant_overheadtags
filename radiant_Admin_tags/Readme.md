# 🌟 Radiant Development — Overhead Tag System  
Standalone • Discord Role Sync • ACE Enforcement • NUI • Version Checker

Welcome to the **RadiantDev Overhead Tag System**, a fully standalone overhead-tag resource powered by:

- Discord role authentication  
- ACE permission groups  
- RadiantDev’s animated, glowing version panel  
- Modern UI for tag editing  
- Escrow-safe configuration  
- Automatic GitHub version checks  
- Build 2699+ enforcement  

This resource follows the full **RadiantDev Master Prompt standard**.

---

# 📌 1. Requirements

Before installing this script, make sure you have:

- **FiveM server build ≥ 2699**  
- **A Discord Bot** created in the Developer Portal  
- Your server's **Discord Guild ID**  
- **Role IDs** for permission mapping  
- The correct **ACE identifiers** for your staff team  

If any of these are missing, the resource will refuse to load.

---

# 🚀 2. Installing the Resource

1. Download or clone the script into your resources folder.  
2. Ensure it in your `server.cfg`:

3. Configure everything inside **config.lua** (directions below).  
4. Restart the server.

---

# 🤖 3. Creating a Discord Bot

A Discord bot **is required** for the script to read player roles.

### ✔ Step 1 — Create the Application

1. Go to: https://discord.com/developers/applications  
2. Click **New Application**  
3. Name it:  
   `RadiantDev Overhead Tags Bot`  
4. Save.

### ✔ Step 2 — Add a Bot User

1. Go to the **Bot** tab  
2. Click **Add Bot**  
3. Enable:  
   - “MESSAGE CONTENT INTENT”  
   - “SERVER MEMBERS INTENT”

### ✔ Step 3 — Get Your Bot Token

Under **Bot → Token**:

Click **Reset Token** → Copy it → Paste it into `config.lua`:

```lua
Config.Discord.BotToken = "YOUR_BOT_TOKEN_HERE"

