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
        local success, result = pcall(function()
            return exports['lxr-core']:GetCoreObject()
        end)
        
        if success then
            Framework.Object = result
            print('[LXR-PedScale] Server initialized with LXR-Core')
        else
            print('[LXR-PedScale] ERROR: Failed to get LXR-Core object, falling back to standalone')
            Framework.Active = 'standalone'
            Framework.Object = {}
        end
        
    elseif Framework.Active == 'rsg-core' then
        -- RSG-Core initialization
        local success, result = pcall(function()
            return exports['rsg-core']:GetCoreObject()
        end)
        
        if success then
            Framework.Object = result
            print('[LXR-PedScale] Server initialized with RSG-Core')
        else
            print('[LXR-PedScale] ERROR: Failed to get RSG-Core object, falling back to standalone')
            Framework.Active = 'standalone'
            Framework.Object = {}
        end
        
    elseif Framework.Active == 'vorp_core' then
        -- VORP Core initialization
        local success, result = pcall(function()
            return exports.vorp_core:GetCore()
        end)
        
        if success then
            Framework.Object = result
            print('[LXR-PedScale] Server initialized with VORP Core')
        else
            print('[LXR-PedScale] ERROR: Failed to get VORP Core object, falling back to standalone')
            Framework.Active = 'standalone'
            Framework.Object = {}
        end
        
    elseif Framework.Active == 'standalone' then
        -- Standalone - minimal framework object
        Framework.Object = {}
        print('[LXR-PedScale] Server running in standalone mode')
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
        local success, result = pcall(function()
            return exports['lxr-core']:GetCoreObject()
        end)
        
        if success then
            Framework.Object = result
            
            -- Wait for player loaded
            RegisterNetEvent('lxr-core:client:OnPlayerLoaded', function()
                Framework.Loaded = true
                Framework.PlayerData = Framework.Object.Functions.GetPlayerData()
                print('[LXR-PedScale] Player loaded (LXR-Core)')
            end)
            
            RegisterNetEvent('lxr-core:client:OnPlayerUnload', function()
                Framework.Loaded = false
                Framework.PlayerData = {}
            end)
            
            -- Check if already loaded
            if Framework.Object.Functions.GetPlayerData() then
                Framework.Loaded = true
                Framework.PlayerData = Framework.Object.Functions.GetPlayerData()
                print('[LXR-PedScale] Player already loaded (LXR-Core)')
            end
        else
            print('[LXR-PedScale] ERROR: Failed to get LXR-Core object, falling back to standalone')
            Framework.Active = 'standalone'
            Framework.Loaded = true
            Framework.PlayerData = {firstname = 'John', lastname = 'Doe', money = {cash = 9999, gold = 9999}}
        end
        
    elseif Framework.Active == 'rsg-core' then
        -- RSG-Core initialization
        local success, result = pcall(function()
            return exports['rsg-core']:GetCoreObject()
        end)
        
        if success then
            Framework.Object = result
            
            RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
                Framework.Loaded = true
                Framework.PlayerData = Framework.Object.Functions.GetPlayerData()
                print('[LXR-PedScale] Player loaded (RSG-Core)')
            end)
            
            RegisterNetEvent('RSGCore:Client:OnPlayerUnload', function()
                Framework.Loaded = false
                Framework.PlayerData = {}
            end)
            
            if Framework.Object.Functions.GetPlayerData() then
                Framework.Loaded = true
                Framework.PlayerData = Framework.Object.Functions.GetPlayerData()
                print('[LXR-PedScale] Player already loaded (RSG-Core)')
            end
        else
            print('[LXR-PedScale] ERROR: Failed to get RSG-Core object, falling back to standalone')
            Framework.Active = 'standalone'
            Framework.Loaded = true
            Framework.PlayerData = {firstname = 'John', lastname = 'Doe', money = {cash = 9999, gold = 9999}}
        end
        
    elseif Framework.Active == 'vorp_core' then
        -- VORP Core initialization
        local success, result = pcall(function()
            return exports.vorp_core:GetCore()
        end)
        
        if success then
            Framework.Object = result
            
            RegisterNetEvent('vorp:SelectedCharacter', function()
                Wait(1000)
                Framework.Loaded = true
                TriggerServerEvent('lxr-pedscale:server:getPlayerData')
                print('[LXR-PedScale] Player loaded (VORP)')
            end)
            
            RegisterNetEvent('lxr-pedscale:client:setPlayerData', function(data)
                Framework.PlayerData = data
            end)
        else
            print('[LXR-PedScale] ERROR: Failed to get VORP Core object, falling back to standalone')
            Framework.Active = 'standalone'
            Framework.Loaded = true
            Framework.PlayerData = {firstname = 'John', lastname = 'Doe', money = {cash = 9999, gold = 9999}}
        end
        
    elseif Framework.Active == 'standalone' then
        -- Standalone - always loaded
        Framework.Loaded = true
        Framework.PlayerData = {
            firstname = 'John',
            lastname = 'Doe',
            money = {cash = 9999, gold = 9999}
        }
        print('[LXR-PedScale] Running in standalone mode')
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
            if Config.FrameworkSettings[Framework.Active].notifications == 'ox_lib' and GetResourceState('ox_lib') == 'started' then
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
            -- Fallback to 3D text notification
            CreateThread(function()
                local startTime = GetGameTimer()
                local displayDuration = duration or 5000
                
                while GetGameTimer() - startTime < displayDuration do
                    Wait(0)
                    
                    -- Draw notification in screen center
                    SetTextScale(0.40, 0.40)
                    if type == 'error' then
                        SetTextColor(255, 100, 100, 255)
                    elseif type == 'success' then
                        SetTextColor(100, 255, 100, 255)
                    else
                        SetTextColor(255, 200, 100, 255)
                    end
                    SetTextCentre(true)
                    SetTextDropshadow(2, 0, 0, 0, 255)
                    DisplayText(CreateVarString(10, 'LITERAL_STRING', message), 0.5, 0.85)
                end
            end)
            
            -- Also print to console
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
        if GetResourceState('ox_lib') == 'started' then
            local input = exports['ox_lib']:inputDialog(header, inputs)
            if input then
                cb(input)
            else
                cb(nil)
            end
        else
            -- Fallback to native RedM input
            local results = {}
            for i, input in ipairs(inputs) do
                -- Use RedM native prompt for text input
                AddTextEntry('INPUT_PROMPT_' .. i, input.label or 'Enter text')
                DisplayOnscreenKeyboard(0, 'INPUT_PROMPT_' .. i, '', input.default or '', '', '', '', 64)
                
                while true do
                    Wait(0)
                    local status = UpdateOnscreenKeyboard()
                    if status == 1 then
                        -- Input confirmed
                        local result = GetOnscreenKeyboardResult()
                        if result and result ~= '' then
                            results[input.name or i] = result
                            break
                        else
                            -- Empty result
                            if input.required then
                                cb(nil)
                                return
                            else
                                results[input.name or i] = ''
                                break
                            end
                        end
                    elseif status == 2 then
                        -- Input cancelled
                        cb(nil)
                        return
                    elseif status == 3 then
                        -- Input cancelled (alternative code)
                        cb(nil)
                        return
                    end
                end
            end
            cb(results)
        end
    end
    
    -- Show menu
    function Framework.ShowMenu(header, options, cb)
        if GetResourceState('ox_lib') == 'started' then
            exports['ox_lib']:registerContext({
                id = 'lxr_pedscale_menu',
                title = header,
                options = options
            })
            exports['ox_lib']:showContext('lxr_pedscale_menu')
        else
            -- Fallback - simple native menu using text display
            CreateThread(function()
                local currentOption = 1
                local menuActive = true
                
                while menuActive do
                    Wait(0)
                    
                    -- Draw menu background
                    DrawSprite('generic_textures', 'hud_menu_4a', 0.5, 0.3, 0.35, 0.5, 0.0, 0, 0, 0, 200)
                    
                    -- Draw header
                    SetTextScale(0.45, 0.45)
                    SetTextColor(255, 200, 100, 255)
                    SetTextCentre(true)
                    SetTextDropshadow(1, 0, 0, 0, 255)
                    DisplayText(CreateVarString(10, 'LITERAL_STRING', header), 0.5, 0.15)
                    
                    -- Draw options
                    for i, option in ipairs(options) do
                        local yPos = 0.20 + (i * 0.04)
                        
                        if i == currentOption then
                            SetTextScale(0.38, 0.38)
                            SetTextColor(255, 200, 100, 255)
                            DisplayText(CreateVarString(10, 'LITERAL_STRING', '> ' .. option.title), 0.5, yPos)
                        else
                            SetTextScale(0.35, 0.35)
                            SetTextColor(200, 200, 200, 255)
                            DisplayText(CreateVarString(10, 'LITERAL_STRING', '  ' .. option.title), 0.5, yPos)
                        end
                        SetTextCentre(true)
                        SetTextDropshadow(1, 0, 0, 0, 255)
                    end
                    
                    -- Draw controls hint
                    SetTextScale(0.30, 0.30)
                    SetTextColor(150, 150, 150, 255)
                    SetTextCentre(true)
                    DisplayText(CreateVarString(10, 'LITERAL_STRING', 'Arrow Keys to navigate | Enter to select | Backspace to cancel'), 0.5, 0.45)
                    
                    -- Handle input
                    if IsControlJustPressed(0, 0xD9D0E1C0) then -- Arrow Up
                        currentOption = currentOption - 1
                        if currentOption < 1 then currentOption = #options end
                    elseif IsControlJustPressed(0, 0x05CA7C52) then -- Arrow Down
                        currentOption = currentOption + 1
                        if currentOption > #options then currentOption = 1 end
                    elseif IsControlJustPressed(0, 0xC7B5340A) then -- Enter
                        if options[currentOption] and options[currentOption].onSelect then
                            menuActive = false
                            options[currentOption].onSelect()
                        end
                    elseif IsControlJustPressed(0, 0x156F7119) then -- Backspace
                        menuActive = false
                        if cb then cb(nil) end
                    end
                end
            end)
        end
    end
    
    -- Progress bar
    function Framework.ProgressBar(label, duration, cb)
        if GetResourceState('ox_lib') == 'started' then
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
