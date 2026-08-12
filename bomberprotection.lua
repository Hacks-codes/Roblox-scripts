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
frame.Size = UDim2.new(0, 190, 0, 194)
frame.Position = UDim2.new(0.5, -95, 0.4, -97)
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
title.Text = "Bomber Protection Engine"
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

-- Menu Toggle Button
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

-- Floating Quick Toggle Button for Bomber Aim
local quickAimBtn = Instance.new("TextButton")
quickAimBtn.Name = getRandomName()
quickAimBtn.Size = UDim2.new(0, 65, 0, 24)
quickAimBtn.Position = UDim2.new(0.01, 0, 0.26, 0)
quickAimBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
quickAimBtn.BorderSizePixel = 1
quickAimBtn.BorderColor3 = Color3.fromRGB(120, 40, 40)
quickAimBtn.Text = "BOMBER: OFF"
quickAimBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
quickAimBtn.Font = Enum.Font.SourceSansBold
quickAimBtn.TextSize = 10
quickAimBtn.Active = true
quickAimBtn.Visible = false
quickAimBtn.Parent = screenGui

makeDraggable(quickAimBtn, quickAimBtn)

-- Feature States
local states = {
    bomberAim = false,
    separateBtnVisible = false,
    bomberEsp = false,
    blastRadius = false,
    autoRepel = false
}

-- Visual Tracking Containers
local activeEspBoxes = {}
local activeCircles = {}

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

local function clearEsp()
    for _, box in pairs(activeEspBoxes) do
        if box and box.Parent then box:Destroy() end
    end
    table.clear(activeEspBoxes)
end

local function clearCircles()
    for _, circle in pairs(activeCircles) do
        if circle and circle.Parent then circle:Destroy() end
    end
    table.clear(activeCircles)
end

-- Synchronized Bomber Aim Controller
local mainAimBtn
local function setBomberAimState(enabled)
    states.bomberAim = enabled
    local stateTxt = states.bomberAim and "ON" or "OFF"
    local activeColor = states.bomberAim and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(200, 200, 200)

    if mainAimBtn then
        mainAimBtn.Text = "Bomber Aimlock: " .. stateTxt
        mainAimBtn.TextColor3 = activeColor
    end

    quickAimBtn.Text = "BOMBER: " .. stateTxt
    quickAimBtn.TextColor3 = activeColor

    if not states.bomberAim then
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

mainAimBtn = createToggleBtn("Bomber Aimlock: OFF", UDim2.new(0, 4, 0, 28), function()
    setBomberAimState(not states.bomberAim)
end)

quickAimBtn.MouseButton1Click:Connect(function()
    setBomberAimState(not states.bomberAim)
end)

createToggleBtn("Bomber Aim Button: OFF", UDim2.new(0, 4, 0, 54), function(btn)
    states.separateBtnVisible = not states.separateBtnVisible
    quickAimBtn.Visible = states.separateBtnVisible
    btn.Text = "Bomber Aim Button: " .. (states.separateBtnVisible and "ON" or "OFF")
    btn.TextColor3 = states.separateBtnVisible and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(200, 200, 200)
end)

createToggleBtn("Bomber ESP: OFF", UDim2.new(0, 4, 0, 80), function(btn)
    states.bomberEsp = not states.bomberEsp
    btn.Text = "Bomber ESP: " .. (states.bomberEsp and "ON" or "OFF")
    btn.TextColor3 = states.bomberEsp and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(200, 200, 200)
    if not states.bomberEsp then clearEsp() end
end)

createToggleBtn("Blast Radius (4 Studs): OFF", UDim2.new(0, 4, 0, 106), function(btn)
    states.blastRadius = not states.blastRadius
    btn.Text = "Blast Radius (4 Studs): " .. (states.blastRadius and "ON" or "OFF")
    btn.TextColor3 = states.blastRadius and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(200, 200, 200)
    if not states.blastRadius then clearCircles() end
end)

createToggleBtn("12 Stud Safe Repel: OFF", UDim2.new(0, 4, 0, 132), function(btn)
    states.autoRepel = not states.autoRepel
    btn.Text = "12 Stud Safe Repel: " .. (states.autoRepel and "ON" or "OFF")
    btn.TextColor3 = states.autoRepel and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(200, 200, 200)
end)

-- Unload Button
local mainLoopConnection
local disableBtn = Instance.new("TextButton")
disableBtn.Name = getRandomName()
disableBtn.Size = UDim2.new(1, -8, 0, 22)
disableBtn.Position = UDim2.new(0, 4, 0, 158)
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

    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end

    clearEsp()
    clearCircles()
    screenGui:Destroy()
end)

-- Bomber Identification Algorithm
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

-- Robust Line-of-Sight Check (Considers Map Geometry)
local function isVisible(origin, targetPos, zombie, char)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {char, zombie}
    raycastParams.IgnoreWater = true

    local direction = targetPos - origin
    local result = Workspace:Raycast(origin, direction, raycastParams)
    
    if result then
        return result.Instance:IsDescendantOf(zombie)
    end
    return true
end

-- Target Finder with Raycasting Check
local function getNearestVisibleBomber(hrp, char)
    local zombiesFolder = Workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return nil end

    local closestHead = nil
    local shortestDist = math.huge

    for _, zombie in ipairs(zombiesFolder:GetChildren()) do
        if isBomber(zombie) and zombie.Parent then
            local zHead = zombie:FindFirstChild("Head") or zombie:FindFirstChild("HumanoidRootPart")
            if zHead then
                local dist = (hrp.Position - zHead.Position).Magnitude
                if dist < shortestDist then
                    if isVisible(hrp.Position + Vector3.new(0, 1.5, 0), zHead.Position, zombie, char) then
                        shortestDist = dist
                        closestHead = zHead
                    end
                end
            end
        end
    end

    return closestHead
end

-- Raycast-Validated Position Enforcement (Prevents wall clipping & floor voids)
local function getSafeEnforcedPosition(char, hrp, targetPos)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {char, Workspace:FindFirstChild("Zombies")}
    raycastParams.IgnoreWater = true

    local moveDir = targetPos - hrp.Position
    local distance = moveDir.Magnitude

    if distance < 0.01 then return hrp.Position end

    -- Check path for physical barriers
    local wallResult = Workspace:Raycast(hrp.Position, moveDir, raycastParams)
    local safePos = targetPos
    if wallResult then
        safePos = wallResult.Position - (moveDir.Unit * 0.8)
    end

    -- Verify solid ground under enforced coordinate
    local floorResult = Workspace:Raycast(safePos + Vector3.new(0, 2, 0), Vector3.new(0, -12, 0), raycastParams)
    if floorResult then
        return Vector3.new(safePos.X, floorResult.Position.Y + (hrp.Size.Y / 2) + 0.1, safePos.Z)
    end

    return nil
end

-- RenderStepped Main Loop
mainLoopConnection = RunService.RenderStepped:Connect(function()
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local camera = Workspace.CurrentCamera
    local zombiesFolder = Workspace:FindFirstChild("Zombies")

    if not zombiesFolder then return end

    local currentBombers = {}

    for _, zombie in ipairs(zombiesFolder:GetChildren()) do
        if isBomber(zombie) and zombie.Parent then
            currentBombers[zombie] = true

            -- Selection Box ESP
            if states.bomberEsp then
                if not activeEspBoxes[zombie] or not activeEspBoxes[zombie].Parent then
                    local box = Instance.new("SelectionBox")
                    box.Name = getRandomName()
                    box.Adornee = zombie
                    box.Color3 = Color3.fromRGB(255, 30, 30)
                    box.LineThickness = 0.05
                    box.SurfaceColor3 = Color3.fromRGB(255, 0, 0)
                    box.SurfaceTransparency = 0.7
                    box.AlwaysOnTop = true
                    box.Parent = screenGui
                    activeEspBoxes[zombie] = box
                end
            end

            -- 4 Stud Blast Radius Cylinder
            if states.blastRadius then
                local zHrp = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Head")
                if zHrp and (not activeCircles[zombie] or not activeCircles[zombie].Parent) then
                    local circle = Instance.new("CylinderHandleAdornment")
                    circle.Name = getRandomName()
                    circle.Adornee = zHrp
                    circle.Height = 0.1
                    circle.Radius = 4
                    circle.Color3 = Color3.fromRGB(255, 40, 40)
                    circle.Transparency = 0.4
                    circle.CFrame = CFrame.Angles(math.rad(90), 0, 0)
                    circle.AlwaysOnTop = true
                    circle.Parent = screenGui
                    activeCircles[zombie] = circle
                end
            end
        end
    end

    -- Cleanup Dead Visuals
    for zombie, box in pairs(activeEspBoxes) do
        if not currentBombers[zombie] then
            if box and box.Parent then box:Destroy() end
            activeEspBoxes[zombie] = nil
        end
    end

    for zombie, circle in pairs(activeCircles) do
        if not currentBombers[zombie] then
            if circle and circle.Parent then circle:Destroy() end
            activeCircles[zombie] = nil
        end
    end

    if not states.bomberEsp then clearEsp() end
    if not states.blastRadius then clearCircles() end

    if not hrp or not hum then return end

    -- Strict 12-Stud Boundary Repulsion Engine
    if states.autoRepel then
        for zombie in pairs(currentBombers) do
            local zHrp = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Head")
            if zHrp then
                local flatHrpPos = Vector3.new(hrp.Position.X, 0, hrp.Position.Z)
                local flatZHrpPos = Vector3.new(zHrp.Position.X, 0, zHrp.Position.Z)
                local distVec = flatHrpPos - flatZHrpPos
                local dist = distVec.Magnitude

                if dist < 12 then
                    local pushDirection = (dist > 0.001) and distVec.Unit or Vector3.new(0, 0, 1)
                    local targetFlatPos = flatZHrpPos + (pushDirection * 12)
                    local targetPos = Vector3.new(targetFlatPos.X, hrp.Position.Y, targetFlatPos.Z)

                    local safePos = getSafeEnforcedPosition(char, hrp, targetPos)
                    if safePos then
                        hrp.CFrame = CFrame.new(safePos) * hrp.CFrame.Rotation
                    end
                end
            end
        end
    end

    -- Dedicated Bomber Aimlock Engine
    if states.bomberAim then
        local targetHead = getNearestVisibleBomber(hrp, char)
        if targetHead then
            local headPos = targetHead.Position
            local isShiftLock = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter

            if isShiftLock then
                hum.AutoRotate = true
                if camera then
                    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, headPos)
                end
            else
                hum.AutoRotate = false
                local lookAtPos = Vector3.new(headPos.X, hrp.Position.Y, headPos.Z)
                if (lookAtPos - hrp.Position).Magnitude > 0.01 then
                    hrp.CFrame = CFrame.lookAt(hrp.Position, lookAtPos)
                end
            end
        else
            hum.AutoRotate = true
        end
    end
end)
