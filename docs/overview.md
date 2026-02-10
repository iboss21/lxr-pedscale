```
██╗     ██╗  ██╗██████╗       ██████╗ ███████╗██████╗ ███████╗ ██████╗ █████╗ ██╗     ███████╗
██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝██╔══██╗██║     ██╔════╝
██║      ╚███╔╝ ██████╔╝█████╗██████╔╝█████╗  ██║  ██║███████╗██║     ███████║██║     █████╗  
██║      ██╔██╗ ██╔══██╗╚════╝██╔═══╝ ██╔══╝  ██║  ██║╚════██║██║     ██╔══██║██║     ██╔══╝  
███████╗██╔╝ ██╗██║  ██║      ██║     ███████╗██████╔╝███████║╚██████╗██║  ██║███████╗███████╗
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝     ╚══════╝╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝
```

# 📘 LXR Ped Scale - Overview

**🐺 wolves.land | The Land of Wolves**

---

## Purpose

LXR Ped Scale is a production-grade character customization system for RedM servers that allows players to modify their character's identity and physical appearance through immersive NPC interactions.

This system is designed for serious roleplay servers that require:
- Secure, server-side validated customization
- Framework flexibility (multi-framework support)
- Immersive player experience with visual previews
- Economic integration with configurable costs
- Administrative control and logging

---

## Core Features

### 1. Name Customization

Players can change their character's:
- **Firstname** only
- **Lastname** only
- **Both names** simultaneously (with discount pricing)

All name changes are:
- Validated server-side for length, characters, and profanity
- Logged to Discord (optional)
- Subject to cooldowns to prevent abuse
- Charged according to configured economy settings

### 2. Scale (Height) Customization

Players can adjust their character's scale/height:
- **Live preview** with a cloned ped showing the new scale
- **Real-time adjustment** using increase/decrease buttons
- **Visual feedback** with overhead light and scale indicator
- **Configurable limits** (default: 0.85 to 1.15 = 85% to 115% of normal)
- **Fine control** with 1% adjustment steps

The scale system includes:
- Clone preview spawned in front of player
- Cinematic camera focusing on clone
- Overhead spotlight effect
- Real-time scale display
- Confirmation before applying changes

### 3. Multi-Framework Support

Built-in support for multiple frameworks with automatic detection:

**Primary Support:**
- **LXR-Core** - Full integration
- **RSG-Core** - Full integration

**Supported:**
- **VORP Core** - Compatible with VORP systems

**Standalone:**
- Works without any framework for testing

The framework bridge provides unified API calls so the core logic remains framework-agnostic.

### 4. Flexible NPC System

- **Multiple NPC locations** configurable
- **Per-location feature toggles**:
  - Enable only name changes
  - Enable only scale changes
  - Enable both
  - Default to scale if both disabled
- **Custom NPC models** and scenarios
- **Blip system** with custom sprites and names
- **Smart spawning** based on player distance

### 5. Interaction Modes

Two interaction modes to suit your server:

**Target System Mode:**
- Uses ox_target for modern interaction
- Clean UI with icon and label
- Configurable interaction distance
- Best for servers with target systems

**Prompt Mode:**
- Fallback for servers without target systems
- Shows prompt when near NPC
- Key-based interaction (G key default)
- 3D world text display

### 6. Visual Experience

**Camera System:**
- Cinematic camera transitions
- Different camera positions for name vs scale
- Smooth FOV and positioning
- Configurable transition times

**Clone Preview (Scale):**
- Full clone of player character
- Real-time scale updates
- Overhead spotlight effect
- Scale indicator text
- Semi-transparent appearance
- Faces player for easy viewing

### 7. Economy Integration

**Configurable Pricing:**
- Separate costs for firstname, lastname, both
- Separate cost for scale changes
- Choice of currency: Cash or Gold
- Admin bypass option (no cost for admins)

**Payment Validation:**
- Server-side fund checking
- Automatic deduction on success
- Refund on failure
- Insufficient funds notification

### 8. Security Features

**Server-Side Validation:**
- All changes validated on server
- Distance checking (prevent exploits)
- Rate limiting per player
- Cooldown system per action type
- Request count limiting

**Name Validation:**
- Minimum/maximum length checks
- Character type restrictions
- Forbidden name list
- Profanity filter
- No spaces/numbers/special chars (configurable)

**Scale Validation:**
- Min/max boundary enforcement
- Type checking (must be number)
- Reasonable limits to prevent abuse

**Anti-Abuse Measures:**
- Per-player cooldowns
- Global cooldown option
- Rate limiting (requests per minute)
- Change limiting (changes per minute)
- Suspicious activity logging
- Optional kick/ban on exploit detection

### 9. Logging & Discord Integration

**Discord Webhook Support:**
- Rich embed logs
- Name change logs with before/after
- Scale change logs with old/new values
- Admin bypass notifications
- Failed attempt logs
- Timestamp and player info
- Configurable colors per log type

**Console Logging:**
- Debug mode with detailed prints
- Framework detection logs
- NPC spawn/despawn logs
- Validation failure logs
- Security violation logs

### 10. Localization

**Multi-Language Support:**
- English (complete)
- Georgian (complete) - ქართული
- Spanish (complete) - Español
- French (complete) - Français
- Easy to add more languages

All UI text, notifications, and messages are localized.

### 11. Performance Optimization

**Client-Side:**
- Efficient NPC spawn/despawn based on distance
- Cached player data
- Optimized camera system
- Smart update intervals
- Minimal draw calls

**Server-Side:**
- Cooldown cleanup thread
- Efficient rate limit tracking
- Minimal database calls
- Framework bridge for reduced calls
- Memory-based cooldown storage (optional DB persistence)

**Configurable Performance:**
- Adjustable update intervals
- Configurable cleanup frequency
- Optional features can be disabled
- Debug mode toggles

---

## Use Cases

### Serious Roleplay Servers
- Allow character identity changes for roleplay reasons
- Maintain immersion with cinematic experience
- Track all changes via Discord logs
- Charge in-game currency for services

### Whitelist Servers
- Admin-approved name changes
- Secure validation prevents abuse
- Permission system for who can use
- Cooldowns prevent spam

### Economy-Focused Servers
- Create money sinks with customization costs
- Different pricing for different actions
- Premium service feel with visual effects
- Job restrictions (optional)

### Testing/Development
- Standalone mode for testing
- Debug mode for troubleshooting
- Admin commands for quick testing
- Framework-agnostic design

---

## Technical Architecture

### File Structure

```
lxr-pedscale/
├── fxmanifest.lua          # Resource manifest
├── config.lua              # Main configuration
├── client/
│   └── main.lua            # Client-side logic
├── server/
│   └── main.lua            # Server-side logic
├── shared/
│   ├── bridge.lua          # Framework adapter
│   └── locale.lua          # Translations
└── docs/
    ├── overview.md         # This file
    ├── installation.md     # Installation guide
    ├── configuration.md    # Config reference
    ├── frameworks.md       # Framework details
    ├── events.md           # Event system
    ├── security.md         # Security guide
    ├── performance.md      # Performance tips
    └── screenshots.md      # Visual examples
```

### Component Responsibilities

**config.lua**
- All server-specific settings
- NPC locations and data
- Economy settings
- Validation rules
- Security settings
- Performance tuning

**shared/bridge.lua**
- Framework auto-detection
- Unified API for all frameworks
- Player data retrieval
- Notification system
- Callback system
- Menu system

**shared/locale.lua**
- Multi-language translations
- Locale helper functions
- Easy language addition

**client/main.lua**
- NPC spawning and management
- Player interaction handling
- Camera system
- Clone preview system
- Menu system
- UI/UX logic

**server/main.lua**
- Request validation
- Security enforcement
- Economy integration
- Framework integration
- Discord logging
- Cooldown management
- Admin commands

---

## Design Philosophy

### 1. Security First
All player actions are validated server-side. Never trust the client.

### 2. Framework Agnostic
Core logic uses unified API through bridge layer. Easy to add new frameworks.

### 3. Immersive Experience
Visual effects, camera work, and smooth transitions create engaging player experience.

### 4. Server Control
Everything is configurable. Server owners have full control over features, costs, and limits.

### 5. Performance Conscious
Optimized code with configurable update intervals. Minimal impact on server resources.

### 6. Production Ready
Branded, documented, secure, and tested. Ready for live server deployment.

---

## Comparison with Alternatives

| Feature | LXR Ped Scale | Basic Scripts |
|---------|---------------|---------------|
| Multi-Framework | ✅ Auto-detect | ❌ Single framework |
| Live Preview | ✅ Clone + Camera | ❌ No preview |
| Security | ✅ Full validation | ⚠️ Basic or none |
| Discord Logs | ✅ Rich embeds | ❌ No logging |
| Localization | ✅ 4+ languages | ❌ English only |
| Documentation | ✅ Comprehensive | ⚠️ Minimal |
| Branding | ✅ Professional | ❌ Generic |
| Admin Tools | ✅ Commands + bypass | ⚠️ Limited |

---

## Future Enhancements

Potential future features (not yet implemented):
- Database persistence for scales
- More granular permissions per action
- Custom currency support beyond cash/gold
- Integration with appearance/barber systems
- Scheduled price changes (events/holidays)
- Player name history tracking
- UI customization options

---

**© 2026 iBoss21 / The Lux Empire | wolves.land**
