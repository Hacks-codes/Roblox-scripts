-- Unified Precision & Bomber Utility Engine
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

-- Global Feature States
local states = {
    aimLock = false,
    aimMode = "Body",
    aimRange = 5,
    separateAimBtnVisible = false,

    bomberAim = false,
    separateBomberBtnVisible = false
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
local function makeDraggable(guiObject, targetFrame)
    local dragging, dragStart, startPos

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- UI Initialization
local screenGui = Instance.new("ScreenGui")
screenGui.Name = getRandomName()
screenGui.ResetOnSpawn = false
screenGui.Parent = getGuiParent()

-- Main Control Frame
local frame = Instance.new("Frame")
frame.Name = getRandomName()
frame.Size = UDim2.new(0, 200, 0, 250)
frame.Position = UDim2.new(0.5, -100, 0.35, -125)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Parent = screenGui
applyCorner(frame, 6)
applyStroke(frame, Color3.fromRGB(60, 60, 60), 1)

-- Header Bar
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 24)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
header.BorderSizePixel = 0
header.Parent = frame
applyCorner(header, 6)
makeDraggable(header, frame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 1, 0)
title.Position = UDim2.new(0, 6, 0, 0)
title.Text = "Precision Engine"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 20)
closeBtn.Position = UDim2.new(1, -22, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 11
closeBtn.Parent = header
applyCorner(closeBtn, 4)
closeBtn.MouseButton1Click:Connect(function() frame.Visible = false end)

-- Main Floating Menu Toggle Button
local menuToggleBtn = Instance.new("TextButton")
menuToggleBtn.Name = getRandomName()
menuToggleBtn.Size = UDim2.new(0, 50, 0, 24)
menuToggleBtn.Position = UDim2.new(0.01, 0, 0.18, 0)
menuToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
menuToggleBtn.BorderSizePixel = 0
menuToggleBtn.Text = "MENU"
menuToggleBtn.TextColor3 = Color3.fromRGB(0, 220, 220)
menuToggleBtn.Font = Enum.Font.SourceSansBold
menuToggleBtn.TextSize = 11
menuToggleBtn.Active = true
menuToggleBtn.Parent = screenGui
applyCorner(menuToggleBtn, 4)
applyStroke(menuToggleBtn, Color3.fromRGB(80, 80, 80), 1)
makeDraggable(menuToggleBtn, menuToggleBtn)
menuToggleBtn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

-- Standalone Floating Aimlock Toggle Button
local quickAimBtn = Instance.new("TextButton")
quickAimBtn.Name = getRandomName()
quickAimBtn.Size = UDim2.new(0, 60, 0, 24)
quickAimBtn.Position = UDim2.new(0.01, 0, 0.23, 0)
quickAimBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
quickAimBtn.BorderSizePixel = 0
quickAimBtn.Text = "AIM: OFF"
quickAimBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
quickAimBtn.Font = Enum.Font.SourceSansBold
quickAimBtn.TextSize = 10
quickAimBtn.Active = true
quickAimBtn.Visible = false
quickAimBtn.Parent = screenGui
applyCorner(quickAimBtn, 4)
applyStroke(quickAimBtn, Color3.fromRGB(80, 80, 80), 1)
makeDraggable(quickAimBtn, quickAimBtn)

-- Standalone Floating Bomber Aim Toggle Button
local quickBomberBtn = Instance.new("TextButton")
quickBomberBtn.Name = getRandomName()
quickBomberBtn.Size = UDim2.new(0, 85, 0, 24)
quickBomberBtn.Position = UDim2.new(0.01, 0, 0.28, 0)
quickBomberBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
quickBomberBtn.BorderSizePixel = 0
quickBomberBtn.Text = "BOMBER AIM: OFF"
quickBomberBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
quickBomberBtn.Font = Enum.Font.SourceSansBold
quickBomberBtn.TextSize = 10
quickBomberBtn.Active = true
quickBomberBtn.Visible = false
quickBomberBtn.Parent = screenGui
applyCorner(quickBomberBtn, 4)
applyStroke(quickBomberBtn, Color3.fromRGB(80, 80, 80), 1)
makeDraggable(quickBomberBtn, quickBomberBtn)

-- Dynamic Button Generator Helper
local function createToggleBtn(text, pos, onClick)
    local btn = Instance.new("TextButton")
    btn.Name = getRandomName()
    btn.Size = UDim2.new(1, -10, 0, 22)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 11
    btn.Parent = frame
    applyCorner(btn, 4)
    applyStroke(btn, Color3.fromRGB(60, 60, 60), 1)
    btn.MouseButton1Click:Connect(function() onClick(btn) end)
    return btn
end

-- Synchronized Aim Controllers
local mainAimBtn
local mainBomberBtn

local function setAimlockState(enabled)
    states.aimLock = enabled
    local stateTxt = states.aimLock and "ON" or "OFF"
    local activeColor = states.aimLock and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(200, 200, 200)

    if mainAimBtn then
        mainAimBtn.Text = "Aim Lock: " .. stateTxt
        mainAimBtn.TextColor3 = activeColor
    end

    quickAimBtn.Text = "AIM: " .. stateTxt
    quickAimBtn.TextColor3 = activeColor

    if not states.aimLock and not states.bomberAim then
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

local function setBomberAimState(enabled)
    states.bomberAim = enabled
    local stateTxt = states.bomberAim and "ON" or "OFF"
    local activeColor = states.bomberAim and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(200, 200, 200)

    if mainBomberBtn then
        mainBomberBtn.Text = "Bomber Aimlock: " .. stateTxt
        mainBomberBtn.TextColor3 = activeColor
    end

    quickBomberBtn.Text = "BOMBER: " .. stateTxt
    quickBomberBtn.TextColor3 = activeColor

    if not states.aimLock and not states.bomberAim then
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

-- GUI Controls Creation
mainAimBtn = createToggleBtn("Aim Lock: OFF", UDim2.new(0, 5, 0, 28), function()
    setAimlockState(not states.aimLock)
end)

quickAimBtn.MouseButton1Click:Connect(function()
    setAimlockState(not states.aimLock)
end)

createToggleBtn("Aim Lock Button: OFF", UDim2.new(0, 5, 0, 54), function(btn)
    states.separateAimBtnVisible = not states.separateAimBtnVisible
    quickAimBtn.Visible = states.separateAimBtnVisible
    btn.Text = "Aim Lock Button: " .. (states.separateAimBtnVisible and "ON" or "OFF")
    btn.TextColor3 = states.separateAimBtnVisible and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(200, 200, 200)
end)

mainBomberBtn = createToggleBtn("Bomber Aimlock: OFF", UDim2.new(0, 5, 0, 80), function()
    setBomberAimState(not states.bomberAim)
end)

quickBomberBtn.MouseButton1Click:Connect(function()
    setBomberAimState(not states.bomberAim)
end)

createToggleBtn("Bomber Button: OFF", UDim2.new(0, 5, 0, 106), function(btn)
    states.separateBomberBtnVisible = not states.separateBomberBtnVisible
    quickBomberBtn.Visible = states.separateBomberBtnVisible
    btn.Text = "Bomber Button: " .. (states.separateBomberBtnVisible and "ON" or "OFF")
    btn.TextColor3 = states.separateBomberBtnVisible and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(200, 200, 200)
end)

-- Custom Aim Range Container
local rangeContainer = Instance.new("Frame")
rangeContainer.Size = UDim2.new(1, -10, 0, 22)
rangeContainer.Position = UDim2.new(0, 5, 0, 132)
rangeContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
rangeContainer.BorderSizePixel = 0
rangeContainer.Parent = frame
applyCorner(rangeContainer, 4)
applyStroke(rangeContainer, Color3.fromRGB(60, 60, 60), 1)

local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(0.65, 0, 1, 0)
rangeLabel.Position = UDim2.new(0, 4, 0, 0)
rangeLabel.Text = "Aim Range (Studs):"
rangeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
rangeLabel.Font = Enum.Font.SourceSans
rangeLabel.TextSize = 11
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
rangeLabel.BackgroundTransparency = 1
rangeLabel.Parent = rangeContainer

local rangeBox = Instance.new("TextBox")
rangeBox.Size = UDim2.new(0.3, 0, 1, -4)
rangeBox.Position = UDim2.new(0.67, 0, 0, 2)
rangeBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
rangeBox.BorderSizePixel = 0
rangeBox.Text = "5"
rangeBox.TextColor3 = Color3.fromRGB(0, 220, 220)
rangeBox.Font = Enum.Font.SourceSansBold
rangeBox.TextSize = 11
rangeBox.ClearTextOnFocus = false
rangeBox.Parent = rangeContainer
applyCorner(rangeBox, 3)

rangeBox.FocusLost:Connect(function()
    local val = tonumber(rangeBox.Text)
    if val and val > 0 then
        states.aimRange = val
    else
        rangeBox.Text = tostring(states.aimRange)
    end
end)

-- Aim Mode Switcher
createToggleBtn("Aim Mode: Body", UDim2.new(0, 5, 0, 158), function(btn)
    states.aimMode = (states.aimMode == "Body") and "Camera" or "Body"
    btn.Text = "Aim Mode: " .. states.aimMode

    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end
end)

-- Unload Script
local mainLoopConnection
local disableBtn = Instance.new("TextButton")
disableBtn.Name = getRandomName()
disableBtn.Size = UDim2.new(1, -10, 0, 22)
disableBtn.Position = UDim2.new(0, 5, 0, 184)
disableBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
disableBtn.BorderSizePixel = 0
disableBtn.Text = "UNLOAD SCRIPT"
disableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
disableBtn.Font = Enum.Font.SourceSansBold
disableBtn.TextSize = 11
disableBtn.Parent = frame
applyCorner(disableBtn, 4)

disableBtn.MouseButton1Click:Connect(function()
    if mainLoopConnection then
        mainLoopConnection:Disconnect()
        mainLoopConnection = nil
    end

    if lp then
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end

    screenGui:Destroy()
end)

-- Strict Bomber Identification Algorithm
local function isBomber(zombie)
    if not zombie then return false end
    local zType = tostring(zombie:GetAttribute("Type") or "")
    if zType == "Barrel" or zType == "Igniter" or zType == "Bomber" then
        return true
    end

    local zName = zombie.Name:lower()
    if zName:find("barrel") or zName:find("bomber") or zName:find("igniter") then
        return true
    end

    if zombie:FindFirstChild("Barrel") or zombie:FindFirstChild("Bomb") or zombie:FindFirstChild("Powder") or zombie:FindFirstChild("PowderBarrel") then
        return true
    end

    return false
end

-- General Target Acquisition (Head)
local function getTargetHead(hrp)
    local zombiesFolder = Workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return nil end

    local closestHead = nil
    local shortestDist = states.aimRange

    for _, zombie in ipairs(zombiesFolder:GetChildren()) do
        if not isBomber(zombie) then
            local zHead = zombie:FindFirstChild("Head") or zombie:FindFirstChild("HumanoidRootPart")
            if zHead and zombie.Parent then
                local dist = (hrp.Position - zHead.Position).Magnitude
                if dist <= shortestDist then
                    shortestDist = dist
                    closestHead = zHead
                end
            end
        end
    end

    return closestHead
end

-- Bomber Target Acquisition (Torso / HumanoidRootPart)
local function getNearestBomberTorso(hrp)
    local zombiesFolder = Workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return nil end

    local closestTorso = nil
    local shortestDist = math.huge

    for _, zombie in ipairs(zombiesFolder:GetChildren()) do
        local zHum = zombie:FindFirstChildOfClass("Humanoid")
        if zombie.Parent and zHum and zHum.Health > 0 and isBomber(zombie) then
            local zTorso = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("UpperTorso") or zombie:FindFirstChild("Torso")
            if zTorso then
                local dist = (hrp.Position - zTorso.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestTorso = zTorso
                end
            end
        end
    end

    return closestTorso
end

-- Optimized RenderStepped Main Processing Loop
mainLoopConnection = RunService.RenderStepped:Connect(function()
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local camera = Workspace.CurrentCamera

    if not hrp or not hum then return end

    -- Priority 1: Bomber Aim Override (ALWAYS Camera Aim onto Torso)
    if states.bomberAim then
        local targetTorso = getNearestBomberTorso(hrp)
        if targetTorso then
            local torsoPos = targetTorso.Position
            if camera then
                camera.CFrame = CFrame.lookAt(camera.CFrame.Position, torsoPos)
            end
            return
        end
    end

    -- Priority 2: Standard Aim Lock
    if states.aimLock then
        local targetHead = getTargetHead(hrp)
        if targetHead then
            local headPos = targetHead.Position

            if states.aimMode == "Body" then
                -- Disable auto-rotate to prevent Shift Lock from counter-rotating the character
                hum.AutoRotate = false
                local lookAtPos = Vector3.new(headPos.X, hrp.Position.Y, headPos.Z)
                if (lookAtPos - hrp.Position).Magnitude > 0.01 then
                    hrp.CFrame = CFrame.lookAt(hrp.Position, lookAtPos)
                end
            elseif states.aimMode == "Camera" then
                hum.AutoRotate = true
                if camera then
                    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, headPos)
                end
            end
            return
        end
    end

    -- Reset AutoRotate when no target is acquired or when aim features are toggled off
    hum.AutoRotate = true
end)
