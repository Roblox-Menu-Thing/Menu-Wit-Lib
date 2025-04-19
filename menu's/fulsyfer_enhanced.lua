--[[
    Fulsyfer Enhanced.lua
    
    An enhanced version of the Fulsyfer script with improved UI, 
    full functionality for all options, and proper unloading via End key.
    
    Features:
    - Center FOV indicator/crosshair
    - Mouse aim assistance functionality
    - Player ESP/visual highlighting system
    - Enhanced settings UI for customization
    - Clean unloading via End key
]]

-- ===== UTILITIES MODULE =====

local Utilities = {}

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Constants
local RAYCAST_PARAMS = RaycastParams.new()
RAYCAST_PARAMS.FilterType = Enum.RaycastFilterType.Blacklist
RAYCAST_PARAMS.IgnoreWater = true

-- Check if a part is visible from the camera
function Utilities.IsPartVisible(part)
    if not part then return false end
    
    -- Update filter to ignore the player's character
    local character = LocalPlayer.Character
    if character then
        RAYCAST_PARAMS.FilterDescendantsInstances = {character}
    end
    
    -- Cast ray from camera to target part
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit
    local distance = (part.Position - origin).Magnitude
    
    local raycastResult = Workspace:Raycast(origin, direction * distance, RAYCAST_PARAMS)
    
    -- If we hit something, check if it's the target part
    if raycastResult then
        if raycastResult.Instance:IsDescendantOf(part.Parent) then
            return true
        else
            return false
        end
    end
    
    -- If we didn't hit anything, the part is visible
    return true
end

-- Get the closest visible part from a list of parts
function Utilities.GetClosestVisiblePart(parts)
    local closestDistance = math.huge
    local closestPart = nil
    
    for _, part in pairs(parts) do
        if Utilities.IsPartVisible(part) then
            local distance = (part.Position - Camera.CFrame.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPart = part
            end
        end
    end
    
    return closestPart, closestDistance
end

-- Get an array of humanoid parts from a character
function Utilities.GetCharacterParts(character)
    local parts = {}
    
    if not character then return parts end
    
    -- Check common parts
    local checkParts = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}
    
    for _, partName in ipairs(checkParts) do
        local part = character:FindFirstChild(partName)
        if part then
            table.insert(parts, part)
        end
    end
    
    -- Check limbs
    local limbs = {"Left", "Right"}
    local limbParts = {"Arm", "Leg", "Foot", "Hand", "UpperArm", "LowerArm", "UpperLeg", "LowerLeg"}
    
    for _, side in ipairs(limbs) do
        for _, limb in ipairs(limbParts) do
            local partName = side .. limb
            local part = character:FindFirstChild(partName)
            if part then
                table.insert(parts, part)
            end
        end
    end
    
    return parts
end

-- Check if player is on screen
function Utilities.IsOnScreen(position)
    local screenPosition, onScreen = Camera:WorldToScreenPoint(position)
    return onScreen, screenPosition
end

-- Lerp (linear interpolation) between two values
function Utilities.Lerp(a, b, t)
    return a + (b - a) * t
end

-- Lerp between two Vector3 values
function Utilities.LerpVector3(a, b, t)
    return Vector3.new(
        Utilities.Lerp(a.X, b.X, t),
        Utilities.Lerp(a.Y, b.Y, t),
        Utilities.Lerp(a.Z, b.Z, t)
    )
end

-- Generate a random color
function Utilities.RandomColor()
    return Color3.fromRGB(
        math.random(0, 255),
        math.random(0, 255),
        math.random(0, 255)
    )
end

-- Create a simple notification UI
function Utilities.CreateNotification(text, duration)
    duration = duration or 3
    
    -- Create notification GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FulsyferNotificationGui"
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Name = "NotificationFrame"
    frame.Size = UDim2.new(0, 250, 0, 60)
    frame.Position = UDim2.new(0.5, -125, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.1
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Add a decorative accent
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.Position = UDim2.new(0, 0, 0, 0)
    accent.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
    accent.BorderSizePixel = 0
    accent.Parent = frame
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 8)
    accentCorner.Parent = accent
    
    local paddingX = Instance.new("UIPadding")
    paddingX.PaddingLeft = UDim.new(0, 15)
    paddingX.PaddingRight = UDim.new(0, 10)
    paddingX.PaddingTop = UDim.new(0, 5)
    paddingX.PaddingBottom = UDim.new(0, 5)
    paddingX.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "NotificationText"
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 16
    textLabel.Font = Enum.Font.SourceSansSemibold
    textLabel.Text = text
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = frame
    
    -- Add to player GUI
    local success, err = pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(screenGui)
            screenGui.Parent = CoreGui
        else
            screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
    
    if not success then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Animate in
    frame.Position = UDim2.new(0.5, -125, -0.1, 0)
    local targetPosition = UDim2.new(0.5, -125, 0.1, 0)
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local tween = TweenService:Create(frame, tweenInfo, {Position = targetPosition})
    tween:Play()
    
    -- Remove after duration
    spawn(function()
        wait(duration)
        
        -- Animate out
        local tweenOut = TweenService:Create(
            frame, 
            TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), 
            {Position = UDim2.new(0.5, -125, -0.1, 0)}
        )
        tweenOut:Play()
        
        tweenOut.Completed:Wait()
        screenGui:Destroy()
    end)
    
    return screenGui
end

-- Save settings to player's local storage
function Utilities.SaveSettings(key, data)
    local success, err = pcall(function()
        -- Try to use other methods if possible
        if writefile then
            local jsonData = game:GetService("HttpService"):JSONEncode(data)
            writefile("fulsyfer_" .. key .. ".json", jsonData)
            return
        end
        
        -- Fall back to DataStore if available
        local DataStoreService = game:GetService("DataStoreService")
        local settingsStore = DataStoreService:GetDataStore("UserSettings_" .. LocalPlayer.UserId)
        local jsonData = game:GetService("HttpService"):JSONEncode(data)
        settingsStore:SetAsync(key, jsonData)
    end)
    
    if not success then
        warn("Failed to save settings: " .. tostring(err))
    end
end

-- Load settings from player's local storage
function Utilities.LoadSettings(key, defaultSettings)
    local data = defaultSettings or {}
    
    local success, loadedData = pcall(function()
        -- Try to use other methods if possible
        if readfile and isfile and isfile("fulsyfer_" .. key .. ".json") then
            local content = readfile("fulsyfer_" .. key .. ".json")
            return game:GetService("HttpService"):JSONDecode(content)
        end
        
        -- Fall back to DataStore if available
        local DataStoreService = game:GetService("DataStoreService")
        local settingsStore = DataStoreService:GetDataStore("UserSettings_" .. LocalPlayer.UserId)
        local jsonData = settingsStore:GetAsync(key)
        if jsonData then
            return game:GetService("HttpService"):JSONDecode(jsonData)
        end
        return nil
    end)
    
    if success and loadedData then
        -- Merge with default settings
        for k, v in pairs(loadedData) do
            data[k] = v
        end
    end
    
    return data
end

-- Function to check if current game allows certain features
function Utilities.FeatureAllowed(featureName)
    -- List of features that might be restricted in certain games
    local restrictedFeatures = {
        ["AimAssist"] = {
            -- Games that specifically block aim assist
            ["1113868126"] = false,  -- PUBG
            ["292439477"] = false,   -- Phantom Forces
            ["4581966615"] = false   -- Anomic
        },
        ["ESP"] = {
            -- Games that specifically block ESP
            ["292439477"] = false,   -- Phantom Forces
            ["4581966615"] = false   -- Anomic
        }
    }
    
    -- Check if the feature is restricted for this game
    if restrictedFeatures[featureName] then
        local gameId = tostring(game.GameId)
        if restrictedFeatures[featureName][gameId] == false then
            return false
        end
    end
    
    return true
end

-- Get the current game's compatibility status
function Utilities.GetGameCompatibility()
    local gameId = tostring(game.GameId)
    local compatibility = {
        Name = game.Name,
        GameId = gameId,
        AimAssistAllowed = Utilities.FeatureAllowed("AimAssist"),
        ESPAllowed = Utilities.FeatureAllowed("ESP"),
        RecommendedSettings = {}
    }
    
    -- Game-specific recommended settings
    local gameSettings = {
        ["292439477"] = {  -- Phantom Forces
            AimAssist = {
                Sensitivity = 0.3,
                AssistStrength = 0.2,
                FieldOfView = 5
            },
            FOV = {
                Size = 5,
                Transparency = 0.8
            }
        },
        ["1113868126"] = {  -- PUBG
            AimAssist = {
                Sensitivity = 0.4,
                AssistStrength = 0.25,
                FieldOfView = 8
            },
            FOV = {
                Size = 8,
                Transparency = 0.7
            }
        }
    }
    
    -- Set recommended settings if available
    if gameSettings[gameId] then
        compatibility.RecommendedSettings = gameSettings[gameId]
    end
    
    return compatibility
end

-- ===== FOV INDICATOR MODULE =====

local FOVIndicator = {}

-- Settings (with defaults)
FOVIndicator.Settings = {
    Enabled = false,
    Size = 10,           -- FOV circle size in degrees
    DynamicSize = false, -- Adjust size based on distance
    Color = Color3.fromRGB(255, 255, 255),
    Transparency = 0.7,
    Thickness = 1,
    Filled = false,
    FillTransparency = 0.9,
    Sides = 60,          -- Number of segments in the circle
    RainbowMode = false,
    CrosshairEnabled = true,
    CrosshairSize = 8,
    CrosshairThickness = 2,
    CrosshairColor = Color3.fromRGB(255, 255, 255),
    FollowMouse = false, -- Whether FOV circle follows mouse
    VisibleCheck = true, -- Whether FOV should only target visible enemies
    PulsateEffect = false, -- Add a pulsating effect to the FOV circle
    PulsateSpeed = 1,     -- Speed of pulsation
    PulsateSize = 2       -- Size change during pulsation
}

-- Module variables
local FOVCircle = nil
local CrosshairLines = {}
local FOVUpdateConnection = nil
local RainbowCycle = 0
local Drawings = {}

-- Create a circle drawing
local function CreateCircle()
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Radius = 100  -- Will be calculated based on FOV
    circle.Color = FOVIndicator.Settings.Color
    circle.Thickness = FOVIndicator.Settings.Thickness
    circle.Transparency = FOVIndicator.Settings.Transparency
    circle.NumSides = FOVIndicator.Settings.Sides
    circle.Filled = FOVIndicator.Settings.Filled
    circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    table.insert(Drawings, circle)
    return circle
end

-- Create crosshair lines
local function CreateCrosshair()
    local lines = {}
    
    -- Horizontal line
    local horizontal = Drawing.new("Line")
    horizontal.Visible = false
    horizontal.From = Vector2.new(0, 0)
    horizontal.To = Vector2.new(0, 0)
    horizontal.Color = FOVIndicator.Settings.CrosshairColor
    horizontal.Thickness = FOVIndicator.Settings.CrosshairThickness
    horizontal.Transparency = 1
    
    -- Vertical line
    local vertical = Drawing.new("Line")
    vertical.Visible = false
    vertical.From = Vector2.new(0, 0)
    vertical.To = Vector2.new(0, 0)
    vertical.Color = FOVIndicator.Settings.CrosshairColor
    vertical.Thickness = FOVIndicator.Settings.CrosshairThickness
    vertical.Transparency = 1
    
    lines.Horizontal = horizontal
    lines.Vertical = vertical
    
    table.insert(Drawings, horizontal)
    table.insert(Drawings, vertical)
    
    return lines
end

-- Calculate FOV circle radius based on current FOV setting and screen size
local function CalculateFOVRadius()
    local fovSize = FOVIndicator.Settings.Size
    
    -- Calculate radius based on screen height and FOV
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local cameraFOV = Camera.FieldOfView
    
    -- Convert FOV angle to screen radius using trigonometry
    local screenHeight = Camera.ViewportSize.Y
    local fovInRadians = math.rad(fovSize)
    local cameraFOVInRadians = math.rad(cameraFOV)
    
    -- Calculate the tangent ratio
    local tanFOV = math.tan(fovInRadians / 2)
    local tanCameraFOV = math.tan(cameraFOVInRadians / 2)
    
    -- Calculate radius in pixels
    local radius = (tanFOV / tanCameraFOV) * (screenHeight / 2)
    
    -- Apply dynamic size adjustment if enabled
    if FOVIndicator.Settings.DynamicSize then
        -- Get the player's current target distance
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local closestPlayer = AimAssist.GetClosestPlayerToCursor()
            if closestPlayer then
                local distance = (closestPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                local adjustmentFactor = math.clamp(100 / distance, 0.5, 2)
                radius = radius * adjustmentFactor
            end
        end
    end
    
    -- Apply pulsation effect if enabled
    if FOVIndicator.Settings.PulsateEffect then
        local pulseFactor = math.sin(tick() * FOVIndicator.Settings.PulsateSpeed)
        local pulseAmount = FOVIndicator.Settings.PulsateSize
        radius = radius + (pulseFactor * pulseAmount)
    end
    
    return radius
end

-- Update the FOV circle and crosshair
local function UpdateFOVVisuals()
    if not FOVCircle then
        FOVCircle = CreateCircle()
    end
    
    if #CrosshairLines == 0 then
        CrosshairLines = CreateCrosshair()
    end
    
    -- Check if FOV indicator is enabled
    FOVCircle.Visible = FOVIndicator.Settings.Enabled
    
    if FOVIndicator.Settings.Enabled then
        -- Update circle position
        local mousePosition = UserInputService:GetMouseLocation()
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        FOVCircle.Position = FOVIndicator.Settings.FollowMouse and mousePosition or screenCenter
        
        -- Update circle properties
        FOVCircle.Radius = CalculateFOVRadius()
        FOVCircle.NumSides = FOVIndicator.Settings.Sides
        FOVCircle.Thickness = FOVIndicator.Settings.Thickness
        FOVCircle.Transparency = FOVIndicator.Settings.Transparency
        FOVCircle.Filled = FOVIndicator.Settings.Filled
        
        if FOVCircle.Filled then
            FOVCircle.Transparency = FOVIndicator.Settings.FillTransparency
        end
        
        -- Update rainbow mode
        if FOVIndicator.Settings.RainbowMode then
            RainbowCycle = (RainbowCycle + 0.01) % 1
            FOVCircle.Color = Color3.fromHSV(RainbowCycle, 1, 1)
        else
            FOVCircle.Color = FOVIndicator.Settings.Color
        end
    end
    
    -- Update crosshair visibility
    local crosshairVisible = FOVIndicator.Settings.Enabled and FOVIndicator.Settings.CrosshairEnabled
    
    CrosshairLines.Horizontal.Visible = crosshairVisible
    CrosshairLines.Vertical.Visible = crosshairVisible
    
    if crosshairVisible then
        -- Update crosshair position
        local center = FOVIndicator.Settings.FollowMouse 
            and UserInputService:GetMouseLocation() 
            or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        local size = FOVIndicator.Settings.CrosshairSize
        
        -- Horizontal line
        CrosshairLines.Horizontal.From = Vector2.new(center.X - size, center.Y)
        CrosshairLines.Horizontal.To = Vector2.new(center.X + size, center.Y)
        CrosshairLines.Horizontal.Thickness = FOVIndicator.Settings.CrosshairThickness
        
        -- Vertical line
        CrosshairLines.Vertical.From = Vector2.new(center.X, center.Y - size)
        CrosshairLines.Vertical.To = Vector2.new(center.X, center.Y + size)
        CrosshairLines.Vertical.Thickness = FOVIndicator.Settings.CrosshairThickness
        
        -- Update color
        if FOVIndicator.Settings.RainbowMode then
            CrosshairLines.Horizontal.Color = FOVCircle.Color
            CrosshairLines.Vertical.Color = FOVCircle.Color
        else
            CrosshairLines.Horizontal.Color = FOVIndicator.Settings.CrosshairColor
            CrosshairLines.Vertical.Color = FOVIndicator.Settings.CrosshairColor
        end
    end
end

-- Initialize the FOV indicator
function FOVIndicator.Init()
    FOVCircle = CreateCircle()
    CrosshairLines = CreateCrosshair()
    
    -- Set up update connection
    FOVUpdateConnection = RunService.RenderStepped:Connect(UpdateFOVVisuals)
    
    return FOVIndicator
end

-- Clean up the FOV indicator
function FOVIndicator.Cleanup()
    if FOVUpdateConnection then
        FOVUpdateConnection:Disconnect()
        FOVUpdateConnection = nil
    end
    
    if FOVCircle then
        FOVCircle:Remove()
        FOVCircle = nil
    end
    
    if CrosshairLines.Horizontal then
        CrosshairLines.Horizontal:Remove()
    end
    
    if CrosshairLines.Vertical then
        CrosshairLines.Vertical:Remove()
    end
    
    CrosshairLines = {}
end

-- Update FOV indicator settings
function FOVIndicator.UpdateSettings(newSettings)
    for key, value in pairs(newSettings) do
        FOVIndicator.Settings[key] = value
    end
end

-- ===== AIM ASSIST MODULE =====

local AimAssist = {}

-- Settings (with defaults)
AimAssist.Settings = {
    Enabled = false,
    ToggleKey = Enum.KeyCode.Q,
    HoldKey = Enum.UserInputType.MouseButton2, -- Right mouse button
    Sensitivity = 0.5,
    FieldOfView = 10,    -- FOV for target acquisition in degrees
    TargetPart = "Head",   -- Part to aim at: "Head", "HumanoidRootPart", "Torso", "Random"
    TeamCheck = true,    -- Don't target teammates
    VisibleCheck = true, -- Only target visible players
    SmoothLock = true,   -- Smooth aim transition
    SmoothFactor = 0.5,  -- How smooth the aim movement is
    AutoFire = false,    -- Auto fire when target acquired
    UseMouseButton = false, -- Use mouse button instead of key
    DistanceLimit = 1000, -- Maximum distance for targets
    TargetBlacklist = {}, -- List of players to ignore
    PredictMovement = false, -- Predict target movement
    PredictionFactor = 0.5, -- How much to predict movement
    AssistStrength = 0.5,  -- Strength of the aim assist (0.0 to 1.0)
    LockMode = false      -- Full lock vs. assist mode
}

-- Module variables
local AimActive = false
local CurrentTarget = nil
local AimUpdateConnection = nil
local InputBeganConnection = nil
local InputEndedConnection = nil
local ToggleKeyPressed = false
local HoldKeyPressed = false

-- Find the best target based on settings
function AimAssist.GetClosestPlayerToCursor()
    local closestPlayer = nil
    local closestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        -- Skip if player is the local player
        if player == LocalPlayer then
            continue
        end
        
        -- Skip if player is on the same team and team check is enabled
        if AimAssist.Settings.TeamCheck and player.Team == LocalPlayer.Team then
            continue
        end
        
        -- Skip if player is blacklisted
        if table.find(AimAssist.Settings.TargetBlacklist, player.Name) then
            continue
        end
        
        -- Check if player has a character and humanoid
        local character = player.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        -- Determine target part
        local targetPart
        if AimAssist.Settings.TargetPart == "Random" then
            local parts = Utilities.GetCharacterParts(character)
            if #parts > 0 then
                targetPart = parts[math.random(1, #parts)]
            end
        else
            targetPart = character:FindFirstChild(AimAssist.Settings.TargetPart)
        end
        
        if not targetPart then
            targetPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        end
        
        if not targetPart then continue end
        
        -- Check distance
        local distance = (targetPart.Position - Camera.CFrame.Position).Magnitude
        if distance > AimAssist.Settings.DistanceLimit then continue end
        
        -- Check visibility
        if AimAssist.Settings.VisibleCheck and not Utilities.IsPartVisible(targetPart) then
            continue
        end
        
        -- Check if target is within FOV
        local partPosition = targetPart.Position
        
        -- Apply prediction if enabled
        if AimAssist.Settings.PredictMovement then
            local velocity = targetPart.Velocity
            local predictionOffset = velocity * AimAssist.Settings.PredictionFactor
            partPosition = partPosition + predictionOffset
        end
        
        local screenPos, onScreen = Camera:WorldToScreenPoint(partPosition)
        
        if not onScreen then continue end
        
        local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        
        -- Convert FOV to screen distance
        local fovRadius = CalculateFOVRadius()
        
        if screenDistance < fovRadius and screenDistance < closestDistance then
            closestDistance = screenDistance
            closestPlayer = {
                Player = player,
                Character = character,
                TargetPart = targetPart,
                ScreenPosition = Vector2.new(screenPos.X, screenPos.Y),
                Distance = distance
            }
        end
    end
    
    return closestPlayer
end

-- Update aim towards target
local function UpdateAim()
    -- Check if aim assist is enabled and active
    if not AimAssist.Settings.Enabled or not AimActive then
        CurrentTarget = nil
        return
    end
    
    -- Get the closest player to cursor
    local target = AimAssist.GetClosestPlayerToCursor()
    CurrentTarget = target
    
    if not target then return end
    
    -- Calculate aim position
    local aimPosition = target.TargetPart.Position
    
    -- Apply prediction if enabled
    if AimAssist.Settings.PredictMovement then
        local velocity = target.TargetPart.Velocity
        local predictionOffset = velocity * AimAssist.Settings.PredictionFactor
        aimPosition = aimPosition + predictionOffset
    end
    
    -- Get current camera orientation
    local cameraPosition = Camera.CFrame.Position
    
    -- Calculate target orientation
    local targetOrientation = CFrame.new(cameraPosition, aimPosition)
    
    -- If smooth lock is enabled, gradually adjust camera
    if AimAssist.Settings.SmoothLock then
        local smoothFactor = 1 - AimAssist.Settings.SmoothFactor
        smoothFactor = math.clamp(smoothFactor, 0.1, 0.9) * AimAssist.Settings.AssistStrength
        
        local currentCameraCFrame = Camera.CFrame
        
        -- In lock mode, move camera directly to target
        if AimAssist.Settings.LockMode then
            Camera.CFrame = currentCameraCFrame:Lerp(targetOrientation, smoothFactor)
        else
            -- In assist mode, adjust mouse movement
            local currentLookVector = currentCameraCFrame.LookVector
            local targetLookVector = targetOrientation.LookVector
            
            local adjustedLookVector = currentLookVector:Lerp(targetLookVector, smoothFactor)
            local newCameraCFrame = CFrame.new(cameraPosition, cameraPosition + adjustedLookVector)
            
            Camera.CFrame = newCameraCFrame
        end
    else
        -- Direct lock without smoothing
        if AimAssist.Settings.LockMode then
            Camera.CFrame = targetOrientation
        end
    end
    
    -- Auto-fire if enabled
    if AimAssist.Settings.AutoFire then
        -- Simulate mouse button press for firing
        mouse1press()
        wait(0.1)
        mouse1release()
    end
end

-- Handle input for toggling aim assist
local function HandleInput(input, gameProcessed)
    if gameProcessed then return end
    
    -- Check toggle key
    if input.KeyCode == AimAssist.Settings.ToggleKey then
        ToggleKeyPressed = true
        AimActive = not AimActive
        
        if AimActive then
            Utilities.CreateNotification("Aim Assist: ON", 1)
        else
            Utilities.CreateNotification("Aim Assist: OFF", 1)
        end
    end
    
    -- Check hold key
    if (AimAssist.Settings.UseMouseButton and input.UserInputType == AimAssist.Settings.HoldKey) or
       (not AimAssist.Settings.UseMouseButton and input.KeyCode == AimAssist.Settings.HoldKey) then
        HoldKeyPressed = true
        AimActive = true
    end
end

-- Handle input released
local function HandleInputEnded(input, gameProcessed)
    if gameProcessed then return end
    
    -- Check hold key released
    if (AimAssist.Settings.UseMouseButton and input.UserInputType == AimAssist.Settings.HoldKey) or
       (not AimAssist.Settings.UseMouseButton and input.KeyCode == AimAssist.Settings.HoldKey) then
        HoldKeyPressed = false
        
        -- Only deactivate if we're in hold mode, not toggle mode
        if not ToggleKeyPressed then
            AimActive = false
        end
    end
    
    -- Reset toggle key state
    if input.KeyCode == AimAssist.Settings.ToggleKey then
        ToggleKeyPressed = false
    end
end

-- Initialize the aim assist
function AimAssist.Init()
    -- Set up update connection
    AimUpdateConnection = RunService.RenderStepped:Connect(UpdateAim)
    
    -- Set up input connections
    InputBeganConnection = UserInputService.InputBegan:Connect(HandleInput)
    InputEndedConnection = UserInputService.InputEnded:Connect(HandleInputEnded)
    
    return AimAssist
end

-- Clean up the aim assist
function AimAssist.Cleanup()
    AimActive = false
    CurrentTarget = nil
    
    if AimUpdateConnection then
        AimUpdateConnection:Disconnect()
        AimUpdateConnection = nil
    end
    
    if InputBeganConnection then
        InputBeganConnection:Disconnect()
        InputBeganConnection = nil
    end
    
    if InputEndedConnection then
        InputEndedConnection:Disconnect()
        InputEndedConnection = nil
    end
end

-- Update aim assist settings
function AimAssist.UpdateSettings(newSettings)
    for key, value in pairs(newSettings) do
        AimAssist.Settings[key] = value
    end
end

-- ===== ESP MODULE =====

local ESP = {}

-- Settings (with defaults)
ESP.Settings = {
    Enabled = false,
    BoxEnabled = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxTransparency = 0.5,
    BoxThickness = 1,
    BoxOutline = true,
    BoxOutlineColor = Color3.fromRGB(0, 0, 0),
    TracerEnabled = false,
    TracerColor = Color3.fromRGB(255, 255, 255),
    TracerTransparency = 0.5,
    TracerThickness = 1,
    TracerOrigin = "Bottom", -- "Bottom", "Top", "Mouse"
    NameEnabled = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameOutline = true,
    NameOutlineColor = Color3.fromRGB(0, 0, 0),
    NameSize = 14,
    DistanceEnabled = true,
    DistanceColor = Color3.fromRGB(255, 255, 255),
    DistanceOutline = true,
    DistanceOutlineColor = Color3.fromRGB(0, 0, 0),
    DistanceSize = 12,
    HealthEnabled = true,
    HealthColor = Color3.fromRGB(0, 255, 0),
    HealthDynamicColor = true,
    TeamCheck = true,
    TeamColor = true,
    TeamMates = false,
    LimitDistance = true,
    MaxDistance = 1000,
    VisibleOnly = false,
    VisibleColor = Color3.fromRGB(0, 255, 0),
    InvisibleColor = Color3.fromRGB(255, 0, 0),
    TextCase = "Normal" -- "Normal", "Uppercase", "Lowercase"
}

-- Module variables
local ESPObjects = {}
local ESPUpdateConnection = nil

-- Get ESP object for player
local function GetOrCreateESPObject(player)
    if ESPObjects[player] then
        return ESPObjects[player]
    end
    
    -- Create new ESP object
    local espObject = {
        Player = player,
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        TracerOutline = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        HealthBarBackground = Drawing.new("Line")
    }
    
    -- Setup Box
    espObject.Box.Visible = false
    espObject.Box.Color = ESP.Settings.BoxColor
    espObject.Box.Thickness = ESP.Settings.BoxThickness
    espObject.Box.Transparency = ESP.Settings.BoxTransparency
    espObject.Box.Filled = false
    
    -- Setup Box Outline
    espObject.BoxOutline.Visible = false
    espObject.BoxOutline.Color = ESP.Settings.BoxOutlineColor
    espObject.BoxOutline.Thickness = ESP.Settings.BoxThickness + 2
    espObject.BoxOutline.Transparency = ESP.Settings.BoxTransparency
    espObject.BoxOutline.Filled = false
    
    -- Setup Tracer
    espObject.Tracer.Visible = false
    espObject.Tracer.Color = ESP.Settings.TracerColor
    espObject.Tracer.Thickness = ESP.Settings.TracerThickness
    espObject.Tracer.Transparency = ESP.Settings.TracerTransparency
    
    -- Setup Tracer Outline
    espObject.TracerOutline.Visible = false
    espObject.TracerOutline.Color = ESP.Settings.BoxOutlineColor
    espObject.TracerOutline.Thickness = ESP.Settings.TracerThickness + 2
    espObject.TracerOutline.Transparency = ESP.Settings.TracerTransparency
    
    -- Setup Name
    espObject.Name.Visible = false
    espObject.Name.Color = ESP.Settings.NameColor
    espObject.Name.Size = ESP.Settings.NameSize
    espObject.Name.Center = true
    espObject.Name.Outline = ESP.Settings.NameOutline
    espObject.Name.OutlineColor = ESP.Settings.NameOutlineColor
    
    -- Setup Distance
    espObject.Distance.Visible = false
    espObject.Distance.Color = ESP.Settings.DistanceColor
    espObject.Distance.Size = ESP.Settings.DistanceSize
    espObject.Distance.Center = true
    espObject.Distance.Outline = ESP.Settings.DistanceOutline
    espObject.Distance.OutlineColor = ESP.Settings.DistanceOutlineColor
    
    -- Setup Health
    espObject.Health.Visible = false
    espObject.Health.Color = ESP.Settings.HealthColor
    espObject.Health.Size = ESP.Settings.DistanceSize
    espObject.Health.Center = true
    espObject.Health.Outline = true
    espObject.Health.OutlineColor = Color3.new(0, 0, 0)
    
    -- Setup Health Bar
    espObject.HealthBar.Visible = false
    espObject.HealthBar.Color = ESP.Settings.HealthColor
    espObject.HealthBar.Thickness = 2
    espObject.HealthBar.Transparency = 1
    
    -- Setup Health Bar Background
    espObject.HealthBarBackground.Visible = false
    espObject.HealthBarBackground.Color = Color3.new(0.1, 0.1, 0.1)
    espObject.HealthBarBackground.Thickness = 2
    espObject.HealthBarBackground.Transparency = 1
    
    -- Add to drawings for cleanup
    for _, drawing in pairs(espObject) do
        if type(drawing) ~= "table" and drawing.Remove then
            table.insert(Drawings, drawing)
        end
    end
    
    ESPObjects[player] = espObject
    return espObject
end

-- Update ESP for a player
local function UpdateESPForPlayer(player)
    if not ESP.Settings.Enabled then return end
    
    -- Skip if player is the local player
    if player == LocalPlayer then return end
    
    -- Check if player has a character
    local character = player.Character
    if not character then return end
    
    -- Check if player has a humanoid
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    -- Check if we show teammates
    if ESP.Settings.TeamCheck and player.Team == LocalPlayer.Team and not ESP.Settings.TeamMates then
        return
    end
    
    -- Check for root part
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Get or create ESP object
    local espObject = GetOrCreateESPObject(player)
    
    -- Check distance
    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    if ESP.Settings.LimitDistance and distance > ESP.Settings.MaxDistance then
        -- Hide all elements
        for _, drawing in pairs(espObject) do
            if type(drawing) ~= "table" and drawing.Visible then
                drawing.Visible = false
            end
        end
        return
    end
    
    -- Check visibility
    local isVisible = not ESP.Settings.VisibleOnly or Utilities.IsPartVisible(rootPart)
    
    -- Calculate player box dimensions
    local topPosition = rootPart.Position + Vector3.new(0, 3, 0) -- Above head
    local bottomPosition = rootPart.Position - Vector3.new(0, 3, 0) -- Below feet
    
    local onScreenTop, topScreenPos = Utilities.IsOnScreen(topPosition)
    local onScreenBottom, bottomScreenPos = Utilities.IsOnScreen(bottomPosition)
    
    -- Hide ESP if player is not on screen
    if not onScreenTop and not onScreenBottom then
        for _, drawing in pairs(espObject) do
            if type(drawing) ~= "table" and drawing.Visible then
                drawing.Visible = false
            end
        end
        return
    end
    
    -- Determine box height based on character
    local boxHeight = math.abs(topScreenPos.Y - bottomScreenPos.Y)
    local boxWidth = boxHeight * 0.6 -- Approximate width based on height
    
    -- Calculate box position
    local boxCenter = Vector2.new(bottomScreenPos.X, bottomScreenPos.Y - boxHeight / 2)
    
    -- Update ESP Components
    
    -- Determine color based on visibility and team
    local color = ESP.Settings.BoxColor
    
    if ESP.Settings.VisibleOnly then
        color = isVisible and ESP.Settings.VisibleColor or ESP.Settings.InvisibleColor
    elseif ESP.Settings.TeamColor and player.Team then
        color = player.TeamColor.Color
    end
    
    -- Update Box
    if ESP.Settings.BoxEnabled then
        espObject.Box.Visible = true
        espObject.Box.Size = Vector2.new(boxWidth, boxHeight)
        espObject.Box.Position = Vector2.new(boxCenter.X - boxWidth / 2, boxCenter.Y - boxHeight / 2)
        espObject.Box.Color = color
        espObject.Box.Transparency = ESP.Settings.BoxTransparency
        espObject.Box.Thickness = ESP.Settings.BoxThickness
        
        if ESP.Settings.BoxOutline then
            espObject.BoxOutline.Visible = true
            espObject.BoxOutline.Size = espObject.Box.Size
            espObject.BoxOutline.Position = espObject.Box.Position
            espObject.BoxOutline.Thickness = ESP.Settings.BoxThickness + 2
        else
            espObject.BoxOutline.Visible = false
        end
    else
        espObject.Box.Visible = false
        espObject.BoxOutline.Visible = false
    end
    
    -- Update Tracer
    if ESP.Settings.TracerEnabled then
        espObject.Tracer.Visible = true
        
        -- Determine tracer origin
        local origin
        if ESP.Settings.TracerOrigin == "Bottom" then
            origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        elseif ESP.Settings.TracerOrigin == "Top" then
            origin = Vector2.new(Camera.ViewportSize.X / 2, 0)
        else -- "Mouse"
            origin = UserInputService:GetMouseLocation()
        end
        
        espObject.Tracer.From = origin
        espObject.Tracer.To = Vector2.new(bottomScreenPos.X, bottomScreenPos.Y)
        espObject.Tracer.Color = color
        espObject.Tracer.Transparency = ESP.Settings.TracerTransparency
        espObject.Tracer.Thickness = ESP.Settings.TracerThickness
        
        espObject.TracerOutline.Visible = true
        espObject.TracerOutline.From = origin
        espObject.TracerOutline.To = Vector2.new(bottomScreenPos.X, bottomScreenPos.Y)
        espObject.TracerOutline.Thickness = ESP.Settings.TracerThickness + 2
    else
        espObject.Tracer.Visible = false
        espObject.TracerOutline.Visible = false
    end
    
    -- Update Name
    if ESP.Settings.NameEnabled then
        espObject.Name.Visible = true
        
        -- Format name based on setting
        local nameText = player.Name
        if ESP.Settings.TextCase == "Uppercase" then
            nameText = nameText:upper()
        elseif ESP.Settings.TextCase == "Lowercase" then
            nameText = nameText:lower()
        end
        
        -- Add display name if different
        if player.DisplayName ~= player.Name then
            nameText = nameText .. " (" .. player.DisplayName .. ")"
        end
        
        espObject.Name.Text = nameText
        espObject.Name.Position = Vector2.new(boxCenter.X, boxCenter.Y - boxHeight / 2 - 15)
        espObject.Name.Color = color
        espObject.Name.Outline = ESP.Settings.NameOutline
    else
        espObject.Name.Visible = false
    end
    
    -- Update Distance
    if ESP.Settings.DistanceEnabled then
        espObject.Distance.Visible = true
        espObject.Distance.Text = math.floor(distance) .. " studs"
        espObject.Distance.Position = Vector2.new(boxCenter.X, boxCenter.Y + boxHeight / 2 + 5)
        espObject.Distance.Color = ESP.Settings.DistanceColor
        espObject.Distance.Outline = ESP.Settings.DistanceOutline
    else
        espObject.Distance.Visible = false
    end
    
    -- Update Health
    if ESP.Settings.HealthEnabled then
        espObject.Health.Visible = true
        
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local healthText = math.floor(healthPercent * 100) .. "%"
        espObject.Health.Text = healthText
        espObject.Health.Position = Vector2.new(boxCenter.X - boxWidth / 2 - 20, boxCenter.Y)
        
        -- Update health color dynamically if enabled
        if ESP.Settings.HealthDynamicColor then
            local healthColor = Color3.new(
                math.clamp(2 - 2 * healthPercent, 0, 1),
                math.clamp(2 * healthPercent, 0, 1),
                0
            )
            espObject.Health.Color = healthColor
            espObject.HealthBar.Color = healthColor
        else
            espObject.Health.Color = ESP.Settings.HealthColor
            espObject.HealthBar.Color = ESP.Settings.HealthColor
        end
        
        -- Update health bar
        espObject.HealthBarBackground.Visible = true
        espObject.HealthBarBackground.From = Vector2.new(boxCenter.X - boxWidth / 2 - 5, boxCenter.Y - boxHeight / 2)
        espObject.HealthBarBackground.To = Vector2.new(boxCenter.X - boxWidth / 2 - 5, boxCenter.Y + boxHeight / 2)
        
        espObject.HealthBar.Visible = true
        espObject.HealthBar.From = Vector2.new(boxCenter.X - boxWidth / 2 - 5, boxCenter.Y + boxHeight / 2)
        espObject.HealthBar.To = Vector2.new(
            boxCenter.X - boxWidth / 2 - 5, 
            boxCenter.Y + boxHeight / 2 - boxHeight * healthPercent
        )
    else
        espObject.Health.Visible = false
        espObject.HealthBar.Visible = false
        espObject.HealthBarBackground.Visible = false
    end
end

-- Update ESP for all players
local function UpdateESP()
    if not ESP.Settings.Enabled then
        -- Hide all ESP objects
        for _, espObject in pairs(ESPObjects) do
            for _, drawing in pairs(espObject) do
                if type(drawing) ~= "table" and drawing.Visible then
                    drawing.Visible = false
                end
            end
        end
        return
    end
    
    -- Update ESP for each player
    for _, player in pairs(Players:GetPlayers()) do
        UpdateESPForPlayer(player)
    end
end

-- Clean up ESP for a player
local function CleanupESPForPlayer(player)
    local espObject = ESPObjects[player]
    if not espObject then return end
    
    -- Remove all drawing objects
    for _, drawing in pairs(espObject) do
        if type(drawing) ~= "table" and drawing.Remove then
            drawing:Remove()
        end
    end
    
    ESPObjects[player] = nil
end

-- Initialize the ESP
function ESP.Init()
    -- Set up update connection
    ESPUpdateConnection = RunService.RenderStepped:Connect(UpdateESP)
    
    -- Set up player removal handler
    Players.PlayerRemoving:Connect(CleanupESPForPlayer)
    
    return ESP
end

-- Clean up the ESP
function ESP.Cleanup()
    if ESPUpdateConnection then
        ESPUpdateConnection:Disconnect()
        ESPUpdateConnection = nil
    end
    
    -- Clean up all ESP objects
    for player, _ in pairs(ESPObjects) do
        CleanupESPForPlayer(player)
    end
    
    ESPObjects = {}
end

-- Update ESP settings
function ESP.UpdateSettings(newSettings)
    for key, value in pairs(newSettings) do
        ESP.Settings[key] = value
    end
end

-- ===== UI MODULE =====

local UI = {}

-- UI components
local UIElements = {
    MainGui = nil,
    Tabs = {},
    Panels = {},
    Settings = {}
}

-- UI settings
UI.Settings = {
    GUIEnabled = true,
    UIScale = 1.0,
    UIColor = Color3.fromRGB(35, 35, 50),
    UIAccentColor = Color3.fromRGB(110, 200, 255),
    UIGradientEnabled = true,
    UITextColor = Color3.fromRGB(255, 255, 255),
    UIFont = Enum.Font.SourceSansSemibold,
    UICornerRadius = UDim.new(0, 5),
    UITransparency = 0.1,
    UIAnimations = true,
    ToggleKey = Enum.KeyCode.RightShift
}

-- Create a UI element with common properties
local function CreateUIElement(name, elementType, parent, defaultProp)
    local element = Instance.new(elementType)
    element.Name = name
    
    -- Apply default properties
    if defaultProp then
        for prop, value in pairs(defaultProp) do
            element[prop] = value
        end
    end
    
    -- Apply UI settings
    if elementType == "Frame" or elementType == "ScrollingFrame" then
        element.BackgroundColor3 = UI.Settings.UIColor
        element.BackgroundTransparency = UI.Settings.UITransparency
        element.BorderSizePixel = 0
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UI.Settings.UICornerRadius
        corner.Parent = element
    elseif elementType == "TextLabel" or elementType == "TextButton" or elementType == "TextBox" then
        element.Font = UI.Settings.UIFont
        element.TextColor3 = UI.Settings.UITextColor
        element.TextSize = 14
        element.TextWrapped = true
        
        if elementType ~= "TextLabel" then
            element.BackgroundColor3 = UI.Settings.UIColor
            element.BackgroundTransparency = UI.Settings.UITransparency
            element.BorderSizePixel = 0
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UI.Settings.UICornerRadius
            corner.Parent = element
            
            -- Add hover effect for buttons
            if elementType == "TextButton" then
                local hoverEnter = function()
                    TweenService:Create(element, TweenInfo.new(0.2), {
                        BackgroundColor3 = element.BackgroundColor3:Lerp(UI.Settings.UIAccentColor, 0.3)
                    }):Play()
                end
                
                local hoverLeave = function()
                    TweenService:Create(element, TweenInfo.new(0.2), {
                        BackgroundColor3 = UI.Settings.UIColor
                    }):Play()
                end
                
                element.MouseEnter:Connect(hoverEnter)
                element.MouseLeave:Connect(hoverLeave)
            end
        end
    end
    
    if parent then
        element.Parent = parent
    end
    
    return element
end

-- Create a tab button and content panel
local function CreateTab(name, icon, parent, contentParent)
    local tabButton = CreateUIElement(name.."Tab", "TextButton", parent, {
        Size = UDim2.new(1, 0, 0, 40),
        Text = "   " .. name,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = UI.Settings.UIFont,
        TextSize = 14,
        AutoButtonColor = false
    })
    
    -- Create icon
    local iconLabel = CreateUIElement(name.."Icon", "TextLabel", tabButton, {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 10, 0.5, -10),
        Text = icon,
        TextSize = 18,
        BackgroundTransparency = 1,
        TextColor3 = UI.Settings.UIAccentColor
    })
    
    -- Create content panel
    local contentPanel = CreateUIElement(name.."Panel", "ScrollingFrame", contentParent, {
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = UI.Settings.UIAccentColor,
        Visible = false,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = contentPanel
    
    -- Add layout
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = contentPanel
    
    -- Store references
    UIElements.Tabs[name] = tabButton
    UIElements.Panels[name] = contentPanel
    
    return tabButton, contentPanel
end

-- Create a section divider
local function CreateSection(name, parent)
    local section = CreateUIElement(name.."Section", "Frame", parent, {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 0.9
    })
    
    local sectionTitle = CreateUIElement(name.."Title", "TextLabel", section, {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        Text = name,
        TextSize = 16,
        Font = Enum.Font.SourceSansBold,
        TextColor3 = UI.Settings.UIAccentColor,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local line = CreateUIElement(name.."Line", "Frame", section, {
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.new(0, 10, 1, -1),
        BackgroundColor3 = UI.Settings.UIAccentColor,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0
    })
    
    return section
end

-- Create a toggle setting
local function CreateToggle(name, description, defaultValue, callback, parent)
    local toggle = CreateUIElement(name.."Toggle", "Frame", parent, {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 0.8
    })
    
    local title = CreateUIElement(name.."Title", "TextLabel", toggle, {
        Size = UDim2.new(1, -70, 0, 20),
        Position = UDim2.new(0, 5, 0, 5),
        Text = name,
        TextSize = 14,
        Font = Enum.Font.SourceSansSemibold,
        TextColor3 = UI.Settings.UITextColor,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local desc = CreateUIElement(name.."Description", "TextLabel", toggle, {
        Size = UDim2.new(1, -70, 0, 20),
        Position = UDim2.new(0, 5, 0, 25),
        Text = description,
        TextSize = 12,
        Font = Enum.Font.SourceSans,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggleFrame = CreateUIElement(name.."ToggleFrame", "Frame", toggle, {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        BackgroundColor3 = defaultValue and UI.Settings.UIAccentColor or Color3.fromRGB(80, 80, 80),
        BackgroundTransparency = 0
    })
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggleFrame
    
    local toggleCircle = CreateUIElement(name.."Circle", "Frame", toggleFrame, {
        Size = UDim2.new(0, 16, 0, 16),
        Position = defaultValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle
    
    -- Button for the entire row
    local button = CreateUIElement(name.."Button", "TextButton", toggle, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })
    
    -- Set initial value
    UIElements.Settings[name] = defaultValue
    
    -- Handle toggle
    button.MouseButton1Click:Connect(function()
        local newValue = not UIElements.Settings[name]
        UIElements.Settings[name] = newValue
        
        -- Animate toggle
        if UI.Settings.UIAnimations then
            if newValue then
                TweenService:Create(toggleFrame, TweenInfo.new(0.2), {
                    BackgroundColor3 = UI.Settings.UIAccentColor
                }):Play()
                TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
                    Position = UDim2.new(1, -18, 0.5, -8)
                }):Play()
            else
                TweenService:Create(toggleFrame, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                }):Play()
                TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
                    Position = UDim2.new(0, 2, 0.5, -8)
                }):Play()
            end
        else
            toggleFrame.BackgroundColor3 = newValue and UI.Settings.UIAccentColor or Color3.fromRGB(80, 80, 80)
            toggleCircle.Position = newValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        end
        
        callback(newValue)
    end)
    
    return toggle, UIElements.Settings[name]
end

-- Create a slider setting
local function CreateSlider(name, description, min, max, defaultValue, decimals, suffix, callback, parent)
    local slider = CreateUIElement(name.."Slider", "Frame", parent, {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundTransparency = 0.8
    })
    
    local title = CreateUIElement(name.."Title", "TextLabel", slider, {
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 5),
        Text = name,
        TextSize = 14,
        Font = Enum.Font.SourceSansSemibold,
        TextColor3 = UI.Settings.UITextColor,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local desc = CreateUIElement(name.."Description", "TextLabel", slider, {
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 25),
        Text = description,
        TextSize = 12,
        Font = Enum.Font.SourceSans,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local sliderTrack = CreateUIElement(name.."Track", "Frame", slider, {
        Size = UDim2.new(1, -110, 0, 6),
        Position = UDim2.new(0, 5, 0, 50),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0
    })
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = sliderTrack
    
    -- Calculate initial fill
    local percent = (defaultValue - min) / (max - min)
    
    local sliderFill = CreateUIElement(name.."Fill", "Frame", sliderTrack, {
        Size = UDim2.new(percent, 0, 1, 0),
        BackgroundColor3 = UI.Settings.UIAccentColor,
        BorderSizePixel = 0
    })
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    
    local sliderKnob = CreateUIElement(name.."Knob", "Frame", sliderTrack, {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(percent, -7, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 2,
        BorderSizePixel = 0
    })
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = sliderKnob
    
    local valueDisplay = CreateUIElement(name.."Value", "TextBox", slider, {
        Size = UDim2.new(0, 60, 0, 25),
        Position = UDim2.new(1, -65, 0, 40),
        Text = tostring(defaultValue) .. (suffix or ""),
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BackgroundTransparency = 0,
        ClearTextOnFocus = true
    })
    
    -- Set initial value
    UIElements.Settings[name] = defaultValue
    
    -- Update function for slider
    local function UpdateSlider(value)
        -- Clamp value between min and max
        value = math.clamp(value, min, max)
        
        -- Round to specified decimal places
        if decimals then
            local mult = 10 ^ decimals
            value = math.floor(value * mult + 0.5) / mult
        end
        
        -- Update value
        UIElements.Settings[name] = value
        
        -- Update display
        valueDisplay.Text = tostring(value) .. (suffix or "")
        
        -- Update slider visuals
        local percent = (value - min) / (max - min)
        
        if UI.Settings.UIAnimations then
            TweenService:Create(sliderFill, TweenInfo.new(0.1), {
                Size = UDim2.new(percent, 0, 1, 0)
            }):Play()
            TweenService:Create(sliderKnob, TweenInfo.new(0.1), {
                Position = UDim2.new(percent, -7, 0.5, -7)
            }):Play()
        else
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderKnob.Position = UDim2.new(percent, -7, 0.5, -7)
        end
        
        callback(value)
    end
    
    -- Handle slider drag
    local isDragging = false
    
    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
        end
    end)
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Calculate value based on mouse position
            local percent = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * percent
            
            UpdateSlider(value)
            isDragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            -- Calculate value based on mouse position
            local percent = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * percent
            
            UpdateSlider(value)
        end
    end)
    
    -- Handle direct value input
    valueDisplay.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local inputValue = tonumber(valueDisplay.Text:gsub(suffix or "", ""))
            if inputValue then
                UpdateSlider(inputValue)
            else
                valueDisplay.Text = tostring(UIElements.Settings[name]) .. (suffix or "")
            end
        else
            valueDisplay.Text = tostring(UIElements.Settings[name]) .. (suffix or "")
        end
    end)
    
    return slider, UIElements.Settings[name]
end

-- Create a color picker setting
local function CreateColorPicker(name, description, defaultColor, callback, parent)
    local colorPicker = CreateUIElement(name.."ColorPicker", "Frame", parent, {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 0.8
    })
    
    local title = CreateUIElement(name.."Title", "TextLabel", colorPicker, {
        Size = UDim2.new(1, -70, 0, 20),
        Position = UDim2.new(0, 5, 0, 5),
        Text = name,
        TextSize = 14,
        Font = Enum.Font.SourceSansSemibold,
        TextColor3 = UI.Settings.UITextColor,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local desc = CreateUIElement(name.."Description", "TextLabel", colorPicker, {
        Size = UDim2.new(1, -70, 0, 20),
        Position = UDim2.new(0, 5, 0, 25),
        Text = description,
        TextSize = 12,
        Font = Enum.Font.SourceSans,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local colorDisplay = CreateUIElement(name.."Display", "Frame", colorPicker, {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -50, 0.5, -20),
        BackgroundColor3 = defaultColor,
        BorderSizePixel = 0
    })
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = colorDisplay
    
    -- Set initial value
    UIElements.Settings[name] = defaultColor
    
    -- Setup color picker popup
    local colorMenu = CreateUIElement(name.."Menu", "Frame", nil, {
        Size = UDim2.new(0, 200, 0, 240),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Visible = false
    })
    
    local colorMenuCorner = Instance.new("UICorner")
    colorMenuCorner.CornerRadius = UDim.new(0, 5)
    colorMenuCorner.Parent = colorMenu
    
    -- RGB sliders
    local redSlider = CreateSlider("Red", "Red component", 0, 255, defaultColor.R * 255, 0, "", function(value)
        local newColor = Color3.fromRGB(
            value,
            UIElements.Settings[name].G * 255,
            UIElements.Settings[name].B * 255
        )
        
        colorDisplay.BackgroundColor3 = newColor
        UIElements.Settings[name] = newColor
        callback(newColor)
    end, colorMenu)
    
    local greenSlider = CreateSlider("Green", "Green component", 0, 255, defaultColor.G * 255, 0, "", function(value)
        local newColor = Color3.fromRGB(
            UIElements.Settings[name].R * 255,
            value,
            UIElements.Settings[name].B * 255
        )
        
        colorDisplay.BackgroundColor3 = newColor
        UIElements.Settings[name] = newColor
        callback(newColor)
    end, colorMenu)
    
    local blueSlider = CreateSlider("Blue", "Blue component", 0, 255, defaultColor.B * 255, 0, "", function(value)
        local newColor = Color3.fromRGB(
            UIElements.Settings[name].R * 255,
            UIElements.Settings[name].G * 255,
            value
        )
        
        colorDisplay.BackgroundColor3 = newColor
        UIElements.Settings[name] = newColor
        callback(newColor)
    end, colorMenu)
    
    -- Show the color picker when clicking the display
    colorDisplay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Position the menu
            colorMenu.Position = UDim2.new(0, colorDisplay.AbsolutePosition.X - 160, 0, colorDisplay.AbsolutePosition.Y + 50)
            colorMenu.Visible = true
            colorMenu.Parent = UIElements.MainGui
        end
    end)
    
    -- Close the color menu when clicking outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and colorMenu.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local menuPos = colorMenu.AbsolutePosition
            local menuSize = colorMenu.AbsoluteSize
            
            if mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X or
               mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y then
                colorMenu.Visible = false
            end
        end
    end)
    
    return colorPicker, UIElements.Settings[name]
end

-- Create a dropdown setting
local function CreateDropdown(name, description, options, defaultValue, callback, parent)
    local dropdown = CreateUIElement(name.."Dropdown", "Frame", parent, {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 0.8
    })
    
    local title = CreateUIElement(name.."Title", "TextLabel", dropdown, {
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 5),
        Text = name,
        TextSize = 14,
        Font = Enum.Font.SourceSansSemibold,
        TextColor3 = UI.Settings.UITextColor,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local desc = CreateUIElement(name.."Description", "TextLabel", dropdown, {
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 25),
        Text = description,
        TextSize = 12,
        Font = Enum.Font.SourceSans,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local currentOption = defaultValue or options[1]
    
    -- Selection box
    local selector = CreateUIElement(name.."Selector", "TextButton", dropdown, {
        Size = UDim2.new(1, -10, 0, 30),
        Position = UDim2.new(0, 5, 0, 60),
        Text = currentOption,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BackgroundTransparency = 0
    })
    
    -- Dropdown arrow
    local arrow = CreateUIElement(name.."Arrow", "TextLabel", selector, {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0.5, -10),
        Text = "▼",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundTransparency = 1
    })
    
    -- Dropdown menu
    local dropdownMenu = CreateUIElement(name.."Menu", "Frame", nil, {
        Size = UDim2.new(1, -10, 0, #options * 30),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 5
    })
    
    local menuLayout = Instance.new("UIListLayout")
    menuLayout.Padding = UDim.new(0, 0)
    menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
    menuLayout.Parent = dropdownMenu
    
    -- Create option buttons
    for i, option in ipairs(options) do
        local optionButton = CreateUIElement(option.."Option", "TextButton", dropdownMenu, {
            Size = UDim2.new(1, 0, 0, 30),
            Text = option,
            TextSize = 14,
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BackgroundTransparency = option == currentOption and 0.5 or 0,
            ZIndex = 5
        })
        
        -- Select option
        optionButton.MouseButton1Click:Connect(function()
            currentOption = option
            selector.Text = option
            dropdownMenu.Visible = false
            UIElements.Settings[name] = option
            callback(option)
            
            -- Update appearance of selected item
            for _, child in pairs(dropdownMenu:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundTransparency = child.Text == option and 0.5 or 0
                end
            end
        end)
    end
    
    -- Set initial value
    UIElements.Settings[name] = currentOption
    
    -- Adjust parent size
    dropdown.Size = UDim2.new(1, 0, 0, 100)
    
    -- Toggle dropdown visibility
    selector.MouseButton1Click:Connect(function()
        dropdownMenu.Position = UDim2.new(0, selector.AbsolutePosition.X, 0, selector.AbsolutePosition.Y + selector.AbsoluteSize.Y)
        dropdownMenu.Size = UDim2.new(0, selector.AbsoluteSize.X, 0, #options * 30)
        dropdownMenu.Visible = not dropdownMenu.Visible
        dropdownMenu.Parent = UIElements.MainGui
        
        -- Update arrow
        arrow.Text = dropdownMenu.Visible and "▲" or "▼"
    end)
    
    -- Close the dropdown when clicking outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownMenu.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local menuPos = dropdownMenu.AbsolutePosition
            local menuSize = dropdownMenu.AbsoluteSize
            
            if mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X or
               mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y then
                dropdownMenu.Visible = false
                arrow.Text = "▼"
            end
        end
    end)
    
    return dropdown, UIElements.Settings[name]
end

-- Create a key bind setting
local function CreateKeybind(name, description, defaultKey, callback, parent)
    local keybind = CreateUIElement(name.."Keybind", "Frame", parent, {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 0.8
    })
    
    local title = CreateUIElement(name.."Title", "TextLabel", keybind, {
        Size = UDim2.new(1, -85, 0, 20),
        Position = UDim2.new(0, 5, 0, 5),
        Text = name,
        TextSize = 14,
        Font = Enum.Font.SourceSansSemibold,
        TextColor3 = UI.Settings.UITextColor,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local desc = CreateUIElement(name.."Description", "TextLabel", keybind, {
        Size = UDim2.new(1, -85, 0, 20),
        Position = UDim2.new(0, 5, 0, 25),
        Text = description,
        TextSize = 12,
        Font = Enum.Font.SourceSans,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local currentKey = defaultKey
    local listeningForKey = false
    
    -- Key display
    local keyDisplay = CreateUIElement(name.."Display", "TextButton", keybind, {
        Size = UDim2.new(0, 75, 0, 30),
        Position = UDim2.new(1, -80, 0.5, -15),
        Text = currentKey.Name,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BackgroundTransparency = 0
    })
    
    -- Set initial value
    UIElements.Settings[name] = currentKey
    
    -- Listen for key press
    keyDisplay.MouseButton1Click:Connect(function()
        if listeningForKey then return end
        
        listeningForKey = true
        keyDisplay.Text = "..."
        keyDisplay.TextColor3 = UI.Settings.UIAccentColor
        
        -- Create connection to capture next key press
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keyDisplay.Text = currentKey.Name
                keyDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
                UIElements.Settings[name] = currentKey
                callback(currentKey)
                listeningForKey = false
                connection:Disconnect()
            end
        end)
    end)
    
    return keybind, UIElements.Settings[name]
end

-- Create the main GUI
function UI.CreateLoadingScreen()
    -- Create loading screen GUI
    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "FulsyferLoading"
    loadingGui.ResetOnSpawn = false
    loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loadingGui.DisplayOrder = 999999 -- Set highest display order to show over everything
    
    -- Try to use protected mode if available
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(loadingGui)
            loadingGui.Parent = CoreGui
        else
            loadingGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
    
    -- Background frame
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    background.BorderSizePixel = 0
    background.Parent = loadingGui
    
    -- Add blur effect
    local blur = Instance.new("BlurEffect")
    blur.Size = 15
    blur.Parent = workspace.CurrentCamera
    
    -- Center container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 400, 0, 300)
    container.Position = UDim2.new(0.5, -200, 0.5, -150)
    container.BackgroundTransparency = 1
    container.Parent = background
    
    -- Logo
    local logoFrame = Instance.new("Frame")
    logoFrame.Name = "LogoFrame"
    logoFrame.Size = UDim2.new(0, 120, 0, 120)
    logoFrame.Position = UDim2.new(0.5, -60, 0.3, -60)
    logoFrame.BackgroundTransparency = 1
    logoFrame.Parent = container
    
    local logoText = Instance.new("TextLabel")
    logoText.Name = "LogoText"
    logoText.Size = UDim2.new(1, 0, 1, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = "★"
    logoText.TextSize = 80
    logoText.Font = Enum.Font.SourceSansBold
    logoText.TextColor3 = UI.Settings.UIAccentColor
    logoText.Parent = logoFrame
    
    -- Create pulse animation for logo
    spawn(function()
        while loadingGui.Parent do
            for i = 0.8, 1.2, 0.02 do
                if not loadingGui.Parent then break end
                logoText.TextSize = 80 * i
                logoText.Rotation = logoText.Rotation + 0.5
                wait(0.02)
            end
            for i = 1.2, 0.8, -0.02 do
                if not loadingGui.Parent then break end
                logoText.TextSize = 80 * i
                logoText.Rotation = logoText.Rotation + 0.5
                wait(0.02)
            end
        end
    end)
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 300, 0, 40)
    title.Position = UDim2.new(0.5, -150, 0.5, -20)
    title.BackgroundTransparency = 1
    title.Text = "FULSYFER ENHANCED"
    title.TextSize = 28
    title.Font = Enum.Font.SourceSansBold
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = container
    
    -- Loading bar background
    local loadingBarBg = Instance.new("Frame")
    loadingBarBg.Name = "LoadingBarBg"
    loadingBarBg.Size = UDim2.new(0, 300, 0, 10)
    loadingBarBg.Position = UDim2.new(0.5, -150, 0.6, 0)
    loadingBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    loadingBarBg.BorderSizePixel = 0
    loadingBarBg.Parent = container
    
    local loadingBarBgCorner = Instance.new("UICorner")
    loadingBarBgCorner.CornerRadius = UDim.new(0, 5)
    loadingBarBgCorner.Parent = loadingBarBg
    
    -- Loading bar fill
    local loadingBar = Instance.new("Frame")
    loadingBar.Name = "LoadingBar"
    loadingBar.Size = UDim2.new(0, 0, 1, 0)
    loadingBar.BackgroundColor3 = UI.Settings.UIAccentColor
    loadingBar.BorderSizePixel = 0
    loadingBar.Parent = loadingBarBg
    
    local loadingBarCorner = Instance.new("UICorner")
    loadingBarCorner.CornerRadius = UDim.new(0, 5)
    loadingBarCorner.Parent = loadingBar
    
    -- Loading text
    local loadingText = Instance.new("TextLabel")
    loadingText.Name = "LoadingText"
    loadingText.Size = UDim2.new(0, 300, 0, 20)
    loadingText.Position = UDim2.new(0.5, -150, 0.7, 0)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "Initializing..."
    loadingText.TextSize = 16
    loadingText.Font = Enum.Font.SourceSans
    loadingText.TextColor3 = Color3.fromRGB(180, 180, 180)
    loadingText.Parent = container
    
    -- Progress the loading bar animation
    local loadMessages = {
        "Loading assets...",
        "Setting up FOV indicator...",
        "Initializing aim assistance...",
        "Configuring ESP features...",
        "Optimizing performance...",
        "Final preparations..."
    }
    
    spawn(function()
        for i = 1, #loadMessages do
            local progress = i / #loadMessages
            loadingText.Text = loadMessages[i]
            
            local targetSize = UDim2.new(progress, 0, 1, 0)
            local tween = TweenService:Create(
                loadingBar,
                TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = targetSize}
            )
            tween:Play()
            
            wait(0.7)
        end
        
        wait(0.5)
        
        -- Fade out loading screen
        local fadeTween = TweenService:Create(
            background,
            TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 1}
        )
        fadeTween:Play()
        
        -- Fade out all elements
        for _, child in pairs(container:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("Frame") then
                TweenService:Create(
                    child,
                    TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 1, TextTransparency = 1}
                ):Play()
            end
        end
        
        -- Remove blur effect
        TweenService:Create(
            blur,
            TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = 0}
        ):Play()
        
        wait(1)
        loadingGui:Destroy()
        blur:Destroy()
    end)
    
    return loadingGui
end

function UI.CreateGUI()
    -- Check if GUI already exists
    if UIElements.MainGui then
        UIElements.MainGui.Enabled = true
        return UIElements.MainGui
    end
    
    -- Create main GUI
    local mainGui = Instance.new("ScreenGui")
    mainGui.Name = "FulsyferGUI"
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.DisplayOrder = 999999 -- Set highest display order to show over everything
    
    -- Try to use protected mode if available
    local success, error = pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(mainGui)
            mainGui.Parent = CoreGui
        else
            mainGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
    
    if not success then
        mainGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main frame
    local mainFrame = CreateUIElement("MainFrame", "Frame", mainGui, {
        Size = UDim2.new(0, 950, 0, 600),
        Position = UDim2.new(0.5, -475, 0.5, -300),
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BackgroundTransparency = 0.05
    })
    
    -- Add gradient for a more modern look
    if UI.Settings.UIGradientEnabled then
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 45, 65))
        })
        gradient.Rotation = 45
        gradient.Parent = mainFrame
    end
    
    -- Make the UI draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
    
    -- Title bar
    local titleBar = CreateUIElement("TitleBar", "Frame", mainFrame, {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BackgroundTransparency = 0
    })
    
    -- Only round the top corners
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 5)
    titleCorner.Parent = titleBar
    
    -- Apply a mask to only round the top
    local mask = CreateUIElement("Mask", "Frame", titleBar, {
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 0
    })
    
    -- Title with cool styling
    local titleContainer = CreateUIElement("TitleContainer", "Frame", titleBar, {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1
    })
    
    local titleLogo = CreateUIElement("Logo", "TextLabel", titleContainer, {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 0, 0.5, -15),
        Text = "★",
        TextSize = 24,
        Font = Enum.Font.SourceSansBold,
        TextColor3 = UI.Settings.UIAccentColor,
        BackgroundTransparency = 1
    })
    
    local title = CreateUIElement("Title", "TextLabel", titleContainer, {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        Text = "FULSYFER ENHANCED",
        TextSize = 22,
        Font = Enum.Font.SourceSansBold,
        TextColor3 = UI.Settings.UIAccentColor,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Add a glow effect to the title using multiple shadows
    local shadowOffset = 1
    for i = 1, 3 do
        local shadow = CreateUIElement("TitleShadow"..i, "TextLabel", titleContainer, {
            Size = title.Size,
            Position = UDim2.new(0, 40 + shadowOffset * i, 0, shadowOffset * i),
            Text = "FULSYFER ENHANCED",
            TextSize = 22,
            Font = Enum.Font.SourceSansBold,
            TextColor3 = Color3.fromRGB(
                math.floor(UI.Settings.UIAccentColor.R * 255 * 0.3),
                math.floor(UI.Settings.UIAccentColor.G * 255 * 0.3),
                math.floor(UI.Settings.UIAccentColor.B * 255 * 0.3)
            ),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.7,
            ZIndex = -i
        })
    end
    
    -- Close button
    local closeButton = CreateUIElement("CloseButton", "TextButton", titleBar, {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -40, 0, 0),
        Text = "✕",
        TextSize = 20,
        Font = Enum.Font.SourceSansBold,
        TextColor3 = Color3.fromRGB(255, 100, 100),
        BackgroundTransparency = 1
    })
    
    closeButton.MouseButton1Click:Connect(function()
        mainGui.Enabled = false
    end)
    
    -- Main content area
    local contentArea = CreateUIElement("ContentArea", "Frame", mainFrame, {
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1
    })
    
    -- Side menu
    local sideMenu = CreateUIElement("SideMenu", "Frame", contentArea, {
        Size = UDim2.new(0, 180, 1, 0),
        BackgroundColor3 = Color3.fromRGB(35, 35, 45),
        BackgroundTransparency = 0
    })
    
    -- Tab content area
    local tabContent = CreateUIElement("TabContent", "Frame", contentArea, {
        Size = UDim2.new(1, -180, 1, 0),
        Position = UDim2.new(0, 180, 0, 0),
        BackgroundTransparency = 1
    })
    
    -- Create a layout for the side menu
    local sideMenuLayout = Instance.new("UIListLayout")
    sideMenuLayout.Padding = UDim.new(0, 5)
    sideMenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sideMenuLayout.Parent = sideMenu
    
    -- Add padding to the side menu
    local sideMenuPadding = Instance.new("UIPadding")
    sideMenuPadding.PaddingTop = UDim.new(0, 10)
    sideMenuPadding.Parent = sideMenu
    
    -- Add a gradient to side menu for a cleaner look
    local sideMenuGradient = Instance.new("UIGradient")
    sideMenuGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
    })
    sideMenuGradient.Rotation = 90
    sideMenuGradient.Parent = sideMenu
    
    -- Store references
    UIElements.MainGui = mainGui
    UIElements.MainFrame = mainFrame
    UIElements.TabContent = tabContent
    UIElements.SideMenu = sideMenu
    
    -- Create tabs
    local tabButtons = {}
    
    -- FOV tab
    local fovButton, fovPanel = CreateTab("FOV", "⊕", sideMenu, tabContent)
    table.insert(tabButtons, fovButton)
    
    -- Aim Assist tab
    local aimButton, aimPanel = CreateTab("Aim Assist", "⊗", sideMenu, tabContent)
    table.insert(tabButtons, aimButton)
    
    -- ESP tab
    local espButton, espPanel = CreateTab("ESP", "👁", sideMenu, tabContent)
    table.insert(tabButtons, espButton)
    
    -- Settings tab
    local settingsButton, settingsPanel = CreateTab("Settings", "⚙", sideMenu, tabContent)
    table.insert(tabButtons, settingsButton)
    
    -- Function to switch tabs
    local function SwitchTab(selected)
        for _, button in ipairs(tabButtons) do
            button.BackgroundTransparency = button == selected and 0.5 or UI.Settings.UITransparency
            button.TextColor3 = button == selected and UI.Settings.UIAccentColor or UI.Settings.UITextColor
        end
        
        for _, panel in pairs(UIElements.Panels) do
            panel.Visible = false
        end
        
        UIElements.Panels[selected.Text:match("^%s*(.-)%s*$")].Visible = true
    end
    
    -- Set up tab switching
    for _, button in ipairs(tabButtons) do
        button.MouseButton1Click:Connect(function()
            SwitchTab(button)
        end)
    end
    
    -- Activate the first tab
    SwitchTab(fovButton)
    
    -- Version text at the bottom with a cooler design
    local versionContainer = CreateUIElement("VersionContainer", "Frame", sideMenu, {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 1, -35),
        BackgroundTransparency = 0.7,
        BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    })
    
    local versionCorner = Instance.new("UICorner")
    versionCorner.CornerRadius = UDim.new(0, 4)
    versionCorner.Parent = versionContainer
    
    local versionText = CreateUIElement("VersionText", "TextLabel", versionContainer, {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Text = "ENHANCED v2.0",
        TextSize = 14,
        Font = Enum.Font.SourceSansBold,
        TextColor3 = UI.Settings.UIAccentColor,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center
    })
    
    -- Add a tooltip with unload instructions
    local unloadHint = CreateUIElement("UnloadHint", "TextLabel", versionContainer, {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, 5),
        Text = "Press End key to unload",
        TextSize = 11,
        Font = Enum.Font.SourceSans,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundTransparency = 0.8,
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = false
    })
    
    local unloadCorner = Instance.new("UICorner")
    unloadCorner.CornerRadius = UDim.new(0, 4)
    unloadCorner.Parent = unloadHint
    
    versionContainer.MouseEnter:Connect(function()
        unloadHint.Visible = true
    end)
    
    versionContainer.MouseLeave:Connect(function()
        unloadHint.Visible = false
    end)
    
    -- Create content for each tab
    
    -- FOV Tab Content
    local fovSection = CreateSection("FOV Circle Settings", fovPanel)
    
    local enableFOV = CreateToggle("Enable FOV", "Displays a field of view circle", FOVIndicator.Settings.Enabled, function(value)
        FOVIndicator.Settings.Enabled = value
    end, fovPanel)
    
    local fovSize = CreateSlider("FOV Size", "Size of the FOV circle", 1, 50, FOVIndicator.Settings.Size, 1, "°", function(value)
        FOVIndicator.Settings.Size = value
    end, fovPanel)
    
    local fovColor = CreateColorPicker("FOV Color", "Color of the FOV circle", FOVIndicator.Settings.Color, function(color)
        FOVIndicator.Settings.Color = color
    end, fovPanel)
    
    local fovTransparency = CreateSlider("Transparency", "FOV circle transparency", 0, 1, FOVIndicator.Settings.Transparency, 2, "", function(value)
        FOVIndicator.Settings.Transparency = value
    end, fovPanel)
    
    local fovThickness = CreateSlider("Thickness", "FOV circle line thickness", 1, 5, FOVIndicator.Settings.Thickness, 1, "px", function(value)
        FOVIndicator.Settings.Thickness = value
    end, fovPanel)
    
    local fovFilled = CreateToggle("Filled Circle", "Fill the FOV circle", FOVIndicator.Settings.Filled, function(value)
        FOVIndicator.Settings.Filled = value
    end, fovPanel)
    
    local fovFillTransparency = CreateSlider("Fill Transparency", "Transparency of the filled circle", 0, 1, FOVIndicator.Settings.FillTransparency, 2, "", function(value)
        FOVIndicator.Settings.FillTransparency = value
    end, fovPanel)
    
    local fovRainbow = CreateToggle("Rainbow Mode", "Cycle through colors", FOVIndicator.Settings.RainbowMode, function(value)
        FOVIndicator.Settings.RainbowMode = value
    end, fovPanel)
    
    local fovPulsate = CreateToggle("Pulsate Effect", "Add a pulsating effect to the FOV", FOVIndicator.Settings.PulsateEffect, function(value)
        FOVIndicator.Settings.PulsateEffect = value
    end, fovPanel)
    
    local pulsateSpeed = CreateSlider("Pulsate Speed", "Speed of the pulsating effect", 0.1, 3, FOVIndicator.Settings.PulsateSpeed, 1, "x", function(value)
        FOVIndicator.Settings.PulsateSpeed = value
    end, fovPanel)
    
    local crosshairSection = CreateSection("Crosshair Settings", fovPanel)
    
    local enableCrosshair = CreateToggle("Enable Crosshair", "Display a crosshair at the center", FOVIndicator.Settings.CrosshairEnabled, function(value)
        FOVIndicator.Settings.CrosshairEnabled = value
    end, fovPanel)
    
    local crosshairSize = CreateSlider("Crosshair Size", "Size of the crosshair", 1, 20, FOVIndicator.Settings.CrosshairSize, 1, "px", function(value)
        FOVIndicator.Settings.CrosshairSize = value
    end, fovPanel)
    
    local crosshairThickness = CreateSlider("Crosshair Thickness", "Thickness of crosshair lines", 1, 5, FOVIndicator.Settings.CrosshairThickness, 1, "px", function(value)
        FOVIndicator.Settings.CrosshairThickness = value
    end, fovPanel)
    
    local crosshairColor = CreateColorPicker("Crosshair Color", "Color of the crosshair", FOVIndicator.Settings.CrosshairColor, function(color)
        FOVIndicator.Settings.CrosshairColor = color
    end, fovPanel)
    
    local followMouse = CreateToggle("Follow Mouse", "Makes FOV follow mouse position", FOVIndicator.Settings.FollowMouse, function(value)
        FOVIndicator.Settings.FollowMouse = value
    end, fovPanel)
    
    -- Aim Assist Tab Content
    local aimSection = CreateSection("Aim Assist Settings", aimPanel)
    
    local enableAim = CreateToggle("Enable Aim Assist", "Provides assistance when aiming", AimAssist.Settings.Enabled, function(value)
        AimAssist.Settings.Enabled = value
    end, aimPanel)
    
    local aimSensitivity = CreateSlider("Sensitivity", "Aim assist sensitivity", 0.1, 1, AimAssist.Settings.Sensitivity, 2, "", function(value)
        AimAssist.Settings.Sensitivity = value
    end, aimPanel)
    
    local aimFOV = CreateSlider("Field of View", "Aim assist field of view", 1, 30, AimAssist.Settings.FieldOfView, 1, "°", function(value)
        AimAssist.Settings.FieldOfView = value
    end, aimPanel)
    
    local aimStrength = CreateSlider("Assist Strength", "Strength of aim assistance", 0.1, 1, AimAssist.Settings.AssistStrength, 2, "", function(value)
        AimAssist.Settings.AssistStrength = value
    end, aimPanel)
    
    local targetPart = CreateDropdown("Target Part", "Which part to target", {"Head", "HumanoidRootPart", "Torso", "Random"}, AimAssist.Settings.TargetPart, function(value)
        AimAssist.Settings.TargetPart = value
    end, aimPanel)
    
    local teamCheck = CreateToggle("Team Check", "Don't target teammates", AimAssist.Settings.TeamCheck, function(value)
        AimAssist.Settings.TeamCheck = value
    end, aimPanel)
    
    local visibleCheck = CreateToggle("Visible Check", "Only target visible players", AimAssist.Settings.VisibleCheck, function(value)
        AimAssist.Settings.VisibleCheck = value
    end, aimPanel)
    
    local smoothLock = CreateToggle("Smooth Lock", "Gradually move aim to target", AimAssist.Settings.SmoothLock, function(value)
        AimAssist.Settings.SmoothLock = value
    end, aimPanel)
    
    local smoothFactor = CreateSlider("Smoothness", "How smooth the aim movement is", 0.1, 1, AimAssist.Settings.SmoothFactor, 2, "", function(value)
        AimAssist.Settings.SmoothFactor = value
    end, aimPanel)
    
    local predictMovement = CreateToggle("Predict Movement", "Predict target movement", AimAssist.Settings.PredictMovement, function(value)
        AimAssist.Settings.PredictMovement = value
    end, aimPanel)
    
    local predictionFactor = CreateSlider("Prediction Factor", "How much to predict movement", 0.1, 1, AimAssist.Settings.PredictionFactor, 2, "", function(value)
        AimAssist.Settings.PredictionFactor = value
    end, aimPanel)
    
    local lockMode = CreateToggle("Lock Mode", "Full lock vs assist mode", AimAssist.Settings.LockMode, function(value)
        AimAssist.Settings.LockMode = value
    end, aimPanel)
    
    local autoFire = CreateToggle("Auto Fire", "Auto fire when target acquired", AimAssist.Settings.AutoFire, function(value)
        AimAssist.Settings.AutoFire = value
    end, aimPanel)
    
    local toggleKey = CreateKeybind("Toggle Key", "Key to toggle aim assist", AimAssist.Settings.ToggleKey, function(key)
        AimAssist.Settings.ToggleKey = key
    end, aimPanel)
    
    -- ESP Tab Content
    local espSection = CreateSection("ESP Settings", espPanel)
    
    local enableESP = CreateToggle("Enable ESP", "Display information about players", ESP.Settings.Enabled, function(value)
        ESP.Settings.Enabled = value
    end, espPanel)
    
    local boxESP = CreateToggle("Show Boxes", "Display boxes around players", ESP.Settings.BoxEnabled, function(value)
        ESP.Settings.BoxEnabled = value
    end, espPanel)
    
    local boxColor = CreateColorPicker("Box Color", "Color of ESP boxes", ESP.Settings.BoxColor, function(color)
        ESP.Settings.BoxColor = color
    end, espPanel)
    
    local boxTransparency = CreateSlider("Box Transparency", "Box transparency", 0, 1, ESP.Settings.BoxTransparency, 2, "", function(value)
        ESP.Settings.BoxTransparency = value
    end, espPanel)
    
    local nameESP = CreateToggle("Show Names", "Display player names", ESP.Settings.NameEnabled, function(value)
        ESP.Settings.NameEnabled = value
    end, espPanel)
    
    local nameColor = CreateColorPicker("Name Color", "Color of player names", ESP.Settings.NameColor, function(color)
        ESP.Settings.NameColor = color
    end, espPanel)
    
    local distanceESP = CreateToggle("Show Distance", "Display distance to players", ESP.Settings.DistanceEnabled, function(value)
        ESP.Settings.DistanceEnabled = value
    end, espPanel)
    
    local tracerESP = CreateToggle("Show Tracers", "Display lines to players", ESP.Settings.TracerEnabled, function(value)
        ESP.Settings.TracerEnabled = value
    end, espPanel)
    
    local tracerOrigin = CreateDropdown("Tracer Origin", "Where tracers start from", {"Bottom", "Top", "Mouse"}, ESP.Settings.TracerOrigin, function(value)
        ESP.Settings.TracerOrigin = value
    end, espPanel)
    
    local tracerColor = CreateColorPicker("Tracer Color", "Color of tracers", ESP.Settings.TracerColor, function(color)
        ESP.Settings.TracerColor = color
    end, espPanel)
    
    local healthESP = CreateToggle("Show Health", "Display player health", ESP.Settings.HealthEnabled, function(value)
        ESP.Settings.HealthEnabled = value
    end, espPanel)
    
    local healthDynamicColor = CreateToggle("Dynamic Health Color", "Change health color based on value", ESP.Settings.HealthDynamicColor, function(value)
        ESP.Settings.HealthDynamicColor = value
    end, espPanel)
    
    local teamColor = CreateToggle("Use Team Colors", "Use player team colors", ESP.Settings.TeamColor, function(value)
        ESP.Settings.TeamColor = value
    end, espPanel)
    
    local teamMates = CreateToggle("Show Teammates", "Display ESP for teammates", ESP.Settings.TeamMates, function(value)
        ESP.Settings.TeamMates = value
    end, espPanel)
    
    local maxDistance = CreateSlider("Max Distance", "Maximum distance for ESP", 100, 5000, ESP.Settings.MaxDistance, 0, " studs", function(value)
        ESP.Settings.MaxDistance = value
    end, espPanel)
    
    local textCase = CreateDropdown("Text Case", "Case style for text", {"Normal", "Uppercase", "Lowercase"}, ESP.Settings.TextCase, function(value)
        ESP.Settings.TextCase = value
    end, espPanel)
    
    -- Settings Tab Content
    local generalSection = CreateSection("General Settings", settingsPanel)
    
    local uiScale = CreateSlider("UI Scale", "Scale of the user interface", 0.5, 1.5, UI.Settings.UIScale, 2, "x", function(value)
        UI.Settings.UIScale = value
        mainFrame.Size = UDim2.new(0, 950 * value, 0, 600 * value)
        mainFrame.Position = UDim2.new(0.5, -475 * value, 0.5, -300 * value)
    end, settingsPanel)
    
    local uiColor = CreateColorPicker("UI Color", "Main color of the interface", UI.Settings.UIColor, function(color)
        UI.Settings.UIColor = color
        -- Update UI colors
        for _, panel in pairs(UIElements.Panels) do
            for _, child in pairs(panel:GetDescendants()) do
                if (child:IsA("Frame") or child:IsA("TextButton")) and not child:GetAttribute("NoColorUpdate") then
                    if child.BackgroundColor3 ~= UI.Settings.UIAccentColor then
                        child.BackgroundColor3 = UI.Settings.UIColor
                    end
                end
            end
        end
    end, settingsPanel)
    
    local uiAccentColor = CreateColorPicker("Accent Color", "Accent color for highlights", UI.Settings.UIAccentColor, function(color)
        UI.Settings.UIAccentColor = color
        title.TextColor3 = color
    end, settingsPanel)
    
    local uiAnimations = CreateToggle("UI Animations", "Enable UI animations", UI.Settings.UIAnimations, function(value)
        UI.Settings.UIAnimations = value
    end, settingsPanel)
    
    local toggleKey = CreateKeybind("Menu Toggle Key", "Key to toggle the menu", UI.Settings.ToggleKey, function(key)
        UI.Settings.ToggleKey = key
    end, settingsPanel)
    
    local savesettingsSection = CreateSection("Save & Load", settingsPanel)
    
    local saveSettings = CreateUIElement("SaveButton", "TextButton", settingsPanel, {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 0),
        Text = "Save All Settings",
        TextSize = 16,
        BackgroundColor3 = UI.Settings.UIAccentColor,
        BackgroundTransparency = 0
    })
    
    -- Add a cool hover animation for buttons
    local function AddButtonEffects(button)
        -- Add a glow effect on hover
        local glowEffect = Instance.new("Frame")
        glowEffect.Name = "GlowEffect"
        glowEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        glowEffect.BackgroundTransparency = 0.9
        glowEffect.Size = UDim2.new(1, 0, 0, 2)
        glowEffect.Position = UDim2.new(0, 0, 1, -2)
        glowEffect.BorderSizePixel = 0
        glowEffect.Visible = false
        glowEffect.ZIndex = button.ZIndex + 1
        glowEffect.Parent = button
        
        -- Rounded corners for the glow
        local glowCorner = Instance.new("UICorner")
        glowCorner.CornerRadius = UDim.new(0, 4)
        glowCorner.Parent = glowEffect
        
        button.MouseEnter:Connect(function()
            -- Show the glow effect
            glowEffect.Visible = true
            
            -- Scale button slightly
            TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset + 10, button.Size.Y.Scale, button.Size.Y.Offset + 5),
                Position = UDim2.new(button.Position.X.Scale, button.Position.X.Offset - 5, button.Position.Y.Scale, button.Position.Y.Offset - 2.5),
                TextSize = button.TextSize + 2
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            -- Hide the glow effect
            glowEffect.Visible = false
            
            -- Return to normal size
            TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset - 10, button.Size.Y.Scale, button.Size.Y.Offset - 5),
                Position = UDim2.new(button.Position.X.Scale, button.Position.X.Offset + 5, button.Position.Y.Scale, button.Position.Y.Offset + 2.5),
                TextSize = button.TextSize - 2
            }):Play()
        end)
        
        -- Add click effect
        button.MouseButton1Down:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.3
            }):Play()
        end)
        
        button.MouseButton1Up:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0
            }):Play()
        end)
    end
    
    -- Apply cool effects to this button
    AddButtonEffects(saveSettings)
    
    saveSettings.MouseButton1Click:Connect(function()
        -- Save all settings
        local settings = {
            FOV = FOVIndicator.Settings,
            AimAssist = AimAssist.Settings,
            ESP = ESP.Settings,
            UI = UI.Settings
        }
        
        -- Make a deep copy to avoid reference issues
        local settingsCopy = {}
        for moduleName, moduleSettings in pairs(settings) do
            settingsCopy[moduleName] = {}
            for key, value in pairs(moduleSettings) do
                if type(value) == "table" then
                    -- Handle nested tables (like colors)
                    settingsCopy[moduleName][key] = {}
                    for k, v in pairs(value) do
                        settingsCopy[moduleName][key][k] = v
                    end
                else
                    settingsCopy[moduleName][key] = value
                end
            end
        end
        
        settings = settingsCopy
        
        Utilities.SaveSettings("FulsyferSettings", settings)
        Utilities.CreateNotification("Settings saved successfully!", 2)
    end)
    
    local loadSettings = CreateUIElement("LoadButton", "TextButton", settingsPanel, {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 60),
        Text = "Load Settings",
        TextSize = 16,
        BackgroundColor3 = UI.Settings.UIAccentColor, -- Make all buttons the same accent color
        BackgroundTransparency = 0
    })
    
    -- Apply cool effects to this button too
    AddButtonEffects(loadSettings)
    
    loadSettings.MouseButton1Click:Connect(function()
        -- Load settings
        local settings = Utilities.LoadSettings("FulsyferSettings", {})
        
        if settings.FOV then
            FOVIndicator.UpdateSettings(settings.FOV)
        end
        
        if settings.AimAssist then
            AimAssist.UpdateSettings(settings.AimAssist)
        end
        
        if settings.ESP then
            ESP.UpdateSettings(settings.ESP)
        end
        
        if settings.UI then
            for key, value in pairs(settings.UI) do
                UI.Settings[key] = value
            end
        end
        
        Utilities.CreateNotification("Settings loaded successfully!", 2)
        
        -- Update UI to reflect loaded settings
        mainGui.Enabled = false
        wait(0.1)
        UI.CreateGUI()
    end)
    
    local resetSettings = CreateUIElement("ResetButton", "TextButton", settingsPanel, {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 120),
        Text = "Reset All Settings",
        TextSize = 16,
        BackgroundColor3 = UI.Settings.UIAccentColor, -- Make all buttons the same accent color
        BackgroundTransparency = 0
    })
    
    -- Apply cool effects to reset button too
    AddButtonEffects(resetSettings)
    
    resetSettings.MouseButton1Click:Connect(function()
        -- Reset all settings to default
        FOVIndicator.Cleanup()
        AimAssist.Cleanup()
        ESP.Cleanup()
        
        FOVIndicator.Init()
        AimAssist.Init()
        ESP.Init()
        
        Utilities.CreateNotification("Settings reset to default!", 2)
        
        -- Recreate UI
        mainGui.Enabled = false
        wait(0.1)
        UI.CreateGUI()
    end)
    
    return mainGui
end

-- Toggle the visibility of the UI
function UI.ToggleUI()
    if UIElements.MainGui then
        UIElements.MainGui.Enabled = not UIElements.MainGui.Enabled
    else
        UI.CreateGUI()
    end
end

-- Initialize the UI
function UI.Init()
    -- Load saved settings if available
    local savedSettings = Utilities.LoadSettings("FulsyferSettings", {})
    
    if savedSettings.FOV then
        for key, value in pairs(savedSettings.FOV) do
            FOVIndicator.Settings[key] = value
        end
    end
    
    if savedSettings.AimAssist then
        for key, value in pairs(savedSettings.AimAssist) do
            AimAssist.Settings[key] = value
        end
    end
    
    if savedSettings.ESP then
        for key, value in pairs(savedSettings.ESP) do
            ESP.Settings[key] = value
        end
    end
    
    if savedSettings.UI then
        for key, value in pairs(savedSettings.UI) do
            UI.Settings[key] = value
        end
    end
    
    -- Show loading screen first
    UI.CreateLoadingScreen()
    
    -- Schedule the main GUI to appear after loading is done
    spawn(function()
        wait(6) -- Wait for loading screen to finish animations
        
        -- Create the actual GUI with a cool slide-in animation
        local mainGui = UI.CreateGUI()
        
        -- Animate main GUI appearance
        local mainFrame = mainGui:FindFirstChild("MainFrame")
        if mainFrame then
            mainFrame.Position = UDim2.new(0.5, -475, 1.5, 0) -- Start from below screen
            
            -- Slide up with bounce
            local tweenInfo = TweenInfo.new(
                1.2, -- Duration
                Enum.EasingStyle.Bounce, -- Bouncy style
                Enum.EasingDirection.Out -- Ease out
            )
            
            local tween = TweenService:Create(
                mainFrame,
                tweenInfo,
                {Position = UDim2.new(0.5, -475, 0.5, -300)} -- Final position
            )
            
            tween:Play()
        end
    end)
    
    -- Set up toggle key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == UI.Settings.ToggleKey then
            UI.ToggleUI()
        end
        
        -- Add End key to unload script
        if input.KeyCode == Enum.KeyCode.End then
            Main.Unload()
        end
    end)
    
    return UI
end

-- Clean up UI elements
function UI.Cleanup()
    if UIElements.MainGui then
        UIElements.MainGui:Destroy()
        UIElements.MainGui = nil
    end
    
    -- Clear stored elements
    UIElements.Tabs = {}
    UIElements.Panels = {}
end

-- ===== MAIN MODULE =====

local Main = {}

-- Initialize the scripts
function Main.Init()
    -- Display welcome message
    Utilities.CreateNotification("Fulsyfer Enhanced v2.0 loaded! Press " .. UI.Settings.ToggleKey.Name .. " to toggle UI", 5)
    
    -- Initialize all modules
    FOVIndicator.Init()
    AimAssist.Init()
    ESP.Init()
    UI.Init()
    
    return Main
end

-- Unload all scripts and clean up
function Main.Unload()
    -- Clean up modules
    FOVIndicator.Cleanup()
    AimAssist.Cleanup()
    ESP.Cleanup()
    UI.Cleanup()
    
    -- Remove all drawings
    for _, drawing in ipairs(Drawings) do
        if drawing.Remove then
            drawing:Remove()
        end
    end
    
    -- Disconnect all connections
    local connections = getconnections or get_signal_connections
    if connections then
        -- Try to disconnect everything from UserInputService
        for _, connection in pairs(connections(UserInputService.InputBegan)) do
            connection:Disconnect()
        end
        
        for _, connection in pairs(connections(UserInputService.InputEnded)) do
            connection:Disconnect()
        end
        
        for _, connection in pairs(connections(RunService.RenderStepped)) do
            if connection.Function and tostring(connection.Function):find("Fulsyfer") then
                connection:Disconnect()
            end
        end
    end
    
    -- Show unload notification
    Utilities.CreateNotification("Fulsyfer Enhanced unloaded successfully!", 3)
    
    -- Find and destroy all UI elements
    for _, instance in pairs(CoreGui:GetDescendants()) do
        if instance.Name:match("Fulsyfer") then
            instance:Destroy()
        end
    end
    
    for _, instance in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if instance.Name:match("Fulsyfer") then
            instance:Destroy()
        end
    end
    
    -- Additional cleanup for any leftover objects
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Fulsyfer") then
            table.clear(v)
        end
    end
end

-- Initialize the script
Main.Init()

-- Return the main module
return Main
