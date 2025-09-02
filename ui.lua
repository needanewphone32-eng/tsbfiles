-- Add this code before the main UI initialization
local presetGui = Instance.new("ScreenGui")
presetGui.Name = "PresetSelector"
presetGui.Parent = game.CoreGui
presetGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainUI = nil -- Will reference the main UI later

local function createPresetFrame()
    local darkTheme = a.load'd'().Dark
    
    local mainFrame = a.load'a'().New("Frame", {
        Size = UDim2.new(0, 300, 0, 200),
        Position = UDim2.new(0.5, -150, 0.5, -100),
        BackgroundColor3 = Color3.fromHex(darkTheme.Dialog),
        Parent = presetGui
    })
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = mainFrame
    
    local title = a.load'a'().New("TextLabel", {
        Text = "Select your GUI size",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromHex(darkTheme.Text),
        Font = a.load'a'().Font,
        TextSize = 18,
        Parent = mainFrame
    })
    
    local sizes = {
        Small = UDim2.new(0, 500, 0, 400),
        Medium = UDim2.new(0, 600, 0, 500),
        Large = UDim2.new(0, 700, 0, 600)
    }
    
    local buttonContainer = a.load'a'().New("Frame", {
        Size = UDim2.new(1, -40, 0, 100),
        Position = UDim2.new(0, 20, 0, 50),
        BackgroundTransparency = 1,
        Parent = mainFrame
    })
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.FillDirection = Enum.FillDirection.Vertical
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    uiListLayout.Parent = buttonContainer
    
    for name, size in pairs(sizes) do
        local button = a.load'a'().New("TextButton", {
            Text = name,
            Size = UDim2.new(0.8, 0, 0, 30),
            BackgroundColor3 = Color3.fromHex(darkTheme.Button),
            TextColor3 = Color3.fromHex(darkTheme.Text),
            Font = a.load'a'().Font,
            TextSize = 14,
            Parent = buttonContainer
        })
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            -- Set main UI size and show it
            if mainUI then
                mainUI.UIElements.Main.Size = size
                presetGui.Enabled = false
            end
        end)
    end
    
    -- Discord button
    local discordBtn = a.load'a'().New("TextButton", {
        Text = "D",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 1, -40),
        BackgroundColor3 = Color3.fromHex(darkTheme.Button),
        TextColor3 = Color3.fromHex(darkTheme.Text),
        Font = a.load'a'().Font,
        TextSize = 14,
        Parent = mainFrame
    })
    
    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0, 8)
    discordCorner.Parent = discordBtn
    
    discordBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/Q6HkNG4vwP")
        -- You can add a notification here if needed
    end)
    
    -- Keybind button
    local keybindBtn = a.load'a'().New("TextButton", {
        Text = "K",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -80, 1, -40),
        BackgroundColor3 = Color3.fromHex(darkTheme.Button),
        TextColor3 = Color3.fromHex(darkTheme.Text),
        Font = a.load'a'().Font,
        TextSize = 14,
        Parent = mainFrame
    })
    
    local keybindCorner = Instance.new("UICorner")
    keybindCorner.CornerRadius = UDim.new(0, 8)
    keybindCorner.Parent = keybindBtn
    
    keybindBtn.MouseButton1Click:Connect(function()
        -- Add keybind change functionality here
        print("Keybind change button clicked")
    end)
    
    return mainFrame
end

-- Create the preset frame
createPresetFrame()

-- Then later when creating your main UI, store a reference to it
-- mainUI = WindUI:CreateWindow(options)
