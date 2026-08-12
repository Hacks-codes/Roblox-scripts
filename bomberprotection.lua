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
    bomberAim = false,
    separateBtnVisible = false,
    bomberEsp = false,
    blastRadius = false,
    blastRadiusStuds = 4,
    autoRepel = false,
    repelDistance = 12
}

-- Visual Tracking Caches
local activeEspBoxes = {}
local activeCircles = {}

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
frame.Size = UDim2.new(0, 210, 0, 290)
frame.Position = UDim2.new(0.5, -105, 0.4, -145)
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
title.Text = "OBSIDIAN // BOMBER"
title.TextColor3 = Color3.fromRGB(239, 68, 68)
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

-- Main Menu Toggle Button
local menuToggleBtn = Instance.new("TextButton")
menuToggleBtn.Name = getRandomName()
menuToggleBtn.Size = UDim2.new(0, 60, 0, 26)
menuToggleBtn.Position = UDim2.new(0.01, 0, 0.2, 0)
menuToggleBtn.BackgroundColor3 = Color3.fromRGB(22, 24, 31)
menuToggleBtn.BorderSizePixel = 0
menuToggleBtn.Text = "BOMBER"
menuToggleBtn.TextColor3 = Color3.fromRGB(239, 68, 68)
menuToggleBtn.Font = Enum.Font.Code
menuToggleBtn.TextSize = 10
menuToggleBtn.Active = true
menuToggleBtn.Parent = screenGui
applyCorner(menuToggleBtn, 4)
applyStroke(menuToggleBtn, Color3.fromRGB(50, 52, 68), 1)
makeDraggable(menuToggleBtn, menuToggleBtn)

menuToggleBtn.MouseButton1Click:Connect(function() 
    frame.Visible = not frame.Visible 
end)

-- Separate On-Screen Quick Aimlock Toggle Button
local quickAimBtn = Instance.new("TextButton")
quickAimBtn.Name = getRandomName()
quickAimBtn.Size = UDim2.new(0, 85, 0, 26)
quickAimBtn.Position = UDim2.new(0.01, 0, 0.26, 0)
quickAimBtn.BackgroundColor3 = Color3.fromRGB(22, 24, 31)
quickAimBtn.BorderSizePixel = 0
quickAimBtn.Text = "BOMBER AIM: OFF"
quickAimBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
quickAimBtn.Font = Enum.Font.Code
quickAimBtn.TextSize = 9
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

-- Controls Integration
local mainAimBtn

local function setBomberAimState(enabled)
    states.bomberAim = enabled
    local stateTxt = states.bomberAim and "ON" or "OFF"
    local activeColor = states.bomberAim and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(160, 165, 180)

    if mainAimBtn then
        mainAimBtn.Text = "Bomber Aimlock: " .. stateTxt
        mainAimBtn.TextColor3 = activeColor
    end

    quickAimBtn.Text = "BOMBER AIM: " .. stateTxt
    quickAimBtn.TextColor3 = activeColor

    if not states.bomberAim then
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

mainAimBtn = createToggleBtn("Bomber Aimlock: OFF", UDim2.new(0, 6, 0, 32), function()
    setBomberAimState(not states.bomberAim)
end)

quickAimBtn.MouseButton1Click:Connect(function()
    setBomberAimState(not states.bomberAim)
end)

createToggleBtn("Separate Aim Button: OFF", UDim2.new(0, 6, 0, 60), function(btn)
    states.separateBtnVisible = not states.separateBtnVisible
    quickAimBtn.Visible = states.separateBtnVisible
    btn.Text = "Separate Aim Button: " .. (states.separateBtnVisible and "ON" or "OFF")
    btn.TextColor3 = states.separateBtnVisible and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(160, 165, 180)
end)

createToggleBtn("Bomber ESP: OFF", UDim2.new(0, 6, 0, 88), function(btn)
    states.bomberEsp = not states.bomberEsp
    btn.Text = "Bomber ESP: " .. (states.bomberEsp and "ON" or "OFF")
    btn.TextColor3 = states.bomberEsp and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(160, 165, 180)
    if not states.bomberEsp then clearEsp() end
end)

createToggleBtn("Blast Indicator: OFF", UDim2.new(0, 6, 0, 116), function(btn)
    states.blastRadius = not states.blastRadius
    btn.Text = "Blast Indicator: " .. (states.blastRadius and "ON" or "OFF")
    btn.TextColor3 = states.blastRadius and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(160, 165, 180)
    if not states.blastRadius then clearCircles() end
end)

-- Blast Radius Input Box
local radiusBox = Instance.new("TextBox")
radiusBox.Name = getRandomName()
radiusBox.Size = UDim2.new(1, -12, 0, 24)
radiusBox.Position = UDim2.new(0, 6, 0, 144)
radiusBox.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
radiusBox.BorderSizePixel = 0
radiusBox.Text = "Indicator Studs: 4"
radiusBox.PlaceholderText = "Indicator Radius..."
radiusBox.TextColor3 = Color3.fromRGB(160, 165, 180)
radiusBox.Font = Enum.Font.Code
radiusBox.TextSize = 10
radiusBox.ClearTextOnFocus = false
radiusBox.Parent = frame
applyCorner(radiusBox, 4)
applyStroke(radiusBox, Color3.fromRGB(38, 40, 52), 1)

radiusBox.FocusLost:Connect(function()
    local val = tonumber(radiusBox.Text:match("%d+"))
    if val then
        states.blastRadiusStuds = val
        radiusBox.Text = "Indicator Studs: " .. tostring(val)
        for _, circle in pairs(activeCircles) do
            if circle then circle.Radius = val end
        end
    else
        radiusBox.Text = "Indicator Studs: " .. tostring(states.blastRadiusStuds)
    end
end)

createToggleBtn("Backwalk Repel: OFF", UDim2.new(0, 6, 0, 172), function(btn)
    states.autoRepel = not states.autoRepel
    btn.Text = "Backwalk Repel: " .. (states.autoRepel and "ON" or "OFF")
    btn.TextColor3 = states.autoRepel and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(160, 165, 180)
end)

-- Repel Range Input Box
local repelBox = Instance.new("TextBox")
repelBox.Name = getRandomName()
repelBox.Size = UDim2.new(1, -12, 0, 24)
repelBox.Position = UDim2.new(0, 6, 0, 200)
repelBox.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
repelBox.BorderSizePixel = 0
repelBox.Text = "Repel Studs: 12"
repelBox.PlaceholderText = "Repel Range..."
repelBox.TextColor3 = Color3.fromRGB(160, 165, 180)
repelBox.Font = Enum.Font.Code
repelBox.TextSize = 10
repelBox.ClearTextOnFocus = false
repelBox.Parent = frame
applyCorner(repelBox, 4)
applyStroke(repelBox, Color3.fromRGB(38, 40, 52), 1)

repelBox.FocusLost:Connect(function()
    local val = tonumber(repelBox.Text:match("%d+"))
    if val then
        states.repelDistance = val
        repelBox.Text = "Repel Studs: " .. tostring(val)
    else
        repelBox.Text = "Repel Studs: " .. tostring(states.repelDistance)
    end
end)

-- Bomber Identification Algorithm
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

-- Target Acquisition Engine
local function getNearestBomber(hrp)
    local zombiesFolder = Workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return nil end

    local closestHead = nil
    local shortestDist = math.huge
    local children = zombiesFolder:GetChildren()

    for i = 1, #children do
        local zombie = children[i]
        local zHum = zombie:FindFirstChildOfClass("Humanoid")
        if zombie.Parent and zHum and zHum.Health > 0 and isBomber(zombie) then
            local zHead = zombie:FindFirstChild("Head") or zombie:FindFirstChild("HumanoidRootPart")
            if zHead then
                local dist = (hrp.Position - zHead.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestHead = zHead
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
disableBtn.Position = UDim2.new(0, 6, 0, 238)
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

    clearEsp()
    clearCircles()
    screenGui:Destroy()
end)

-- Main Loop
mainLoopConnection = RunService.RenderStepped:Connect(function()
    local zombiesFolder = Workspace:FindFirstChild("Zombies")
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local camera = Workspace.CurrentCamera

    local currentBombers = {}

    if zombiesFolder then
        local children = zombiesFolder:GetChildren()
        for i = 1, #children do
            local zombie = children[i]
            local zHum = zombie:FindFirstChildOfClass("Humanoid")
            if zombie.Parent and zHum and zHum.Health > 0 and isBomber(zombie) then
                currentBombers[zombie] = true

                -- Selection Box ESP
                if states.bomberEsp then
                    if not activeEspBoxes[zombie] or not activeEspBoxes[zombie].Parent then
                        local box = Instance.new("SelectionBox")
                        box.Name = getRandomName()
                        box.Adornee = zombie
                        box.Color3 = Color3.fromRGB(239, 68, 68)
                        box.LineThickness = 0.05
                        box.SurfaceColor3 = Color3.fromRGB(239, 68, 68)
                        box.SurfaceTransparency = 0.7
                        box.AlwaysOnTop = true
                        box.Parent = screenGui
                        activeEspBoxes[zombie] = box
                    end
                end

                -- Adjustable Blast Indicator
                if states.blastRadius then
                    local zHrp = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Head")
                    if zHrp and (not activeCircles[zombie] or not activeCircles[zombie].Parent) then
                        local circle = Instance.new("CylinderHandleAdornment")
                        circle.Name = getRandomName()
                        circle.Adornee = zHrp
                        circle.Height = 0.1
                        circle.Radius = states.blastRadiusStuds
                        circle.Color3 = Color3.fromRGB(239, 68, 68)
                        circle.Transparency = 0.4
                        circle.CFrame = CFrame.Angles(math.rad(90), 0, 0)
                        circle.AlwaysOnTop = true
                        circle.Parent = screenGui
                        activeCircles[zombie] = circle
                    end
                end
            end
        end
    end

    -- Cleanup Visual Caches
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

    -- Smooth Physical Backwalk Movement Repel Engine
    if states.autoRepel then
        local threatVector = Vector3.zero
        local inRangeCount = 0

        for zombie in pairs(currentBombers) do
            local zHrp = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Head")
            if zHrp then
                local flatHrpPos = Vector3.new(hrp.Position.X, 0, hrp.Position.Z)
                local flatZHrpPos = Vector3.new(zHrp.Position.X, 0, zHrp.Position.Z)
                local distVec = flatHrpPos - flatZHrpPos
                local dist = distVec.Magnitude

                if dist < states.repelDistance and dist > 0.001 then
                    threatVector = threatVector + (distVec.Unit * (states.repelDistance - dist))
                    inRangeCount = inRangeCount + 1
                end
            end
        end

        if inRangeCount > 0 and threatVector.Magnitude > 0.001 then
            local moveDirection = threatVector.Unit
            hum:Move(moveDirection, false)
        end
    end

    -- Bomber Aimlock
    if states.bomberAim then
        local targetHead = getNearestBomber(hrp)
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
                if camera then
                    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, headPos)
                end
            end
        else
            hum.AutoRotate = true
        end
    end
end)
