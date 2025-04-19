--[[
    Roblox UI Library
    
    A lightweight, modular UI library for Roblox games
    
    Usage: loadstring(game:HttpGet("https://raw.githubusercontent.com/Roblox-Menu-Thing/Menu-Wit-Lib/refs/heads/main/Lib/Lib.lua",true))()
    
    Author: AI Assistant
    Version: 1.0.0
--]]

-- Make library available globally through getgenv()
if getgenv then
    getgenv().MenuLib = {} -- Will be populated at the end of the script
end

local Library = {}
Library.__index = Library

-- Constants
local TWEEN_SERVICE = game:GetService("TweenService")
local USER_INPUT_SERVICE = game:GetService("UserInputService")
local PLAYERS = game:GetService("Players")
local LOCAL_PLAYER = PLAYERS.LocalPlayer
local MOUSE = LOCAL_PLAYER:GetMouse()

-- UI Colors
local COLORS = {
    Background = Color3.fromRGB(30, 30, 30),
    Secondary = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(65, 105, 225),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(200, 200, 200),
    Positive = Color3.fromRGB(75, 180, 75),
    Negative = Color3.fromRGB(180, 75, 75)
}

-- Utility Functions
local function createInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        instance[property] = value
    end
    return instance
end

local function tween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    
    local tween = TWEEN_SERVICE:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function draggable(frame, dragObject)
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        dragObject.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = dragObject.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    USER_INPUT_SERVICE.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function rippleEffect(button, rippleColor)
    local ripple = createInstance("Frame", {
        BackgroundColor3 = rippleColor or Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Position = UDim2.new(0, MOUSE.X - button.AbsolutePosition.X, 0, MOUSE.Y - button.AbsolutePosition.Y),
        Size = UDim2.new(0, 0, 0, 0),
        ZIndex = button.ZIndex + 1,
        Parent = button,
        AnchorPoint = Vector2.new(0.5, 0.5)
    })
    
    createInstance("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    tween(ripple, {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1
    }, 0.5)
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

local function hover(button, enterColor, leaveColor)
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        tween(button, {BackgroundColor3 = enterColor or COLORS.Secondary}, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        tween(button, {BackgroundColor3 = leaveColor or originalColor}, 0.2)
    end)
end

-- Initialize Library
function Library.new(title, theme)
    local self = setmetatable({}, Library)
    
    -- Apply theme if provided
    if theme then
        for key, value in pairs(theme) do
            if COLORS[key] then
                COLORS[key] = value
            end
        end
    end
    
    -- Create UI
    self.ScreenGui = createInstance("ScreenGui", {
        Name = "LibraryUI",
        Parent = LOCAL_PLAYER:WaitForChild("PlayerGui"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Main Frame
    self.Main = createInstance("Frame", {
        Name = "Main",
        BackgroundColor3 = COLORS.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 500, 0, 350),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = self.ScreenGui
    })
    
    -- Round corners
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = self.Main
    })
    
    -- Shadow effect
    local shadow = createInstance("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.65,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = -1,
        Parent = self.Main
    })
    
    -- Title Bar
    self.TitleBar = createInstance("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = COLORS.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35),
        Parent = self.Main
    })
    
    -- Round top corners
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = self.TitleBar
    })
    
    -- Fix corners of title bar
    createInstance("Frame", {
        Name = "BottomFix",
        BackgroundColor3 = COLORS.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -6),
        Size = UDim2.new(1, 0, 0, 6),
        Parent = self.TitleBar
    })
    
    -- Title Text
    self.TitleText = createInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = title or "Library UI",
        TextColor3 = COLORS.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar
    })
    
    -- Close Button
    self.CloseButton = createInstance("TextButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 5),
        Size = UDim2.new(0, 25, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = COLORS.Text,
        TextSize = 20,
        Parent = self.TitleBar
    })
    
    self.CloseButton.MouseEnter:Connect(function()
        tween(self.CloseButton, {TextColor3 = COLORS.Negative}, 0.2)
    end)
    
    self.CloseButton.MouseLeave:Connect(function()
        tween(self.CloseButton, {TextColor3 = COLORS.Text}, 0.2)
    end)
    
    self.CloseButton.MouseButton1Click:Connect(function()
        tween(self.Main, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
        tween(self.Main, {BackgroundTransparency = 1}, 0.3)
        tween(shadow, {ImageTransparency = 1}, 0.3)
        wait(0.3)
        self.ScreenGui:Destroy()
    end)
    
    -- Minimize Button
    self.MinimizeButton = createInstance("TextButton", {
        Name = "MinimizeButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0, 5),
        Size = UDim2.new(0, 25, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = "-",
        TextColor3 = COLORS.Text,
        TextSize = 20,
        Parent = self.TitleBar
    })
    
    self.MinimizeButton.MouseEnter:Connect(function()
        tween(self.MinimizeButton, {TextColor3 = COLORS.Accent}, 0.2)
    end)
    
    self.MinimizeButton.MouseLeave:Connect(function()
        tween(self.MinimizeButton, {TextColor3 = COLORS.Text}, 0.2)
    end)
    
    local minimized = false
    self.MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tween(self.Main, {Size = UDim2.new(0, 500, 0, 35)}, 0.3)
        else
            tween(self.Main, {Size = UDim2.new(0, 500, 0, 350)}, 0.3)
        end
    end)
    
    -- Content Area
    self.ContentArea = createInstance("Frame", {
        Name = "ContentArea",
        BackgroundColor3 = COLORS.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        ClipsDescendants = true,
        Parent = self.Main
    })
    
    -- Tab container
    self.TabButtons = createInstance("Frame", {
        Name = "TabButtons",
        BackgroundColor3 = COLORS.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 30),
        Parent = self.ContentArea
    })
    
    -- Tab shadow
    createInstance("Frame", {
        Name = "TabShadow",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = self.TabButtons
    })
    
    -- Tab container for buttons
    self.TabButtonsContainer = createInstance("ScrollingFrame", {
        Name = "TabButtonsContainer",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        Parent = self.TabButtons
    })
    
    -- Layout for tab buttons
    createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = self.TabButtonsContainer
    })
    
    createInstance("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        Parent = self.TabButtonsContainer
    })
    
    -- Content container for tabs
    self.TabsContainer = createInstance("Frame", {
        Name = "TabsContainer",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 1, -30),
        ClipsDescendants = true,
        Parent = self.ContentArea
    })
    
    -- Make main frame draggable
    draggable(self.TitleBar, self.Main)
    
    self.Tabs = {}
    self.SelectedTab = nil
    
    -- Animation entrance
    self.Main.Size = UDim2.new(0, 0, 0, 0)
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Main.BackgroundTransparency = 1
    shadow.ImageTransparency = 1
    
    tween(self.Main, {Size = UDim2.new(0, 500, 0, 350), BackgroundTransparency = 0}, 0.3)
    tween(shadow, {ImageTransparency = 0.65}, 0.3)
    
    return self
end

function Library:CreateTab(name)
    local tab = {}
    
    -- Tab button
    tab.Button = createInstance("TextButton", {
        Name = name.."Tab",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = #self.Tabs == 0 and COLORS.Accent or COLORS.TextDark,
        TextSize = 14,
        Parent = self.TabButtonsContainer
    })
    
    createInstance("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = tab.Button
    })
    
    -- Indicator for selected tab
    tab.Indicator = createInstance("Frame", {
        Name = "Indicator",
        BackgroundColor3 = COLORS.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        Visible = #self.Tabs == 0,
        Parent = tab.Button
    })
    
    -- Tab content
    tab.Container = createInstance("ScrollingFrame", {
        Name = name.."Container",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = #self.Tabs == 0,
        Parent = self.TabsContainer
    })
    
    -- Padding for content
    createInstance("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = tab.Container
    })
    
    -- Layout for elements
    createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = tab.Container
    })
    
    -- Custom scrollbar
    local scrollBarFrame = createInstance("Frame", {
        Name = "ScrollBarFrame",
        BackgroundColor3 = COLORS.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -6, 0, 0),
        Size = UDim2.new(0, 6, 1, 0),
        ZIndex = 2,
        Parent = tab.Container
    })
    
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 3),
        Parent = scrollBarFrame
    })
    
    -- Tab button click event
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
    
    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        self.SelectedTab = tab
    end
    
    -- API to add elements to the tab
    function tab:AddSection(sectionName)
        local section = {}
        
        -- Section container
        section.Container = createInstance("Frame", {
            Name = sectionName.."Section",
            BackgroundColor3 = COLORS.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = tab.Container
        })
        
        createInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = section.Container
        })
        
        -- Section header
        section.Header = createInstance("TextLabel", {
            Name = "Header",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.GothamSemibold,
            Text = sectionName,
            TextColor3 = COLORS.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = section.Container
        })
        
        createInstance("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            Parent = section.Header
        })
        
        -- Content container
        section.Content = createInstance("Frame", {
            Name = "Content",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 30),
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = section.Container
        })
        
        -- Layout for elements
        createInstance("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = section.Content
        })
        
        createInstance("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent = section.Content
        })
        
        -- API for adding elements to section
        function section:AddLabel(text)
            local label = createInstance("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = COLORS.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section.Content
            })
            
            local labelObj = {Instance = label}
            
            function labelObj:SetText(newText)
                label.Text = newText
            end
            
            return labelObj
        end
        
        function section:AddButton(text, callback)
            local button = createInstance("TextButton", {
                Name = "Button",
                BackgroundColor3 = COLORS.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 32),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = COLORS.Text,
                TextSize = 14,
                AutoButtonColor = false,
                ClipsDescendants = true,
                Parent = section.Content
            })
            
            createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = button
            })
            
            button.MouseButton1Click:Connect(function()
                rippleEffect(button)
                pcall(callback)
            end)
            
            local buttonObj = {Instance = button}
            
            function buttonObj:SetText(newText)
                button.Text = newText
            end
            
            function buttonObj:SetCallback(newCallback)
                callback = newCallback
            end
            
            return buttonObj
        end
        
        function section:AddToggle(text, default, callback)
            local toggleContainer = createInstance("Frame", {
                Name = "ToggleContainer",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                Parent = section.Content
            })
            
            local label = createInstance("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = COLORS.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggleContainer
            })
            
            local toggleBackground = createInstance("Frame", {
                Name = "ToggleBackground",
                BackgroundColor3 = default and COLORS.Accent or COLORS.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -40, 0.5, 0),
                Size = UDim2.new(0, 40, 0, 20),
                AnchorPoint = Vector2.new(0, 0.5),
                Parent = toggleContainer
            })
            
            createInstance("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleBackground
            })
            
            local toggleButton = createInstance("Frame", {
                Name = "ToggleButton",
                BackgroundColor3 = COLORS.Text,
                BorderSizePixel = 0,
                Position = default and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                AnchorPoint = Vector2.new(0, 0.5),
                Parent = toggleBackground
            })
            
            createInstance("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleButton
            })
            
            local toggle = {
                Instance = toggleContainer,
                Value = default or false
            }
            
            local function updateToggle()
                if toggle.Value then
                    tween(toggleBackground, {BackgroundColor3 = COLORS.Accent}, 0.2)
                    tween(toggleButton, {Position = UDim2.new(1, -18, 0.5, 0)}, 0.2)
                else
                    tween(toggleBackground, {BackgroundColor3 = COLORS.Secondary}, 0.2)
                    tween(toggleButton, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.2)
                end
                pcall(callback, toggle.Value)
            end
            
            toggleBackground.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggle.Value = not toggle.Value
                    updateToggle()
                end
            end)
            
            function toggle:SetValue(value)
                if type(value) == "boolean" then
                    toggle.Value = value
                    updateToggle()
                end
            end
            
            function toggle:GetValue()
                return toggle.Value
            end
            
            return toggle
        end
        
        function section:AddSlider(text, min, max, default, callback)
            local sliderContainer = createInstance("Frame", {
                Name = "SliderContainer",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 50),
                Parent = section.Content
            })
            
            local label = createInstance("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = COLORS.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sliderContainer
            })
            
            local valueDisplay = createInstance("TextLabel", {
                Name = "Value",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -40, 0, 0),
                Size = UDim2.new(0, 40, 0, 20),
                Font = Enum.Font.Gotham,
                Text = tostring(default),
                TextColor3 = COLORS.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = sliderContainer
            })
            
            local sliderBackground = createInstance("Frame", {
                Name = "SliderBackground",
                BackgroundColor3 = COLORS.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 0, 10),
                Parent = sliderContainer
            })
            
            createInstance("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderBackground
            })
            
            local sliderFill = createInstance("Frame", {
                Name = "SliderFill",
                BackgroundColor3 = COLORS.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                Parent = sliderBackground
            })
            
            createInstance("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderFill
            })
            
            local sliderButton = createInstance("Frame", {
                Name = "SliderButton",
                BackgroundColor3 = COLORS.Text,
                BorderSizePixel = 0,
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 15, 0, 15),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Parent = sliderFill
            })
            
            createInstance("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderButton
            })
            
            local slider = {
                Instance = sliderContainer,
                Value = default,
                Min = min,
                Max = max
            }
            
            local function updateSlider(value)
                value = math.clamp(value, min, max)
                slider.Value = value
                sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                valueDisplay.Text = tostring(math.floor(value * 100) / 100)
                pcall(callback, value)
            end
            
            local dragging = false
            
            sliderBackground.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    local relativePos = MOUSE.X - sliderBackground.AbsolutePosition.X
                    local percent = math.clamp(relativePos / sliderBackground.AbsoluteSize.X, 0, 1)
                    updateSlider(min + (max - min) * percent)
                end
            end)
            
            USER_INPUT_SERVICE.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local relativePos = MOUSE.X - sliderBackground.AbsolutePosition.X
                    local percent = math.clamp(relativePos / sliderBackground.AbsoluteSize.X, 0, 1)
                    updateSlider(min + (max - min) * percent)
                end
            end)
            
            USER_INPUT_SERVICE.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            function slider:SetValue(value)
                updateSlider(value)
            end
            
            function slider:GetValue()
                return slider.Value
            end
            
            return slider
        end
        
        function section:AddDropdown(text, options, default, callback)
            local dropdownContainer = createInstance("Frame", {
                Name = "DropdownContainer",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 55),
                ClipsDescendants = true,
                Parent = section.Content
            })
            
            local label = createInstance("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = COLORS.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdownContainer
            })
            
            local dropdownButton = createInstance("TextButton", {
                Name = "DropdownButton",
                BackgroundColor3 = COLORS.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.Gotham,
                Text = " " .. (default or options[1] or "Select..."),
                TextColor3 = COLORS.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                Parent = dropdownContainer
            })
            
            createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = dropdownButton
            })
            
            local arrow = createInstance("TextLabel", {
                Name = "Arrow",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -20, 0, 0),
                Size = UDim2.new(0, 20, 1, 0),
                Font = Enum.Font.Gotham,
                Text = "▼",
                TextColor3 = COLORS.Text,
                TextSize = 12,
                Parent = dropdownButton
            })
            
            local optionsFrame = createInstance("Frame", {
                Name = "OptionsFrame",
                BackgroundColor3 = COLORS.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 60),
                Size = UDim2.new(1, 0, 0, 0),
                Visible = false,
                ZIndex = 5,
                Parent = dropdownContainer
            })
            
            createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = optionsFrame
            })
            
            local optionsList = createInstance("ScrollingFrame", {
                Name = "OptionsList",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 4,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                ZIndex = 5,
                Parent = optionsFrame
            })
            
            createInstance("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = optionsList
            })
            
            createInstance("UIPadding", {
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5),
                Parent = optionsList
            })
            
            local dropdown = {
                Instance = dropdownContainer,
                Value = default or options[1],
                Options = options,
                Open = false
            }
            
            -- Populate options
            local function createOption(optionText)
                local option = createInstance("TextButton", {
                    Name = optionText .. "Option",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 25),
                    Font = Enum.Font.Gotham,
                    Text = optionText,
                    TextColor3 = COLORS.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = optionsList
                })
                
                option.MouseEnter:Connect(function()
                    tween(option, {BackgroundTransparency = 0.9, BackgroundColor3 = COLORS.Accent}, 0.2)
                end)
                
                option.MouseLeave:Connect(function()
                    tween(option, {BackgroundTransparency = 1}, 0.2)
                end)
                
                option.MouseButton1Click:Connect(function()
                    dropdown.Value = optionText
                    dropdownButton.Text = " " .. optionText
                    pcall(callback, optionText)
                    dropdown:Close()
                end)
            end
            
            for _, option in ipairs(options) do
                createOption(option)
            end
            
            -- Toggle dropdown
            dropdownButton.MouseButton1Click:Connect(function()
                if dropdown.Open then
                    dropdown:Close()
                else
                    dropdown:Open()
                end
            end)
            
            function dropdown:Open()
                dropdown.Open = true
                
                -- Calculate height based on options
                local optionsHeight = math.min(#options * 30, 150)
                
                -- Show options frame
                optionsFrame.Visible = true
                optionsFrame.Size = UDim2.new(1, 0, 0, 0)
                
                -- Animate arrow
                tween(arrow, {Rotation = 180}, 0.2)
                
                -- Animate options frame
                tween(optionsFrame, {Size = UDim2.new(1, 0, 0, optionsHeight)}, 0.2)
                
                -- Adjust container size
                tween(dropdownContainer, {Size = UDim2.new(1, 0, 0, 55 + optionsHeight)}, 0.2)
            end
            
            function dropdown:Close()
                dropdown.Open = false
                
                -- Animate arrow
                tween(arrow, {Rotation = 0}, 0.2)
                
                -- Animate options frame
                tween(optionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                
                -- Adjust container size
                tween(dropdownContainer, {Size = UDim2.new(1, 0, 0, 55)}, 0.2)
                
                -- Hide options frame after animation
                task.delay(0.2, function()
                    optionsFrame.Visible = false
                end)
            end
            
            function dropdown:SetValue(value)
                if table.find(options, value) then
                    dropdown.Value = value
                    dropdownButton.Text = " " .. value
                    pcall(callback, value)
                end
            end
            
            function dropdown:GetValue()
                return dropdown.Value
            end
            
            function dropdown:UpdateOptions(newOptions)
                dropdown.Options = newOptions
                
                -- Clear existing options
                for _, child in ipairs(optionsList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                -- Add new options
                for _, option in ipairs(newOptions) do
                    createOption(option)
                end
                
                -- Update value if current value is not in the new options
                if not table.find(newOptions, dropdown.Value) then
                    dropdown.Value = newOptions[1]
                    dropdownButton.Text = " " .. newOptions[1]
                    pcall(callback, newOptions[1])
                end
            end
            
            return dropdown
        end
        
        function section:AddColorPicker(text, default, callback)
            default = default or Color3.fromRGB(255, 255, 255)
            
            local colorPickerContainer = createInstance("Frame", {
                Name = "ColorPickerContainer",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 50),
                ClipsDescendants = true,
                Parent = section.Content
            })
            
            local label = createInstance("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -60, 0, 30),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = COLORS.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = colorPickerContainer
            })
            
            local colorDisplay = createInstance("TextButton", {
                Name = "ColorDisplay",
                BackgroundColor3 = default,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -50, 0, 0),
                Size = UDim2.new(0, 50, 0, 30),
                Text = "",
                Parent = colorPickerContainer
            })
            
            createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = colorDisplay
            })
            
            local colorPickerFrame = createInstance("Frame", {
                Name = "ColorPickerFrame",
                BackgroundColor3 = COLORS.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 0),
                Visible = false,
                ZIndex = 5,
                Parent = colorPickerContainer
            })
            
            createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = colorPickerFrame
            })
            
            -- Simplified color picker (just basic colors for simplicity)
            local colorGrid = createInstance("Frame", {
                Name = "ColorGrid",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 5, 0, 5),
                Size = UDim2.new(1, -10, 1, -40),
                ZIndex = 5,
                Parent = colorPickerFrame
            })
            
            createInstance("UIGridLayout", {
                CellSize = UDim2.new(0, 25, 0, 25),
                CellPadding = UDim2.new(0, 5, 0, 5),
                FillDirectionMaxCells = 8,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = colorGrid
            })
            
            -- RGB inputs
            local rInput = createInstance("TextBox", {
                Name = "RInput",
                BackgroundColor3 = COLORS.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 5, 1, -30),
                Size = UDim2.new(0, 50, 0, 25),
                Font = Enum.Font.Gotham,
                Text = tostring(math.floor(default.R * 255)),
                TextColor3 = COLORS.Text,
                TextSize = 14,
                PlaceholderText = "R",
                ZIndex = 5,
                Parent = colorPickerFrame
            })
            
            createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = rInput
            })
            
            local gInput = createInstance("TextBox", {
                Name = "GInput",
                BackgroundColor3 = COLORS.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 60, 1, -30),
                Size = UDim2.new(0, 50, 0, 25),
                Font = Enum.Font.Gotham,
                Text = tostring(math.floor(default.G * 255)),
                TextColor3 = COLORS.Text,
                TextSize = 14,
                PlaceholderText = "G",
                ZIndex = 5,
                Parent = colorPickerFrame
            })
            
            createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = gInput
            })
            
            local bInput = createInstance("TextBox", {
                Name = "BInput",
                BackgroundColor3 = COLORS.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 115, 1, -30),
                Size = UDim2.new(0, 50, 0, 25),
                Font = Enum.Font.Gotham,
                Text = tostring(math.floor(default.B * 255)),
                TextColor3 = COLORS.Text,
                TextSize = 14,
                PlaceholderText = "B",
                ZIndex = 5,
                Parent = colorPickerFrame
            })
            
            createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = bInput
            })
            
            local confirmButton = createInstance("TextButton", {
                Name = "ConfirmButton",
                BackgroundColor3 = COLORS.Accent,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -55, 1, -30),
                Size = UDim2.new(0, 50, 0, 25),
                Font = Enum.Font.Gotham,
                Text = "OK",
                TextColor3 = COLORS.Text,
                TextSize = 14,
                ZIndex = 5,
                Parent = colorPickerFrame
            })
            
            createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = confirmButton
            })
            
            -- Predefined colors
            local colors = {
                Color3.fromRGB(255, 255, 255), -- White
                Color3.fromRGB(0, 0, 0), -- Black
                Color3.fromRGB(255, 0, 0), -- Red
                Color3.fromRGB(0, 255, 0), -- Green
                Color3.fromRGB(0, 0, 255), -- Blue
                Color3.fromRGB(255, 255, 0), -- Yellow
                Color3.fromRGB(0, 255, 255), -- Cyan
                Color3.fromRGB(255, 0, 255), -- Magenta
                Color3.fromRGB(128, 0, 0), -- Maroon
                Color3.fromRGB(0, 128, 0), -- Dark Green
                Color3.fromRGB(0, 0, 128), -- Navy Blue
                Color3.fromRGB(128, 128, 0), -- Olive
                Color3.fromRGB(128, 0, 128), -- Purple
                Color3.fromRGB(0, 128, 128), -- Teal
                Color3.fromRGB(192, 192, 192), -- Silver
                Color3.fromRGB(128, 128, 128), -- Gray
                Color3.fromRGB(255, 165, 0), -- Orange
                Color3.fromRGB(255, 192, 203), -- Pink
                Color3.fromRGB(210, 180, 140), -- Tan
                Color3.fromRGB(165, 42, 42), -- Brown
                Color3.fromRGB(240, 230, 140), -- Khaki
                Color3.fromRGB(143, 188, 143), -- Dark Sea Green
                Color3.fromRGB(72, 61, 139), -- Dark Slate Blue
                Color3.fromRGB(221, 160, 221), -- Plum
            }
            
            -- Create color swatches
            for i, color in ipairs(colors) do
                local colorSwatch = createInstance("TextButton", {
                    Name = "ColorSwatch" .. i,
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 25, 0, 25),
                    Text = "",
                    ZIndex = 5,
                    Parent = colorGrid
                })
                
                createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = colorSwatch
                })
                
                colorSwatch.MouseButton1Click:Connect(function()
                    colorDisplay.BackgroundColor3 = color
                    rInput.Text = tostring(math.floor(color.R * 255))
                    gInput.Text = tostring(math.floor(color.G * 255))
                    bInput.Text = tostring(math.floor(color.B * 255))
                end)
            end
            
            local colorPicker = {
                Instance = colorPickerContainer,
                Value = default,
                Open = false
            }
            
            local function updateColor()
                local r = tonumber(rInput.Text) or 0
                local g = tonumber(gInput.Text) or 0
                local b = tonumber(bInput.Text) or 0
                
                r = math.clamp(r, 0, 255) / 255
                g = math.clamp(g, 0, 255) / 255
                b = math.clamp(b, 0, 255) / 255
                
                local color = Color3.new(r, g, b)
                colorDisplay.BackgroundColor3 = color
                colorPicker.Value = color
                pcall(callback, color)
            end
            
            rInput.FocusLost:Connect(function()
                updateColor()
            end)
            
            gInput.FocusLost:Connect(function()
                updateColor()
            end)
            
            bInput.FocusLost:Connect(function()
                updateColor()
            end)
            
            confirmButton.MouseButton1Click:Connect(function()
                updateColor()
                colorPicker:Close()
            end)
            
            colorDisplay.MouseButton1Click:Connect(function()
                if colorPicker.Open then
                    colorPicker:Close()
                else
                    colorPicker:Open()
                end
            end)
            
            function colorPicker:Open()
                colorPicker.Open = true
                
                -- Show color picker frame
                colorPickerFrame.Visible = true
                colorPickerFrame.Size = UDim2.new(1, 0, 0, 0)
                
                -- Animate
                tween(colorPickerFrame, {Size = UDim2.new(1, 0, 0, 200)}, 0.2)
                
                -- Adjust container size
                tween(colorPickerContainer, {Size = UDim2.new(1, 0, 0, 250)}, 0.2)
            end
            
            function colorPicker:Close()
                colorPicker.Open = false
                
                -- Animate
                tween(colorPickerFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                
                -- Adjust container size
                tween(colorPickerContainer, {Size = UDim2.new(1, 0, 0, 50)}, 0.2)
                
                -- Hide color picker frame after animation
                task.delay(0.2, function()
                    colorPickerFrame.Visible = false
                end)
            end
            
            function colorPicker:SetValue(color)
                if typeof(color) == "Color3" then
                    colorPicker.Value = color
                    colorDisplay.BackgroundColor3 = color
                    rInput.Text = tostring(math.floor(color.R * 255))
                    gInput.Text = tostring(math.floor(color.G * 255))
                    bInput.Text = tostring(math.floor(color.B * 255))
                    pcall(callback, color)
                end
            end
            
            function colorPicker:GetValue()
                return colorPicker.Value
            end
            
            return colorPicker
        end
        
        function section:AddTextBox(text, default, callback)
            local textboxContainer = createInstance("Frame", {
                Name = "TextBoxContainer",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 50),
                Parent = section.Content
            })
            
            local label = createInstance("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = COLORS.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = textboxContainer
            })
            
            local textbox = createInstance("TextBox", {
                Name = "TextBox",
                BackgroundColor3 = COLORS.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.Gotham,
                Text = default or "",
                TextColor3 = COLORS.Text,
                TextSize = 14,
                ClearTextOnFocus = false,
                Parent = textboxContainer
            })
            
            createInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = textbox
            })
            
            createInstance("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                Parent = textbox
            })
            
            local textboxObj = {
                Instance = textboxContainer,
                Value = default or ""
            }
            
            textbox.Focused:Connect(function()
                tween(textbox, {BackgroundColor3 = COLORS.Accent}, 0.2)
            end)
            
            textbox.FocusLost:Connect(function()
                tween(textbox, {BackgroundColor3 = COLORS.Secondary}, 0.2)
                textboxObj.Value = textbox.Text
                pcall(callback, textbox.Text)
            end)
            
            function textboxObj:SetValue(value)
                textboxObj.Value = value
                textbox.Text = value
                pcall(callback, value)
            end
            
            function textboxObj:GetValue()
                return textboxObj.Value
            end
            
            return textboxObj
        end
        
        return section
    end
    
    return tab
end

function Library:SelectTab(tabName)
    for _, tab in ipairs(self.Tabs) do
        if tab.Button.Text == tabName then
            -- Deselect all tabs
            for _, t in ipairs(self.Tabs) do
                t.Indicator.Visible = false
                t.Container.Visible = false
                tween(t.Button, {TextColor3 = COLORS.TextDark}, 0.2)
            end
            
            -- Select the chosen tab
            tab.Indicator.Visible = true
            tab.Container.Visible = true
            tween(tab.Button, {TextColor3 = COLORS.Accent}, 0.2)
            self.SelectedTab = tab
        end
    end
end

function Library:Notify(title, message, duration)
    duration = duration or 3
    
    local notification = createInstance("Frame", {
        Name = "Notification",
        BackgroundColor3 = COLORS.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -20, 1, -20),
        AnchorPoint = Vector2.new(1, 1),
        Size = UDim2.new(0, 250, 0, 0),
        Parent = self.ScreenGui
    })
    
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = notification
    })
    
    -- Shadow effect
    local shadow = createInstance("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.65,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = -1,
        Parent = notification
    })
    
    local titleLabel = createInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.GothamSemibold,
        Text = title,
        TextColor3 = COLORS.Accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification
    })
    
    local messageLabel = createInstance("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 35),
        Size = UDim2.new(1, -20, 0, 0),
        Font = Enum.Font.Gotham,
        Text = message,
        TextColor3 = COLORS.Text,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = notification
    })
    
    -- Calculate text size
    local textSize = game:GetService("TextService"):GetTextSize(
        message,
        14,
        Enum.Font.Gotham,
        Vector2.new(230, math.huge)
    )
    
    messageLabel.Size = UDim2.new(1, -20, 0, textSize.Y)
    notification.Size = UDim2.new(0, 250, 0, 45 + textSize.Y)
    
    -- Animation
    notification.Size = UDim2.new(0, 0, 0, 45 + textSize.Y)
    notification.BackgroundTransparency = 1
    shadow.ImageTransparency = 1
    titleLabel.TextTransparency = 1
    messageLabel.TextTransparency = 1
    
    tween(notification, {Size = UDim2.new(0, 250, 0, 45 + textSize.Y), BackgroundTransparency = 0}, 0.3)
    tween(shadow, {ImageTransparency = 0.65}, 0.3)
    tween(titleLabel, {TextTransparency = 0}, 0.3)
    tween(messageLabel, {TextTransparency = 0}, 0.3)
    
    task.delay(duration, function()
        tween(notification, {BackgroundTransparency = 1}, 0.3)
        tween(shadow, {ImageTransparency = 1}, 0.3)
        tween(titleLabel, {TextTransparency = 1}, 0.3)
        tween(messageLabel, {TextTransparency = 1}, 0.3)
        task.delay(0.3, function()
            notification:Destroy()
        end)
    end)
end

-- Export library

-- Set the global library for future reference
if getgenv then
    for k, v in pairs(Library) do
        getgenv().MenuLib[k] = v
    end
end

-- Add UI notification function
function Library:Notify(title, message, duration)
    duration = duration or 3
    
    -- Create notification container if it doesn't exist
    if not self.NotificationContainer then
        self.NotificationContainer = createInstance("Frame", {
            Name = "NotificationContainer",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -20, 0, 20),
            Size = UDim2.new(0, 250, 1, -40),
            AnchorPoint = Vector2.new(1, 0),
            Parent = self.ScreenGui
        })
        
        createInstance("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = self.NotificationContainer
        })
    end
    
    -- Create notification
    local notification = createInstance("Frame", {
        Name = "Notification",
        BackgroundColor3 = COLORS.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 80),
        Parent = self.NotificationContainer
    })
    
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = notification
    })
    
    local notifTitle = createInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(1, -30, 0, 20),
        Font = Enum.Font.GothamSemibold,
        Text = title,
        TextColor3 = COLORS.Accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification
    })
    
    local notifMessage = createInstance("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 35),
        Size = UDim2.new(1, -30, 0, 35),
        Font = Enum.Font.Gotham,
        Text = message,
        TextColor3 = COLORS.Text,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification
    })
    
    -- Create close button for notification
    local closeButton = createInstance("TextButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 10),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = COLORS.TextDark,
        TextSize = 18,
        Parent = notification
    })
    
    closeButton.MouseEnter:Connect(function()
        tween(closeButton, {TextColor3 = COLORS.Text}, 0.2)
    end)
    
    closeButton.MouseLeave:Connect(function()
        tween(closeButton, {TextColor3 = COLORS.TextDark}, 0.2)
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        tween(notification, {Position = UDim2.new(1, 250, 0, 0)}, 0.3)
        task.delay(0.3, function()
            notification:Destroy()
        end)
    end)
    
    -- Animate notification
    notification.Position = UDim2.new(1, 250, 0, 0)
    tween(notification, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
    
    -- Auto-close notification after duration
    task.delay(duration, function()
        if notification and notification.Parent then
            tween(notification, {Position = UDim2.new(1, 250, 0, 0)}, 0.3)
            task.delay(0.3, function()
                if notification and notification.Parent then
                    notification:Destroy()
                end
            end)
        end
    end)
end

return Library
