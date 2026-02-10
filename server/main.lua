--[[
    ██╗     ██╗  ██╗██████╗       ██████╗ ███████╗██████╗ ███████╗ ██████╗ █████╗ ██╗     ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝██╔══██╗██║     ██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝█████╗  ██║  ██║███████╗██║     ███████║██║     █████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔═══╝ ██╔══╝  ██║  ██║╚════██║██║     ██╔══██║██║     ██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ██║     ███████╗██████╔╝███████║╚██████╗██║  ██║███████╗███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝     ╚══════╝╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝
                                                                                                   
    🐺 LXR Ped Scale - Server Script
    
    Handles server-side validation, security, framework integration, and Discord logging.
    
    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 SERVER STATE MANAGEMENT
-- ═══════════════════════════════════════════════════════════════════════════════

local playerCooldowns = {}
local playerRequestCounts = {}
local playerScales = {} -- Store player scales in memory

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Get localized text
local function L(key, ...)
    local text = Locale:Get(key)
    if ... then
        return string.format(text, ...)
    end
    return text
end

-- Format cooldown time
local function FormatCooldownTime(ms)
    local seconds = math.floor(ms / 1000)
    local minutes = math.floor(seconds / 60)
    
    if minutes > 0 then
        return L('cooldown_minutes', minutes)
    else
        return L('cooldown_seconds', seconds)
    end
end

-- Check cooldown
local function CheckCooldown(source, cooldownType)
    local identifier = Framework.GetIdentifier(source)
    if not identifier then return false end
    
    if not playerCooldowns[identifier] then
        playerCooldowns[identifier] = {}
    end
    
    local cooldown = playerCooldowns[identifier][cooldownType]
    if cooldown and cooldown > GetGameTimer() then
        local remaining = cooldown - GetGameTimer()
        return false, remaining
    end
    
    return true, 0
end

-- Set cooldown
local function SetCooldown(source, cooldownType, duration)
    local identifier = Framework.GetIdentifier(source)
    if not identifier then return end
    
    if not playerCooldowns[identifier] then
        playerCooldowns[identifier] = {}
    end
    
    playerCooldowns[identifier][cooldownType] = GetGameTimer() + duration
end

-- Check rate limit
local function CheckRateLimit(source, action)
    if not Config.Security.enabled then return true end
    
    local identifier = Framework.GetIdentifier(source)
    if not identifier then return false end
    
    if not playerRequestCounts[identifier] then
        playerRequestCounts[identifier] = {}
    end
    
    if not playerRequestCounts[identifier][action] then
        playerRequestCounts[identifier][action] = {count = 0, resetTime = GetGameTimer() + 60000}
    end
    
    local data = playerRequestCounts[identifier][action]
    
    -- Reset counter if time expired
    if GetGameTimer() > data.resetTime then
        data.count = 0
        data.resetTime = GetGameTimer() + 60000
    end
    
    data.count = data.count + 1
    
    local limit = action == 'change' and Config.Security.maxChangesPerMinute or Config.Security.maxRequestsPerMinute
    
    if data.count > limit then
        if Config.Debug.enabled then
            print(string.format('[LXR-PedScale] Rate limit exceeded for %s - Action: %s', identifier, action))
        end
        return false
    end
    
    return true
end

-- Validate name
local function ValidateName(name)
    if not name or type(name) ~= 'string' then
        return false, L('error_invalid_name')
    end
    
    -- Length check
    if #name < Config.Validation.minNameLength or #name > Config.Validation.maxNameLength then
        return false, L('error_invalid_name')
    end
    
    -- Character validation
    if not Config.Validation.allowSpaces and string.find(name, ' ') then
        return false, L('error_invalid_name')
    end
    
    if not Config.Validation.allowNumbers and string.find(name, '%d') then
        return false, L('error_invalid_name')
    end
    
    if not Config.Validation.allowSpecialChars and string.find(name, '[^%w%s]') then
        return false, L('error_invalid_name')
    end
    
    -- Check forbidden names
    local lowerName = string.lower(name)
    for _, forbidden in ipairs(Config.Validation.forbiddenNames) do
        if lowerName == string.lower(forbidden) then
            return false, L('error_forbidden_name')
        end
    end
    
    -- Profanity filter
    if Config.Validation.profanityFilter then
        for _, profanity in ipairs(Config.Validation.profanityList) do
            if string.find(lowerName, string.lower(profanity)) then
                return false, L('error_profanity_detected')
            end
        end
    end
    
    return true, nil
end

-- Validate scale
local function ValidateScale(scale)
    if not scale or type(scale) ~= 'number' then
        return false, L('error_generic')
    end
    
    if scale < Config.Scale.min or scale > Config.Scale.max then
        return false, string.format('Scale must be between %.2f and %.2f', Config.Scale.min, Config.Scale.max)
    end
    
    return true, nil
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 DISCORD WEBHOOK LOGGING
-- ═══════════════════════════════════════════════════════════════════════════════

local function SendDiscordLog(title, description, color, fields)
    if not Config.Discord.enabled or not Config.Discord.webhook or Config.Discord.webhook == '' then
        return
    end
    
    local embed = {
        {
            ['title'] = title,
            ['description'] = description,
            ['type'] = 'rich',
            ['color'] = color or Config.Discord.colors.nameChange,
            ['fields'] = fields or {},
            ['footer'] = {
                ['text'] = 'LXR Ped Scale | wolves.land',
                ['icon_url'] = Config.Discord.avatar or ''
            },
            ['timestamp'] = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }
    }
    
    PerformHttpRequest(Config.Discord.webhook, function(err, text, headers) end, 'POST', json.encode({
        username = Config.Discord.username,
        avatar_url = Config.Discord.avatar,
        embeds = embed
    }), {['Content-Type'] = 'application/json'})
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 CHARACTER NAME CHANGE
-- ═══════════════════════════════════════════════════════════════════════════════

RegisterNetEvent('lxr-pedscale:server:changeName', function(firstname, lastname, changeType)
    local source = source
    local identifier = Framework.GetIdentifier(source)
    
    if not identifier then
        TriggerClientEvent('lxr-pedscale:client:nameChangeResponse', source, false, L('error_generic'))
        return
    end
    
    -- Rate limit check
    if not CheckRateLimit(source, 'change') then
        TriggerClientEvent('lxr-pedscale:client:nameChangeResponse', source, false, 'Rate limit exceeded')
        return
    end
    
    -- Check cooldown
    local canChange, remaining = CheckCooldown(source, 'nameChange')
    if not canChange then
        TriggerClientEvent('lxr-pedscale:client:nameChangeResponse', source, false, L('error_cooldown_active', FormatCooldownTime(remaining)))
        return
    end
    
    -- Get player data
    local playerData = Framework.GetPlayerData(source)
    if not playerData then
        TriggerClientEvent('lxr-pedscale:client:nameChangeResponse', source, false, L('error_generic'))
        return
    end
    
    -- Determine what to change
    local oldFirstname = playerData.firstname
    local oldLastname = playerData.lastname
    local newFirstname = firstname or oldFirstname
    local newLastname = lastname or oldLastname
    
    -- Validate names
    if changeType == 'firstname' or changeType == 'both' then
        local valid, err = ValidateName(firstname)
        if not valid then
            TriggerClientEvent('lxr-pedscale:client:nameChangeResponse', source, false, err)
            return
        end
    end
    
    if changeType == 'lastname' or changeType == 'both' then
        local valid, err = ValidateName(lastname)
        if not valid then
            TriggerClientEvent('lxr-pedscale:client:nameChangeResponse', source, false, err)
            return
        end
    end
    
    -- Determine cost
    local cost = 0
    if changeType == 'both' then
        cost = Config.Economy.nameChange.both
    elseif changeType == 'firstname' then
        cost = Config.Economy.nameChange.firstname
    elseif changeType == 'lastname' then
        cost = Config.Economy.nameChange.lastname
    end
    
    -- Check admin bypass
    local isAdmin = Framework.HasPermission(source, 'admin')
    if isAdmin and Config.Permissions.adminBypass then
        cost = 0
    end
    
    -- Check funds
    if cost > 0 then
        local currency = Config.Economy.nameChange.currency
        local playerMoney = Framework.GetMoney(source, currency)
        
        if playerMoney < cost then
            TriggerClientEvent('lxr-pedscale:client:nameChangeResponse', source, false, L('error_insufficient_funds', cost))
            return
        end
        
        -- Remove money
        Framework.RemoveMoney(source, currency, cost)
    end
    
    -- Update character name
    local success = Framework.UpdateCharacterName(source, newFirstname, newLastname)
    
    if success then
        -- Set cooldown
        SetCooldown(source, 'nameChange', Config.Cooldowns.nameChange)
        
        -- Success message
        local message = ''
        if changeType == 'both' then
            message = L('success_name_changed', newFirstname, newLastname)
        elseif changeType == 'firstname' then
            message = L('success_firstname_changed', newFirstname)
        elseif changeType == 'lastname' then
            message = L('success_lastname_changed', newLastname)
        end
        
        TriggerClientEvent('lxr-pedscale:client:nameChangeResponse', source, true, message)
        
        -- Discord logging
        if Config.Discord.enabled and Config.Discord.logNameChange then
            SendDiscordLog(
                '📝 Name Changed',
                string.format('Player changed their character name'),
                Config.Discord.colors.nameChange,
                {
                    {name = 'Player', value = GetPlayerName(source), inline = true},
                    {name = 'Identifier', value = identifier, inline = true},
                    {name = 'Old Name', value = oldFirstname .. ' ' .. oldLastname, inline = false},
                    {name = 'New Name', value = newFirstname .. ' ' .. newLastname, inline = false},
                    {name = 'Cost', value = isAdmin and 'Admin Bypass' or '$' .. cost, inline = true},
                    {name = 'Type', value = changeType, inline = true}
                }
            )
        end
        
        if Config.Debug.enabled then
            print(string.format('[LXR-PedScale] %s changed name from %s %s to %s %s', 
                GetPlayerName(source), oldFirstname, oldLastname, newFirstname, newLastname))
        end
    else
        TriggerClientEvent('lxr-pedscale:client:nameChangeResponse', source, false, L('error_generic'))
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 CHARACTER SCALE CHANGE
-- ═══════════════════════════════════════════════════════════════════════════════

RegisterNetEvent('lxr-pedscale:server:changeScale', function(newScale)
    local source = source
    local identifier = Framework.GetIdentifier(source)
    
    if not identifier then
        TriggerClientEvent('lxr-pedscale:client:scaleChangeResponse', source, false, L('error_generic'), 1.0)
        return
    end
    
    -- Rate limit check
    if not CheckRateLimit(source, 'change') then
        TriggerClientEvent('lxr-pedscale:client:scaleChangeResponse', source, false, 'Rate limit exceeded', 1.0)
        return
    end
    
    -- Validate scale
    local valid, err = ValidateScale(newScale)
    if not valid then
        TriggerClientEvent('lxr-pedscale:client:scaleChangeResponse', source, false, err, 1.0)
        return
    end
    
    -- Check cooldown
    local canChange, remaining = CheckCooldown(source, 'scaleChange')
    if not canChange then
        TriggerClientEvent('lxr-pedscale:client:scaleChangeResponse', source, false, L('error_cooldown_active', FormatCooldownTime(remaining)), 1.0)
        return
    end
    
    -- Get old scale
    local oldScale = playerScales[identifier] or 1.0
    
    -- Check if scale actually changed
    if math.abs(oldScale - newScale) < 0.001 then
        TriggerClientEvent('lxr-pedscale:client:scaleChangeResponse', source, false, 'Scale unchanged', oldScale)
        return
    end
    
    -- Determine cost
    local cost = Config.Economy.scaleChange.cost
    
    -- Check admin bypass
    local isAdmin = Framework.HasPermission(source, 'admin')
    if isAdmin and Config.Permissions.adminBypass then
        cost = 0
    end
    
    -- Check funds
    if cost > 0 then
        local currency = Config.Economy.scaleChange.currency
        local playerMoney = Framework.GetMoney(source, currency)
        
        if playerMoney < cost then
            TriggerClientEvent('lxr-pedscale:client:scaleChangeResponse', source, false, L('error_insufficient_funds', cost), oldScale)
            return
        end
        
        -- Remove money
        Framework.RemoveMoney(source, currency, cost)
    end
    
    -- Store new scale
    playerScales[identifier] = newScale
    
    -- Set cooldown
    SetCooldown(source, 'scaleChange', Config.Cooldowns.scaleChange)
    
    -- Success
    TriggerClientEvent('lxr-pedscale:client:scaleChangeResponse', source, true, L('success_scale_changed', newScale), newScale)
    
    -- Discord logging
    if Config.Discord.enabled and Config.Discord.logScaleChange then
        SendDiscordLog(
            '📏 Scale Changed',
            string.format('Player adjusted their character height'),
            Config.Discord.colors.scaleChange,
            {
                {name = 'Player', value = GetPlayerName(source), inline = true},
                {name = 'Identifier', value = identifier, inline = true},
                {name = 'Old Scale', value = string.format('%.2f', oldScale), inline = true},
                {name = 'New Scale', value = string.format('%.2f', newScale), inline = true},
                {name = 'Cost', value = isAdmin and 'Admin Bypass' or '$' .. cost, inline = true}
            }
        )
    end
    
    if Config.Debug.enabled then
        print(string.format('[LXR-PedScale] %s changed scale from %.2f to %.2f', 
            GetPlayerName(source), oldScale, newScale))
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 SCALE REQUEST/PERSISTENCE
-- ═══════════════════════════════════════════════════════════════════════════════

RegisterNetEvent('lxr-pedscale:server:requestScale', function()
    local source = source
    local identifier = Framework.GetIdentifier(source)
    
    if identifier and playerScales[identifier] then
        TriggerClientEvent('lxr-pedscale:client:applyScale', source, playerScales[identifier])
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 VORP SPECIFIC EVENTS
-- ═══════════════════════════════════════════════════════════════════════════════

if Framework.Active == 'vorp_core' then
    RegisterNetEvent('lxr-pedscale:server:getPlayerData', function()
        local source = source
        local playerData = Framework.GetPlayerData(source)
        TriggerClientEvent('lxr-pedscale:client:setPlayerData', source, playerData)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 CLEANUP & MAINTENANCE
-- ═══════════════════════════════════════════════════════════════════════════════

-- Periodic cleanup of expired cooldowns
CreateThread(function()
    while true do
        Wait(Config.Performance.cleanupInterval)
        
        local currentTime = GetGameTimer()
        local cleaned = 0
        
        for identifier, cooldowns in pairs(playerCooldowns) do
            for cooldownType, expireTime in pairs(cooldowns) do
                if currentTime > expireTime then
                    playerCooldowns[identifier][cooldownType] = nil
                    cleaned = cleaned + 1
                end
            end
        end
        
        if Config.Debug.enabled and cleaned > 0 then
            print(string.format('[LXR-PedScale] Cleaned %d expired cooldowns', cleaned))
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 ADMIN COMMANDS (Optional)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Reset player cooldowns (admin only)
RegisterCommand('pedscale_resetcooldown', function(source, args, rawCommand)
    if source == 0 or Framework.HasPermission(source, 'admin') then
        local targetId = tonumber(args[1])
        if targetId then
            local identifier = Framework.GetIdentifier(targetId)
            if identifier then
                playerCooldowns[identifier] = {}
                print(string.format('[LXR-PedScale] Reset cooldowns for player %d', targetId))
                if source ~= 0 then
                    TriggerClientEvent('chat:addMessage', source, {
                        args = {'[LXR-PedScale]', 'Cooldowns reset for player ' .. targetId}
                    })
                end
            end
        end
    end
end, false)

-- Set player scale (admin only)
RegisterCommand('pedscale_setscale', function(source, args, rawCommand)
    if source == 0 or Framework.HasPermission(source, 'admin') then
        local targetId = tonumber(args[1])
        local scale = tonumber(args[2])
        
        if targetId and scale then
            local valid, err = ValidateScale(scale)
            if valid then
                local identifier = Framework.GetIdentifier(targetId)
                if identifier then
                    playerScales[identifier] = scale
                    TriggerClientEvent('lxr-pedscale:client:applyScale', targetId, scale)
                    print(string.format('[LXR-PedScale] Set scale %.2f for player %d', scale, targetId))
                    if source ~= 0 then
                        TriggerClientEvent('chat:addMessage', source, {
                            args = {'[LXR-PedScale]', string.format('Set scale %.2f for player %d', scale, targetId)}
                        })
                    end
                end
            else
                if source ~= 0 then
                    TriggerClientEvent('chat:addMessage', source, {args = {'[LXR-PedScale]', err}})
                end
            end
        end
    end
end, false)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════════

print('[LXR-PedScale] Server initialized - Framework: ' .. Framework.GetActiveFramework())
