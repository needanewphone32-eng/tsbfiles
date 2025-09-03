-- WindUI full script (ready for exiecutors)
-- Filename: WindUI_FULL_ready_EXEC_v2.lua
-- Discord: https://discord.gg/NYJtHJaQ

local Players = game:GetService('Players')
local TweenService = game:GetService('TweenService')
local UserInputService = game:GetService('UserInputService')
local HttpService = game:GetService('HttpService')

-- Safe clipboard wrapper
local function safeSetClipboard(text)
    if type(text) ~= 'string' then text = tostring(text) end
    if type(setclipboard) == 'function' then pcall(setclipboard, text); return true end
    if type(toclipboard) == 'function' then pcall(toclipboard, text); return true end
    if syn and type(syn.set_clipboard) == 'function' then pcall(syn.set_clipboard, text); return true end
    warn('safeSetClipboard: clipboard API not available in this environment')
    return false
end

-- Safe http request wrapper
local function safeRequest(opts)
    opts = opts or {}
    if syn and type(syn.request) == 'function' then return syn.request(opts) end
    if type(request) == 'function' then return request(opts) end
    if type(http_request) == 'function' then return http_request(opts) end
    local method = (opts.Method or opts.method or 'GET'):upper()
    local url = opts.Url or opts.url or opts.url
    if not url then return { StatusCode = 0, Body = nil } end
    local ok, body = pcall(function()
        if method == 'GET' then return HttpService:GetAsync(url, true) end
        if method == 'POST' then return HttpService:PostAsync(url, opts.Body or '', Enum.HttpContentType.ApplicationJson) end
        return HttpService:GetAsync(url, true)
    end)
    if ok then return { StatusCode = 200, Body = body } end
    return { StatusCode = 0, Body = nil }
end

-- Safe loader for WindUI (tries multiple strategies)
local function loadWindUI()
    if rawget(_G, '__WINDUI_OBJ__') and type(_G.__WINDUI_OBJ__) == 'table' then return _G.__WINDUI_OBJ__ end
    local sources = { 'https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua' }
    for _, url in ipairs(sources) do
        local ok, content = pcall(function() return game:HttpGet(url, true) end)
        if ok and content and content:match('%S') then
            local loader = loadstring or load
            if loader then
                local f_ok, f = pcall(function() return loader(content) end)
                if f_ok and type(f) == 'function' then
                    local ok2, lib = pcall(f)
                    if ok2 and type(lib) == 'table' then _G.__WINDUI_OBJ__ = lib; return lib end
                end
            else
                local ok2, res = pcall(function() return assert(load(content))() end)
                if ok2 and type(res) == 'table' then _G.__WINDUI_OBJ__ = res; return res end
            end
        end
    end
    local ReplicatedStorage = game:GetService('ReplicatedStorage')
    local ServerStorage = game:GetService('ServerStorage')
    local player = Players.LocalPlayer
    local places = { ReplicatedStorage, ServerStorage }
    if player and player:FindFirstChild('PlayerScripts') then table.insert(places, player.PlayerScripts) end
    for _, parent in ipairs(places) do
        if parent then
            local mod = parent:FindFirstChild('WindUI')
            if mod and typeof(mod) == 'Instance' then
                local ok, lib = pcall(function() return require(mod) end)
                if ok and type(lib) == 'table' then _G.__WINDUI_OBJ__ = lib; return lib end
            end
        end
    end
    return nil
end

local WindUI = loadWindUI()
if not WindUI or type(WindUI) ~= 'table' then warn('WindUI could not be loaded. Aborting.'); return end

local function createMainUI(selectedSize)
    
    WindUI:Localization({
        Enabled = true,
        Prefix = "loc:",
        DefaultLanguage = "en",
        Translations = {
            --[[["ru"] = {
                ["WINDUI_EXAMPLE"] = "WindUI ÃÅ¸Ã‘â‚¬ÃÂ¸ÃÂ¼ÃÂµÃ‘â‚¬",
                ["WELCOME"] = "Ãâ€ÃÂ¾ÃÂ±Ã‘â‚¬ÃÂ¾ ÃÂ¿ÃÂ¾ÃÂ¶ÃÂ°ÃÂ»ÃÂ¾ÃÂ²ÃÂ°Ã‘â€šÃ‘Å’ ÃÂ² WindUI!",
                ["LIB_DESC"] = "Ãâ€˜ÃÂ¸ÃÂ±ÃÂ»ÃÂ¸ÃÂ¾Ã‘â€šÃÂµÃÂºÃÂ° ÃÂ´ÃÂ»ÃÂ¯ Ã‘ÂÃÂ¾ÃÂ·ÃÂ´ÃÂ°ÃÂ½ÃÂ¸Ã‘Â ÃÂºÃ‘â‚¬ÃÂ°Ã‘ÂÃÂ¸ÃÂ²Ã‘â€¹Ã‘â€¦ ÃÂ¸ÃÂ½Ã‘â€šÃÂµÃ‘â‚¬Ã‘â€žÃÂµÃÂ¹Ã‘ÂÃÂ¾ÃÂ²",
                ["SETTINGS"] = "ÃÂÃÂ°Ã‘ÂÃ‘â€šÃ‘â‚¬ÃÂ¾ÃÂ¹ÃÂºÃÂ¸",
                ["APPEARANCE"] = "Ãâ€™ÃÂ½ÃÂµÃ‘Ë†ÃÂ½ÃÂ¸ÃÂ¹ ÃÂ²ÃÂ¸ÃÂ´",
                ["FEATURES"] = "ÃÂ¤Ã‘Æ’ÃÂ½ÃÂºÃ‘â€ ÃÂ¸ÃÂ¾ÃÂ½ÃÂ°ÃÂ»",
                ["UTILITIES"] = "ÃËœÃÂ½Ã‘ÂÃ‘â€šÃ‘â‚¬Ã‘Æ’ÃÂ¼ÃÂµÃÂ½Ã‘â€šÃ‘â€¹",
                ["UI_ELEMENTS"] = "UI ÃÂ­ÃÂ»ÃÂµÃÂ¼ÃÂµÃÂ½Ã‘â€šÃ‘â€¹",
                ["CONFIGURATION"] = "ÃÅ¡ÃÂ¾ÃÂ½Ã‘â€žÃÂ¸ÃÂ³Ã‘Æ’Ã‘â‚¬ÃÂ°Ã‘â€ ÃÂ¸Ã‘Â",
                ["SAVE_CONFIG"] = "ÃÂ¡ÃÂ¾Ã‘â‚¬ÃÂ°ÃÂ½ÃÂ¸Ã‘â€šÃ‘Å’ ÃÂºÃÂ¾ÃÂ½Ã‘â€žÃÂ¸ÃÂ³Ã‘Æ’Ã‘â‚¬ÃÂ°Ã‘â€ ÃÂ¸Ã‘Å½",
                ["LOAD_CONFIG"] = "Ãâ€ÃÂ°ÃÂ³Ã‘â‚¬Ã‘Æ’ÃÂ·ÃÂ¸Ã‘â€šÃ‘Å’ ÃÂºÃÂ¾ÃÂ½Ã‘â€žÃÂ¸ÃÂ³Ã‘Æ’Ã‘â‚¬ÃÂ°Ã‘â€ ÃÂ¸Ã‘Å½",
                ["THEME_SELECT"] = "Ãâ€™Ã‘â€¹ÃÂ±ÃÂµÃ‘â‚¬ÃÂ¸Ã‘â€šÃÂµ Ã‘â€šÃÂµÃÂ¼Ã‘Æ’",
                ["TRANSPARENCY"] = "ÃÅ¸Ã‘â‚¬ÃÂ¾ÃÂ·Ã‘â‚¬ÃÂ°Ã‘â€¡ÃÂ½ÃÂ¾Ã‘ÂÃ‘â€šÃ‘Å’ ÃÂ¾ÃÂºÃÂ½ÃÂ°"
            },--]]
            ["en"] = {
                ["WINDUI_EXAMPLE"] = "WindUI Example",
                ["WELCOME"] = "Welcome to WindUI!",
                ["LIB_DESC"] = "Beautiful UI library for Roblox",
                ["SETTINGS"] = "Settings",
                ["APPEARANCE"] = "Appearance",
                ["FEATURES"] = "Features",
                ["UTILITIES"] = "Utilities",
                ["UI_ELEMENTS"] = "UI Elements",
                ["CONFIGURATION"] = "Configuration",
                ["SAVE_CONFIG"] = "Save Configuration",
                ["LOAD_CONFIG"] = "Load Configuration",
                ["THEME_SELECT"] = "Select Theme",
                ["TRANSPARENCY"] = "Window Transparency"
            }
        }
    })
    
    WindUI.TransparencyValue = 0.2
    WindUI:SetTheme("Dark")
    
    local function gradient(text, startColor, endColor)
        local result = ""
        for i = 1, #text do
            local t = (i - 1) / (#text - 1)
            local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
            local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
            local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
            result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, text:sub(i, i))
        end
        return result
    end

local sizes = { { Name = 'Small', Size = UDim2.new(0,500,0,400) }, { Name = 'Medium', Size = UDim2.new(0,600,0,500) }, { Name = 'Large', Size = UDim2.new(0,700,0,600) } }

local function createSizeSelector()
    local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local playerGui = player:WaitForChild('PlayerGui')
    local old = playerGui:FindFirstChild('Select you gui size')
    if old then pcall(function() old:Destroy() end) end
    local screenGui = Instance.new('ScreenGui')
    screenGui.Name = 'Select you gui size'
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local frame = Instance.new('Frame')
    frame.Size = UDim2.new(0, 340, 0, 180)
    frame.Position = UDim2.new(0.5, -170, 0.5, -90)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    local corner = Instance.new('UICorner', frame); corner.CornerRadius = UDim.new(0, 10)
    local title = Instance.new('TextLabel', frame)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
    title.Text = 'Select you gui size'
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.BorderSizePixel = 0
    local titleCorner = Instance.new('UICorner', title); titleCorner.CornerRadius = UDim.new(0, 10)
    local container = Instance.new('Frame', frame)
    container.Size = UDim2.new(1, -40, 0, 84)
    container.Position = UDim2.new(0, 20, 0, 60)
    container.BackgroundTransparency = 1
    local layout = Instance.new('UIListLayout', container)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 10)
    for i, info in ipairs(sizes) do
        local b = Instance.new('TextButton', container)
        b.Size = UDim2.new(0, 96, 0, 44)
        b.BackgroundColor3 = Color3.fromRGB(63, 63, 70)
        b.BorderSizePixel = 0
        b.Text = info.Name
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.Gotham
        b.TextSize = 16
        local bc = Instance.new('UICorner', b); bc.CornerRadius = UDim.new(0, 8)
        b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(82,82,91)}):Play() end)
        b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(63,63,70)}):Play() end)
        b.MouseButton1Click:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(112,112,122)}):Play()
            task.delay(0.09, function() TweenService:Create(b, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(82,82,91)}):Play() end)
            task.delay(0.18, function() pcall(function() screenGui:Destroy() end); pcall(function() createMainUI(info.Size) end) end)
        end)
    end
    ); pcall(function() WindUI:Notify({Title = 'Discord', Content = 'Invite copied to clipboard!'}) end) end)
end

UserInputService.InputBegan:Connect(function(input, gp) if gp then return end if input.KeyCode == Enum.KeyCode.F9 then local player = Players.LocalPlayer if player and player:FindFirstChild('PlayerGui') and not player.PlayerGui:FindFirstChild('Select you gui size') then createSizeSelector() end end end)


    
    WindUI:Popup({
        Title = gradient("WindUI Demo", Color3.fromHex("#6A11CB"), Color3.fromHex("#2575FC")),
        Icon = "sparkles",
        Content = "loc:LIB_DESC",
        Buttons = {
            {
                Title = "Get Started",
                Icon = "arrow-right",
                Variant = "Primary",
                Callback = function() end
            }
        }
    })
    
    
    -- Add your service to get key 
    --[[
    WindUI.Services.mysuperservicetogetkey = {
        Name = "My Super Service",
        Icon = "droplet", -- lucide or rbxassetid or raw link to img
        
        Args = { "ServiceId" }, --       <- \
        --                                   |
        -- important!!!!!!!!!!!!!!!          |
        New = function(ServiceId) -- <------ | Args!!!!!!!!!!!!
            
            function validateKey(key) -- <--- this too important!!!
                -- your function to validate key
                -- see examples at src/utils/
                
                if not key then
                    return false, "Key is invalid!" 
                    
                end
                
                return true, "Key is valid!" 
            end
            
            function copyLink()
                return safeSetClipboard("link to key system service.")
            end
            
            return {
                -- Ã¢â€ â€œ do not change this!!1!1!1!1!1!!1!100
                Verify = validateKey, -- <-----  THIS TOO IMPORTANT!!!!!
                Copy = copyLink -- <-------- IMPORTANT!1!1!1!1!1!1!11!
                -- Ã¢â€ â€˜ do not change this!!1!1!1!1!1!!1!100
            }
        end
    }
    ]]
    
    local Window = WindUI:CreateWindow({
        Title = "loc:WINDUI_EXAMPLE",
        Icon = "geist:window",
        Author = "loc:WELCOME",
        Folder = "WindUI_Example",
        Size = (selectedSize or UDim2.fromOffset(580,490)),
        Theme = "Dark",
        -- Background = WindUI:Gradient({
        --     ["0"] = { Color = Color3.fromHex("#0f0c29"), Transparency = 1 },
        --     ["100"] = { Color = Color3.fromHex("#302b63"), Transparency = 0.9 },
        -- }, {
        --     Rotation = 45,
        -- }),
        --Background = "video:https://cdn.discordapp.com/attachments/1337368451865645096/1402703845657673878/VID_20250616_180732_158.webm?ex=68958a01&is=68943881&hm=164c5b04d1076308b38055075f7eb0653c1d73bec9bcee08e918a31321fe3058&",
        User = {
            Enabled = true,
            Anonymous = true,
            Callback = function()
                WindUI:Notify({
                    Title = "User Profile",
                    Content = "User profile clicked!",
                    Duration = 3
                })
            end
        },
        Acrylic = false,
        HideSearchBar = false,
        SideBarWidth = 200,
        -- KeySystem = { -- <- Ã¢â€ â€œ remove this all, if you dont neet the key system
        --     -- Key = { "1234", "5678" },  
        --     Note = "Example Key System. With platoboost, etc.",
        --     -- URL = "https://github.com/Footagesus/WindUI",
        --     -- Thumbnail = {
        --     --     Image = "rbxassetid://",
        --     --     Title = "Thumbnail",
        --     --     Width = 180, -- default 200
        --     -- },
        --     API = {
        --         {   
        --             -- Title = "Platoboost", -- optional 
        --             -- Desc = "Click to copy.", -- optional
        --             -- Icon = "rbxassetid://", -- optional
        
        --             Type = "platoboost", -- type: platoboost, ...
        --             ServiceId = 5541, -- service id
        --             Secret = "1eda3b70-aab4-4394-82e4-4e7f507ae198", -- platoboost secret
        --         },
        --         {   
        --             -- Title = "Other service", -- optional 
        --             -- Desc = nil, -- optional
        --             -- Icon = "rbxassetid://", -- optional
        
        --             Type = "pandadevelopment", -- type: platoboost, ...
        --             ServiceId = "windui", -- service id
        --         },
        --         {   
        --             Type = "luarmor",
        --             ScriptId = "...",
        --             Discord = "https://discord.com/invite/...",
        --         },
        --         { -- Custom service ( Ã¢â€ â€˜Ã¢â€ â€˜ look at line 73 Ã¢â€ â€˜Ã¢â€ â€˜ )
        --             Type = "mysuperservicetogetkey",
        --             ServiceId = 42,
        --         }
        --     },
        --     SaveKey = true,
        -- },
        -- KeySystem = {
        --     Key = { "pisun" },
        --     Thumbnail = {
        --         Image = "rbxassetid://88271032881974",
        --         Width = 180, -- default 200
        --     }
        -- }
    })
    
    
    -- OPTIONAL   >:(
    
    Window:Tag({
        Title = "v1.6.4",
        Color = Color3.fromHex("#30ff6a")
    })
    Window:Tag({
        Title = "Beta",
        Color = Color3.fromHex("#315dff")
    })
    local TimeTag = Window:Tag({
        Title = "--:--",
        Radius = 0,
        --Color = Color3.fromHex("#000000"),
        Color = WindUI:Gradient({
            ["0"]   = { Color = Color3.fromHex("#FF0F7B"), Transparency = 0 },
            ["100"] = { Color = Color3.fromHex("#F89B29"), Transparency = 0 },
        }, {
            Rotation = 45,
        }),
    })
    
    
    local hue = 0
    
    -- Rainbow effect & Time 
    task.spawn(function()
    	while true do
    		local now = os.date("*t")
    		local hours = string.format("%02d", now.hour)
    		local minutes = string.format("%02d", now.min)
    		
    		hue = (hue + 0.01) % 1
    		local color = Color3.fromHSV(hue, 1, 1)
    		
    		TimeTag:SetTitle(hours .. ":" .. minutes)
    		--TimeTag:SetColor(color)
    
    		task.wait(0.06)
    	end
    end)
    
    
    Window:CreateTopbarButton("theme-switcher", "moon", function()
        WindUI:SetTheme(WindUI:GetCurrentTheme() == "Dark" and "Light" or "Dark")
        WindUI:Notify({
            Title = "Theme Changed",
            Content = "Current theme: "..WindUI:GetCurrentTheme(),
            Duration = 2
        })
    end, 990)
    
    local Tabs = {
        Main = Window:Section({ Title = "loc:FEATURES", Opened = true }),
        Settings = Window:Section({ Title = "loc:SETTINGS", Opened = true }),
        Utilities = Window:Section({ Title = "loc:UTILITIES", Opened = true })
    }
    
    local TabHandles = {
        Elements = Tabs.Main:Tab({ Title = "loc:UI_ELEMENTS", Icon = "layout-grid", Desc = "UI Elements Example" }),
        Appearance = Tabs.Settings:Tab({ Title = "loc:APPEARANCE", Icon = "brush" }),
        Config = Tabs.Utilities:Tab({ Title = "loc:CONFIGURATION", Icon = "settings" })
    }
    
    TabHandles.Elements:Paragraph({
        Title = "Interactive Components",
        Desc = "Explore WindUI's powerful elements",
        Image = "component",
        ImageSize = 20,
        Color = Color3.fromHex("#30ff6a"),
    })
    
    TabHandles.Elements:Divider()
    
    local ElementsSection = TabHandles.Elements:Section({
        Title = "Section Example",
        Icon = "bird",
    })
    
    local toggleState = false
    local featureToggle = ElementsSection:Toggle({
        Title = "Enable Features",
        --Desc = "Unlocks additional functionality",
        Value = false,
        Callback = function(state) 
            toggleState = state
            WindUI:Notify({
                Title = "Features",
                Content = state and "Features Enabled" or "Features Disabled",
                Icon = state and "check" or "x",
                Duration = 2
            })
        end
    })
    
    local intensitySlider = ElementsSection:Slider({
        Title = "Effect Intensity",
        Desc = "Adjust the effect strength",
        Value = { Min = 0, Max = 100, Default = 50 },
        Callback = function(value)
            print("Intensity set to:", value)
        end
    })
    
    local modeDropdown = ElementsSection:Dropdown({
        Title = "Select Mode",
        Values = { "Standard", "Advanced", "Expert" },
        Value = "Standard",
        Callback = function(option)
            WindUI:Notify({
                Title = "Mode Changed",
                Content = "Selected: "..option,
                Duration = 2
            })
        end
    })
    
    ElementsSection:Divider()
    
    ElementsSection:Button({
        Title = "Show Notification",
        Icon = "bell",
        Callback = function()
            WindUI:Notify({
                Title = "Hello WindUI!",
                Content = "This is a sample notification",
                Icon = "bell",
                Duration = 3
            })
        end
    })
    
    ElementsSection:Colorpicker({
        Title = "Select Color",
        --Desc = "Select coloe",
        Default = Color3.fromHex("#30ff6a"),
        Transparency = 0, -- enable transparency
        Callback = function(color, transparency)
            WindUI:Notify({
                Title = "Color Changed",
                Content = "New color: "..color:ToHex().."\nTransparency: "..transparency,
                Duration = 2
            })
        end
    })
    
    ElementsSection:Code({
        Title = "my_code.luau",
        Code = [[print("Hello world!")]],
        OnCopy = function()
            print("Copied to clipboard!")
        end
    })
    
    TabHandles.Appearance:Paragraph({
        Title = "Customize Interface",
        Desc = "Personalize your experience",
        Image = "palette",
        ImageSize = 20,
        Color = "White"
    })
    
    local themes = {}
    for themeName, _ in pairs(WindUI:GetThemes()) do
        table.insert(themes, themeName)
    end
    table.sort(themes)
    
    local canchangetheme = true
    local canchangedropdown = true
    
    
    
    local themeDropdown = TabHandles.Appearance:Dropdown({
        Title = "loc:THEME_SELECT",
        Values = themes,
        Value = "Dark",
        Callback = function(theme)
            canchangedropdown = false
            WindUI:SetTheme(theme)
            WindUI:Notify({
                Title = "Theme Applied",
                Content = theme,
                Icon = "palette",
                Duration = 2
            })
            canchangedropdown = true
        end
    })
    
    local transparencySlider = TabHandles.Appearance:Slider({
        Title = "loc:TRANSPARENCY",
        Value = { 
            Min = 0,
            Max = 1,
            Default = 0.2,
        },
        Step = 0.1,
        Callback = function(value)
            WindUI.TransparencyValue = tonumber(value)
            Window:ToggleTransparency(tonumber(value) > 0)
        end
    })
    
    local ThemeToggle = TabHandles.Appearance:Toggle({
        Title = "Enable Dark Mode",
        Desc = "Use dark color scheme",
        Value = true,
        Callback = function(state)
            if canchangetheme then
                WindUI:SetTheme(state and "Dark" or "Light")
            end
            if canchangedropdown then
                themeDropdown:Select(state and "Dark" or "Light")
            end
        end
    })
    
    WindUI:OnThemeChange(function(theme)
        canchangetheme = false
        ThemeToggle:Set(theme == "Dark")
        canchangetheme = true
    end)
    
    
    TabHandles.Appearance:Button({
        Title = "Create New Theme",
        Icon = "plus",
        Callback = function()
            Window:Dialog({
                Title = "Create Theme",
                Content = "This feature is coming soon!",
                Buttons = {
                    {
                        Title = "OK",
                        Variant = "Primary"
                    }
                }
            })
        end
    })
    
    TabHandles.Config:Paragraph({
        Title = "Configuration Manager",
        Desc = "Save and load your settings",
        Image = "save",
        ImageSize = 20,
        Color = "White"
    })
    
    local configName = "default"
    local configFile = nil
    local MyPlayerData = {
        name = "Player1",
        level = 1,
        inventory = { "sword", "shield", "potion" }
    }
    
    TabHandles.Config:Input({
        Title = "Config Name",
        Value = configName,
        Callback = function(value)
            configName = value or "default"
        end
    })
    
    local ConfigManager = Window.ConfigManager
    if ConfigManager then
        ConfigManager:Init(Window)
        
        TabHandles.Config:Button({
            Title = "loc:SAVE_CONFIG",
            Icon = "save",
            Variant = "Primary",
            Callback = function()
                configFile = ConfigManager:CreateConfig(configName)
                
                configFile:Register("featureToggle", featureToggle)
                configFile:Register("intensitySlider", intensitySlider)
                configFile:Register("modeDropdown", modeDropdown)
                configFile:Register("themeDropdown", themeDropdown)
                configFile:Register("transparencySlider", transparencySlider)
                
                configFile:Set("playerData", MyPlayerData)
                configFile:Set("lastSave", os.date("%Y-%m-%d %H:%M:%S"))
                
                if configFile:Save() then
                    WindUI:Notify({ 
                        Title = "loc:SAVE_CONFIG", 
                        Content = "Saved as: "..configName,
                        Icon = "check",
                        Duration = 3
                    })
                else
                    WindUI:Notify({ 
                        Title = "Error", 
                        Content = "Failed to save config",
                        Icon = "x",
                        Duration = 3
                    })
                end
            end
        })
    
        TabHandles.Config:Button({
            Title = "loc:LOAD_CONFIG",
            Icon = "folder",
            Callback = function()
                configFile = ConfigManager:CreateConfig(configName)
                local loadedData = configFile:Load()
                
                if loadedData then
                    if loadedData.playerData then
                        MyPlayerData = loadedData.playerData
                    end
                    
                    local lastSave = loadedData.lastSave or "Unknown"
                    WindUI:Notify({ 
                        Title = "loc:LOAD_CONFIG", 
                        Content = "Loaded: "..configName.."\nLast save: "..lastSave,
                        Icon = "refresh-cw",
                        Duration = 5
                    })
                    
                    TabHandles.Config:Paragraph({
                        Title = "Player Data",
                        Desc = string.format("Name: %s\nLevel: %d\nInventory: %s", 
                            MyPlayerData.name, 
                            MyPlayerData.level, 
                            table.concat(MyPlayerData.inventory, ", "))
                    })
                else
                    WindUI:Notify({ 
                        Title = "Error", 
                        Content = "Failed to load config",
                        Icon = "x",
                        Duration = 3
                    })
                end
            end
        })
    else
        TabHandles.Config:Paragraph({
            Title = "Config Manager Not Available",
            Desc = "This feature requires ConfigManager",
            Image = "alert-triangle",
            ImageSize = 20,
            Color = "White"
        })
    end
    
    
    local footerSection = Window:Section({ Title = "WindUI " .. WindUI.Version })
    TabHandles.Config:Paragraph({
        Title = "Created with Ã¢ÂÂ¤Ã¯Â¸Â",
        Desc = "github.com/Footagesus/WindUI",
        Image = "github",
        ImageSize = 20,
        Color = "Grey",
        Buttons = {
            {
                Title = "Copy Link",
                Icon = "copy",
                Variant = "Tertiary",
                Callback = function()
                    safeSetClipboard("https://github.com/Footagesus/WindUI")
                    WindUI:Notify({
                        Title = "Copied!",
                        Content = "GitHub link copied to clipboard",
                        Duration = 2
                    })
                end
            }
        }
    })
    
    Window:OnClose(function()
        print("Window closed")
        
        if ConfigManager and configFile then
            configFile:Set("playerData", MyPlayerData)
            configFile:Set("lastSave", os.date("%Y-%m-%d %H:%M:%S"))
            configFile:Save()
            print("Config auto-saved on close")
        end
    end)
    
    Window:OnDestroy(function()
        print("Window destroyed")
    end)
end

createSizeSelector()
_G.__WINDUI_OBJ__ = WindUI
