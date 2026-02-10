--[[
    ██╗     ██╗  ██╗██████╗       ██████╗ ███████╗██████╗ ███████╗ ██████╗ █████╗ ██╗     ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝██╔══██╗██║     ██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝█████╗  ██║  ██║███████╗██║     ███████║██║     █████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔═══╝ ██╔══╝  ██║  ██║╚════██║██║     ██╔══██║██║     ██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ██║     ███████╗██████╔╝███████║╚██████╗██║  ██║███████╗███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝     ╚══════╝╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝
                                                                                                   
    🐺 LXR Ped Scale - Framework Bridge / Adapter Layer
    
    This file provides a unified API layer for multi-framework support.
    Auto-detects framework and provides consistent functions across all frameworks.
    
    Supported Frameworks:
    - LXR-Core (Primary)
    - RSG-Core (Primary)
    - VORP Core (Supported)
    - Standalone (Fallback)
    
    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 FRAMEWORK AUTO-DETECTION
-- ═══════════════════════════════════════════════════════════════════════════════

Framework = {}
Framework.Active = nil
Framework.Object = nil
Framework.PlayerData = {}
Framework.Loaded = false

-- Detect active framework
local function DetectFramework()
    if Config.Framework ~= 'auto' then
        if Config.Debug.printFramework then
            print('[LXR-PedScale] Manual framework set: ' .. Config.Framework)
        end
        return Config.Framework
    end
    
    -- Check for LXR-Core
    if GetResourceState('lxr-core') == 'started' then
        if Config.Debug.printFramework then
            print('[LXR-PedScale] Detected: LXR-Core')
        end
        return 'lxr-core'
    end
    
    -- Check for RSG-Core
    if GetResourceState('rsg-core') == 'started' then
        if Config.Debug.printFramework then
            print('[LXR-PedScale] Detected: RSG-Core')
        end
        return 'rsg-core'
    end
    
    -- Check for VORP Core
    if GetResourceState('vorp_core') == 'started' then
        if Config.Debug.printFramework then
            print('[LXR-PedScale] Detected: VORP Core')
        end
        return 'vorp_core'
    end
    
    -- Fallback to standalone
    if Config.Debug.printFramework then
        print('[LXR-PedScale] No framework detected - Running standalone')
    end
    return 'standalone'
end

Framework.Active = DetectFramework()

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 FRAMEWORK INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════════

if IsDuplicityVersion() then
    -- ═══════════════════════════════════════════════════════════════════════════
    -- SERVER-SIDE BRIDGE
    -- ═══════════════════════════════════════════════════════════════════════════
    
    if Framework.Active == 'lxr-core' then
        -- LXR-Core initialization
        Framework.Object = exports['lxr-core']:GetCoreObject()
        
    elseif Framework.Active == 'rsg-core' then
        -- RSG-Core initialization
        Framework.Object = exports['rsg-core']:GetCoreObject()
        
    elseif Framework.Active == 'vorp_core' then
        -- VORP Core initialization
        Framework.Object = exports.vorp_core:GetCore()
        
    elseif Framework.Active == 'standalone' then
        -- Standalone - minimal framework object
        Framework.Object = {}
    end
    
    -- ═══════════════════════════════════════════════════════════════════════════
    -- SERVER UNIFIED API
    -- ═══════════════════════════════════════════════════════════════════════════
    
    -- Get player identifier
    function Framework.GetIdentifier(source)
        if Framework.Active == 'lxr-core' or Framework.Active == 'rsg-core' then
            local Player = Framework.Object.Functions.GetPlayer(source)
            return Player and Player.PlayerData.citizenid or nil
        elseif Framework.Active == 'vorp_core' then
            local Character = Framework.Object.getUser(source).getUsedCharacter
            return Character and tostring(Character.charIdentifier) or nil
        else
            return 'standalone_' .. source
        end
    end
    
    -- Get player data
    function Framework.GetPlayerData(source)
        if Framework.Active == 'lxr-core' or Framework.Active == 'rsg-core' then
            local Player = Framework.Object.Functions.GetPlayer(source)
            return Player and Player.PlayerData or nil
        elseif Framework.Active == 'vorp_core' then
            local User = Framework.Object.getUser(source)
            if not User then return nil end
            local Character = User.getUsedCharacter
            return Character and {
                firstname = Character.firstname,
                lastname = Character.lastname,
                charIdentifier = Character.charIdentifier,
                money = Character.money,
                gold = Character.gold
            } or nil
        else
            return {firstname = 'John', lastname = 'Doe', money = 0, gold = 0}
        end
    end
    
    -- Get player money
    function Framework.GetMoney(source, account)
        if Framework.Active == 'lxr-core' or Framework.Active == 'rsg-core' then
            local Player = Framework.Object.Functions.GetPlayer(source)
            return Player and Player.PlayerData.money[account] or 0
        elseif Framework.Active == 'vorp_core' then
            local Character = Framework.Object.getUser(source).getUsedCharacter
            if account == 'cash' then
                return Character and Character.money or 0
            elseif account == 'gold' then
                return Character and Character.gold or 0
            end
        else
            return 9999 -- Standalone always has money
        end
    end
    
    -- Remove money
    function Framework.RemoveMoney(source, account, amount)
        if Framework.Active == 'lxr-core' or Framework.Active == 'rsg-core' then
            local Player = Framework.Object.Functions.GetPlayer(source)
            if Player then
                Player.Functions.RemoveMoney(account, amount)
                return true
            end
        elseif Framework.Active == 'vorp_core' then
            local User = Framework.Object.getUser(source)
            if User then
                local Character = User.getUsedCharacter
                if account == 'cash' then
                    Character.removeCurrency(0, amount)
                elseif account == 'gold' then
                    Character.removeCurrency(1, amount)
                end
                return true
            end
        else
            return true -- Standalone always succeeds
        end
        return false
    end
    
    -- Update character name
    function Framework.UpdateCharacterName(source, firstname, lastname)
        if Framework.Active == 'lxr-core' or Framework.Active == 'rsg-core' then
            local Player = Framework.Object.Functions.GetPlayer(source)
            if Player then
                Player.Functions.UpdateCharacterData({
                    firstname = firstname,
                    lastname = lastname
                })
                return true
            end
        elseif Framework.Active == 'vorp_core' then
            local User = Framework.Object.getUser(source)
            if User then
                local Character = User.getUsedCharacter
                Character.updateCharinfo('firstname', firstname)
                Character.updateCharinfo('lastname', lastname)
                return true
            end
        else
            return true -- Standalone always succeeds
        end
        return false
    end
    
    -- Check if player has permission
    function Framework.HasPermission(source, permission)
        if Config.Permissions.adminBypass then
            if Framework.Active == 'lxr-core' or Framework.Active == 'rsg-core' then
                local Player = Framework.Object.Functions.GetPlayer(source)
                if Player and Player.PlayerData.group then
                    for _, group in ipairs(Config.Permissions.adminGroups) do
                        if Player.PlayerData.group == group then
                            return true
                        end
                    end
                end
            elseif Framework.Active == 'vorp_core' then
                local User = Framework.Object.getUser(source)
                if User then
                    for _, group in ipairs(Config.Permissions.adminGroups) do
                        if User.getGroup() == group then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end
    
    -- Register server callback
    function Framework.CreateCallback(name, cb)
        if Framework.Active == 'lxr-core' or Framework.Active == 'rsg-core' then
            Framework.Object.Functions.CreateCallback(name, cb)
        elseif Framework.Active == 'vorp_core' then
            Framework.Object.Callback.Register(name, cb)
        else
            -- Standalone callback system
            RegisterNetEvent(name, function(...)
                local args = {...}
                local source = source
                cb(source, function(...)
                    TriggerClientEvent(name .. ':response', source, ...)
                end, table.unpack(args))
            end)
        end
    end
    
else
    -- ═══════════════════════════════════════════════════════════════════════════
    -- CLIENT-SIDE BRIDGE
    -- ═══════════════════════════════════════════════════════════════════════════
    
    if Framework.Active == 'lxr-core' then
        -- LXR-Core initialization
        Framework.Object = exports['lxr-core']:GetCoreObject()
        
        -- Wait for player loaded
        RegisterNetEvent('lxr-core:client:OnPlayerLoaded', function()
            Framework.Loaded = true
            Framework.PlayerData = Framework.Object.Functions.GetPlayerData()
        end)
        
        RegisterNetEvent('lxr-core:client:OnPlayerUnload', function()
            Framework.Loaded = false
            Framework.PlayerData = {}
        end)
        
        -- Check if already loaded
        if Framework.Object.Functions.GetPlayerData() then
            Framework.Loaded = true
            Framework.PlayerData = Framework.Object.Functions.GetPlayerData()
        end
        
    elseif Framework.Active == 'rsg-core' then
        -- RSG-Core initialization
        Framework.Object = exports['rsg-core']:GetCoreObject()
        
        RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
            Framework.Loaded = true
            Framework.PlayerData = Framework.Object.Functions.GetPlayerData()
        end)
        
        RegisterNetEvent('RSGCore:Client:OnPlayerUnload', function()
            Framework.Loaded = false
            Framework.PlayerData = {}
        end)
        
        if Framework.Object.Functions.GetPlayerData() then
            Framework.Loaded = true
            Framework.PlayerData = Framework.Object.Functions.GetPlayerData()
        end
        
    elseif Framework.Active == 'vorp_core' then
        -- VORP Core initialization
        Framework.Object = exports.vorp_core:GetCore()
        
        RegisterNetEvent('vorp:SelectedCharacter', function()
            Wait(1000)
            Framework.Loaded = true
            TriggerServerEvent('lxr-pedscale:server:getPlayerData')
        end)
        
        RegisterNetEvent('lxr-pedscale:client:setPlayerData', function(data)
            Framework.PlayerData = data
        end)
        
    elseif Framework.Active == 'standalone' then
        -- Standalone - always loaded
        Framework.Loaded = true
        Framework.PlayerData = {
            firstname = 'John',
            lastname = 'Doe',
            money = {cash = 9999, gold = 9999}
        }
    end
    
    -- ═══════════════════════════════════════════════════════════════════════════
    -- CLIENT UNIFIED API
    -- ═══════════════════════════════════════════════════════════════════════════
    
    -- Check if player is loaded
    function Framework.IsPlayerLoaded()
        return Framework.Loaded
    end
    
    -- Get player data
    function Framework.GetPlayerData()
        return Framework.PlayerData
    end
    
    -- Notify player
    function Framework.Notify(message, type, duration)
        if Framework.Active == 'lxr-core' or Framework.Active == 'rsg-core' then
            if Config.FrameworkSettings[Framework.Active].notifications == 'ox_lib' then
                exports['ox_lib']:notify({
                    description = message,
                    type = type or 'info',
                    duration = duration or 5000
                })
            else
                Framework.Object.Functions.Notify(message, type or 'primary', duration or 5000)
            end
        elseif Framework.Active == 'vorp_core' then
            Framework.Object.NotifyLeft('LXR Ped Scale', message, 'generic_textures', 'tick', duration or 5000)
        else
            -- Fallback to print
            print('[LXR-PedScale] ' .. message)
        end
    end
    
    -- Trigger server callback
    function Framework.TriggerCallback(name, cb, ...)
        if Framework.Active == 'lxr-core' or Framework.Active == 'rsg-core' then
            Framework.Object.Functions.TriggerCallback(name, cb, ...)
        elseif Framework.Active == 'vorp_core' then
            Framework.Object.Callback.TriggerAsync(name, cb, ...)
        else
            -- Standalone callback system
            local callbackReceived = false
            RegisterNetEvent(name .. ':response', function(...)
                if not callbackReceived then
                    callbackReceived = true
                    cb(...)
                end
            end)
            TriggerServerEvent(name, ...)
        end
    end
    
    -- Open input dialog
    function Framework.OpenInput(header, inputs, cb)
        if exports['ox_lib'] then
            local input = exports['ox_lib']:inputDialog(header, inputs)
            if input then
                cb(input)
            else
                cb(nil)
            end
        else
            -- Fallback to native input (simplified)
            local results = {}
            for i, input in ipairs(inputs) do
                AddTextEntry('INPUT_' .. i, input.label)
                DisplayOnscreenKeyboard(1, 'INPUT_' .. i, '', input.default or '', '', '', '', 64)
                while UpdateOnscreenKeyboard() == 0 do
                    Wait(0)
                end
                if GetOnscreenKeyboardResult() then
                    results[input.name or i] = GetOnscreenKeyboardResult()
                else
                    cb(nil)
                    return
                end
            end
            cb(results)
        end
    end
    
    -- Show menu
    function Framework.ShowMenu(header, options, cb)
        if exports['ox_lib'] then
            exports['ox_lib']:registerContext({
                id = 'lxr_pedscale_menu',
                title = header,
                options = options
            })
            exports['ox_lib']:showContext('lxr_pedscale_menu')
        else
            -- Fallback - trigger first option for testing
            if options and #options > 0 and options[1].onSelect then
                options[1].onSelect()
            end
        end
    end
    
    -- Progress bar
    function Framework.ProgressBar(label, duration, cb)
        if exports['ox_lib'] then
            exports['ox_lib']:progressBar({
                duration = duration,
                label = label,
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                    car = true,
                    combat = true
                }
            })
            cb(true)
        else
            -- Fallback - just wait
            Wait(duration)
            cb(true)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 HELPER FUNCTIONS (Shared)
-- ═══════════════════════════════════════════════════════════════════════════════

function Framework.GetActiveFramework()
    return Framework.Active
end

function Framework.GetFrameworkObject()
    return Framework.Object
end

-- Debug print
function Framework.Debug(message)
    if Config.Debug.enabled then
        print('[LXR-PedScale Debug] ' .. tostring(message))
    end
end
