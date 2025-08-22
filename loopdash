-- // KIBA - True Loop Dash (Full Final Version) with fixed UI visibility
-- Place this LocalScript in StarterPlayerScripts

local animationIds = {
	["rbxassetid://10503381238"] = true,
	["rbxassetid://13379003796"] = true,
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- wait for LocalPlayer safely (in case script runs a hair early)
local player = Players.LocalPlayer
while not player do
	task.wait()
	player = Players.LocalPlayer
end

-- ensure PlayerGui exists
local playerGui = player:WaitForChild("PlayerGui")

local gui
local button         -- TextButton (clickable but visually transparent over frame)
local container      -- Frame behind the button that shows green background
local statusDot      -- small indicator dot
local toggleConnection
local systemEnabled = false

-- CONFIG (tweak these to change feel)
local DETECT_BUFFER = 0.05      -- 50 ms wait right after detecting the activating animation
local PRE_START_DELAY = 0.025   -- small pre-start delay before orbit begins
local LOOP_DURATION = 0.5       -- seconds spent orbiting
local NUM_LOOPS = 1             -- full revolutions around the target
local DASH_COUNT = 6            -- how many Q fires during loop
local LOOP_RADIUS = 4           -- orbit radius (studs)
local HEIGHT_OFFSET = 2         -- vertical offset while orbiting (studs)
local MIN_TARGET_DIST = 15      -- maximum distance to consider a nearby target
local COOLDOWN_SECONDS = 4      -- cooldown after loop
local SETTLE_DEPTH = 3          -- how many studs below target to end at (the "bottom")
local SETTLE_TWEEN_TIME = 0.12  -- tween time when settling to bottom
local SETTLE_HOLD_TIME = 0.6    -- how long a temporary BodyPosition holds you under target

-- UI color config
local ON_COLOR = Color3.fromRGB(0, 200, 80)     -- bright green when ON
local OFF_COLOR = Color3.fromRGB(8, 110, 24)    -- dark green when OFF
local HOVER_COLOR = Color3.fromRGB(24, 160, 64) -- hover tint
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)

-- Helper: safe remote fire for Q dash
local function fireDash(character)
	if not character then return end
	local remote = character:FindFirstChild("Communicate")
	if remote and typeof(remote.FireServer) == "function" then
		local args = {
			{
				Dash = Enum.KeyCode.W,
				Key = Enum.KeyCode.Q,
				Goal = "KeyPress"
			}
		}
		pcall(function() remote:FireServer(unpack(args)) end)
	end
end

-- Smooth per-frame orbit that keeps facing the target.
-- After the orbit ends we do a creative "settle to bottom" tween + short BodyPosition hold.
local function performLoopDash(character, target)
	if not character or not target then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local thrp = target:FindFirstChild("HumanoidRootPart")
	if not hrp or not thrp then return end

	-- tiny pre-start delay to avoid snaps
	task.wait(PRE_START_DELAY)

	local startTime = tick()
	local endTime = startTime + LOOP_DURATION
	local totalAngle = NUM_LOOPS * math.pi * 2

	-- determine initial angle from current relative position so orbit continues smoothly
	local rel = hrp.Position - thrp.Position
	local initialAngle = math.atan2(rel.Z, rel.X)

	-- schedule dash fires evenly during the loop
	local fireInterval = LOOP_DURATION / math.max(1, DASH_COUNT)
	local lastFireTime = startTime - fireInterval

	-- Connect to Heartbeat for smooth motion (update every physics frame)
	local conn
	conn = RunService.Heartbeat:Connect(function(delta)
		-- safety checks
		if not character.Parent or not target.Parent or not hrp.Parent or not thrp.Parent then
			if conn then conn:Disconnect() end
			return
		end

		local now = tick()
		if now >= endTime then
			-- finished looping: disconnect and perform settle
			if conn then conn:Disconnect() end

			-- Creative settle: move to just under the target and hold briefly using a BodyPosition + BodyGyro
			local center = thrp.Position
			local bottomPos = Vector3.new(center.X, center.Y - SETTLE_DEPTH, center.Z)
			-- face target while settling (target may move, so we look at its current position)
			local settleCFrame = CFrame.new(bottomPos, thrp.Position)
			-- quick tween for a clean landing feel
			local settleTween = TweenService:Create(hrp, TweenInfo.new(SETTLE_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = settleCFrame
			})
			settleTween:Play()
			settleTween.Completed:Wait()

			-- Soft hold with BodyPosition and BodyGyro to "stick" under target for a moment (looks legit)
			local bodyPos = Instance.new("BodyPosition")
			bodyPos.Name = "KibaSettleBP"
			bodyPos.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			bodyPos.P = 10000
			bodyPos.D = 100
			bodyPos.Position = bottomPos
			bodyPos.Parent = hrp

			local bodyGyro = Instance.new("BodyGyro")
			bodyGyro.Name = "KibaSettleBG"
			bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
			bodyGyro.P = 5000
			bodyGyro.D = 100
			bodyGyro.CFrame = CFrame.new(bottomPos, thrp.Position)
			bodyGyro.Parent = hrp

			-- Keep HRP facing target while holding (in case target moves)
			local holdConn
			holdConn = RunService.Heartbeat:Connect(function()
				if not bodyGyro or not bodyGyro.Parent or not thrp.Parent then
					if holdConn then holdConn:Disconnect() end
					return
				end
				bodyGyro.CFrame = CFrame.new(hrp.Position, thrp.Position)
			end)

			task.delay(SETTLE_HOLD_TIME, function()
				if holdConn then holdConn:Disconnect() end
				if bodyPos and bodyPos.Parent then bodyPos:Destroy() end
				if bodyGyro and bodyGyro.Parent then bodyGyro:Destroy() end
			end)

			return
		end

		-- normalized progress [0..1]
		local t = (now - startTime) / math.max(0.0001, LOOP_DURATION)
		-- progress angle from initialAngle -> initialAngle + totalAngle
		local angle = initialAngle + totalAngle * t
		local center = thrp.Position
		local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * LOOP_RADIUS
		local newPos = center + offset + Vector3.new(0, HEIGHT_OFFSET, 0)

		-- set position while orienting to face target (so movement is circular but facing locked)
		hrp.CFrame = CFrame.new(newPos, center)

		-- fire Q dash at intervals
		if now - lastFireTime >= fireInterval then
			lastFireTime = now
			fireDash(character)
		end
	end)
end

-- Setup character monitoring: watches animations and starts loop dash sequence when triggered
local function setupCharacter(character)
	if toggleConnection then toggleConnection:Disconnect() end
	if not systemEnabled then return end

	local isLooping = false
	local lastPlaying = false
	local cooldown = false

	toggleConnection = RunService.RenderStepped:Connect(function()
		if not character or not character.Parent then return end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if not hrp or not humanoid then return end

		-- check if any watched animations are playing
		local isPlaying = false
		for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
			if track.Animation and animationIds[track.Animation.AnimationId] then
				isPlaying = true
				break
			end
		end

		if isPlaying and not isLooping and not lastPlaying and not cooldown then
			-- enter looping state to prevent reentry
			isLooping = true
			lastPlaying = true
			cooldown = true

			-- spawn the activation buffer so we don't block RenderStepped
			task.spawn(function()
				-- 50ms detection buffer as requested
				task.wait(DETECT_BUFFER)

				-- preserve the original small feel delay (keeps same timing you used before)
				task.delay(0.18, function()
					-- find nearest target within MIN_TARGET_DIST inside Workspace.Live
					local target = nil
					local shortestDist = MIN_TARGET_DIST
					local live = Workspace:FindFirstChild("Live")
					if live then
						for _, model in ipairs(live:GetChildren()) do
							if model:IsA("Model") and model ~= character then
								local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model:FindFirstChild("UpperTorso")
								if root then
									local dist = (hrp.Position - root.Position).Magnitude
									if dist < shortestDist then
										shortestDist = dist
										target = model
									end
								end
							end
						end
					end

					-- perform the loop dash on found target
					if target and target:FindFirstChild("HumanoidRootPart") then
						performLoopDash(character, target)
					end

					-- exit looping state and set cooldown
					isLooping = false
					task.delay(COOLDOWN_SECONDS, function()
						cooldown = false
					end)
				end)
			end)
		elseif not isPlaying then
			-- reset lastPlaying when animation stops
			lastPlaying = false
		end
	end)
end

-- Enable/Disable system and update the UI button (container color + status dot)
local function setSystemEnabled(enabled)
	systemEnabled = enabled
	if container then
		container.BackgroundColor3 = systemEnabled and ON_COLOR or OFF_COLOR
	end
	if statusDot then
		statusDot.BackgroundColor3 = systemEnabled and Color3.fromRGB(180,255,200) or Color3.fromRGB(60,120,70)
	end
	if button then
		button.Text = systemEnabled and "Loop Dash: ON" or "Loop Dash: OFF"
	end

	if systemEnabled and player.Character then
		setupCharacter(player.Character)
	elseif toggleConnection then
		toggleConnection:Disconnect()
	end
end

-- GUI setup (Loop Dash button + visuals) — redesigned green style
-- Create ScreenGui robustly and ensure visibility
gui = Instance.new("ScreenGui")
gui.Name = "LoopDashToggle"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui
gui.Enabled = true

-- Container Frame (background, gradient-like effect via subtle color and stroke)
container = Instance.new("Frame")
container.Name = "LoopDashContainer"
container.Size = UDim2.new(0, 180, 0, 48)
container.Position = UDim2.new(0, 20, 0.78, 0)
container.BackgroundColor3 = OFF_COLOR
container.BorderSizePixel = 0
container.ClipsDescendants = false
container.ZIndex = 100 -- ensure topmost
container.Visible = true
container.Parent = gui
container.AnchorPoint = Vector2.new(0,0)

-- Rounded corners
local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 12)
containerCorner.Parent = container

-- Subtle stroke
local containerStroke = Instance.new("UIStroke")
containerStroke.Color = Color3.fromRGB(14, 70, 20)
containerStroke.Thickness = 1.5
containerStroke.Transparency = 0.15
containerStroke.Parent = container

-- Soft shadow (image used as shadow)
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.new(0.5, 2, 0.5, 2)
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.75
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.ZIndex = container.ZIndex - 1
shadow.Parent = container

-- Status dot (small indicator on left)
statusDot = Instance.new("Frame")
statusDot.Name = "StatusDot"
statusDot.Size = UDim2.new(0, 12, 0, 12)
statusDot.Position = UDim2.new(0, 12, 0.5, -6)
statusDot.BackgroundColor3 = Color3.fromRGB(60,120,70)
statusDot.BorderSizePixel = 0
statusDot.ZIndex = container.ZIndex + 1
statusDot.Parent = container
local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = statusDot

-- Main clickable TextButton (transparent background so the container shows through)
button = Instance.new("TextButton")
button.Name = "LoopDashButton"
button.Size = UDim2.new(1, -24, 1, -12)
button.Position = UDim2.new(0, 18, 0, 6)
button.BackgroundTransparency = 1
button.Text = "Loop Dash: OFF"
button.TextColor3 = TEXT_COLOR
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.AutoButtonColor = false
button.Parent = container
button.ZIndex = container.ZIndex + 2
button.AnchorPoint = Vector2.new(0, 0)

-- Small subtitle label to add style
local subLabel = Instance.new("TextLabel")
subLabel.Name = "SubLabel"
subLabel.Size = UDim2.new(0.6, 0, 0.35, 0)
subLabel.Position = UDim2.new(0.35, 0, 0.65, 0)
subLabel.BackgroundTransparency = 1
subLabel.Text = "Toggle loop tech"
subLabel.TextColor3 = Color3.fromRGB(200, 255, 220)
subLabel.Font = Enum.Font.Gotham
subLabel.TextSize = 12
subLabel.TextXAlignment = Enum.TextXAlignment.Left
subLabel.ZIndex = button.ZIndex + 1
subLabel.Parent = container

-- Hover + click behavior (tweens container color to hover/press states)
local hoverTweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local hoverOn = TweenService:Create(container, hoverTweenInfo, {BackgroundColor3 = HOVER_COLOR})
local hoverOff = TweenService:Create(container, hoverTweenInfo, {BackgroundColor3 = OFF_COLOR})
local pressEffect = TweenService:Create(container, hoverTweenInfo, {BackgroundColor3 = Color3.fromRGB(0,160,60)})

button.MouseEnter:Connect(function() if not systemEnabled then hoverOn:Play() end end)
button.MouseLeave:Connect(function() if not systemEnabled then hoverOff:Play() end end)
button.MouseButton1Down:Connect(function() pressEffect:Play() end)
button.MouseButton1Up:Connect(function()
	-- return to current state color (on or off)
	if systemEnabled then
		local t = TweenService:Create(container, hoverTweenInfo, {BackgroundColor3 = ON_COLOR})
		t:Play()
	else
		hoverOff:Play()
	end
end)

button.MouseButton1Click:Connect(function()
	setSystemEnabled(not systemEnabled)
end)

-- Make container draggable (drag from the container area)
local dragging, dragInput, dragStart, startPos
container.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = container.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
container.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Character initialization
player.CharacterAdded:Connect(function(char)
	if systemEnabled then
		setupCharacter(char)
	end
end)

if player.Character then
	setupCharacter(player.Character)
end
