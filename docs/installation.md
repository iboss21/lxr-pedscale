```
██╗     ██╗  ██╗██████╗       ██████╗ ███████╗██████╗ ███████╗ ██████╗ █████╗ ██╗     ███████╗
██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝██╔══██╗██║     ██╔════╝
██║      ╚███╔╝ ██████╔╝█████╗██████╔╝█████╗  ██║  ██║███████╗██║     ███████║██║     █████╗  
██║      ██╔██╗ ██╔══██╗╚════╝██╔═══╝ ██╔══╝  ██║  ██║╚════██║██║     ██╔══██║██║     ██╔══╝  
███████╗██╔╝ ██╗██║  ██║      ██║     ███████╗██████╔╝███████║╚██████╗██║  ██║███████╗███████╗
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝     ╚══════╝╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝
```

# 📦 Installation Guide

**🐺 wolves.land | The Land of Wolves**

Complete installation instructions for LXR Ped Scale.

---

## Prerequisites

Before installing, ensure you have:

### Required
- ✅ RedM server (up to date)
- ✅ One of these frameworks (or none for standalone):
  - lxr-core
  - rsg-core
  - vorp_core

### Recommended
- ✅ **ox_lib** - For notifications and menu system
- ✅ **ox_target** - For target-based interaction (optional)

### Optional
- Discord webhook URL (for logging)

---

## Step-by-Step Installation

### 1. Download the Resource

**Option A: GitHub Release**
1. Go to [Releases](https://github.com/iboss21/lxr-pedscale/releases)
2. Download the latest version
3. Extract the ZIP file

**Option B: Git Clone**
```bash
cd resources
git clone https://github.com/iboss21/lxr-pedscale.git
```

### 2. Verify Folder Name

⚠️ **CRITICAL**: The folder MUST be named exactly `lxr-pedscale`

```
resources/
└── lxr-pedscale/      ✅ Correct
    └── fxmanifest.lua
```

NOT:
```
resources/
└── lxr-pedscale-main/   ❌ Wrong
└── lxr-pedscale-1.0.0/  ❌ Wrong
└── pedscale/            ❌ Wrong
```

The resource has runtime name protection and will NOT start if the folder name is incorrect.

### 3. Configure the Resource

Open `config.lua` and configure basic settings:

```lua
-- Framework (auto-detect recommended)
Config.Framework = 'auto'

-- Language
Config.Lang = 'en'  -- or 'ge', 'es', 'fr'

-- Interaction Mode
Config.General.useTarget = true  -- false if you don't have ox_target

-- Economy
Config.Economy.nameChange.currency = 'cash'  -- or 'gold'
Config.Economy.nameChange.firstname = 50
Config.Economy.nameChange.lastname = 50
Config.Economy.nameChange.both = 90
Config.Economy.scaleChange.cost = 100

-- Scale Limits
Config.Scale.min = 0.85
Config.Scale.max = 1.15
```

See [Configuration Guide](configuration.md) for all options.

### 4. Add to server.cfg

Add the resource to your `server.cfg`:

```cfg
# LXR Ped Scale - Character Customization
ensure lxr-pedscale
```

**Load order matters!** Ensure it loads AFTER your framework:

```cfg
# Framework
ensure lxr-core  # or rsg-core, vorp_core

# Other resources
ensure ox_lib
ensure ox_target

# LXR Resources
ensure lxr-pedscale
```

### 5. Start Your Server

Start or restart your server:

```bash
# Linux
./run.sh +exec server.cfg

# Windows
run.cmd +exec server.cfg
```

Or use the restart command if server is running:
```
restart lxr-pedscale
```

### 6. Verify Installation

Check your server console for the startup banner:

```
═══════════════════════════════════════════════════════════════
🐺 CHARACTER CUSTOMIZATION SYSTEM - SUCCESSFULLY LOADED
═══════════════════════════════════════════════════════════════
Version:     1.0.0
Server:      The Land of Wolves 🐺
Framework:   Auto-detect enabled
NPCs:        3 customization locations
...
═══════════════════════════════════════════════════════════════
```

If you see this, installation was successful! ✅

---

## Post-Installation Configuration

### Configure NPC Locations

Edit `Config.NPCs` in `config.lua` to add your custom locations:

```lua
Config.NPCs = {
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
    },
    -- Add more locations as needed
}
```

**Finding Coordinates:**
1. Stand where you want the NPC
2. Type `/getcoords` (if you have a coord command)
3. Or use a coordinate script
4. Copy the vector4 with X, Y, Z, Heading

### Configure Discord Logging (Optional)

To enable Discord logs:

1. Create a webhook in your Discord server
2. Copy the webhook URL
3. Update `config.lua`:

```lua
Config.Discord.enabled = true
Config.Discord.webhook = 'YOUR_WEBHOOK_URL_HERE'
Config.Discord.logNameChange = true
Config.Discord.logScaleChange = true
```

### Configure Permissions

Set up admin permissions:

```lua
Config.Permissions = {
    adminBypass = true,  -- Admins don't pay
    adminGroups = {'admin', 'moderator', 'owner'}
}
```

Group names must match your framework's permission groups.

### Test the System

1. Join your server
2. Look for NPCs with blips on your map
3. Approach an NPC
4. Press G (or use target) to interact
5. Try changing your name or scale
6. Verify charges are applied correctly

---

## Troubleshooting Installation

### Resource Won't Start

**Error: "Resource name mismatch"**
```
❌ CRITICAL ERROR: RESOURCE NAME MISMATCH ❌
Expected: lxr-pedscale
Got: lxr-pedscale-main
```

**Solution:** Rename the folder to exactly `lxr-pedscale`

---

**Error: "Framework not found"**

**Solution:** 
- Ensure your framework resource is started
- Check framework resource name matches Config.FrameworkSettings
- Try manual framework: `Config.Framework = 'lxr-core'`

---

**Error: "ox_lib not found"**

**Solution:**
- Install ox_lib: https://github.com/overextended/ox_lib
- Or disable ox_lib features in config

---

### NPCs Not Spawning

**Check:**
1. Are coordinates valid? (not 0,0,0)
2. Is model hash correct?
3. Enable debug: `Config.Debug.printNPCSpawns = true`
4. Check console for errors

**Test:** Spawn NPC manually:
```lua
/spawnnpc U_M_M_BHT_DOCWORMWOOD
```

---

### Menus Not Opening

**Check:**
1. Is ox_lib installed and started?
2. Is player fully loaded? (Wait a few seconds after spawn)
3. Are you close enough? (Check Config.General.interactionDistance)
4. Enable debug: `Config.Debug.enabled = true`

**Try:** Disable target mode:
```lua
Config.General.useTarget = false
```

---

### Camera Issues

**If camera doesn't work:**
```lua
Config.Camera.enabled = false
```

**If camera is stuck:**
- Press X to cancel
- Type `/restorecam` (if you have a camera reset command)
- Relog if necessary

---

### Economy Not Working

**Check:**
1. Currency setting matches your framework: `'cash'` or `'gold'`
2. Player has sufficient funds
3. Admin bypass is not interfering
4. Framework money system is working

**Test:** Give yourself money:
```
/givemoney [id] cash 1000
```

---

## Updating the Resource

### From Older Version

1. **Backup** your `config.lua`
2. **Delete** old resource folder
3. **Install** new version
4. **Restore** your custom configuration
5. **Restart** resource

### Keep Custom Changes

Always save your custom:
- NPC locations
- Prices
- Validation rules
- Discord webhooks
- Language customizations

---

## Uninstallation

To remove the resource:

1. **Stop** the resource:
```
stop lxr-pedscale
```

2. **Remove** from server.cfg:
```cfg
# ensure lxr-pedscale  # Commented out
```

3. **Delete** the resource folder:
```bash
rm -rf resources/lxr-pedscale
```

4. **Restart** server

---

## Next Steps

After installation:

1. Read [Configuration Guide](configuration.md) for advanced settings
2. Check [Framework Support](frameworks.md) for framework-specific setup
3. Review [Security Guide](security.md) for best practices
4. See [Performance Guide](performance.md) for optimization

---

**© 2026 iBoss21 / The Lux Empire | wolves.land**
