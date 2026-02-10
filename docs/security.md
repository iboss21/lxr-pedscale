# 🔒 Security Guide
**🐺 wolves.land** - Security features and best practices

## Built-in Security
- Server-side validation for all actions
- Rate limiting (requests & changes per minute)
- Cooldown system per player
- Distance validation
- Name validation (length, characters, profanity)
- Scale boundary enforcement
- Suspicious activity logging

## Best Practices
1. Enable Config.Security.enabled = true
2. Set appropriate cooldowns
3. Configure Discord logging
4. Review forbidden names list
5. Test admin bypass permissions
6. Monitor logs for abuse

## Anti-Exploit Measures
- Never trust client input
- All economy validated server-side
- Rate limiting prevents spam
- Distance checks prevent teleport exploits
