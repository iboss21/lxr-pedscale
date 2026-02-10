--[[
    ██╗     ██╗  ██╗██████╗       ██████╗ ███████╗██████╗ ███████╗ ██████╗ █████╗ ██╗     ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝██╔══██╗██║     ██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██████╔╝█████╗  ██║  ██║███████╗██║     ███████║██║     █████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔═══╝ ██╔══╝  ██║  ██║╚════██║██║     ██╔══██║██║     ██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ██║     ███████╗██████╔╝███████║╚██████╗██║  ██║███████╗███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝     ╚══════╝╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝
                                                                                                   
    🐺 LXR Ped Scale - Client Script
    
    Handles NPC interactions, camera control, clone preview, and UI for character customization.
    
    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 CLIENT STATE MANAGEMENT
-- ═══════════════════════════════════════════════════════════════════════════════

local spawnedNPCs = {}
local currentCamera = nil
local currentClone = nil
local currentScale = 1.0
local inCustomization = false
local currentNPCData = nil

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Format currency for display
local function FormatCurrency(amount)
    return string.format('$%d', amount)
end

-- Get localized text
local function L(key, ...)
    local text = Locale:Get(key)
    if ... then
        return string.format(text, ...)
    end
    return text
end

-- Create blip for NPC
local function CreateNPCBlip(coords, blipData)
    if not blipData or not blipData.enabled then return nil end
    
    local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, coords.x, coords.y, coords.z)
    SetBlipSprite(blip, blipData.sprite or `blip_proc_doctor`, true)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, blipData.name or 'Character Customization')
    return blip
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 NPC SPAWNING & MANAGEMENT
-- ═══════════════════════════════════════════════════════════════════════════════

-- Spawn NPC at location
local function SpawnNPC(npcData)
    local model = npcData.model
    local coords = npcData.coords
    
    -- Request model
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    
    -- Create ped
    local ped = CreatePed(model, coords.x, coords.y, coords.z - 1.0, coords.w, false, false, false, false)
    
    Citizen.InvokeNative(0x283978A15512B2FE, ped, true) -- SetRandomOutfitVariation
    SetEntityAsMissionEntity(ped, true, true)
    SetPedAsGroupMember(ped, GetPedGroupIndex(PlayerPedId()))
    SetPedConfigFlag(ped, 130, true)
    SetPedConfigFlag(ped, 131, true)
    SetPedConfigFlag(ped, 407, true)
    SetPedConfigFlag(ped, 418, true)
    SetPedConfigFlag(ped, 419, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    
    -- Set scenario
    if npcData.scenario then
        TaskStartScenarioInPlace(ped, GetHashKey(npcData.scenario), -1, true, false, false, false)
    end
    
    -- Create blip
    local blip = CreateNPCBlip(coords, npcData.blip)
    
    -- Store NPC data
    table.insert(spawnedNPCs, {
        ped = ped,
        blip = blip,
        data = npcData,
        coords = coords
    })
    
    if Config.Debug.printNPCSpawns then
        print('[LXR-PedScale] Spawned NPC: ' .. npcData.name)
    end
    
    return ped
end

-- Delete all spawned NPCs
local function DeleteAllNPCs()
    for _, npc in pairs(spawnedNPCs) do
        if DoesEntityExist(npc.ped) then
            DeleteEntity(npc.ped)
        end
        if npc.blip then
            RemoveBlip(npc.blip)
        end
    end
    spawnedNPCs = {}
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 CAMERA SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

-- Create and activate camera
local function CreateCustomCamera(targetCoords, offsetType)
    if not Config.Camera.enabled then return end
    
    local offset = offsetType == 'scale' and Config.Camera.scaleChangeOffset or Config.Camera.nameChangeOffset
    local camCoords = vector3(
        targetCoords.x + offset.x,
        targetCoords.y + offset.y,
        targetCoords.z + offset.z
    )
    
    currentCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(currentCamera, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtCoord(currentCamera, targetCoords.x, targetCoords.y, targetCoords.z + 0.5)
    SetCamFov(currentCamera, Config.Camera.fov)
    
    RenderScriptCams(true, true, Config.Camera.transitionTime, true, true)
    
    if Config.Debug.printCamera then
        print('[LXR-PedScale] Camera created at: ' .. tostring(camCoords))
    end
end

-- Destroy camera
local function DestroyCustomCamera()
    if currentCamera then
        RenderScriptCams(false, true, Config.Camera.transitionTime, true, true)
        DestroyCam(currentCamera, false)
        currentCamera = nil
        
        if Config.Debug.printCamera then
            print('[LXR-PedScale] Camera destroyed')
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 CLONE PREVIEW SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

-- Create clone for scale preview
local function CreateClonePreview()
    if not Config.General.enableClonePreview then return end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    
    -- Calculate clone position
    local forwardVector = GetEntityForwardVector(playerPed)
    local cloneCoords = vector3(
        playerCoords.x + (forwardVector.x * Config.Scale.previewDistance),
        playerCoords.y + (forwardVector.y * Config.Scale.previewDistance),
        playerCoords.z
    )
    
    -- Clone player ped
    currentClone = ClonePed(playerPed, playerHeading + Config.Scale.previewHeading, false, false)
    SetEntityCoords(currentClone, cloneCoords.x, cloneCoords.y, cloneCoords.z)
    SetEntityHeading(currentClone, playerHeading + 180.0)
    FreezeEntityPosition(currentClone, true)
    SetEntityAlpha(currentClone, 200, false)
    
    -- Set initial scale
    SetPedScale(currentClone, currentScale)
    
    -- Create overhead light
    if Config.General.enableOverheadLight then
        CreateThread(function()
            while currentClone and DoesEntityExist(currentClone) do
                local clonePos = GetEntityCoords(currentClone)
                DrawLightWithRange(
                    clonePos.x, clonePos.y, clonePos.z + 2.0,
                    255, 200, 100,
                    Config.Scale.previewLightRange,
                    Config.Scale.previewLightIntensity
                )
                Wait(0)
            end
        end)
    end
    
    -- Create overhead indicator
    if Config.General.enableOverheadIndicator then
        CreateThread(function()
            while currentClone and DoesEntityExist(currentClone) do
                local clonePos = GetEntityCoords(currentClone)
                local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(clonePos.x, clonePos.y, clonePos.z + 1.0)
                if onScreen then
                    SetTextScale(0.35, 0.35)
                    SetTextColor(255, 200, 100, 255)
                    SetTextCentre(true)
                    SetTextDropshadow(1, 0, 0, 0, 255)
                    DisplayText(CreateVarString(10, 'LITERAL_STRING', L('info_current_scale', currentScale)), screenX, screenY)
                end
                Wait(0)
            end
        end)
    end
    
    if Config.Debug.printScale then
        print('[LXR-PedScale] Clone created with scale: ' .. currentScale)
    end
end

-- Update clone scale
local function UpdateCloneScale(newScale)
    if currentClone and DoesEntityExist(currentClone) then
        currentScale = newScale
        SetPedScale(currentClone, currentScale)
        
        if Config.Debug.printScale then
            print('[LXR-PedScale] Clone scale updated to: ' .. currentScale)
        end
    end
end

-- Delete clone
local function DeleteClonePreview()
    if currentClone and DoesEntityExist(currentClone) then
        DeleteEntity(currentClone)
        currentClone = nil
        
        if Config.Debug.printScale then
            print('[LXR-PedScale] Clone deleted')
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 MENU SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

-- Open main customization menu
local function OpenMainMenu(npcData)
    local canChangeName = npcData.enableNameChange
    local canChangeScale = npcData.enableScaleChange
    
    -- If both disabled, open scale by default
    if not canChangeName and not canChangeScale then
        canChangeScale = true
    end
    
    -- If only one option, open it directly
    if canChangeName and not canChangeScale then
        OpenNameChangeMenu()
        return
    elseif canChangeScale and not canChangeName then
        OpenScaleChangeMenu()
        return
    end
    
    -- Both enabled - show choice menu
    local options = {}
    
    if canChangeName then
        table.insert(options, {
            title = L('option_change_name', FormatCurrency(Config.Economy.nameChange.both)),
            description = 'Change your firstname and/or lastname',
            icon = 'fa-solid fa-id-card',
            onSelect = function()
                OpenNameChangeMenu()
            end
        })
    end
    
    if canChangeScale then
        table.insert(options, {
            title = L('option_change_scale', FormatCurrency(Config.Economy.scaleChange.cost)),
            description = 'Adjust your character height',
            icon = 'fa-solid fa-arrows-up-down',
            onSelect = function()
                OpenScaleChangeMenu()
            end
        })
    end
    
    table.insert(options, {
        title = L('option_cancel'),
        description = 'Close menu',
        icon = 'fa-solid fa-xmark',
        onSelect = function()
            CloseCustomization()
        end
    })
    
    Framework.ShowMenu(L('menu_choose_option'), options)
end

-- Open name change menu
function OpenNameChangeMenu()
    local options = {
        {
            title = L('option_firstname', FormatCurrency(Config.Economy.nameChange.firstname)),
            description = 'Change only your firstname',
            icon = 'fa-solid fa-user',
            onSelect = function()
                OpenNameInput('firstname')
            end
        },
        {
            title = L('option_lastname', FormatCurrency(Config.Economy.nameChange.lastname)),
            description = 'Change only your lastname',
            icon = 'fa-solid fa-user',
            onSelect = function()
                OpenNameInput('lastname')
            end
        },
        {
            title = L('option_both_names', FormatCurrency(Config.Economy.nameChange.both)),
            description = 'Change both firstname and lastname',
            icon = 'fa-solid fa-users',
            onSelect = function()
                OpenNameInput('both')
            end
        },
        {
            title = L('option_cancel'),
            icon = 'fa-solid fa-xmark',
            onSelect = function()
                if currentNPCData.enableScaleChange then
                    OpenMainMenu(currentNPCData)
                else
                    CloseCustomization()
                end
            end
        }
    }
    
    Framework.ShowMenu(L('menu_name_change'), options)
end

-- Open name input dialog
function OpenNameInput(changeType)
    local inputs = {}
    
    if changeType == 'firstname' or changeType == 'both' then
        table.insert(inputs, {
            type = 'input',
            label = L('input_firstname'),
            name = 'firstname',
            required = true
        })
    end
    
    if changeType == 'lastname' or changeType == 'both' then
        table.insert(inputs, {
            type = 'input',
            label = L('input_lastname'),
            name = 'lastname',
            required = true
        })
    end
    
    Framework.OpenInput(L('menu_name_change'), inputs, function(result)
        if result then
            TriggerServerEvent('lxr-pedscale:server:changeName', result.firstname, result.lastname, changeType)
        else
            Framework.Notify(L('error_cancelled'), 'error')
            OpenNameChangeMenu()
        end
    end)
end

-- Open scale change menu
function OpenScaleChangeMenu()
    -- Get current player scale
    local playerPed = PlayerPedId()
    currentScale = GetPedScale(playerPed)
    
    -- Create camera
    CreateCustomCamera(GetEntityCoords(playerPed), 'scale')
    
    -- Create clone preview
    CreateClonePreview()
    
    local options = {
        {
            title = L('option_increase_scale'),
            description = string.format('Current: %.2f | Max: %.2f', currentScale, Config.Scale.max),
            icon = 'fa-solid fa-arrow-up',
            onSelect = function()
                local newScale = math.min(currentScale + Config.Scale.step, Config.Scale.max)
                if newScale == currentScale then
                    Framework.Notify(L('error_scale_max', Config.Scale.max), 'error')
                else
                    UpdateCloneScale(newScale)
                end
                Wait(100)
                OpenScaleChangeMenu()
            end
        },
        {
            title = L('option_decrease_scale'),
            description = string.format('Current: %.2f | Min: %.2f', currentScale, Config.Scale.min),
            icon = 'fa-solid fa-arrow-down',
            onSelect = function()
                local newScale = math.max(currentScale - Config.Scale.step, Config.Scale.min)
                if newScale == currentScale then
                    Framework.Notify(L('error_scale_min', Config.Scale.min), 'error')
                else
                    UpdateCloneScale(newScale)
                end
                Wait(100)
                OpenScaleChangeMenu()
            end
        },
        {
            title = L('option_confirm_scale'),
            description = string.format('Confirm scale: %.2f', currentScale),
            icon = 'fa-solid fa-check',
            onSelect = function()
                TriggerServerEvent('lxr-pedscale:server:changeScale', currentScale)
                DeleteClonePreview()
                DestroyCustomCamera()
            end
        },
        {
            title = L('option_cancel'),
            icon = 'fa-solid fa-xmark',
            onSelect = function()
                DeleteClonePreview()
                DestroyCustomCamera()
                if currentNPCData.enableNameChange then
                    OpenMainMenu(currentNPCData)
                else
                    CloseCustomization()
                end
            end
        }
    }
    
    Framework.ShowMenu(L('menu_scale_change'), options)
end

-- Close customization
function CloseCustomization()
    inCustomization = false
    currentNPCData = nil
    DeleteClonePreview()
    DestroyCustomCamera()
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 INTERACTION SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

-- Handle NPC interaction
local function OnNPCInteract(npcData)
    if inCustomization then return end
    if not Framework.IsPlayerLoaded() then
        Framework.Notify('Please wait until fully loaded', 'error')
        return
    end
    
    inCustomization = true
    currentNPCData = npcData
    
    -- Create camera for NPC
    local npcCoords = npcData.coords
    CreateCustomCamera(vector3(npcCoords.x, npcCoords.y, npcCoords.z), 'name')
    
    -- Open menu
    Wait(Config.Camera.transitionTime)
    OpenMainMenu(npcData)
end

-- Setup target system
local function SetupTargetSystem()
    if not Config.General.useTarget then return end
    if GetResourceState('ox_target') ~= 'started' then return end
    
    for _, npcData in ipairs(Config.NPCs) do
        exports['ox_target']:addModel(npcData.model, {
            {
                name = 'lxr_pedscale_' .. npcData.name,
                label = 'Character Customization',
                icon = 'fa-solid fa-user-pen',
                distance = Config.General.interactionDistance,
                onSelect = function()
                    OnNPCInteract(npcData)
                end
            }
        })
    end
end

-- Setup prompt system (fallback)
local function SetupPromptSystem()
    if Config.General.useTarget then return end
    
    CreateThread(function()
        while true do
            local sleep = 1000
            
            if Framework.IsPlayerLoaded() and not inCustomization then
                local playerCoords = GetEntityCoords(PlayerPedId())
                
                for _, npc in pairs(spawnedNPCs) do
                    if DoesEntityExist(npc.ped) then
                        local distance = #(playerCoords - npc.coords.xyz)
                        
                        if distance < Config.General.interactionDistance then
                            sleep = 0
                            
                            -- Draw 3D prompt text above NPC
                            local npcCoords = GetEntityCoords(npc.ped)
                            local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(npcCoords.x, npcCoords.y, npcCoords.z + 1.2)
                            if onScreen then
                                -- Draw title
                                SetTextScale(0.40, 0.40)
                                SetTextColor(255, 200, 100, 255)
                                SetTextCentre(true)
                                SetTextDropshadow(2, 0, 0, 0, 255)
                                DisplayText(CreateVarString(10, 'LITERAL_STRING', npc.data.name), screenX, screenY - 0.025)
                                
                                -- Draw interaction prompt
                                SetTextScale(0.35, 0.35)
                                SetTextColor(200, 255, 200, 255)
                                SetTextCentre(true)
                                SetTextDropshadow(2, 0, 0, 0, 255)
                                DisplayText(CreateVarString(10, 'LITERAL_STRING', '[G] Character Customization'), screenX, screenY + 0.005)
                            end
                            
                            -- Draw marker at NPC feet for better visibility
                            DrawMarker(
                                0x94FDAE17, -- MARKER_CYLINDER
                                npcCoords.x, npcCoords.y, npcCoords.z - 0.98,
                                0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0,
                                0.8, 0.8, 0.5,
                                255, 200, 100, 100,
                                false, false, 2, false, nil, nil, false
                            )
                            
                            -- Check for key press
                            if IsControlJustPressed(0, Config.Keys.interact) then
                                OnNPCInteract(npc.data)
                            end
                        end
                    end
                end
            end
            
            Wait(sleep)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 EVENT HANDLERS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Name change response
RegisterNetEvent('lxr-pedscale:client:nameChangeResponse', function(success, message)
    if success then
        Framework.Notify(message, 'success')
        CloseCustomization()
    else
        Framework.Notify(message, 'error')
        if currentNPCData then
            OpenNameChangeMenu()
        end
    end
end)

-- Scale change response
RegisterNetEvent('lxr-pedscale:client:scaleChangeResponse', function(success, message, newScale)
    if success then
        Framework.Notify(message, 'success')
        
        -- Apply scale to player
        local playerPed = PlayerPedId()
        SetPedScale(playerPed, newScale)
        
        CloseCustomization()
    else
        Framework.Notify(message, 'error')
        if currentNPCData then
            DeleteClonePreview()
            DestroyCustomCamera()
            OpenScaleChangeMenu()
        end
    end
end)

-- Apply scale on spawn/load
RegisterNetEvent('lxr-pedscale:client:applyScale', function(scale)
    if scale and scale ~= 1.0 then
        local playerPed = PlayerPedId()
        SetPedScale(playerPed, scale)
        
        if Config.Debug.printScale then
            print('[LXR-PedScale] Applied saved scale: ' .. scale)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════════

CreateThread(function()
    print('[LXR-PedScale] Initialization starting...')
    print('[LXR-PedScale] Framework: ' .. Framework.GetActiveFramework())
    
    -- Wait for framework to load
    local attempts = 0
    while not Framework.IsPlayerLoaded() do
        Wait(100)
        attempts = attempts + 1
        
        if attempts % 50 == 0 then -- Every 5 seconds
            print('[LXR-PedScale] Waiting for player to load... (' .. (attempts / 10) .. 's)')
        end
        
        if attempts > 600 then -- 60 seconds timeout
            print('[LXR-PedScale] WARNING: Player load timeout, forcing initialization')
            Framework.Loaded = true
            break
        end
    end
    
    Wait(2000) -- Additional wait for stability
    
    print('[LXR-PedScale] Starting NPC spawn process...')
    
    -- Spawn all NPCs
    for i, npcData in ipairs(Config.NPCs) do
        local success, err = pcall(function()
            SpawnNPC(npcData)
        end)
        
        if not success then
            print('[LXR-PedScale] ERROR spawning NPC ' .. (npcData.name or 'Unknown') .. ': ' .. tostring(err))
        else
            print('[LXR-PedScale] Successfully spawned NPC: ' .. (npcData.name or 'Unknown'))
        end
    end
    
    print('[LXR-PedScale] Spawned ' .. #spawnedNPCs .. ' NPCs out of ' .. #Config.NPCs .. ' configured')
    
    -- Setup interaction system
    if Config.General.useTarget then
        local targetState = GetResourceState('ox_target')
        if targetState == 'started' then
            SetupTargetSystem()
            print('[LXR-PedScale] Using ox_target interaction system')
        else
            print('[LXR-PedScale] WARNING: useTarget is true but ox_target is not started (state: ' .. targetState .. ')')
            print('[LXR-PedScale] Falling back to prompt-based interaction')
            SetupPromptSystem()
        end
    else
        SetupPromptSystem()
        print('[LXR-PedScale] Using prompt-based interaction system')
    end
    
    -- Request current scale from server
    TriggerServerEvent('lxr-pedscale:server:requestScale')
    
    print('[LXR-PedScale] Client initialized - Framework: ' .. Framework.GetActiveFramework())
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 KEYBIND REGISTRATION
-- ═══════════════════════════════════════════════════════════════════════════════

-- Register native keybind for interaction (shows in game settings)
-- Note: The actual interaction is handled by the prompt system loop in SetupPromptSystem()
-- which checks for IsControlJustPressed(0, Config.Keys.interact). This RegisterCommand
-- is only for making the keybind visible and rebindable in the game's settings menu.
RegisterCommand('+lxr_pedscale_interact', function()
    -- Intentionally empty - key press is detected by SetupPromptSystem() loop
end, false)

RegisterCommand('-lxr_pedscale_interact', function()
    -- Intentionally empty - key release handler not needed for this use case
end, false)

-- Register the keybind mapping (makes it appear in game settings)
RegisterKeyMapping('+lxr_pedscale_interact', 'Interact with Character Customization NPC', 'keyboard', 'G')

-- Debug command to test menu system
RegisterCommand('pedscale_test', function(source, args, rawCommand)
    if Config.Debug.enabled then
        print('[LXR-PedScale] Testing menu system...')
        
        -- Test with first NPC data
        if Config.NPCs and Config.NPCs[1] then
            OnNPCInteract(Config.NPCs[1])
            print('[LXR-PedScale] Opened test menu')
        else
            print('[LXR-PedScale] ERROR: No NPCs configured')
        end
    end
end, false)

-- Debug command to check spawned NPCs
RegisterCommand('pedscale_status', function(source, args, rawCommand)
    if Config.Debug.enabled then
        print('[LXR-PedScale] === Status Report ===')
        print('Framework: ' .. Framework.GetActiveFramework())
        print('Player Loaded: ' .. tostring(Framework.IsPlayerLoaded()))
        print('Spawned NPCs: ' .. #spawnedNPCs .. ' / ' .. #Config.NPCs)
        print('In Customization: ' .. tostring(inCustomization))
        print('ox_lib State: ' .. GetResourceState('ox_lib'))
        print('ox_target State: ' .. GetResourceState('ox_target'))
        
        for i, npc in ipairs(spawnedNPCs) do
            local exists = DoesEntityExist(npc.ped)
            print(string.format('  NPC %d (%s): %s', i, npc.data.name, exists and 'EXISTS' or 'MISSING'))
        end
    end
end, false)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    DeleteAllNPCs()
    DestroyCustomCamera()
    DeleteClonePreview()
end)
