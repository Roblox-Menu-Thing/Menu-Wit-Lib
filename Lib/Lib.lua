--[[
    Roblox UI Library
    
    A simplified UI library for Roblox games
    
    Usage: loadstring(game:HttpGet("https://raw.githubusercontent.com/Roblox-Menu-Thing/Menu-Wit-Lib/refs/heads/main/Lib/Lib.lua",true))()
--]]

-- Make library accessible globally
if getgenv then
    getgenv().MenuLib = {}
end

-- Main library table
local Library = {}
Library.__index = Library

-- Get services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Default colors
local Colors = {
    Background = Color3.fromRGB(30, 30, 30),
    Secondary = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(65, 105, 225),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(200, 200, 200),
    Positive = Color3.fromRGB(75, 180, 75),
    Negative = Color3.fromRGB(180, 75, 75)
}

-- Utility function to create instances
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

-- Tween function
local function Tween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Make frame draggable
local function MakeDraggable(dragFrame, mainFrame)
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
    
    dragFrame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Create a ripple effect
local function RippleEffect(button)
    local ripple = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Position = UDim2.new(0, Mouse.X - button.AbsolutePosition.X, 0, Mouse.Y - button.AbsolutePosition.Y),
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = button
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Tween(ripple, {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1
    }, 0.5)
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

-- Main library function to create a new UI
function Library.new(title, theme)
    local self = setmetatable({}, Library)
    
    -- Apply theme if provided
    if theme then
        for key, value in pairs(theme) do
            if Colors[key] then
                Colors[key] = value
            end
        end
    end
    
    -- Create ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = "MenuLib",
        Parent = LocalPlayer.PlayerGui,
        ResetOnSpawn = false
    })
    
    -- Main frame
    self.Main = Create("Frame", {
        Name = "Main",
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 500, 0, 350),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = self.ScreenGui
    })
    
    -- Add rounded corners
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = self.Main
    })
    
    -- Title bar
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35),
        Parent = self.Main
    })
    
    -- Add rounded corners to title bar
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = self.TitleBar
    })
    
    -- Fix corners
    Create("Frame", {
        Name = "BottomFix",
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -6),
        Size = UDim2.new(1, 0, 0, 6),
        Parent = self.TitleBar
    })
    
    -- Title text
    self.TitleText = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = title or "Menu Lib",
        TextColor3 = Colors.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar
    })
    
    -- Close button
    self.CloseButton = Create("TextButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 5),
        Size = UDim2.new(0, 25, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Colors.Text,
        TextSize = 20,
        Parent = self.TitleBar
    })
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    })
    
    -- Content container
    self.Content = Create("Frame", {
        Name = "Content",
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        ClipsDescendants = true,
        Parent = self.Main
    })
    
    -- Tabs container
    self.TabButtons = Create("Frame", {
        Name = "TabButtons",
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = self.Content
    })
    
    -- Tabs container frame
    self.TabButtonsContainer = Create("ScrollingFrame", {
        Name = "TabButtonsContainer",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        Parent = self.TabButtons
    })
    
    -- Layout for tabs
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = self.TabButtonsContainer
    })
    
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        Parent = self.TabButtonsContainer
    })
    
    -- Tabs content container
    self.TabContents = Create("Frame", {
        Name = "TabContents",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 1, -30),
        Parent = self.Content
    })
    
    -- Make the UI draggable
    MakeDraggable(self.TitleBar, self.Main)
    
    self.Tabs = {}
    self.ActiveTab = nil
    
    -- Animation for entrance
    self.Main.Size = UDim2.new(0, 0, 0, 0)
    self.Main.BackgroundTransparency = 1
    Tween(self.Main, {Size = UDim2.new(0, 500, 0, 350), BackgroundTransparency = 0}, 0.3)
    
    return self
end

-- Create a new tab
function Library:CreateTab(name)
    local tab = {}
    
    -- Tab button
    tab.Button = Create("TextButton", {
        Name = name .. "Tab",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = #self.Tabs == 0 and Colors.Accent or Colors.TextDark,
        TextSize = 14,
        Parent = self.TabButtonsContainer
    })
    
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = tab.Button
    })
    
    -- Indicator for selected tab
    tab.Indicator = Create("Frame", {
        Name = "Indicator",
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        Visible = #self.Tabs == 0,
        Parent = tab.Button
    })
    
    -- Tab content
    tab.Container = Create("ScrollingFrame", {
        Name = name .. "Container",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = #self.Tabs == 0,
        Parent = self.TabContents
    })
    
    -- Padding for content
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = tab.Container
    })
    
    -- Layout for elements
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = tab.Container
    })
    
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
    
    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        self.ActiveTab = tab
    end
    
    -- Function to add a section to the tab
    function tab:AddSection(name)
        local section = {}
        
        -- Section container
        section.Container = Create("Frame", {
            Name = name .. "Section",
            BackgroundColor3 = Colors.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = tab.Container
        })
        
        -- Rounded corners
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = section.Container
        })
        
        -- Section header
        section.Header = Create("TextLabel", {
            Name = "Header",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.GothamSemibold,
            Text = name,
            TextColor3 = Colors.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = section.Container
        })
        
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            Parent = section.Header
        })
        
        -- Items container
        section.Items = Create("Frame", {
            Name = "Items",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 30),
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = section.Container
        })
        
        -- Layout for items
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = section.Items
        })
        
        -- Padding for items
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent = section.Items
        })
        
        -- Section Elements
        
        -- Button
        function section:AddButton(text, callback)
            local button = Create("TextButton", {
                Name = "Button",
                BackgroundColor3 = Colors.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 32),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Colors.Text,
                TextSize = 14,
                ClipsDescendants = true,
                Parent = section.Items
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = button
            })
            
            button.MouseButton1Click:Connect(function()
                RippleEffect(button)
                callback()
            end)
            
            return button
        end
        
        -- Toggle
        function section:AddToggle(text, default, callback)
            local toggled = default or false
            
            local toggleContainer = Create("Frame", {
                Name = "ToggleContainer",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                Parent = section.Items
            })
            
            local label = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggleContainer
            })
            
            local toggleBackground = Create("Frame", {
                Name = "Background",
                BackgroundColor3 = toggled and Colors.Accent or Colors.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -40, 0.5, 0),
                Size = UDim2.new(0, 40, 0, 20),
                AnchorPoint = Vector2.new(0, 0.5),
                Parent = toggleContainer
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleBackground
            })
            
            local toggleButton = Create("Frame", {
                Name = "Button",
                BackgroundColor3 = Colors.Text,
                BorderSizePixel = 0,
                Position = toggled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                AnchorPoint = Vector2.new(0, 0.5),
                Parent = toggleBackground
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleButton
            })
            
            toggleBackground.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggled = not toggled
                    if toggled then
                        Tween(toggleBackground, {BackgroundColor3 = Colors.Accent}, 0.2)
                        Tween(toggleButton, {Position = UDim2.new(1, -18, 0.5, 0)}, 0.2)
                    else
                        Tween(toggleBackground, {BackgroundColor3 = Colors.Secondary}, 0.2)
                        Tween(toggleButton, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.2)
                    end
                    callback(toggled)
                end
            end)
            
            local toggle = {
                Container = toggleContainer,
                Value = toggled
            }
            
            function toggle:SetValue(value)
                toggled = value
                if toggled then
                    Tween(toggleBackground, {BackgroundColor3 = Colors.Accent}, 0.2)
                    Tween(toggleButton, {Position = UDim2.new(1, -18, 0.5, 0)}, 0.2)
                else
                    Tween(toggleBackground, {BackgroundColor3 = Colors.Secondary}, 0.2)
                    Tween(toggleButton, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.2)
                end
                callback(toggled)
            end
            
            return toggle
        end
        
        -- Slider
        function section:AddSlider(text, min, max, default, callback)
            min = min or 0
            max = max or 100
            default = default or min
            
            local sliderContainer = Create("Frame", {
                Name = "SliderContainer",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 50),
                Parent = section.Items
            })
            
            local label = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sliderContainer
            })
            
            local valueLabel = Create("TextLabel", {
                Name = "Value",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -30, 0, 0),
                Size = UDim2.new(0, 30, 0, 20),
                Font = Enum.Font.Gotham,
                Text = tostring(default),
                TextColor3 = Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = sliderContainer
            })
            
            local sliderBackground = Create("Frame", {
                Name = "Background",
                BackgroundColor3 = Colors.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 0, 10),
                Parent = sliderContainer
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 5),
                Parent = sliderBackground
            })
            
            local sliderFill = Create("Frame", {
                Name = "Fill",
                BackgroundColor3 = Colors.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                Parent = sliderBackground
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 5),
                Parent = sliderFill
            })
            
            local sliderButton = Create("TextButton", {
                Name = "Button",
                BackgroundColor3 = Colors.Accent,
                BorderSizePixel = 0,
                Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
                Size = UDim2.new(0, 15, 0, 15),
                Text = "",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Parent = sliderBackground
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderButton
            })
            
            local dragging = false
            
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * pos)
                
                Tween(sliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                Tween(sliderButton, {Position = UDim2.new(pos, 0, 0.5, 0)}, 0.1)
                
                valueLabel.Text = tostring(value)
                callback(value)
            end
            
            sliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            sliderButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            sliderBackground.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    updateSlider(input)
                    dragging = true
                end
            end)
            
            sliderBackground.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
            
            local slider = {
                Container = sliderContainer,
                Value = default
            }
            
            function slider:SetValue(value)
                value = math.clamp(value, min, max)
                local pos = (value - min) / (max - min)
                
                Tween(sliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                Tween(sliderButton, {Position = UDim2.new(pos, 0, 0.5, 0)}, 0.1)
                
                valueLabel.Text = tostring(value)
                callback(value)
            end
            
            return slider
        end
        
        -- Dropdown
        function section:AddDropdown(text, options, default, callback)
            local dropdown = {}
            local isOpen = false
            local selected = default or options[1]
            
            local dropdownContainer = Create("Frame", {
                Name = "DropdownContainer",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 50),
                ClipsDescendants = true,
                Parent = section.Items
            })
            
            local label = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdownContainer
            })
            
            local dropdownButton = Create("TextButton", {
                Name = "Button",
                BackgroundColor3 = Colors.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 0, 25),
                Font = Enum.Font.Gotham,
                Text = selected,
                TextColor3 = Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdownContainer
            })
            
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                Parent = dropdownButton
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = dropdownButton
            })
            
            local dropdownIcon = Create("TextLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -20, 0, 0),
                Size = UDim2.new(0, 20, 1, 0),
                Font = Enum.Font.Gotham,
                Text = "▼",
                TextColor3 = Colors.Text,
                TextSize = 12,
                Parent = dropdownButton
            })
            
            local optionsContainer = Create("Frame", {
                Name = "Options",
                BackgroundColor3 = Colors.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 55),
                Size = UDim2.new(1, 0, 0, 0),
                Visible = false,
                Parent = dropdownContainer
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = optionsContainer
            })
            
            local optionsList = Create("ScrollingFrame", {
                Name = "List",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 4,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Parent = optionsContainer
            })
            
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = optionsList
            })
            
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5),
                Parent = optionsList
            })
            
            -- Create option buttons
            for _, option in ipairs(options) do
                local optionButton = Create("TextButton", {
                    Name = option,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 25),
                    Font = Enum.Font.Gotham,
                    Text = option,
                    TextColor3 = Colors.Text,
                    TextSize = 14,
                    Parent = optionsList
                })
                
                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10),
                    Parent = optionButton
                })
                
                optionButton.MouseButton1Click:Connect(function()
                    selected = option
                    dropdownButton.Text = selected
                    isOpen = false
                    optionsContainer.Visible = false
                    Tween(dropdownContainer, {Size = UDim2.new(1, 0, 0, 50)}, 0.2)
                    Tween(dropdownIcon, {Rotation = 0}, 0.2)
                    callback(selected)
                end)
            end
            
            dropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    optionsContainer.Visible = true
                    optionsContainer.Size = UDim2.new(1, 0, 0, math.min(#options * 25 + 10, 150))
                    Tween(dropdownContainer, {Size = UDim2.new(1, 0, 0, 60 + optionsContainer.Size.Y.Offset)}, 0.2)
                    Tween(dropdownIcon, {Rotation = 180}, 0.2)
                else
                    Tween(dropdownContainer, {Size = UDim2.new(1, 0, 0, 50)}, 0.2)
                    Tween(dropdownIcon, {Rotation = 0}, 0.2)
                    task.delay(0.2, function()
                        optionsContainer.Visible = false
                    end)
                end
            end)
            
            dropdown.Container = dropdownContainer
            dropdown.Selected = selected
            
            function dropdown:SetValue(value)
                if table.find(options, value) then
                    selected = value
                    dropdownButton.Text = selected
                    callback(selected)
                end
            end
            
            return dropdown
        end
        
        -- Color Picker
        function section:AddColorPicker(text, default, callback)
            default = default or Color3.fromRGB(255, 255, 255)
            
            local colorPickerContainer = Create("Frame", {
                Name = "ColorPickerContainer",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 50),
                Parent = section.Items
            })
            
            local label = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -50, 0, 30),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = colorPickerContainer
            })
            
            local colorDisplay = Create("TextButton", {
                Name = "ColorDisplay",
                BackgroundColor3 = default,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -40, 0, 5),
                Size = UDim2.new(0, 30, 0, 20),
                Text = "",
                Parent = colorPickerContainer
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = colorDisplay
            })
            
            colorDisplay.MouseButton1Click:Connect(function()
                -- Here you would normally open a color picker UI
                -- But for simplicity, we'll just cycle through some preset colors
                local colors = {
                    Color3.fromRGB(255, 0, 0),   -- Red
                    Color3.fromRGB(255, 165, 0), -- Orange
                    Color3.fromRGB(255, 255, 0), -- Yellow
                    Color3.fromRGB(0, 255, 0),   -- Green
                    Color3.fromRGB(0, 0, 255),   -- Blue
                    Color3.fromRGB(128, 0, 128), -- Purple
                    Color3.fromRGB(255, 255, 255) -- White
                }
                
                local currentColor = colorDisplay.BackgroundColor3
                local nextColorIndex = 1
                
                for i, color in ipairs(colors) do
                    if currentColor == color then
                        nextColorIndex = (i % #colors) + 1
                        break
                    end
                end
                
                colorDisplay.BackgroundColor3 = colors[nextColorIndex]
                callback(colors[nextColorIndex])
            end)
            
            local colorPicker = {
                Container = colorPickerContainer,
                Value = default
            }
            
            function colorPicker:SetValue(color)
                colorDisplay.BackgroundColor3 = color
                callback(color)
            end
            
            return colorPicker
        end
        
        -- TextBox
        function section:AddTextBox(text, default, callback)
            local textBoxContainer = Create("Frame", {
                Name = "TextBoxContainer",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 50),
                Parent = section.Items
            })
            
            local label = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = textBoxContainer
            })
            
            local textBox = Create("TextBox", {
                Name = "TextBox",
                BackgroundColor3 = Colors.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 0, 25),
                Font = Enum.Font.Gotham,
                Text = default or "",
                TextColor3 = Colors.Text,
                TextSize = 14,
                PlaceholderText = "Enter text...",
                Parent = textBoxContainer
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = textBox
            })
            
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                Parent = textBox
            })
            
            textBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    callback(textBox.Text)
                end
            end)
            
            local textBoxObj = {
                Container = textBoxContainer,
                Value = default or ""
            }
            
            function textBoxObj:SetValue(value)
                textBox.Text = value
                callback(value)
            end
            
            return textBoxObj
        end
        
        -- Label
        function section:AddLabel(text)
            local label = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Colors.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section.Items
            })
            
            local labelObj = {
                Instance = label
            }
            
            function labelObj:SetText(newText)
                label.Text = newText
            end
            
            return labelObj
        end
        
        return section
    end
    
    return tab
end

-- Select a tab
function Library:SelectTab(name)
    for _, tab in ipairs(self.Tabs) do
        if tab.Button.Text == name then
            tab.Indicator.Visible = true
            tab.Container.Visible = true
            tab.Button.TextColor3 = Colors.Accent
            self.ActiveTab = tab
        else
            tab.Indicator.Visible = false
            tab.Container.Visible = false
            tab.Button.TextColor3 = Colors.TextDark
        end
    end
end

-- Notification function
function Library:Notify(title, message, duration)
    duration = duration or 3
    
    if not self.NotifContainer then
        self.NotifContainer = Create("Frame", {
            Name = "NotificationContainer",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -20, 0, 20),
            Size = UDim2.new(0, 250, 1, -40),
            AnchorPoint = Vector2.new(1, 0),
            Parent = self.ScreenGui
        })
        
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = self.NotifContainer
        })
    end
    
    local notification = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.NotifContainer
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = notification
    })
    
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(1, -30, 0, 20),
        Font = Enum.Font.GothamSemibold,
        Text = title,
        TextColor3 = Colors.Accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification
    })
    
    local messageLabel = Create("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 35),
        Size = UDim2.new(1, -30, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Enum.Font.Gotham,
        Text = message,
        TextColor3 = Colors.Text,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification
    })
    
    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 15),
        Parent = notification
    })
    
    notification.Position = UDim2.new(1, 250, 0, 0)
    Tween(notification, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
    
    task.delay(duration, function()
        Tween(notification, {Position = UDim2.new(1, 250, 0, 0)}, 0.3)
        task.delay(0.3, function()
            notification:Destroy()
        end)
    end)
end

-- Make library globally accessible
if getgenv then
    for k, v in pairs(Library) do
        getgenv().MenuLib[k] = v
    end
end

return Library
