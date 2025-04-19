--[[
    LibUA - A Roblox UI Library
    Inspired by lib.ua design aesthetics
    
    This is a complete, single-file version of the LibUA library.
    All components and utilities are included in this file.
    
    Usage:
    local LibUA = require(ReplicatedStorage.LibUA_Complete)
    
    local button = LibUA.Button.new("Click Me")
    button:SetParent(playerGui.ScreenGui)
]]

local LibUA = {}

-- Utilities
local Theme = {}
local Tween = {}
local Icons = {}

--------------------------------------------------
-- Theme Utility
--------------------------------------------------

-- Default color palette inspired by lib.ua
local DEFAULT_COLORS = {
    -- Primary colors
    primary = Color3.fromRGB(38, 133, 255),    -- #2685FF - Primary blue
    primaryHover = Color3.fromRGB(66, 153, 255), -- #4299FF - Lighter blue for hover
    primaryPress = Color3.fromRGB(13, 110, 235), -- #0D6EEB - Darker blue for press
    
    -- Secondary colors
    secondary = Color3.fromRGB(130, 130, 130), -- #828282 - Medium gray
    secondaryHover = Color3.fromRGB(150, 150, 150), -- #969696 - Lighter gray for hover
    secondaryPress = Color3.fromRGB(110, 110, 110), -- #6E6E6E - Darker gray for press
    
    -- Background colors
    background = Color3.fromRGB(245, 245, 245), -- #F5F5F5 - Light background
    cardBackground = Color3.fromRGB(255, 255, 255), -- #FFFFFF - White card background
    modalBackground = Color3.fromRGB(255, 255, 255), -- #FFFFFF - White modal background
    navBackground = Color3.fromRGB(255, 255, 255), -- #FFFFFF - White navbar background
    inputBackground = Color3.fromRGB(255, 255, 255), -- #FFFFFF - Input field background
    
    -- Card states
    cardHoverBackground = Color3.fromRGB(250, 250, 250), -- #FAFAFA - Subtle hover
    cardPressBackground = Color3.fromRGB(245, 245, 245), -- #F5F5F5 - Subtle press
    
    -- Text colors
    text = Color3.fromRGB(51, 51, 51),         -- #333333 - Primary text
    textSecondary = Color3.fromRGB(102, 102, 102), -- #666666 - Secondary text
    placeholderText = Color3.fromRGB(170, 170, 170), -- #AAAAAA - Placeholder text
    
    -- Navigation items
    navItemText = Color3.fromRGB(102, 102, 102), -- #666666 - Navigation item text
    navItemHover = Color3.fromRGB(51, 51, 51), -- #333333 - Navigation item hover
    
    -- Border colors
    cardBorder = Color3.fromRGB(230, 230, 230), -- #E6E6E6 - Card border
    inputBorder = Color3.fromRGB(217, 217, 217), -- #D9D9D9 - Input border
    inputBorderHover = Color3.fromRGB(191, 191, 191), -- #BFBFBF - Input border on hover
    separator = Color3.fromRGB(230, 230, 230), -- #E6E6E6 - Separator line
    
    -- Toggle states
    toggleTrackOff = Color3.fromRGB(217, 217, 217), -- #D9D9D9 - Toggle track when off
    
    -- Option/dropdown states
    optionHoverBackground = Color3.fromRGB(245, 245, 245), -- #F5F5F5 - Option hover
    optionSelectedBackground = Color3.fromRGB(224, 240, 255), -- #E0F0FF - Option selected
    
    -- Scrollbar
    scrollbarColor = Color3.fromRGB(200, 200, 200), -- #C8C8C8 - Scrollbar color
    
    -- Disabled states
    disabledBackground = Color3.fromRGB(240, 240, 240), -- #F0F0F0 - Disabled background
    disabledText = Color3.fromRGB(180, 180, 180), -- #B4B4B4 - Disabled text
    disabledBorder = Color3.fromRGB(217, 217, 217), -- #D9D9D9 - Disabled border
    
    -- Utility colors
    success = Color3.fromRGB(46, 204, 113), -- #2ECC71 - Success green
    warning = Color3.fromRGB(241, 196, 15), -- #F1C40F - Warning yellow
    error = Color3.fromRGB(231, 76, 60), -- #E74C3C - Error red
    info = Color3.fromRGB(52, 152, 219), -- #3498DB - Info blue
    
    -- Special colors
    transparent = Color3.fromRGB(255, 255, 255) -- Used for transparency, actual color doesn't matter
}

-- Dark theme colors
local DARK_COLORS = {
    -- Primary colors (same as light theme)
    primary = Color3.fromRGB(38, 133, 255),    -- #2685FF - Primary blue
    primaryHover = Color3.fromRGB(66, 153, 255), -- #4299FF - Lighter blue for hover
    primaryPress = Color3.fromRGB(13, 110, 235), -- #0D6EEB - Darker blue for press
    
    -- Secondary colors
    secondary = Color3.fromRGB(130, 130, 130), -- #828282 - Medium gray
    secondaryHover = Color3.fromRGB(150, 150, 150), -- #969696 - Lighter gray for hover
    secondaryPress = Color3.fromRGB(110, 110, 110), -- #6E6E6E - Darker gray for press
    
    -- Background colors
    background = Color3.fromRGB(24, 24, 24), -- #181818 - Dark background
    cardBackground = Color3.fromRGB(36, 36, 36), -- #242424 - Dark card background
    modalBackground = Color3.fromRGB(36, 36, 36), -- #242424 - Dark modal background
    navBackground = Color3.fromRGB(36, 36, 36), -- #242424 - Dark navbar background
    inputBackground = Color3.fromRGB(36, 36, 36), -- #242424 - Dark input field background
    
    -- Card states
    cardHoverBackground = Color3.fromRGB(45, 45, 45), -- #2D2D2D - Subtle hover
    cardPressBackground = Color3.fromRGB(32, 32, 32), -- #202020 - Subtle press
    
    -- Text colors
    text = Color3.fromRGB(255, 255, 255),      -- #FFFFFF - Primary text
    textSecondary = Color3.fromRGB(179, 179, 179), -- #B3B3B3 - Secondary text
    placeholderText = Color3.fromRGB(128, 128, 128), -- #808080 - Placeholder text
    
    -- Navigation items
    navItemText = Color3.fromRGB(179, 179, 179), -- #B3B3B3 - Navigation item text
    navItemHover = Color3.fromRGB(255, 255, 255), -- #FFFFFF - Navigation item hover
    
    -- Border colors
    cardBorder = Color3.fromRGB(48, 48, 48), -- #303030 - Card border
    inputBorder = Color3.fromRGB(64, 64, 64), -- #404040 - Input border
    inputBorderHover = Color3.fromRGB(96, 96, 96), -- #606060 - Input border on hover
    separator = Color3.fromRGB(48, 48, 48), -- #303030 - Separator line
    
    -- Toggle states
    toggleTrackOff = Color3.fromRGB(64, 64, 64), -- #404040 - Toggle track when off
    
    -- Option/dropdown states
    optionHoverBackground = Color3.fromRGB(45, 45, 45), -- #2D2D2D - Option hover
    optionSelectedBackground = Color3.fromRGB(20, 56, 93), -- #14385D - Option selected
    
    -- Scrollbar
    scrollbarColor = Color3.fromRGB(96, 96, 96), -- #606060 - Scrollbar color
    
    -- Disabled states
    disabledBackground = Color3.fromRGB(45, 45, 45), -- #2D2D2D - Disabled background
    disabledText = Color3.fromRGB(102, 102, 102), -- #666666 - Disabled text
    disabledBorder = Color3.fromRGB(64, 64, 64), -- #404040 - Disabled border
    
    -- Utility colors (same as light theme)
    success = Color3.fromRGB(46, 204, 113), -- #2ECC71 - Success green
    warning = Color3.fromRGB(241, 196, 15), -- #F1C40F - Warning yellow
    error = Color3.fromRGB(231, 76, 60), -- #E74C3C - Error red
    info = Color3.fromRGB(52, 152, 219), -- #3498DB - Info blue
    
    -- Special colors
    transparent = Color3.fromRGB(0, 0, 0) -- Used for transparency, actual color doesn't matter
}

-- Current theme
local currentTheme = "light"
local customTheme = nil

-- Get the current theme colors
function Theme.GetColors()
    if customTheme then
        return customTheme
    end
    
    return currentTheme == "light" and DEFAULT_COLORS or DARK_COLORS
end

-- Set the theme to light or dark
function Theme.SetTheme(theme)
    if theme ~= "light" and theme ~= "dark" then
        error("Theme must be 'light' or 'dark'")
        return
    end
    
    currentTheme = theme
    customTheme = nil -- Reset custom theme
    
    -- Return the theme object for chaining
    return Theme
end

-- Get current theme name
function Theme.GetTheme()
    return currentTheme
end

-- Set a custom theme by providing a table of colors
function Theme.SetCustomTheme(colors)
    -- Start with default colors for the current theme
    local baseColors = currentTheme == "light" and DEFAULT_COLORS or DARK_COLORS
    
    -- Create a new theme by merging the base colors with the provided custom colors
    customTheme = {}
    
    -- Copy all base colors
    for key, value in pairs(baseColors) do
        customTheme[key] = value
    end
    
    -- Override with custom colors
    for key, value in pairs(colors) do
        customTheme[key] = value
    end
    
    -- Return the theme object for chaining
    return Theme
end

-- Reset to default theme
function Theme.ResetTheme()
    customTheme = nil
    
    -- Return the theme object for chaining
    return Theme
end

-- Helper function to get color with alpha
function Theme.GetColorWithAlpha(colorName, alpha)
    local color = Theme.GetColors()[colorName]
    return Color3.fromRGB(color.R, color.G, color.B), alpha
end

-- Helper function to darken a color
function Theme.DarkenColor(color, amount)
    amount = math.clamp(amount or 0.1, 0, 1)
    return Color3.new(
        math.clamp(color.R - amount, 0, 1),
        math.clamp(color.G - amount, 0, 1),
        math.clamp(color.B - amount, 0, 1)
    )
end

-- Helper function to lighten a color
function Theme.LightenColor(color, amount)
    amount = math.clamp(amount or 0.1, 0, 1)
    return Color3.new(
        math.clamp(color.R + amount, 0, 1),
        math.clamp(color.G + amount, 0, 1),
        math.clamp(color.B + amount, 0, 1)
    )
end

--------------------------------------------------
-- Tween Utility
--------------------------------------------------
local TweenService = game:GetService("TweenService")

-- Default tween settings
local DEFAULT_EASING_STYLE = Enum.EasingStyle.Quad
local DEFAULT_EASING_DIRECTION = Enum.EasingDirection.Out

-- Create a new tween
function Tween.Create(instance, duration, properties, easingStyle, easingDirection)
    -- Default parameters
    easingStyle = easingStyle or DEFAULT_EASING_STYLE
    easingDirection = easingDirection or DEFAULT_EASING_DIRECTION
    
    -- Create tween info
    local tweenInfo = TweenInfo.new(
        duration,
        easingStyle,
        easingDirection
    )
    
    -- Create and return the tween
    return TweenService:Create(instance, tweenInfo, properties)
end

-- Create and play a tween immediately
function Tween.Play(instance, duration, properties, easingStyle, easingDirection)
    local tween = Tween.Create(instance, duration, properties, easingStyle, easingDirection)
    tween:Play()
    return tween
end

-- Create a sequence of tweens that play one after another
function Tween.Sequence(tweens)
    local sequence = {}
    
    -- Function to play the sequence
    function sequence:Play()
        if #tweens == 0 then return end
        
        local currentIndex = 1
        
        -- Play the first tween
        tweens[currentIndex]:Play()
        
        -- Connect to the Completed event to play subsequent tweens
        local function playNext()
            currentIndex = currentIndex + 1
            
            if currentIndex <= #tweens then
                tweens[currentIndex]:Play()
            end
        end
        
        -- Connect Completed events for all but the last tween
        for i = 1, #tweens - 1 do
            tweens[i].Completed:Connect(function()
                if currentIndex == i then
                    playNext()
                end
            end)
        end
    end
    
    -- Function to cancel the sequence
    function sequence:Cancel()
        for _, tween in ipairs(tweens) do
            tween:Cancel()
        end
    end
    
    return sequence
end

-- Create a parallel group of tweens that play simultaneously
function Tween.Group(tweens)
    local group = {}
    
    -- Function to play the group
    function group:Play()
        for _, tween in ipairs(tweens) do
            tween:Play()
        end
    end
    
    -- Function to cancel the group
    function group:Cancel()
        for _, tween in ipairs(tweens) do
            tween:Cancel()
        end
    end
    
    return group
end

-- Create a spring animation (bouncy effect)
function Tween.Spring(instance, duration, properties, tension, damping)
    tension = tension or 40 -- Higher = more springy
    damping = damping or 8 -- Higher = less bounce
    
    local springTween = Tween.Create(
        instance,
        duration,
        properties,
        Enum.EasingStyle.Elastic,
        Enum.EasingDirection.Out
    )
    
    return springTween
end

-- Create a bouncy animation (for things like buttons)
function Tween.Bounce(instance, scale)
    scale = scale or 0.9
    
    -- Scale down
    local downTween = Tween.Create(
        instance,
        0.1,
        {
            Size = instance.Size * scale,
            Position = instance.Position + UDim2.new(0, instance.AbsoluteSize.X * (1 - scale) / 2, 0, instance.AbsoluteSize.Y * (1 - scale) / 2)
        },
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    -- Scale back up
    local upTween = Tween.Create(
        instance,
        0.2,
        {
            Size = instance.Size,
            Position = instance.Position
        },
        Enum.EasingStyle.Elastic,
        Enum.EasingDirection.Out
    )
    
    -- Create sequence
    return Tween.Sequence({downTween, upTween})
end

-- Fade in animation
function Tween.FadeIn(instance, duration, initialTransparency)
    duration = duration or 0.3
    
    -- Store original transparency values
    local originalTransparency = {}
    if instance:IsA("GuiObject") then
        originalTransparency.BackgroundTransparency = instance.BackgroundTransparency
        
        if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
            originalTransparency.TextTransparency = instance.TextTransparency
        end
        
        if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            originalTransparency.ImageTransparency = instance.ImageTransparency
        end
    end
    
    -- Set initial transparency
    if initialTransparency then
        if instance:IsA("GuiObject") then
            instance.BackgroundTransparency = initialTransparency
            
            if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
                instance.TextTransparency = initialTransparency
            end
            
            if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
                instance.ImageTransparency = initialTransparency
            end
        end
    end
    
    -- Create properties for tween
    local properties = {}
    for property, value in pairs(originalTransparency) do
        properties[property] = value
    end
    
    -- Create and return tween
    return Tween.Create(instance, duration, properties)
end

-- Fade out animation
function Tween.FadeOut(instance, duration, targetTransparency)
    duration = duration or 0.3
    targetTransparency = targetTransparency or 1
    
    -- Create properties for tween
    local properties = {}
    if instance:IsA("GuiObject") then
        properties.BackgroundTransparency = targetTransparency
        
        if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
            properties.TextTransparency = targetTransparency
        end
        
        if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            properties.ImageTransparency = targetTransparency
        end
    end
    
    -- Create and return tween
    return Tween.Create(instance, duration, properties)
end

-- Chain multiple tweens with callbacks
function Tween.Chain(instance, tweenConfigs)
    local chain = {}
    local tweens = {}
    
    for i, config in ipairs(tweenConfigs) do
        local tween = Tween.Create(
            instance,
            config.Duration or 0.3,
            config.Properties or {},
            config.EasingStyle,
            config.EasingDirection
        )
        
        table.insert(tweens, tween)
    end
    
    function chain:Play()
        if #tweens == 0 then return end
        
        local currentIndex = 1
        local function playNext()
            if currentIndex <= #tweens then
                local currentTween = tweens[currentIndex]
                local currentConfig = tweenConfigs[currentIndex]
                
                -- Play tween
                currentTween:Play()
                
                -- Run before callback if exists
                if currentConfig.Before then
                    currentConfig.Before()
                end
                
                -- Set up completed callback
                currentTween.Completed:Connect(function()
                    -- Run after callback if exists
                    if currentConfig.After then
                        currentConfig.After()
                    end
                    
                    -- Move to next tween
                    currentIndex = currentIndex + 1
                    playNext()
                end)
            end
        end
        
        playNext()
    end
    
    function chain:Cancel()
        for _, tween in ipairs(tweens) do
            tween:Cancel()
        end
    end
    
    return chain
end

--------------------------------------------------
-- Icons Utility
--------------------------------------------------

-- Main icon collection
local SVG_ICONS = {
    -- Navigation icons
    ["home"] = "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6",
    ["menu"] = "M4 6h16M4 12h16M4 18h16",
    ["settings"] = "M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z;M15 12a3 3 0 11-6 0 3 3 0 016 0z",
    ["user"] = "M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z",
    ["bell"] = "M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9",
    
    -- Action icons
    ["check"] = "M5 13l4 4L19 7",
    ["x"] = "M6 18L18 6M6 6l12 12",
    ["plus"] = "M12 4v16m8-8H4",
    ["minus"] = "M20 12H4",
    ["search"] = "M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z",
    ["trash"] = "M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16",
    ["edit"] = "M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z",
    ["save"] = "M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4",
    
    -- Direction icons
    ["chevron-down"] = "M19 9l-7 7-7-7",
    ["chevron-up"] = "M5 15l7-7 7 7",
    ["chevron-left"] = "M15 19l-7-7 7-7",
    ["chevron-right"] = "M9 5l7 7-7 7",
    ["arrow-right"] = "M14 5l7 7m0 0l-7 7m7-7H3",
    ["arrow-left"] = "M10 19l-7-7m0 0l7-7m-7 7h18",
    
    -- Form icons
    ["eye"] = "M15 12a3 3 0 11-6 0 3 3 0 016 0z;M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z",
    ["eye-off"] = "M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l18 18",
    ["calendar"] = "M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z",
    ["clock"] = "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z",
    
    -- Communication icons
    ["mail"] = "M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z",
    ["phone"] = "M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z",
    ["share"] = "M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z",
    
    -- Status icons
    ["check-circle"] = "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z",
    ["exclamation"] = "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z",
    ["information"] = "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z",
    ["ban"] = "M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636",
    
    -- Misc icons
    ["cog"] = "M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z;M15 12a3 3 0 11-6 0 3 3 0 016 0z",
    ["heart"] = "M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z",
    ["star"] = "M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z",
    ["dots-horizontal"] = "M5 12h.01M12 12h.01M19 12h.01M6 12a1 1 0 11-2 0 1 1 0 012 0zm7 0a1 1 0 11-2 0 1 1 0 012 0zm7 0a1 1 0 11-2 0 1 1 0 012 0z",
    ["refresh"] = "M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
}

-- Default settings
local DEFAULT_ICON_COLOR = Color3.fromRGB(0, 0, 0)
local DEFAULT_ICON_SIZE = 24
local DEFAULT_STROKE_WIDTH = 2

-- Convert SVG path to Roblox Image ID
local svgCache = {}

-- Get icon by name
function Icons.GetIcon(name)
    -- Check if icon exists
    if not SVG_ICONS[name] then
        warn("Icon '" .. name .. "' not found in icon library. Using placeholder.")
        return "rbxassetid://3926305904" -- Roblox default icons asset ID
    end
    
    -- Convert SVG path to image ID (for now we use a mock implementation)
    -- In a real implementation, you would either:
    -- 1. Pre-convert SVGs to Roblox assets and map names to IDs
    -- 2. Use a system to render SVGs dynamically
    
    -- Temporary implementation using hardcoded IDs
    local iconMap = {
        ["check"] = "rbxassetid://3926305904",
        ["x"] = "rbxassetid://3926305904",
        ["plus"] = "rbxassetid://3926307971",
        ["minus"] = "rbxassetid://3926307971",
        ["chevron-down"] = "rbxassetid://3926305904",
        ["chevron-up"] = "rbxassetid://3926305904",
        ["chevron-left"] = "rbxassetid://3926305904",
        ["chevron-right"] = "rbxassetid://3926305904",
        ["search"] = "rbxassetid://3926305904",
        ["home"] = "rbxassetid://3926305904",
        ["settings"] = "rbxassetid://3926307971",
        ["user"] = "rbxassetid://3926307971",
        ["menu"] = "rbxassetid://3926305904",
        ["heart"] = "rbxassetid://3926307971",
        ["star"] = "rbxassetid://3926307971",
        ["mail"] = "rbxassetid://3926307971",
        ["trash"] = "rbxassetid://3926307971",
        ["edit"] = "rbxassetid://3926307971",
        ["save"] = "rbxassetid://3926305904",
        ["eye"] = "rbxassetid://3926305904",
        ["eye-off"] = "rbxassetid://3926305904",
        ["calendar"] = "rbxassetid://3926305904",
        ["clock"] = "rbxassetid://3926305904",
        ["bell"] = "rbxassetid://3926307971",
        ["phone"] = "rbxassetid://3926307971",
        ["share"] = "rbxassetid://3926305904",
        ["check-circle"] = "rbxassetid://3926305904",
        ["exclamation"] = "rbxassetid://3926305904",
        ["information"] = "rbxassetid://3926305904",
        ["ban"] = "rbxassetid://3926305904",
        ["cog"] = "rbxassetid://3926307971",
        ["dots-horizontal"] = "rbxassetid://3926305904",
        ["refresh"] = "rbxassetid://3926307971",
        ["arrow-right"] = "rbxassetid://3926305904",
        ["arrow-left"] = "rbxassetid://3926305904"
    }
    
    -- Image Rects for Roblox default icon asset
    local iconRects = {
        ["check"] = Rect.new(684, 44, 724, 84),
        ["x"] = Rect.new(924, 724, 964, 764),
        ["plus"] = Rect.new(84, 44, 124, 84),
        ["minus"] = Rect.new(164, 44, 204, 84),
        ["chevron-down"] = Rect.new(444, 844, 484, 884),
        ["chevron-up"] = Rect.new(564, 844, 604, 884),
        ["chevron-left"] = Rect.new(484, 844, 524, 884),
        ["chevron-right"] = Rect.new(524, 844, 564, 884),
        ["search"] = Rect.new(964, 324, 1004, 364),
        ["home"] = Rect.new(964, 44, 1004, 84),
        ["settings"] = Rect.new(144, 4, 184, 44),
        ["user"] = Rect.new(686, 324, 726, 364),
        ["menu"] = Rect.new(884, 684, 924, 724),
        ["heart"] = Rect.new(544, 44, 584, 84),
        ["star"] = Rect.new(444, 44, 484, 84),
        ["mail"] = Rect.new(44, 284, 84, 324),
        ["trash"] = Rect.new(364, 404, 404, 444),
        ["edit"] = Rect.new(84, 644, 124, 684),
        ["save"] = Rect.new(4, 684, 44, 724),
        ["eye"] = Rect.new(564, 44, 604, 84),
        ["eye-off"] = Rect.new(604, 44, 644, 84),
        ["calendar"] = Rect.new(364, 524, 404, 564),
        ["clock"] = Rect.new(212, 44, 252, 84),
        ["bell"] = Rect.new(764, 364, 804, 404),
        ["phone"] = Rect.new(924, 564, 964, 604),
        ["share"] = Rect.new(884, 284, 924, 324),
        ["check-circle"] = Rect.new(804, 84, 844, 124),
        ["exclamation"] = Rect.new(44, 324, 84, 364),
        ["information"] = Rect.new(284, 44, 324, 84),
        ["ban"] = Rect.new(124, 644, 164, 684),
        ["cog"] = Rect.new(464, 4, 504, 44), 
        ["dots-horizontal"] = Rect.new(164, 484, 204, 524),
        ["refresh"] = Rect.new(804, 124, 844, 164),
        ["arrow-right"] = Rect.new(364, 84, 404, 124),
        ["arrow-left"] = Rect.new(324, 84, 364, 124)
    }
    
    -- Return the corresponding icon ID
    if iconMap[name] then
        return iconMap[name], iconRects[name]
    else
        return "rbxassetid://3926305904", Rect.new(564, 284, 604, 324) -- Question mark icon as fallback
    end
end

-- Create an icon instance
function Icons.Create(parent, name, options)
    options = options or {}
    
    -- Create icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon_" .. name
    icon.Size = UDim2.new(0, options.Size or DEFAULT_ICON_SIZE, 0, options.Size or DEFAULT_ICON_SIZE)
    icon.Position = options.Position or UDim2.new(0, 0, 0, 0)
    icon.AnchorPoint = options.AnchorPoint or Vector2.new(0, 0)
    icon.BackgroundTransparency = 1
    icon.BorderSizePixel = 0
    
    -- Get icon image ID and rect
    local imageId, imageRect = Icons.GetIcon(name)
    icon.Image = imageId
    
    -- Apply rect if available
    if imageRect then
        icon.ImageRectOffset = Vector2.new(imageRect.Min.X, imageRect.Min.Y)
        icon.ImageRectSize = Vector2.new(imageRect.Width, imageRect.Height)
    end
    
    icon.ImageColor3 = options.Color or DEFAULT_ICON_COLOR
    
    -- Apply other options
    if options.Rotation then
        icon.Rotation = options.Rotation
    end
    
    if options.ZIndex then
        icon.ZIndex = options.ZIndex
    end
    
    -- Parent the icon
    if parent then
        icon.Parent = parent
    end
    
    return icon
end

-- Get all available icon names
function Icons.GetAvailableIcons()
    local iconNames = {}
    for name, _ in pairs(SVG_ICONS) do
        table.insert(iconNames, name)
    end
    return iconNames
end

--------------------------------------------------
-- Button Component
--------------------------------------------------
local Button = {}
Button.__index = Button

-- Create a new button
function Button.new(text, options)
    local self = setmetatable({}, Button)
    
    -- Default options
    options = options or {}
    self.Text = text or "Button"
    self.Size = options.Size or UDim2.new(0, 200, 0, 50)
    self.Position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
    self.AnchorPoint = options.AnchorPoint or Vector2.new(0.5, 0.5)
    self.TextSize = options.TextSize or 16
    self.Variant = options.Variant or "primary" -- primary, secondary, outline, text
    self.Rounded = options.Rounded == nil and true or options.Rounded
    self.Disabled = options.Disabled or false
    
    -- Create the button instance
    self:_create()
    
    return self
end

-- Internal function to create the button UI
function Button:_create()
    -- Button container
    self.Instance = Instance.new("TextButton")
    self.Instance.Name = "LibUAButton"
    self.Instance.Size = self.Size
    self.Instance.Position = self.Position
    self.Instance.AnchorPoint = self.AnchorPoint
    self.Instance.BackgroundColor3 = self:_getBackgroundColor()
    self.Instance.TextColor3 = self:_getTextColor()
    self.Instance.Font = Enum.Font.GothamMedium
    self.Instance.TextSize = self.TextSize
    self.Instance.Text = self.Text
    self.Instance.AutoButtonColor = false
    self.Instance.ClipsDescendants = true
    
    -- Apply rounded corners if needed
    if self.Rounded then
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 8)
        uiCorner.Parent = self.Instance
    end
    
    -- Add padding for text
    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingLeft = UDim.new(0, 16)
    uiPadding.PaddingRight = UDim.new(0, 16)
    uiPadding.Parent = self.Instance
    
    -- Apply styles based on variant
    self:_applyVariantStyles()
    
    -- Set up button states
    self:_setupButtonStates()
    
    -- Create Clicked event
    self.Clicked = Instance.new("BindableEvent")
end

-- Get background color based on variant
function Button:_getBackgroundColor()
    local colors = Theme.GetColors()
    
    if self.Disabled then
        return colors.disabledBackground
    end
    
    if self.Variant == "primary" then
        return colors.primary
    elseif self.Variant == "secondary" then
        return colors.secondary
    elseif self.Variant == "outline" or self.Variant == "text" then
        return colors.transparent
    end
    
    return colors.primary
end

-- Get text color based on variant
function Button:_getTextColor()
    local colors = Theme.GetColors()
    
    if self.Disabled then
        return colors.disabledText
    end
    
    if self.Variant == "primary" then
        return colors.primaryText
    elseif self.Variant == "secondary" then
        return colors.secondaryText
    elseif self.Variant == "outline" or self.Variant == "text" then
        return colors.primary
    end
    
    return colors.primaryText
end

-- Apply styles based on button variant
function Button:_applyVariantStyles()
    if self.Variant == "outline" then
        -- Add border
        local border = Instance.new("UIStroke")
        border.Color = Theme.GetColors().primary
        border.Thickness = 1
        border.Parent = self.Instance
    elseif self.Variant == "text" then
        -- Text buttons have no visible container
        self.Instance.BackgroundTransparency = 1
    end
    
    -- Apply disabled state
    if self.Disabled then
        self.Instance.BackgroundColor3 = Theme.GetColors().disabledBackground
        self.Instance.TextColor3 = Theme.GetColors().disabledText
    end
end

-- Set up button hover, press states
function Button:_setupButtonStates()
    -- Skip if disabled
    if self.Disabled then
        self.Instance.Text = self.Text
        return
    end
    
    -- Hover effect
    self.Instance.MouseEnter:Connect(function()
        if self.Disabled then return end
        
        local hoverTween = Tween.Create(self.Instance, 0.2, {
            BackgroundColor3 = self:_getHoverColor()
        })
        hoverTween:Play()
    end)
    
    -- Mouse leave effect
    self.Instance.MouseLeave:Connect(function()
        if self.Disabled then return end
        
        local leaveTween = Tween.Create(self.Instance, 0.2, {
            BackgroundColor3 = self:_getBackgroundColor()
        })
        leaveTween:Play()
    end)
    
    -- Click effect (ripple)
    self.Instance.MouseButton1Down:Connect(function()
        if self.Disabled then return end
        
        -- Create ripple effect
        self:_createRipple()
        
        -- Darken button temporarily
        local pressTween = Tween.Create(self.Instance, 0.1, {
            BackgroundColor3 = self:_getPressColor()
        })
        pressTween:Play()
    end)
    
    -- Mouse up effect
    self.Instance.MouseButton1Up:Connect(function()
        if self.Disabled then return end
        
        local releaseTween = Tween.Create(self.Instance, 0.1, {
            BackgroundColor3 = self:_getHoverColor()
        })
        releaseTween:Play()
    end)
    
    -- Button clicked event
    self.Instance.MouseButton1Click:Connect(function()
        if self.Disabled then return end
        
        self.Clicked:Fire()
    end)
end

-- Create ripple effect on click
function Button:_createRipple()
    -- Only for primary and secondary buttons
    if self.Variant == "outline" or self.Variant == "text" then
        return
    end
    
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    
    -- Get mouse position relative to button
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    local relX = mouse.X - self.Instance.AbsolutePosition.X
    local relY = mouse.Y - self.Instance.AbsolutePosition.Y
    
    -- Position ripple at click point
    ripple.Position = UDim2.new(0, relX, 0, relY)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    
    -- Create a circular shape
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    -- Add to button
    ripple.Parent = self.Instance
    
    -- Animate the ripple
    local buttonSize = math.max(self.Instance.AbsoluteSize.X, self.Instance.AbsoluteSize.Y) * 2
    local growTween = Tween.Create(ripple, 0.5, {
        Size = UDim2.new(0, buttonSize, 0, buttonSize),
        BackgroundTransparency = 1
    })
    
    growTween:Play()
    
    -- Clean up after animation
    growTween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

-- Get button hover color based on variant
function Button:_getHoverColor()
    local colors = Theme.GetColors()
    
    if self.Variant == "primary" then
        return colors.primaryHover
    elseif self.Variant == "secondary" then
        return colors.secondaryHover
    elseif self.Variant == "outline" then
        return colors.outlineHover
    elseif self.Variant == "text" then
        return colors.textHover
    end
    
    return colors.primaryHover
end

-- Get button press color
function Button:_getPressColor()
    local colors = Theme.GetColors()
    
    if self.Variant == "primary" then
        return colors.primaryPress
    elseif self.Variant == "secondary" then
        return colors.secondaryPress
    elseif self.Variant == "outline" then
        return colors.outlinePress
    elseif self.Variant == "text" then
        return colors.textPress
    end
    
    return colors.primaryPress
end

-- Set the button's parent
function Button:SetParent(parent)
    self.Instance.Parent = parent
    return self
end

-- Set button text
function Button:SetText(text)
    self.Text = text
    self.Instance.Text = text
    return self
end

-- Set button's position
function Button:SetPosition(position)
    self.Position = position
    self.Instance.Position = position
    return self
end

-- Set button's size
function Button:SetSize(size)
    self.Size = size
    self.Instance.Size = size
    return self
end

-- Enable or disable the button
function Button:SetEnabled(enabled)
    self.Disabled = not enabled
    
    -- Update visuals
    self.Instance.BackgroundColor3 = self:_getBackgroundColor()
    self.Instance.TextColor3 = self:_getTextColor()
    
    return self
end

-- Clean up the button
function Button:Destroy()
    if self.Instance then
        self.Instance:Destroy()
        self.Instance = nil
    end
    
    if self.Clicked then
        self.Clicked:Destroy()
        self.Clicked = nil
    end
end

--------------------------------------------------
-- TextInput Component
--------------------------------------------------
local TextInput = {}
TextInput.__index = TextInput

-- Create a new text input
function TextInput.new(options)
    local self = setmetatable({}, TextInput)
    
    -- Default options
    options = options or {}
    self.Size = options.Size or UDim2.new(0, 300, 0, 40)
    self.Position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
    self.AnchorPoint = options.AnchorPoint or Vector2.new(0.5, 0.5)
    self.Placeholder = options.Placeholder or "Enter text..."
    self.TextSize = options.TextSize or 16
    self.Label = options.Label
    self.Value = options.Value or ""
    self.Disabled = options.Disabled or false
    self.PasswordMode = options.PasswordMode or false
    self.ClearButton = options.ClearButton == nil and true or options.ClearButton
    self.MaxLength = options.MaxLength
    self.Variant = options.Variant or "default" -- default, outlined, underlined
    
    -- Create the text input instance
    self:_create()
    
    return self
end

-- Internal function to create the text input UI
function TextInput:_create()
    -- Container
    self.Container = Instance.new("Frame")
    self.Container.Name = "LibUATextInput"
    self.Container.Size = self.Size
    self.Container.Position = self.Position
    self.Container.AnchorPoint = self.AnchorPoint
    self.Container.BackgroundTransparency = 1
    
    -- Create label if specified
    if self.Label then
        self.LabelInstance = Instance.new("TextLabel")
        self.LabelInstance.Name = "Label"
        self.LabelInstance.Size = UDim2.new(1, 0, 0, 20)
        self.LabelInstance.Position = UDim2.new(0, 0, 0, -24)
        self.LabelInstance.BackgroundTransparency = 1
        self.LabelInstance.Font = Enum.Font.GothamMedium
        self.LabelInstance.TextSize = self.TextSize - 2
        self.LabelInstance.TextColor3 = Theme.GetColors().textSecondary
        self.LabelInstance.TextXAlignment = Enum.TextXAlignment.Left
        self.LabelInstance.Text = self.Label
        self.LabelInstance.Parent = self.Container
    end
    
    -- Input box background
    self.Background = Instance.new("Frame")
    self.Background.Name = "Background"
    self.Background.Size = UDim2.new(1, 0, 0, self.Size.Y.Offset)
    self.Background.Position = UDim2.new(0, 0, 0, 0)
    self.Background.BackgroundColor3 = Theme.GetColors().inputBackground
    self.Background.BorderSizePixel = 0
    self.Background.ClipsDescendants = true
    self.Background.Parent = self.Container
    
    -- Add rounded corners
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = self.Background
    
    -- Add border
    self.Border = Instance.new("UIStroke")
    self.Border.Color = Theme.GetColors().inputBorder
    self.Border.Thickness = 1
    self.Border.Parent = self.Background
    
    -- TextBox
    self.Input = Instance.new("TextBox")
    self.Input.Name = "Input"
    self.Input.Size = UDim2.new(1, -20, 1, 0)
    self.Input.Position = UDim2.new(0, 10, 0, 0)
    self.Input.BackgroundTransparency = 1
    self.Input.Font = Enum.Font.Gotham
    self.Input.TextSize = self.TextSize
    self.Input.TextColor3 = Theme.GetColors().text
    self.Input.PlaceholderText = self.Placeholder
    self.Input.PlaceholderColor3 = Theme.GetColors().placeholderText
    self.Input.Text = self.Value
    self.Input.ClearTextOnFocus = false
    self.Input.ClipsDescendants = true
    self.Input.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Handle password mode
    if self.PasswordMode then
        self.Input.TextTransparency = 1
        
        -- Create masked display
        self.MaskedDisplay = Instance.new("TextLabel")
        self.MaskedDisplay.Name = "MaskedDisplay"
        self.MaskedDisplay.Size = UDim2.new(1, 0, 1, 0)
        self.MaskedDisplay.Position = UDim2.new(0, 0, 0, 0)
        self.MaskedDisplay.BackgroundTransparency = 1
        self.MaskedDisplay.Font = self.Input.Font
        self.MaskedDisplay.TextSize = self.Input.TextSize
        self.MaskedDisplay.TextColor3 = self.Input.TextColor3
        self.MaskedDisplay.TextXAlignment = Enum.TextXAlignment.Left
        self.MaskedDisplay.Parent = self.Input
        
        -- Update masked text when input changes
        self.Input:GetPropertyChangedSignal("Text"):Connect(function()
            self:_updateMaskedText()
        end)
        
        -- Initial masked text
        self:_updateMaskedText()
    end
    
    -- Clear button
    if self.ClearButton then
        self.ClearButtonInstance = Instance.new("TextButton")
        self.ClearButtonInstance.Name = "ClearButton"
        self.ClearButtonInstance.Size = UDim2.new(0, 20, 0, 20)
        self.ClearButtonInstance.Position = UDim2.new(1, -25, 0.5, 0)
        self.ClearButtonInstance.AnchorPoint = Vector2.new(0.5, 0.5)
        self.ClearButtonInstance.BackgroundTransparency = 1
        self.ClearButtonInstance.Text = "×" -- Using a simple X character
        self.ClearButtonInstance.TextSize = self.TextSize + 4
        self.ClearButtonInstance.TextColor3 = Theme.GetColors().textSecondary
        self.ClearButtonInstance.Visible = #self.Value > 0
        self.ClearButtonInstance.Parent = self.Background
        
        -- Clear button functionality
        self.ClearButtonInstance.MouseButton1Click:Connect(function()
            self.Input.Text = ""
            self.Value = ""
            self.ClearButtonInstance.Visible = false
            self.TextChanged:Fire("")
            self.Input:CaptureFocus()
        end)
        
        -- Show/hide clear button based on text
        self.Input:GetPropertyChangedSignal("Text"):Connect(function()
            self.ClearButtonInstance.Visible = #self.Input.Text > 0
        end)
    end
    
    -- Apply variant-specific styling
    self:_applyVariantStyles()
    
    -- Make the Input a direct child of Background
    self.Input.Parent = self.Background
    
    -- Set up input states
    self:_setupInputStates()
    
    -- Create events
    self.TextChanged = Instance.new("BindableEvent")
    self.FocusLost = Instance.new("BindableEvent")
    self.Focused = Instance.new("BindableEvent")
    
    -- Connect input events
    self.Input:GetPropertyChangedSignal("Text"):Connect(function()
        local text = self.Input.Text
        
        -- Handle max length
        if self.MaxLength and #text > self.MaxLength then
            text = string.sub(text, 1, self.MaxLength)
            self.Input.Text = text
        end
        
        self.Value = text
        self.TextChanged:Fire(text)
    end)
    
    self.Input.FocusLost:Connect(function(enterPressed)
        self.FocusLost:Fire(self.Value, enterPressed)
    end)
    
    self.Input.Focused:Connect(function()
        self.Focused:Fire()
    end)
    
    -- Apply disabled state if needed
    if self.Disabled then
        self:SetEnabled(false)
    end
end

-- Update masked text for password input
function TextInput:_updateMaskedText()
    if self.PasswordMode and self.MaskedDisplay then
        local maskChar = "•"
        local maskedText = string.rep(maskChar, #self.Input.Text)
        self.MaskedDisplay.Text = maskedText
    end
end

-- Apply styles based on input variant
function TextInput:_applyVariantStyles()
    if self.Variant == "outlined" then
        -- Outlined style has transparent background
        self.Background.BackgroundTransparency = 1
        self.Border.Thickness = 1
    elseif self.Variant == "underlined" then
        -- Underlined style only has a bottom border
        self.Background.BackgroundTransparency = 1
        self.Border:Destroy()
        
        -- Create a bottom line instead
        local bottomLine = Instance.new("Frame")
        bottomLine.Name = "BottomLine"
        bottomLine.Size = UDim2.new(1, 0, 0, 1)
        bottomLine.Position = UDim2.new(0, 0, 1, 0)
        bottomLine.BackgroundColor3 = Theme.GetColors().inputBorder
        bottomLine.BorderSizePixel = 0
        bottomLine.Parent = self.Background
        
        -- Store for focus animations
        self.BottomLine = bottomLine
    end
end

-- Set up input focus and hover states
function TextInput:_setupInputStates()
    -- Focus effect
    self.Input.Focused:Connect(function()
        if self.Disabled then return end
        
        local focusColor = Theme.GetColors().primary
        
        if self.Variant == "default" or self.Variant == "outlined" then
            -- Animate border
            local borderTween = Tween.Create(self.Border, 0.2, {
                Color = focusColor
            })
            borderTween:Play()
        elseif self.Variant == "underlined" and self.BottomLine then
            -- Animate bottom line
            local lineTween = Tween.Create(self.BottomLine, 0.2, {
                BackgroundColor3 = focusColor,
                Size = UDim2.new(1, 0, 0, 2)
            })
            lineTween:Play()
        end
        
        -- Animate label if exists
        if self.LabelInstance then
            local labelTween = Tween.Create(self.LabelInstance, 0.2, {
                TextColor3 = focusColor
            })
            labelTween:Play()
        end
    end)
    
    -- Unfocus effect
    self.Input.FocusLost:Connect(function()
        if self.Disabled then return end
        
        local borderColor = Theme.GetColors().inputBorder
        
        if self.Variant == "default" or self.Variant == "outlined" then
            -- Animate border
            local borderTween = Tween.Create(self.Border, 0.2, {
                Color = borderColor
            })
            borderTween:Play()
        elseif self.Variant == "underlined" and self.BottomLine then
            -- Animate bottom line
            local lineTween = Tween.Create(self.BottomLine, 0.2, {
                BackgroundColor3 = borderColor,
                Size = UDim2.new(1, 0, 0, 1)
            })
            lineTween:Play()
        end
        
        -- Animate label if exists
        if self.LabelInstance then
            local labelTween = Tween.Create(self.LabelInstance, 0.2, {
                TextColor3 = Theme.GetColors().textSecondary
            })
            labelTween:Play()
        end
    end)
    
    -- Hover effect
    self.Background.MouseEnter:Connect(function()
        if self.Disabled then return end
        
        if not self.Input:IsFocused() then
            local hoverColor = Theme.GetColors().inputBorderHover
            
            if self.Variant == "default" or self.Variant == "outlined" then
                local borderTween = Tween.Create(self.Border, 0.2, {
                    Color = hoverColor
                })
                borderTween:Play()
            elseif self.Variant == "underlined" and self.BottomLine then
                local lineTween = Tween.Create(self.BottomLine, 0.2, {
                    BackgroundColor3 = hoverColor
                })
                lineTween:Play()
            end
        end
    end)
    
    -- Mouse leave effect
    self.Background.MouseLeave:Connect(function()
        if self.Disabled then return end
        
        if not self.Input:IsFocused() then
            local borderColor = Theme.GetColors().inputBorder
            
            if self.Variant == "default" or self.Variant == "outlined" then
                local borderTween = Tween.Create(self.Border, 0.2, {
                    Color = borderColor
                })
                borderTween:Play()
            elseif self.Variant == "underlined" and self.BottomLine then
                local lineTween = Tween.Create(self.BottomLine, 0.2, {
                    BackgroundColor3 = borderColor
                })
                lineTween:Play()
            end
        end
    end)
    
    -- Clicking on the background focuses the input
    self.Background.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not self.Disabled then
            self.Input:CaptureFocus()
        end
    end)
end

-- Set the text input's parent
function TextInput:SetParent(parent)
    self.Container.Parent = parent
    return self
end

-- Get current value
function TextInput:GetValue()
    return self.Value
end

-- Set input value
function TextInput:SetValue(text)
    self.Value = text or ""
    self.Input.Text = self.Value
    
    if self.ClearButton and self.ClearButtonInstance then
        self.ClearButtonInstance.Visible = #self.Value > 0
    end
    
    if self.PasswordMode then
        self:_updateMaskedText()
    end
    
    return self
end

-- Set input placeholder
function TextInput:SetPlaceholder(text)
    self.Placeholder = text
    self.Input.PlaceholderText = text
    return self
end

-- Set the input's position
function TextInput:SetPosition(position)
    self.Position = position
    self.Container.Position = position
    return self
end

-- Set the input's size
function TextInput:SetSize(size)
    self.Size = size
    self.Container.Size = size
    self.Background.Size = UDim2.new(1, 0, 0, size.Y.Offset)
    return self
end

-- Enable or disable the input
function TextInput:SetEnabled(enabled)
    self.Disabled = not enabled
    
    if self.Disabled then
        self.Input.TextColor3 = Theme.GetColors().disabledText
        self.Background.BackgroundColor3 = Theme.GetColors().disabledBackground
        
        if self.Variant == "default" or self.Variant == "outlined" then
            self.Border.Color = Theme.GetColors().disabledBorder
        elseif self.Variant == "underlined" and self.BottomLine then
            self.BottomLine.BackgroundColor3 = Theme.GetColors().disabledBorder
        end
        
        if self.LabelInstance then
            self.LabelInstance.TextColor3 = Theme.GetColors().disabledText
        end
    else
        self.Input.TextColor3 = Theme.GetColors().text
        self.Background.BackgroundColor3 = Theme.GetColors().inputBackground
        
        if self.Variant == "default" or self.Variant == "outlined" then
            self.Border.Color = Theme.GetColors().inputBorder
        elseif self.Variant == "underlined" and self.BottomLine then
            self.BottomLine.BackgroundColor3 = Theme.GetColors().inputBorder
        end
        
        if self.LabelInstance then
            self.LabelInstance.TextColor3 = Theme.GetColors().textSecondary
        end
    end
    
    self.Input.TextEditable = enabled
    
    return self
end

-- Focus the input
function TextInput:Focus()
    if not self.Disabled then
        self.Input:CaptureFocus()
    end
    return self
end

-- Clear input value
function TextInput:Clear()
    return self:SetValue("")
end

-- Clean up the text input
function TextInput:Destroy()
    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end
    
    if self.TextChanged then
        self.TextChanged:Destroy()
        self.TextChanged = nil
    end
    
    if self.FocusLost then
        self.FocusLost:Destroy()
        self.FocusLost = nil
    end
    
    if self.Focused then
        self.Focused:Destroy()
        self.Focused = nil
    end
end

--------------------------------------------------
-- Toggle Component
--------------------------------------------------
local Toggle = {}
Toggle.__index = Toggle

-- Create a new toggle
function Toggle.new(options)
    local self = setmetatable({}, Toggle)
    
    -- Default options
    options = options or {}
    self.Size = options.Size or UDim2.new(0, 200, 0, 24)
    self.Position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
    self.AnchorPoint = options.AnchorPoint or Vector2.new(0.5, 0.5)
    self.Value = options.Value or false
    self.Label = options.Label or "Toggle"
    self.Disabled = options.Disabled or false
    self.Variant = options.Variant or "switch" -- switch, checkbox, radio
    
    -- Create the toggle instance
    self:_create()
    
    return self
end

-- Internal function to create the toggle UI
function Toggle:_create()
    -- Container
    self.Container = Instance.new("Frame")
    self.Container.Name = "LibUAToggle"
    self.Container.Size = self.Size
    self.Container.Position = self.Position
    self.Container.AnchorPoint = self.AnchorPoint
    self.Container.BackgroundTransparency = 1
    
    -- Create appropriate toggle control based on variant
    if self.Variant == "switch" then
        self:_createSwitch()
    elseif self.Variant == "checkbox" then
        self:_createCheckbox()
    elseif self.Variant == "radio" then
        self:_createRadio()
    end
    
    -- Label
    self.LabelInstance = Instance.new("TextLabel")
    self.LabelInstance.Name = "Label"
    self.LabelInstance.Size = UDim2.new(1, -50, 1, 0)
    self.LabelInstance.Position = UDim2.new(0, 40, 0, 0)
    self.LabelInstance.BackgroundTransparency = 1
    self.LabelInstance.Font = Enum.Font.Gotham
    self.LabelInstance.TextSize = 16
    self.LabelInstance.TextColor3 = Theme.GetColors().text
    self.LabelInstance.TextXAlignment = Enum.TextXAlignment.Left
    self.LabelInstance.Text = self.Label
    self.LabelInstance.Parent = self.Container
    
    -- Click detection for entire container
    local button = Instance.new("TextButton")
    button.Name = "ClickDetector"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = self.Container
    
    -- Connect click event
    button.MouseButton1Click:Connect(function()
        if not self.Disabled then
            self:Toggle()
        end
    end)
    
    -- Create events
    self.ValueChanged = Instance.new("BindableEvent")
    
    -- Apply disabled state if needed
    if self.Disabled then
        self:SetEnabled(false)
    end
end

-- Create switch-style toggle (like iOS toggle)
function Toggle:_createSwitch()
    -- Switch track
    self.Track = Instance.new("Frame")
    self.Track.Name = "Track"
    self.Track.Size = UDim2.new(0, 36, 0, 20)
    self.Track.Position = UDim2.new(0, 0, 0.5, 0)
    self.Track.AnchorPoint = Vector2.new(0, 0.5)
    self.Track.BackgroundColor3 = self.Value 
        and Theme.GetColors().primary
        or Theme.GetColors().toggleTrackOff
    self.Track.BorderSizePixel = 0
    self.Track.Parent = self.Container
    
    -- Rounded corners for track
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = self.Track
    
    -- Switch knob
    self.Knob = Instance.new("Frame")
    self.Knob.Name = "Knob"
    self.Knob.Size = UDim2.new(0, 16, 0, 16)
    self.Knob.Position = self.Value 
        and UDim2.new(1, -18, 0.5, 0)
        or UDim2.new(0, 2, 0.5, 0)
    self.Knob.AnchorPoint = Vector2.new(0, 0.5)
    self.Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Knob.BorderSizePixel = 0
    self.Knob.Parent = self.Track
    
    -- Rounded corners for knob
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = self.Knob
    
    -- Add shadow to knob for depth
    local knobShadow = Instance.new("ImageLabel")
    knobShadow.Name = "Shadow"
    knobShadow.Size = UDim2.new(1, 4, 1, 4)
    knobShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    knobShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    knobShadow.BackgroundTransparency = 1
    knobShadow.Image = "rbxassetid://3602733521" -- Shadow asset
    knobShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    knobShadow.ImageTransparency = 0.7
    knobShadow.ZIndex = -1
    knobShadow.Parent = self.Knob
end

-- Create checkbox-style toggle
function Toggle:_createCheckbox()
    -- Checkbox box
    self.Box = Instance.new("Frame")
    self.Box.Name = "Box"
    self.Box.Size = UDim2.new(0, 20, 0, 20)
    self.Box.Position = UDim2.new(0, 0, 0.5, 0)
    self.Box.AnchorPoint = Vector2.new(0, 0.5)
    self.Box.BackgroundColor3 = self.Value 
        and Theme.GetColors().primary
        or Theme.GetColors().inputBackground
    self.Box.BorderSizePixel = 0
    self.Box.Parent = self.Container
    
    -- Rounded corners for box
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = self.Box
    
    -- Border for box
    self.BoxBorder = Instance.new("UIStroke")
    self.BoxBorder.Color = self.Value 
        and Theme.GetColors().primary
        or Theme.GetColors().inputBorder
    self.BoxBorder.Thickness = 1
    self.BoxBorder.Parent = self.Box
    
    -- Checkmark
    self.Checkmark = Instance.new("TextLabel")
    self.Checkmark.Name = "Checkmark"
    self.Checkmark.Size = UDim2.new(1, 0, 1, 0)
    self.Checkmark.BackgroundTransparency = 1
    self.Checkmark.Text = "✓"
    self.Checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.Checkmark.TextSize = 16
    self.Checkmark.Font = Enum.Font.GothamBold
    self.Checkmark.Visible = self.Value
    self.Checkmark.Parent = self.Box
end

-- Create radio button style toggle
function Toggle:_createRadio()
    -- Radio circle
    self.Circle = Instance.new("Frame")
    self.Circle.Name = "Circle"
    self.Circle.Size = UDim2.new(0, 20, 0, 20)
    self.Circle.Position = UDim2.new(0, 0, 0.5, 0)
    self.Circle.AnchorPoint = Vector2.new(0, 0.5)
    self.Circle.BackgroundColor3 = Theme.GetColors().inputBackground
    self.Circle.BorderSizePixel = 0
    self.Circle.Parent = self.Container
    
    -- Make it circular
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = self.Circle
    
    -- Border for circle
    self.CircleBorder = Instance.new("UIStroke")
    self.CircleBorder.Color = self.Value 
        and Theme.GetColors().primary
        or Theme.GetColors().inputBorder
    self.CircleBorder.Thickness = 1
    self.CircleBorder.Parent = self.Circle
    
    -- Inner dot for selected state
    self.Dot = Instance.new("Frame")
    self.Dot.Name = "Dot"
    self.Dot.Size = UDim2.new(0, 10, 0, 10)
    self.Dot.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Dot.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Dot.BackgroundColor3 = Theme.GetColors().primary
    self.Dot.BorderSizePixel = 0
    self.Dot.Visible = self.Value
    self.Dot.Parent = self.Circle
    
    -- Make the dot circular
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = self.Dot
end

-- Toggle the value
function Toggle:Toggle()
    if self.Disabled then return self end
    
    self.Value = not self.Value
    self:_updateVisuals()
    self.ValueChanged:Fire(self.Value)
    
    return self
end

-- Update the visuals based on current value
function Toggle:_updateVisuals()
    if self.Variant == "switch" then
        -- Animate the track color
        local trackTween = Tween.Create(self.Track, 0.2, {
            BackgroundColor3 = self.Value 
                and Theme.GetColors().primary 
                or Theme.GetColors().toggleTrackOff
        })
        trackTween:Play()
        
        -- Animate the knob position
        local knobTween = Tween.Create(self.Knob, 0.2, {
            Position = self.Value 
                and UDim2.new(1, -18, 0.5, 0)
                or UDim2.new(0, 2, 0.5, 0)
        })
        knobTween:Play()
    elseif self.Variant == "checkbox" then
        -- Animate the box color
        local boxTween = Tween.Create(self.Box, 0.2, {
            BackgroundColor3 = self.Value 
                and Theme.GetColors().primary
                or Theme.GetColors().inputBackground
        })
        boxTween:Play()
        
        -- Animate the border color
        local borderTween = Tween.Create(self.BoxBorder, 0.2, {
            Color = self.Value 
                and Theme.GetColors().primary
                or Theme.GetColors().inputBorder
        })
        borderTween:Play()
        
        -- Show/hide checkmark with animation
        if self.Value then
            self.Checkmark.Visible = true
            self.Checkmark.TextTransparency = 1
            local checkTween = Tween.Create(self.Checkmark, 0.2, {
                TextTransparency = 0
            })
            checkTween:Play()
        else
            local checkTween = Tween.Create(self.Checkmark, 0.2, {
                TextTransparency = 1
            })
            checkTween.Completed:Connect(function()
                self.Checkmark.Visible = false
            end)
            checkTween:Play()
        end
    elseif self.Variant == "radio" then
        -- Animate the border color
        local borderTween = Tween.Create(self.CircleBorder, 0.2, {
            Color = self.Value 
                and Theme.GetColors().primary
                or Theme.GetColors().inputBorder
        })
        borderTween:Play()
        
        -- Show/hide dot with animation
        if self.Value then
            self.Dot.Visible = true
            self.Dot.Size = UDim2.new(0, 0, 0, 0)
            local dotTween = Tween.Create(self.Dot, 0.2, {
                Size = UDim2.new(0, 10, 0, 10)
            })
            dotTween:Play()
        else
            local dotTween = Tween.Create(self.Dot, 0.2, {
                Size = UDim2.new(0, 0, 0, 0)
            })
            dotTween.Completed:Connect(function()
                self.Dot.Visible = false
            end)
            dotTween:Play()
        end
    end
end

-- Set the toggle's parent
function Toggle:SetParent(parent)
    self.Container.Parent = parent
    return self
end

-- Get current value
function Toggle:GetValue()
    return self.Value
end

-- Set toggle value without triggering event
function Toggle:SetValue(value)
    if self.Value ~= value then
        self.Value = value
        self:_updateVisuals()
    end
    return self
end

-- Set toggle label
function Toggle:SetLabel(text)
    self.Label = text
    self.LabelInstance.Text = text
    return self
end

-- Set the toggle's position
function Toggle:SetPosition(position)
    self.Position = position
    self.Container.Position = position
    return self
end

-- Set the toggle's size
function Toggle:SetSize(size)
    self.Size = size
    self.Container.Size = size
    return self
end

-- Enable or disable the toggle
function Toggle:SetEnabled(enabled)
    self.Disabled = not enabled
    
    local alpha = self.Disabled and 0.5 or 1
    
    -- Update visuals based on variant
    if self.Variant == "switch" then
        self.Track.BackgroundTransparency = self.Disabled and 0.5 or 0
        self.Knob.BackgroundTransparency = self.Disabled and 0.5 or 0
    elseif self.Variant == "checkbox" then
        self.Box.BackgroundTransparency = self.Disabled and 0.5 or 0
        self.BoxBorder.Transparency = self.Disabled and 0.5 or 0
        if self.Checkmark.Visible then
            self.Checkmark.TextTransparency = self.Disabled and 0.5 or 0
        end
    elseif self.Variant == "radio" then
        self.Circle.BackgroundTransparency = self.Disabled and 0.5 or 0
        self.CircleBorder.Transparency = self.Disabled and 0.5 or 0
        if self.Dot.Visible then
            self.Dot.BackgroundTransparency = self.Disabled and 0.5 or 0
        end
    end
    
    -- Update label
    self.LabelInstance.TextTransparency = self.Disabled and 0.5 or 0
    
    return self
end

-- Clean up the toggle
function Toggle:Destroy()
    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end
    
    if self.ValueChanged then
        self.ValueChanged:Destroy()
        self.ValueChanged = nil
    end
end

--------------------------------------------------
-- Add components to the LibUA table
--------------------------------------------------
LibUA.Button = Button
LibUA.TextInput = TextInput
LibUA.Toggle = Toggle
LibUA.Theme = Theme
LibUA.Tween = Tween
LibUA.Icons = Icons

-- Version information
LibUA.Version = "1.0.0"

-- Initialize the library
function LibUA.Init(theme)
    -- Set custom theme if provided
    if theme then
        LibUA.Theme.SetCustomTheme(theme)
    end
    
    -- Return the library for chaining
    return LibUA
end

return LibUA
</function_text>
</invoke>
