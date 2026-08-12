local function getService(name)
    local service = game:GetService(name)
    return cloneref and cloneref(service) or service
end

local Players = getService("Players")
local RunService = getService("RunService")
local CoreGui = getService("CoreGui")
local UserInputService = getService("UserInputService")
local Workspace = getService("Workspace")

local lp = Players.LocalPlayer

-- Global State
local states = {
    aimlock = false,
    separateBtnVisible = false,
    smoothAim = false,
    smoothness = 0.15,
    wallCheck = true
}

-- Utility Functions
local function getRandomName()
    local bytes = {}
    for i = 1, math.random(8, 14) do
        bytes[i] = math.random(97, 122)
    end
    return string.char(table.unpack(bytes))
end

local function getGuiParent()
    if gethui then return gethui() end
    local ok, res = pcall(function() return CoreGui:FindFirstChild("RobloxGui") end)
    if ok and res then return res end
    return lp:WaitForChild("PlayerGui")
end

local function applyCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
end

local function applyStroke(obj, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = obj
end

-- Universal Mobile & Desktop Dragging Handler
local activeDrag = nil
local function makeDraggable(guiObject, targetFrame)
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            activeDrag = {
                target = targetFrame,
                dragStart = input.Position,
                startPos = targetFrame.Position
            }
        end
    end)
end

UserInputService.InputChanged:Connect(function(input)
    if activeDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - activeDrag.dragStart
        activeDrag.target.Position = UDim2.new(
            activeDrag.startPos.X.Scale, 
            activeDrag.startPos.X.Offset + delta.X, 
            activeDrag.startPos.Y.Scale, 
            activeDrag.startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if activeDrag and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        activeDrag = nil
    end
end)

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = getRandomName()
screenGui.ResetOnSpawn = false
screenGui.Parent = getGuiParent()

local frame = Instance.new("Frame")
frame.Name = getRandomName()
frame.Size = UDim2.new(0, 210, 0, 225)
frame.Position = UDim2.new(0.5, -105, 0.4, -112)
frame.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Parent = screenGui
applyCorner(frame, 6)
applyStroke(frame, Color3.fromRGB(50, 52, 68), 1)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 26)
header.BackgroundColor3 = Color3.fromRGB(22, 24, 31)
header.BorderSizePixel = 0
header.Parent = frame
applyCorner(header, 6)
makeDraggable(header, frame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -26, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.Text = "OBSIDIAN // AIMLOCK"
title.TextColor3 = Color3.fromRGB(139, 92, 246)
title.Font = Enum.Font.Code
title.TextSize = 11
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -24, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.Font = Enum.Font.Code
closeBtn.TextSize = 14
closeBtn.Parent = header
applyCorner(closeBtn, 4)
closeBtn.MouseButton1Click:Connect(function() frame.Visible = false end)

local menuToggleBtn = Instance.new("TextButton")
menuToggleBtn.Name = getRandomName()
menuToggleBtn.Size = UDim2.new(0, 50, 0, 26)
menuToggleBtn.Position = UDim2.new(0.01, 0, 0.2, 0)
menuToggleBtn.BackgroundColor3 = Color3.fromRGB(22, 24, 31)
menuToggleBtn.BorderSizePixel = 0
menuToggleBtn.Text = "AIM"
menuToggleBtn.TextColor3 = Color3.fromRGB(139, 92, 246)
menuToggleBtn.Font = Enum.Font.Code
menuToggleBtn.TextSize = 11
menuToggleBtn.Active = true
menuToggleBtn.Parent = screenGui
applyCorner(menuToggleBtn, 4)
applyStroke(menuToggleBtn, Color3.fromRGB(50, 52, 68), 1)
makeDraggable(menuToggleBtn, menuToggleBtn)

menuToggleBtn.MouseButton1Click:Connect(function() 
    frame.Visible = not frame.Visible 
end)

local quickAimBtn = Instance.new("TextButton")
quickAimBtn.Name = getRandomName()
quickAimBtn.Size = UDim2.new(0, 75, 0, 26)
quickAimBtn.Position = UDim2.new(0.01, 0, 0.26, 0)
quickAimBtn.BackgroundColor3 = Color3.fromRGB(22, 24, 31)
quickAimBtn.BorderSizePixel = 0
quickAimBtn.Text = "AIM: OFF"
quickAimBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
quickAimBtn.Font = Enum.Font.Code
quickAimBtn.TextSize = 10
quickAimBtn.Active = true
quickAimBtn.Visible = false
quickAimBtn.Parent = screenGui
applyCorner(quickAimBtn, 4)
applyStroke(quickAimBtn, Color3.fromRGB(50, 52, 68), 1)
makeDraggable(quickAimBtn, quickAimBtn)

local function createToggleBtn(text, pos, onClick)
    local btn = Instance.new("TextButton")
    btn.Name = getRandomName()
    btn.Size = UDim2.new(1, -12, 0, 24)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(160, 165, 180)
    btn.Font = Enum.Font.Code
    btn.TextSize = 10
    btn.Parent = frame
    applyCorner(btn, 4)
    applyStroke(btn, Color3.fromRGB(38, 40, 52), 1)
    btn.MouseButton1Click:Connect(function() onClick(btn) end)
    return btn
end

-- Controls Integration
local mainAimBtn

local function setAimState(enabled)
    states.aimlock = enabled
    local stateTxt = states.aimlock and "ON" or "OFF"
    local activeColor = states.aimlock and Color3.fromRGB(139, 92, 246) or Color3.fromRGB(160, 165, 180)

    if mainAimBtn then
        mainAimBtn.Text = "Aimlock: " .. stateTxt
        mainAimBtn.TextColor3 = activeColor
    end

    quickAimBtn.Text = "AIM: " .. stateTxt
    quickAimBtn.TextColor3 = activeColor

    if not states.aimlock then
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

mainAimBtn = createToggleBtn("Aimlock: OFF", UDim2.new(0, 6, 0, 32), function()
    setAimState(not states.aimlock)
end)

quickAimBtn.MouseButton1Click:Connect(function()
    setAimState(not states.aimlock)
end)

createToggleBtn("Aimlock Button: OFF", UDim2.new(0, 6, 0, 60), function(btn)
    states.separateBtnVisible = not states.separateBtnVisible
    quickAimBtn.Visible = states.separateBtnVisible
    btn.Text = "Aimlock Button: " .. (states.separateBtnVisible and "ON" or "OFF")
    btn.TextColor3 = states.separateBtnVisible and Color3.fromRGB(139, 92, 246) or Color3.fromRGB(160, 165, 180)
end)

createToggleBtn("Smooth Aim: OFF", UDim2.new(0, 6, 0, 88), function(btn)
    states.smoothAim = not states.smoothAim
    btn.Text = "Smooth Aim: " .. (states.smoothAim and "ON" or "OFF")
    btn.TextColor3 = states.smoothAim and Color3.fromRGB(139, 92, 246) or Color3.fromRGB(160, 165, 180)
end)

local speedPresets = {
    { speed = 0.05, label = "Slow" },
    { speed = 0.15, label = "Medium" },
    { speed = 0.35, label = "Fast" }
}
local currentSpeedIdx = 2

createToggleBtn("Smooth Speed: Medium", UDim2.new(0, 6, 0, 116), function(btn)
    currentSpeedIdx = (currentSpeedIdx % #speedPresets) + 1
    local preset = speedPresets[currentSpeedIdx]
    states.smoothness = preset.speed
    btn.Text = "Smooth Speed: " .. preset.label
    btn.TextColor3 = Color3.fromRGB(139, 92, 246)
end)

createToggleBtn("Wall Check: ON", UDim2.new(0, 6, 0, 144), function(btn)
    states.wallCheck = not states.wallCheck
    btn.Text = "Wall Check: " .. (states.wallCheck and "ON" or "OFF")
    btn.TextColor3 = states.wallCheck and Color3.fromRGB(139, 92, 246) or Color3.fromRGB(160, 165, 180)
end)

-- Optimized Raycasting Engine
local raycastParams = RaycastParams.new()
raycastParams.FilterType = RaycastFilterType.Exclude
raycastParams.IgnoreWater = true

local function isVisible(origin, targetPos, zombie, char)
    if not states.wallCheck then return true end

    raycastParams.FilterDescendantsInstances = {char, zombie}
    local direction = targetPos - origin
    local result = Workspace:Raycast(origin, direction, raycastParams)

    if result then
        return result.Instance:IsDescendantOf(zombie)
    end
    return true
end

-- Valid Target Acquisition System
local function getNearestTarget(hrp, char)
    local zombiesFolder = Workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return nil end

    local closestHead = nil
    local shortestDist = math.huge
    local hrpPos = hrp.Position
    local eyePos = hrpPos + Vector3.new(0, 1.5, 0)
    local children = zombiesFolder:GetChildren()

    for i = 1, #children do
        local zombie = children[i]
        local zHum = zombie:FindFirstChildOfClass("Humanoid")
        -- Filter out dead or despawned zombies
        if zombie.Parent and zHum and zHum.Health > 0 then
            local zHead = zombie:FindFirstChild("Head") or zombie:FindFirstChild("HumanoidRootPart")
            if zHead then
                local dist = (hrpPos - zHead.Position).Magnitude
                if dist < shortestDist then
                    if isVisible(eyePos, zHead.Position, zombie, char) then
                        shortestDist = dist
                        closestHead = zHead
                    end
                end
            end
        end
    end

    return closestHead
end

-- Unload Button Initialization
local mainLoopConnection

local disableBtn = Instance.new("TextButton")
disableBtn.Name = getRandomName()
disableBtn.Size = UDim2.new(1, -12, 0, 24)
disableBtn.Position = UDim2.new(0, 6, 0, 182)
disableBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 25)
disableBtn.BorderSizePixel = 0
disableBtn.Text = "UNLOAD SCRIPT"
disableBtn.TextColor3 = Color3.fromRGB(244, 63, 94)
disableBtn.Font = Enum.Font.Code
disableBtn.TextSize = 10
disableBtn.Parent = frame
applyCorner(disableBtn, 4)
applyStroke(disableBtn, Color3.fromRGB(80, 30, 40), 1)

disableBtn.MouseButton1Click:Connect(function()
    if mainLoopConnection then
        mainLoopConnection:Disconnect()
        mainLoopConnection = nil
    end

    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end

    screenGui:Destroy()
end)

-- Main Aimlock Processing Loop
mainLoopConnection = RunService.RenderStepped:Connect(function(deltaTime)
    if not states.aimlock then return end

    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local camera = Workspace.CurrentCamera

    if not hrp or not hum or not camera then return end

    local targetHead = getNearestTarget(hrp, char)
    if targetHead then
        local headPos = targetHead.Position
        local isShiftLock = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
        local lerpAlpha = states.smoothAim and math.clamp(states.smoothness * deltaTime * 60, 0.01, 1) or 1

        if isShiftLock then
            hum.AutoRotate = true
            local targetCFrame = CFrame.lookAt(camera.CFrame.Position, headPos)
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, lerpAlpha)
        else
            hum.AutoRotate = false
            local lookAtPos = Vector3.new(headPos.X, hrp.Position.Y, headPos.Z)
            if (lookAtPos - hrp.Position).Magnitude > 0.01 then
                local targetCFrame = CFrame.lookAt(hrp.Position, lookAtPos)
                hrp.CFrame = hrp.CFrame:Lerp(targetCFrame, lerpAlpha)
            end
            local targetCameraCFrame = CFrame.lookAt(camera.CFrame.Position, headPos)
            camera.CFrame = camera.CFrame:Lerp(targetCameraCFrame, lerpAlpha)
        end
    else
        hum.AutoRotate = true
    end
end)
