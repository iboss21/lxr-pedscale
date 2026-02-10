# Quick Start Guide - Testing the Fixes

This guide will help you test the UI and interaction fixes immediately.

## Prerequisites
- RedM server (any version)
- Resource folder named exactly `lxr-pedscale`
- No specific framework required (works standalone)

## Step 1: Installation

1. Download/clone the repository
2. Rename folder to `lxr-pedscale` (important!)
3. Place in your `resources` folder
4. Add to `server.cfg`:
   ```
   ensure lxr-pedscale
   ```

## Step 2: First Start

1. Start your server
2. Watch the console for these messages:
   ```
   [LXR-PedScale] Initialization starting...
   [LXR-PedScale] Framework: standalone (or your framework)
   [LXR-PedScale] Starting NPC spawn process...
   [LXR-PedScale] Successfully spawned NPC: Valentine Doctor
   [LXR-PedScale] Successfully spawned NPC: Saint Denis Tailor
   [LXR-PedScale] Successfully spawned NPC: Blackwater Clerk
   [LXR-PedScale] Spawned 3 NPCs out of 3 configured
   [LXR-PedScale] Using prompt-based interaction system
   [LXR-PedScale] Client initialized - Framework: standalone
   ```

3. If you see errors, check:
   - Folder is named `lxr-pedscale`
   - No syntax errors in config
   - Framework is running (if using one)

## Step 3: Quick Status Check

Once in-game, type:
```
/pedscale_status
```

You should see:
```
[LXR-PedScale] === Status Report ===
Framework: standalone
Player Loaded: true
Spawned NPCs: 3 / 3
In Customization: false
ox_lib State: missing
ox_target State: missing
  NPC 1 (Valentine Doctor): EXISTS
  NPC 2 (Saint Denis Tailor): EXISTS
  NPC 3 (Blackwater Clerk): EXISTS
```

✅ If NPCs show "EXISTS", spawning is working!

## Step 4: Test Menu Without Moving

Type:
```
/pedscale_test
```

This will open the menu immediately to test the UI system.

**Expected Result:**
- Menu appears on screen (native menu with arrow key controls)
- OR ox_lib context menu if ox_lib is installed
- You can navigate with arrow keys (Up/Down)
- Enter to select, Backspace to cancel

## Step 5: Find an NPC

Go to one of these locations:

### Valentine Doctor
- Coordinates: `-282.82, 807.23, 119.39`
- Location: Valentine, near the doctor's office

### Saint Denis Tailor  
- Coordinates: `2505.67, -1309.35, 48.98`
- Location: Saint Denis

### Blackwater Clerk
- Coordinates: `-813.63, -1324.01, 43.38`
- Location: Blackwater

## Step 6: Look for Visual Indicators

When you approach an NPC (within 2.5 meters), you should see:

1. **Ground Marker**
   - Gold/orange cylinder at NPC's feet
   - Pulsing/visible from distance

2. **NPC Name**
   - Text above NPC showing their name
   - Example: "Valentine Doctor"

3. **Interaction Prompt**
   - Green text: "[G] Character Customization"
   - Shows what key to press

**Example:**
```
        Valentine Doctor
    [G] Character Customization
```

## Step 7: Test Interaction

1. Press **G** when near the NPC
2. Menu should open immediately
3. You'll see options like:
   - Change Name ($90)
   - Adjust Height ($100)
   - Cancel

## Step 8: Test Menu Navigation

### If using native fallback menu:
- **Arrow Up/Down**: Navigate options
- **Enter**: Select option
- **Backspace**: Cancel/Go back

### If using ox_lib menu:
- **Mouse**: Click options
- **ESC**: Close menu

## Step 9: Test Name Change

1. Select "Change Name"
2. Choose "Change Both Names"
3. Keyboard input should appear:
   - Native RedM keyboard (on-screen)
   - Type your firstname
   - Confirm (Enter/Accept)
   - Type your lastname
   - Confirm again

4. You'll see confirmation message on screen

## Step 10: Test Scale Change

1. Select "Adjust Height"
2. Camera should zoom to your character
3. A clone preview should appear in front of you
4. Menu shows:
   - Increase Height (+1%)
   - Decrease Height (-1%)
   - Confirm Height
   - Cancel

5. Navigate and adjust
6. See changes on the clone in real-time
7. Confirm when happy

## Troubleshooting

### NPCs Not Spawning
```
/pedscale_status
```
Check if NPCs show "EXISTS" or "MISSING"

If MISSING:
- Check coordinates are valid for your map
- Verify NPC models exist
- Check console for spawn errors

### Menu Not Opening
1. Check you're within 2.5 meters of NPC
2. Verify you see the ground marker
3. Try `/pedscale_test` to test menu system
4. Check console for errors
5. Verify `Config.Debug.enabled = true` for logs

### Keyboard Not Appearing
1. The script uses native RedM keyboard
2. Should work automatically when selecting name change
3. If stuck, press ESC and try again
4. Check console for keyboard errors

### No Ground Markers Visible
1. Make sure you're close enough (<2.5m)
2. Check `Config.General.interactionDistance`
3. Try increasing to `5.0` for testing
4. Verify NPC exists with `/pedscale_status`

### Standalone Mode Issues
If running without a framework:
- Script automatically runs in standalone mode
- All features should work
- Name/scale changes save in memory only (lost on restart)
- No money requirement in standalone

## Advanced Testing

### Test with Framework
If you have a framework:
1. Check console shows correct framework
2. Money should be deducted when making changes
3. Changes should persist through restarts
4. Admin permissions should work

### Test with ox_lib
1. Install ox_lib
2. Restart lxr-pedscale
3. Menus should use ox_lib context menus
4. Input dialogs should use ox_lib inputs
5. Notifications should use ox_lib

### Test with ox_target
1. Install ox_target
2. Set `Config.General.useTarget = true`
3. Restart lxr-pedscale
4. Look at NPC with crosshair
5. Target prompt should appear
6. Use target to interact

## Expected Behavior Summary

### ✅ What Should Work:
- NPCs spawn at configured locations
- Ground markers visible near NPCs
- Text prompts visible when close
- Menu opens when pressing G
- Arrow keys navigate menu
- Native keyboard for text input
- Scale preview with clone
- Notifications on screen
- All in standalone mode (no framework needed)

### ⚠️ Known Limitations:
- In standalone, changes don't persist
- Without framework, no money system
- Some features require ox_lib/ox_target
- Native menu is basic (ox_lib recommended)

## Getting Help

If issues persist:
1. Enable debug: `Config.Debug.enabled = true`
2. Restart resource
3. Run `/pedscale_status`
4. Check console logs
5. Copy error messages
6. Report with:
   - Server setup (framework, versions)
   - Console output
   - Status command output
   - Steps to reproduce

## Success Indicators

You know everything is working when:
1. ✅ Console shows successful initialization
2. ✅ `/pedscale_status` shows 3/3 NPCs
3. ✅ You see ground markers at NPC locations
4. ✅ Text prompts appear when near NPCs
5. ✅ `/pedscale_test` opens menu successfully
6. ✅ Menu navigation works with arrow keys
7. ✅ Name change shows keyboard
8. ✅ Scale change shows clone preview
9. ✅ Changes apply to your character

## Next Steps

Once basic functionality is confirmed:
1. Customize NPC locations in `config.lua`
2. Adjust prices and limits
3. Configure your framework integration
4. Add Discord webhooks
5. Set up permissions
6. Disable debug mode
7. Enjoy!

---

**For more information, see:**
- [README.md](README.md) - Full documentation
- [FIXES.md](FIXES.md) - Detailed fix summary
- [docs/](docs/) - Complete guides

**Need help?**
- Discord: https://discord.gg/CrKcWdfd3A
- GitHub: https://github.com/iBoss21/lxr-pedscale
