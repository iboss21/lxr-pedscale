```
██╗     ██╗  ██╗██████╗       ██████╗ ███████╗██████╗ ███████╗ ██████╗ █████╗ ██╗     ███████╗
██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝██╔══██╗██║     ██╔════╝
██║      ╚███╔╝ ██████╔╝█████╗██████╔╝█████╗  ██║  ██║███████╗██║     ███████║██║     █████╗  
██║      ██╔██╗ ██╔══██╗╚════╝██╔═══╝ ██╔══╝  ██║  ██║╚════██║██║     ██╔══██║██║     ██╔══╝  
███████╗██╔╝ ██╗██║  ██║      ██║     ███████╗██████╔╝███████║╚██████╗██║  ██║███████╗███████╗
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝     ╚══════╝╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝
```

<div align="center">

# 🐺 LXR Ped Scale
### Character Customization System for RedM

[![RedM](https://img.shields.io/badge/RedM-Compatible-red?style=for-the-badge&logo=rockstargames)](https://redm.net/)
[![License](https://img.shields.io/badge/License-Custom-blue?style=for-the-badge)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-green?style=for-the-badge)](https://github.com/iboss21/lxr-pedscale)

**Production-grade character customization system for RedM servers**  
*Change firstname, lastname, and character scale with immersive NPC interactions*

[Features](#-features) • [Installation](#-installation) • [Configuration](#-configuration) • [Documentation](#-documentation) • [Support](#-support)

</div>

---

## 🌟 Overview

**lxr-pedscale** is a lightweight and immersive character customization system for RedM servers.

Players can change their **firstname, lastname, and height (scale)** through NPC interactions with configurable prices, visual effects, and full framework compatibility.

Designed for roleplay servers that want clean UI, secure logic, and easy configuration.

---

## ✨ Features

### 🎭 Character Customization
- **Change Firstname & Lastname** via in-game menu
- **Change Character Height (Scale)** with live preview
- Per-location menu control:
  - Enable name change only
  - Enable scale change only
  - Enable both
- If both options are disabled, the scale menu opens by default

### 💰 Economy Integration
- Pay using **Cash or Gold** (fully configurable)
- Configurable prices per action
- Admin bypass option (no cost for admins)
- Currency validation and insufficient funds checking

### 🎥 Visual Effects
- **Cinematic camera** during customization
- **Clone ped preview** with dynamic scale changes
- **Overhead light** and indicator for clone
- Smooth camera transitions

### 🎯 Interaction Systems
- **Target system** support (ox_target)
- **Prompt-only** interaction mode
- NPC-based interaction with scenarios
- Configurable interaction distance

### 🔧 Framework Support
- **LXR-Core** (Primary)
- **RSG-Core** (Primary)
- **VORP Core** (Supported)
- **Standalone** (Compatible)
- Auto-detection with manual override

### 🔒 Security & Validation
- Server-side validation for all actions
- Rate limiting and anti-abuse systems
- Name validation (length, characters, profanity)
- Scale validation (min/max limits)
- Cooldown system per player
- Distance validation
- Suspicious activity logging

### 🌐 Multi-Language Support
- English (en)
- Georgian (ge) - ქართული
- Spanish (es)
- French (fr)
- Easy to add more languages

### 📊 Discord Integration
- Webhook logging for all changes
- Name change logs
- Scale change logs
- Admin bypass logs
- Failed attempt logs
- Rich embeds with player info

### 🎨 Customization Options
- Multiple NPC locations
- Per-location feature toggles
- Configurable blips
- Custom NPC models and scenarios
- Adjustable scale limits (min/max)
- Configurable cooldowns
- Permission system

---

## 📋 Requirements

- RedM server
- One of the supported frameworks (or run standalone):
  - lxr-core
  - rsg-core
  - vorp_core
- **ox_lib** (recommended for notifications and menus)
- **ox_target** (optional, for target-based interaction)

---

## 📦 Installation

1. **Download** the resource
2. **Extract** to your `resources` folder
3. **Rename** the folder to exactly `lxr-pedscale` (important!)
4. **Configure** `config.lua` to your server's needs
5. **Add** to `server.cfg`:
```cfg
ensure lxr-pedscale
```
6. **Restart** your server

> ⚠️ **Important**: The resource folder MUST be named `lxr-pedscale` due to runtime name protection.

---

## ⚙️ Configuration

The resource is highly configurable through `config.lua`:

### Quick Start Configuration

```lua
-- Framework (auto-detect or manual)
Config.Framework = 'auto'

-- Language
Config.Lang = 'en'

-- Interaction Mode
Config.General.useTarget = true  -- true for ox_target, false for prompts

-- Economy
Config.Economy.nameChange.enabled = true
Config.Economy.nameChange.currency = 'cash'  -- 'cash' or 'gold'
Config.Economy.scaleChange.cost = 100

-- Scale Limits
Config.Scale.min = 0.85  -- 85% of normal height
Config.Scale.max = 1.15  -- 115% of normal height

-- Discord Logging
Config.Discord.enabled = false
Config.Discord.webhook = 'YOUR_WEBHOOK_URL_HERE'
```

### NPC Locations

Add or modify NPC locations in `Config.NPCs`:

```lua
{
    name = 'Valentine Doctor',
    model = `U_M_M_BHT_DOCWORMWOOD`,
    coords = vector4(-282.82, 807.23, 119.39, 180.0),
    scenario = 'WORLD_HUMAN_SMOKE_CIGAR',
    enableNameChange = true,
    enableScaleChange = true,
    blip = {
        enabled = true,
        sprite = `blip_proc_doctor`,
        name = 'Character Customization'
    }
}
```

For detailed configuration, see [📖 Configuration Guide](docs/configuration.md)

---

## 📖 Documentation

Comprehensive documentation is available in the `/docs` folder:

- [📘 Overview](docs/overview.md) - Detailed feature overview
- [📦 Installation Guide](docs/installation.md) - Step-by-step installation
- [⚙️ Configuration Guide](docs/configuration.md) - All configuration options
- [🔧 Framework Support](docs/frameworks.md) - Framework integration details
- [🔌 Events & API](docs/events.md) - Event system and API reference
- [🔒 Security](docs/security.md) - Security features and best practices
- [⚡ Performance](docs/performance.md) - Optimization and performance tips
- [📸 Screenshots](docs/screenshots.md) - Visual examples

---

## 🎮 Usage

### For Players

1. **Approach** an NPC marked on your map
2. **Interact** using G key (or target system)
3. **Choose** customization option:
   - Change Name (firstname/lastname/both)
   - Adjust Height (scale with live preview)
4. **Pay** the required amount
5. **Confirm** your changes

### For Admins

**Commands:**
```
/pedscale_resetcooldown [playerid]  - Reset player cooldowns
/pedscale_setscale [playerid] [scale] - Force set player scale
```

**Permissions:**
- Admins can bypass payment costs (configurable)
- Configurable admin groups in config

---

## 🔐 Permissions

Configure admin permissions in `config.lua`:

```lua
Config.Permissions = {
    adminBypass = true,  -- Admins don't pay
    adminGroups = {'admin', 'moderator', 'owner'}
}
```

---

## 🌐 Multi-Language

To add a new language:

1. Open `shared/locale.lua`
2. Add your language code:
```lua
Locale.yourlang = {
    interact_npc = 'Your translation',
    -- ... add all keys
}
```
3. Set in config: `Config.Lang = 'yourlang'`

---

## 🐛 Troubleshooting

### Resource won't start
- Ensure folder is named exactly `lxr-pedscale`
- Check server console for errors
- Verify framework is running

### NPCs not spawning
- Check coordinates in config
- Verify NPC models are valid
- Enable debug mode: `Config.Debug.enabled = true`

### Menus not opening
- Ensure ox_lib is installed and running
- Check if player is fully loaded
- Verify interaction distance

For more help, see [📖 Documentation](docs/) or [🎮 Discord](https://discord.gg/CrKcWdfd3A)

---

## 🚀 Performance

- **Optimized** for minimal server overhead
- **Efficient** client-side NPC management
- **Smart** cooldown cleanup system
- **Cached** player data to reduce framework calls
- **Configurable** update intervals

Target: <0.01ms server, <0.05ms client

---

## 🤝 Support

### The Land of Wolves 🐺

**Server Information:**
- **Name:** The Land of Wolves
- **Tagline:** Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!
- **Type:** Serious Hardcore Roleplay
- **Access:** Discord & Whitelisted

**Links:**
- 🌐 Website: [wolves.land](https://www.wolves.land)
- 💬 Discord: [Join Our Community](https://discord.gg/CrKcWdfd3A)
- 🛒 Store: [The Lux Empire](https://theluxempire.tebex.io)
- 🎮 Server: [RedM Listing](https://servers.redm.net/servers/detail/8gj7eb)
- 💻 GitHub: [iBoss21](https://github.com/iBoss21)

---

## 📝 License

© 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved

This resource is branded for The Land of Wolves. See [LICENSE](LICENSE) for details.

---

## 👨‍💻 Credits

**Script Author:** iBoss21 / The Lux Empire  
**Developed For:** The Land of Wolves (wolves.land)  
**Inspired By:** RedM character customization systems

---

## 🏷️ Tags

`redm` `character-customization` `roleplay` `framework` `lxr-core` `rsg-core` `vorp` `pedscale` `name-change` `height-adjustment` `wolves-land` `georgian-rp`

---

<div align="center">

**Made with ❤️ by iBoss21 for The Land of Wolves 🐺**

*ისტორია ცოცხლდება აქ! (History Lives Here!)*

</div>