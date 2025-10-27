
local StarterGui = game:GetService("StarterGui")

local function sendNoTestingNotification()
    local ok, err = pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "SCRIPT DOWN",
            Text = "The script is down please wait !",
            Icon = "rbxassetid://88536674439005",
            Duration = 10 
        })
    end)
    if not ok then
        warn("SendNotification failed:", err)
    end
end


sendNoTestingNotification()
