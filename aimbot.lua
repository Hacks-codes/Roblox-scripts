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

local function getRandomName()
    local str = ""
    for i = 1, math.random(8, 14) do
        str = str .. string.char(math.random(97, 122))
    end
    return str
end

local function getGuiParent()
    if gethui then return gethui() end
    local ok, res = pcall(function() return CoreGui:FindFirstChild("RobloxGui") end)
    if ok and res then return res end
    return lp:WaitForChild("PlayerGui")
end

-- Screen Container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = getRandomName()
screenGui.ResetOnSpawn = false
screenGui.Parent = getGuiParent()

-- Main Panel
local frame = Instance.new("Frame")
frame.Name = getRandomName()
frame.Size = UDim2.new(0, 190, 0, 272)
frame.Position = UDim2.new(0.5, -95, 0.4, -136)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(60, 60, 60)
frame.Visible = false
frame.Active = true
frame.Parent = screenGui

-- Mobile Touch / Mouse Dragging Helper
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
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Header Bar
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 22)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
header.BorderSizePixel = 0
header.Parent = frame
makeDraggable(header, frame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -22, 1, 0)
title.Position = UDim2.new(0, 6, 0, 0)
title.Text = "Precision Aim Engine"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -22, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 11
closeBtn.Parent = header
closeBtn.MouseButton1Click:Connect(function() frame.Visible = false end)

-- Main Menu Toggle Button
local menuToggleBtn = Instance.new("TextButton")
menuToggleBtn.Name = getRandomName()
menuToggleBtn.Size = UDim2.new(0, 45, 0, 24)
menuToggleBtn.Position = UDim2.new(0.01, 0, 0.2, 0)
menuToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
menuToggleBtn.BorderSizePixel = 1
menuToggleBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
menuToggleBtn.Text = "MENU"
menuToggleBtn.TextColor3 = Color3.fromRGB(0, 220, 220)
menuToggleBtn.Font = Enum.Font.SourceSansBold
menuToggleBtn.TextSize = 11
menuToggleBtn.Active = true
menuToggleBtn.Parent = screenGui

makeDraggable(menuToggleBtn, menuToggleBtn)
menuToggleBtn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

-- Standalone Floating Aimlock Toggle Button
local quickAimBtn = Instance.new("TextButton")
quickAimBtn.Name = getRandomName()
quickAimBtn.Size = UDim2.new(0, 55, 0, 24)
quickAimBtn.Position = UDim2.new(0.01, 0, 0.26, 0)
quickAimBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
quickAimBtn.BorderSizePixel = 1
quickAimBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
quickAimBtn.Text = "AIM: OFF"
quickAimBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
quickAimBtn.Font = Enum.Font.SourceSansBold
quickAimBtn.TextSize = 10
quickAimBtn.Active = true
quickAimBtn.Visible = false
quickAimBtn.Parent = screenGui

makeDraggable(quickAimBtn, quickAimBtn)

-- Feature States
local states = {
    aimLock = false,
    aimMode = "Body",
    separateBtnVisible = false,
    aimRange = 5,
    unlockCam = false,
    smoothAim = false,
    smoothness = 0.2,
    wallCheck = false
}

local function createToggleBtn(text, pos, onClick)
    local btn = Instance.new("TextButton")
    btn.Name = getRandomName()
    btn.Size = UDim2.new(1, -8, 0, 22)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 11
    btn.Parent = frame
    btn.MouseButton1Click:Connect(function() onClick(btn) end)
    return btn
end

-- Synchronized Aimlock Controller Function
local mainAimBtn
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

    if not states.aimLock then
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

mainAimBtn = createToggleBtn("Aim Lock: OFF", UDim2.new(0, 4, 0, 28), function()
    setAimlockState(not states.aimLock)
end)

quickAimBtn.MouseButton1Click:Connect(function()
    setAimlockState(not states.aimLock)
end)

-- Separate Floating Button Toggle Option
createToggleBtn("Aim Lock Button: OFF", UDim2.new(0, 4, 0, 54), function(btn)
    states.separateBtnVisible = not states.separateBtnVisible
    quickAimBtn.Visible = states.separateBtnVisible
    btn.Text = "Aim Lock Button: " .. (states.separateBtnVisible and "ON" or "OFF")
    btn.TextColor3 = states.separateBtnVisible and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(200, 200, 200)
end)

-- Custom Aim Range Container
local rangeContainer = Instance.new("Frame")
rangeContainer.Size = UDim2.new(1, -8, 0, 22)
rangeContainer.Position = UDim2.new(0, 4, 0, 80)
rangeContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
rangeContainer.BorderSizePixel = 1
rangeContainer.BorderColor3 = Color3.fromRGB(60, 60, 60)
rangeContainer.Parent = frame

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
rangeBox.BorderSizePixel = 1
rangeBox.BorderColor3 = Color3.fromRGB(80, 80, 80)
rangeBox.Text = "5"
rangeBox.TextColor3 = Color3.fromRGB(0, 220, 220)
rangeBox.Font = Enum.Font.SourceSansBold
rangeBox.TextSize = 11
rangeBox.ClearTextOnFocus = false
rangeBox.Parent = rangeContainer

rangeBox.FocusLost:Connect(function()
    local val = tonumber(rangeBox.Text)
    if val and val > 0 then
        states.aimRange = val
    else
        rangeBox.Text = tostring(states.aimRange)
    end
end)

-- Aim Mode Switcher
createToggleBtn("Aim Mode: Body", UDim2.new(0, 4, 0, 106), function(btn)
    states.aimMode = (states.aimMode == "Body") and "Camera" or "Body"
    btn.Text = "Aim Mode: " .. states.aimMode

    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end
end)

-- Smooth Aim Toggle
createToggleBtn("Smooth Aim: OFF", UDim2.new(0, 4, 0, 132), function(btn)
    states.smoothAim = not states.smoothAim
    btn.Text = "Smooth Aim: " .. (states.smoothAim and "ON" or "OFF")
    btn.TextColor3 = states.smoothAim and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(200, 200, 200)
end)

-- Wall Check Toggle
createToggleBtn("Wall Check: OFF", UDim2.new(0, 4, 0, 158), function(btn)
    states.wallCheck = not states.wallCheck
    btn.Text = "Wall Check: " .. (states.wallCheck and "ON" or "OFF")
    btn.TextColor3 = states.wallCheck and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(200, 200, 200)
end)

-- Unlock Zoom
createToggleBtn("Unlock Cam Zoom: OFF", UDim2.new(0, 4, 0, 184), function(btn)
    states.unlockCam = not states.unlockCam
    btn.Text = "Unlock Cam Zoom: " .. (states.unlockCam and "ON" or "OFF")
    btn.TextColor3 = states.unlockCam and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(200, 200, 200)
    if not states.unlockCam and lp then
        lp.CameraMaxZoomDistance = 128
        lp.CameraMinZoomDistance = 0.5
    end
end)

-- Unload Script
local mainLoopConnection
local disableBtn = Instance.new("TextButton")
disableBtn.Name = getRandomName()
disableBtn.Size = UDim2.new(1, -8, 0, 22)
disableBtn.Position = UDim2.new(0, 4, 0, 210)
disableBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
disableBtn.BorderSizePixel = 1
disableBtn.BorderColor3 = Color3.fromRGB(100, 20, 20)
disableBtn.Text = "UNLOAD SCRIPT"
disableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
disableBtn.Font = Enum.Font.SourceSansBold
disableBtn.TextSize = 11
disableBtn.Parent = frame

disableBtn.MouseButton1Click:Connect(function()
    if mainLoopConnection then
        mainLoopConnection:Disconnect()
        mainLoopConnection = nil
    end

    if lp then
        lp.CameraMaxZoomDistance = 128
        lp.CameraMinZoomDistance = 0.5
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end

    screenGui:Destroy()
end)

-- Strict Bomber Filter
local function isBomber(zombie)
    if not zombie then return false end
    local zType = tostring(zombie:GetAttribute("Type") or "")
    local zName = zombie.Name:lower()

    if zType == "Barrel" or zType == "Bomber" or zType == "Igniter" or zName:find("barrel") or zName:find("bomber") or zName:find("igniter") then
        return true
    end

    if zombie:FindFirstChild("Barrel") or zombie:FindFirstChild("Bomb") or zombie:FindFirstChild("Powder") or zombie:FindFirstChild("PowderBarrel") then
        return true
    end

    return false
end

-- Safe Raycast Wall Check Helper
local function isVisible(origin, targetPos, ignoreList)
    local ok, visible = pcall(function()
        local direction = targetPos - origin
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = ignoreList or {}
        params.IgnoreWater = true

        local result = Workspace:Raycast(origin, direction, params)
        return result == nil
    end)

    if ok then
        return visible
    end
    return true -- Fallback to visible if raycast errors out so feature doesn't break main targeting
end

-- Dynamic Range Target Acquisition
local function getTargetHead(hrp)
    local zombiesFolder = Workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return nil end

    local closestHead = nil
    local shortestDist = states.aimRange
    local char = lp.Character

    for _, zombie in ipairs(zombiesFolder:GetChildren()) do
        if not isBomber(zombie) then
            local zHead = zombie:FindFirstChild("Head") or zombie:FindFirstChild("HumanoidRootPart")
            if zHead and zombie.Parent then
                local dist = (hrp.Position - zHead.Position).Magnitude
                if dist <= shortestDist then
                    local canTarget = true

                    if states.wallCheck then
                        local ignoreList = {char, zombie}
                        canTarget = isVisible(hrp.Position, zHead.Position, ignoreList)
                    end

                    if canTarget then
                        shortestDist = dist
                        closestHead = zHead
                    end
                end
            end
        end
    end

    return closestHead
end

-- RenderStepped Main Loop
mainLoopConnection = RunService.RenderStepped:Connect(function()
    if states.unlockCam and lp then
        lp.CameraMaxZoomDistance = 10000
        lp.CameraMinZoomDistance = 0
    end

    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local camera = Workspace.CurrentCamera

    if not states.aimLock or not hrp or not hum then
        if hum then hum.AutoRotate = true end
        return
    end

    local targetHead = getTargetHead(hrp)

    if targetHead then
        local headPos = targetHead.Position

        if states.aimMode == "Body" then
            hum.AutoRotate = false
            local lookAtPos = Vector3.new(headPos.X, hrp.Position.Y, headPos.Z)
            if (lookAtPos - hrp.Position).Magnitude > 0.01 then
                local targetCFrame = CFrame.lookAt(hrp.Position, lookAtPos)
                if states.smoothAim then
                    hrp.CFrame = hrp.CFrame:Lerp(targetCFrame, states.smoothness)
                else
                    hrp.CFrame = targetCFrame
                end
            end
        elseif states.aimMode == "Camera" then
            hum.AutoRotate = true
            if camera then
                local targetCFrame = CFrame.lookAt(camera.CFrame.Position, headPos)
                if states.smoothAim then
                    camera.CFrame = camera.CFrame:Lerp(targetCFrame, states.smoothness)
                else
                    camera.CFrame = targetCFrame
                end
            end
        end
    else
        hum.AutoRotate = true
    end
end)
