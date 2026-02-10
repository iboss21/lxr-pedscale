# 🔌 Events & API
**🐺 wolves.land** - Event system reference

## Client Events
- `lxr-pedscale:client:nameChangeResponse` - Name change result
- `lxr-pedscale:client:scaleChangeResponse` - Scale change result
- `lxr-pedscale:client:applyScale` - Apply scale on load

## Server Events
- `lxr-pedscale:server:changeName` - Request name change
- `lxr-pedscale:server:changeScale` - Request scale change
- `lxr-pedscale:server:requestScale` - Get saved scale

## Unified API (Bridge)
- `Framework.GetIdentifier(source)` - Get player identifier
- `Framework.GetPlayerData(source)` - Get player data
- `Framework.GetMoney(source, account)` - Check funds
- `Framework.RemoveMoney(source, account, amount)` - Charge player
- `Framework.UpdateCharacterName(source, first, last)` - Update name
