local aa={
Window=nil,
Theme=nil,
Creator=a.load'a',
LocalizationModule=a.load'b',
NotificationModule=a.load'c',
Themes=a.load'd',
Transparent=false,

TransparencyValue=.15,

UIScale=1,


Version="1.6.45",

Services=a.load'h',

OnThemeChangeFunction=nil,
}


local ac=game:GetService"HttpService"


local ae=ac:JSONDecode(a.load'i')
if ae then
aa.Version=ae.version

end

local af=a.load'm'local ag=

aa.Services

local ah=aa.Themes
local ai=aa.Creator

local aj=ai.New local ak=
ai.Tween

ai.Themes=ah

local al=a.load'q'local am=

game:GetService"Players"and game:GetService"Players".LocalPlayer or nil


local an=protectgui or(syn and syn.protect_gui)or function()end

local ao=gethui and gethui()or game.CoreGui


aa.ScreenGui=aj("ScreenGui",{
Name="WindUI",
Parent=ao,
IgnoreGuiInset=true,
ScreenInsets="None",
},{
aj("UIScale",{
Scale=aa.Scale,
}),
aj("Folder",{
Name="Window"
}),






aj("Folder",{
Name="KeySystem"
}),
aj("Folder",{
Name="Popups"
}),
aj("Folder",{
Name="ToolTips"
})
})

aa.NotificationGui=aj("ScreenGui",{
Name="WindUI/Notifications",
Parent=ao,
IgnoreGuiInset=true,
})
aa.DropdownGui=aj("ScreenGui",{
Name="WindUI/Dropdowns",
Parent=ao,
IgnoreGuiInset=true,
})
an(aa.ScreenGui)
an(aa.NotificationGui)
an(aa.DropdownGui)

ai.Init(aa)

math.clamp(aa.TransparencyValue,0,1)

local ap=aa.NotificationModule.Init(aa.NotificationGui)

function aa.Notify(ar,as)
as.Holder=ap.Frame
as.Window=aa.Window

return aa.NotificationModule.New(as)
end

function aa.SetNotificationLower(ar,as)
ap.SetLower(as)
end

function aa.SetFont(ar,as)
ai.UpdateFont(as)
end

function aa.OnThemeChange(ar,as)
aa.OnThemeChangeFunction=as
end

function aa.AddTheme(ar,as)
ah[as.Name]=as
return as
end

function aa.SetTheme(ar,as)
if ah[as]then
aa.Theme=ah[as]
ai.SetTheme(ah[as])

if aa.OnThemeChangeFunction then
aa.OnThemeChangeFunction(as)
end


return ah[as]
end
return nil
end

function aa.GetThemes(ar)
return ah
end
function aa.GetCurrentTheme(ar)
return aa.Theme.Name
end
function aa.GetTransparency(ar)
return aa.Transparent or false
end
function aa.GetWindowSize(ar)
return Window.UIElements.Main.Size
end
function aa.Localization(ar,as)
return aa.LocalizationModule:New(as,ai)
end

function aa.SetLanguage(ar,as)
if ai.Localization then
return ai.SetLanguage(as)
end
return false
end

function aa.ToggleAcrylic(ar,as)
if aa.Window and aa.Window.AcrylicPaint and aa.Window.AcrylicPaint.Model then
aa.Window.Acrylic=as
aa.Window.AcrylicPaint.Model.Transparency=as and 0.98 or 1
if as then
al.Enable()
else
al.Disable()
end
end
end


aa:SetTheme"Dark"
aa:SetLanguage(ai.Language)


function aa.Gradient(ar,as,at)
local au={}
local av={}

for aw,ax in next,as do
local ay=tonumber(aw)
if ay then
ay=math.clamp(ay/100,0,1)
table.insert(au,ColorSequenceKeypoint.new(ay,ax.Color))
table.insert(av,NumberSequenceKeypoint.new(ay,ax.Transparency or 0))
end
end

table.sort(au,function(ay,az)return ay.Time<az.Time end)
table.sort(av,function(ay,az)return ay.Time<az.Time end)


if#au<2 then
error"ColorSequence requires at least 2 keypoints"
end


local ay={
Color=ColorSequence.new(au),
Transparency=NumberSequence.new(av),
}

if at then
for az,aA in pairs(at)do
ay[az]=aA
end
end

return ay
end


function aa.Popup(ar,as)
as.WindUI=aa
return a.load'r'.new(as)
end


function aa.CreateWindow(ar,as)
local at=a.load'T'

if not isfolder"WindUI"then
makefolder"WindUI"
end
if as.Folder then
makefolder(as.Folder)
else
makefolder(as.Title)
end

as.WindUI=aa
as.Parent=aa.ScreenGui.Window

if aa.Window then
warn"You cannot create more than one window"
return
end

local au=true

local av=ah[as.Theme or"Dark"]


ai.SetTheme(av)


local aw=gethwid or function()
return game:GetService"Players".LocalPlayer.UserId
end

local ax=aw()

if as.KeySystem then
au=false

local function loadKeysystem()
af.new(as,ax,function(ay)au=ay end)
end

local ay=as.Folder.."/"..ax..".key"

if not as.KeySystem.API then
if as.KeySystem.SaveKey and isfile(ay)then
local az=readfile(ay)
local aA=(type(as.KeySystem.Key)=="table")
and table.find(as.KeySystem.Key,az)
or tostring(as.KeySystem.Key)==tostring(az)

if aA then
au=true
else
loadKeysystem()
end
else
loadKeysystem()
end
else
if isfile(ay)then
local az=readfile(ay)
local aA=false

for aB,aC in next,as.KeySystem.API do
local aD=aa.Services[aC.Type]
if aD then
local aE={}
for b,e in next,aD.Args do
table.insert(aE,aC[e])
end

local g=aD.New(table.unpack(aE))
local h=g.Verify(az)
if h then
aA=true
break
end
end
end

au=aA
if not aA then loadKeysystem()end
else
loadKeysystem()
end
end

repeat task.wait()until au
end

local scale = 1
local sizeDialog = ao:Dialog{
Title = "Choose your GUI size",
Content = "Select an option:",
Buttons = {
{Title = "1", Callback = function() scale = 0.6 sizeDialog:Close() end, Variant = "Secondary"},
{Title = "2", Callback = function() scale = 1 sizeDialog:Close() end, Variant = "Secondary"},
{Title = "3", Callback = function() scale = 1.4 sizeDialog:Close() end, Variant = "Secondary"}
}
}
repeat task.wait() until not sizeDialog.UIElements.MainContainer.Visible
ao:SetUIScale(scale)

local ay=at(as)

aa.Transparent=as.Transparent
aa.Window=ay

if as.Acrylic then
al.init()
end













return ay
end

return aa
