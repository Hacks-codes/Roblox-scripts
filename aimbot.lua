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
    aimType = "Camera", -- "Camera" or "Body"
    targetPart = "Head", -- "Head" or "Torso"
    snapType = "Smooth", -- "Snappy" or "Smooth"
    smoothness = 0.2,
    wallCheck = false, -- Default set to false so it works out of the box
    maxDistance = 200,
    noCamLimit = false
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

-- UI Construction
local screenGui = Instance.new("ScreenGui")
screenGui.Name = getRandomName()
screenGui.ResetOnSpawn = false
screenGui.Parent = getGuiParent()

local frame = Instance.new("Frame")
frame.Name = getRandomName()
frame.Size = UDim2.new(0, 210, 0, 310)
frame.Position = UDim2.new(0.5, -105, 0.4, -155)
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
title.Text = "OBSIDIAN // AIMBOT V2"
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

-- Menu Toggle Button
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

-- Separate Quick Aim Toggle Button
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

local mainAimBtn

local function setAimState(enabled)
    states.aimlock = enabled
    local stateTxt = states.aimlock and "ON" or "OFF"
    local activeColor = states.aimlock and Color3.fromRGB(139, 92, 246) or Color3.fromRGB(160, 165, 180)

    if mainAimBtn then
        mainAimBtn.Text = "Aimbot: " .. stateTxt
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

mainAimBtn = createToggleBtn("Aimbot: OFF", UDim2.new(0, 6, 0, 32), function()
    setAimState(not states.aimlock)
end)

quickAimBtn.MouseButton1Click:Connect(function()
    setAimState(not states.aimlock)
end)

createToggleBtn("Separate Aim Button: OFF", UDim2.new(0, 6, 0, 60), function(btn)
    states.separateBtnVisible = not states.separateBtnVisible
    quickAimBtn.Visible = states.separateBtnVisible
    btn.Text = "Separate Aim Button: " .. (states.separateBtnVisible and "ON" or "OFF")
    btn.TextColor3 = states.separateBtnVisible and Color3.fromRGB(139, 92, 246) or Color3.fromRGB(160, 165, 180)
end)

createToggleBtn("Target Part: Head", UDim2.new(0, 6, 0, 88), function(btn)
    states.targetPart = (states.targetPart == "Head") and "Torso" or "Head"
    btn.Text = "Target Part: " .. states.targetPart
    btn.TextColor3 = Color3.fromRGB(139, 92, 246)
end)

createToggleBtn("Aim Mode: Camera Aim", UDim2.new(0, 6, 0, 116), function(btn)
    states.aimType = (states.aimType == "Camera") and "Body" or "Camera"
    btn.Text = "Aim Mode: " .. (states.aimType == "Camera" and "Camera Aim" or "Body Aim")
    btn.TextColor3 = Color3.fromRGB(139, 92, 246)
end)

createToggleBtn("Targeting Style: Smooth", UDim2.new(0, 6, 0, 144), function(btn)
    states.snapType = (states.snapType == "Smooth") and "Snappy" or "Smooth"
    btn.Text = "Targeting Style: " .. states.snapType
    btn.TextColor3 = Color3.fromRGB(139, 92, 246)
end)

local rangeBox = Instance.new("TextBox")
rangeBox.Name = getRandomName()
rangeBox.Size = UDim2.new(1, -12, 0, 24)
rangeBox.Position = UDim2.new(0, 6, 0, 172)
rangeBox.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
rangeBox.BorderSizePixel = 0
rangeBox.Text = "Range (Studs): 200"
rangeBox.PlaceholderText = "Enter range..."
rangeBox.TextColor3 = Color3.fromRGB(160, 165, 180)
rangeBox.Font = Enum.Font.Code
rangeBox.TextSize = 10
rangeBox.ClearTextOnFocus = false
rangeBox.Parent = frame
applyCorner(rangeBox, 4)
applyStroke(rangeBox, Color3.fromRGB(38, 40, 52), 1)

rangeBox.FocusLost:Connect(function()
    local val = tonumber(rangeBox.Text:match("%d+"))
    if val then
        states.maxDistance = val
        rangeBox.Text = "Range (Studs): " .. tostring(val)
    else
        rangeBox.Text = "Range (Studs): " .. tostring(states.maxDistance)
    end
end)

createToggleBtn("Wall Check: OFF", UDim2.new(0, 6, 0, 200), function(btn)
    states.wallCheck = not states.wallCheck
    btn.Text = "Wall Check: " .. (states.wallCheck and "ON" or "OFF")
    btn.TextColor3 = states.wallCheck and Color3.fromRGB(139, 92, 246) or Color3.fromRGB(160, 165, 180)
end)

local zoomConnection
createToggleBtn("No Camera Zoom Limit: OFF", UDim2.new(0, 6, 0, 228), function(btn)
    states.noCamLimit = not states.noCamLimit
    btn.Text = "No Camera Zoom Limit: " .. (states.noCamLimit and "ON" or "OFF")
    btn.TextColor3 = states.noCamLimit and Color3.fromRGB(139, 92, 246) or Color3.fromRGB(160, 165, 180)

    if states.noCamLimit then
        lp.CameraMaxZoomDistance = 100000
        lp.CameraMinZoomDistance = 0.5
        if not zoomConnection then
            zoomConnection = RunService.Stepped:Connect(function()
                if states.noCamLimit then
                    lp.CameraMaxZoomDistance = 100000
                    lp.CameraMinZoomDistance = 0.5
                end
            end)
        end
    else
        if zoomConnection then
            zoomConnection:Disconnect()
            zoomConnection = nil
        end
        lp.CameraMaxZoomDistance = 128
        lp.CameraMinZoomDistance = 0.5
    end
end)

-- Multi-source Search to Find Enemy Models Anywhere
local function getTargetPart(model)
    if states.targetPart == "Head" then
        return model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
    else
        return model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") or model:FindFirstChild("HumanoidRootPart")
    end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = RaycastFilterType.Exclude
raycastParams.IgnoreWater = true

local function isVisible(origin, targetPos, targetModel, myChar)
    if not states.wallCheck then return true end
    raycastParams.FilterDescendantsInstances = {myChar, targetModel}
    local result = Workspace:Raycast(origin, targetPos - origin, raycastParams)
    if result then
        return result.Instance:IsDescendantOf(targetModel)
    end
    return true
end

local function findNearestEnemy(hrp, char)
    local closestPart = nil
    local shortestDist = states.maxDistance
    local hrpPos = hrp.Position
    local eyePos = hrpPos + Vector3.new(0, 1.5, 0)

    -- Collect all potential zombie/enemy models from Workspace and dedicated folders
    local candidates = {}
    local zombiesFolder = Workspace:FindFirstChild("Zombies") or Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("NPCs")
    
    if zombiesFolder then
        for _, v in ipairs(zombiesFolder:GetChildren()) do table.insert(candidates, v) end
    else
        for _, v in ipairs(Workspace:GetChildren()) do table.insert(candidates, v) end
    end

    for i = 1, #candidates do
        local obj = candidates[i]
        if obj ~= char and obj:IsA("Model") then
            local zHum = obj:FindFirstChildOfClass("Humanoid")
            if zHum and zHum.Health > 0 then
                local part = getTargetPart(obj)
                if part then
                    local dist = (hrpPos - part.Position).Magnitude
                    if dist <= shortestDist then
                        if isVisible(eyePos, part.Position, obj, char) then
                            shortestDist = dist
                            closestPart = part
                        end
                    end
                end
            end
        end
    end

    return closestPart
end

-- Unload Button
local renderLoopConnection

local disableBtn = Instance.new("TextButton")
disableBtn.Name = getRandomName()
disableBtn.Size = UDim2.new(1, -12, 0, 24)
disableBtn.Position = UDim2.new(0, 6, 0, 256)
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
    if renderLoopConnection then renderLoopConnection:Disconnect() end
    if zoomConnection then zoomConnection:Disconnect() end

    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end

    lp.CameraMaxZoomDistance = 128
    lp.CameraMinZoomDistance = 0.5
    screenGui:Destroy()
end)

-- Main Aim Loop (RenderStepped)
renderLoopConnection = RunService.RenderStepped:Connect(function(deltaTime)
    if not states.aimlock then return end

    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local camera = Workspace.CurrentCamera

    if not hrp or not hum or not camera then return end

    local targetPart = findNearestEnemy(hrp, char)

    if targetPart then
        local targetPos = targetPart.Position
        local lerpFactor = (states.snapType == "Smooth") and math.clamp(states.smoothness * deltaTime * 60, 0.05, 1) or 1

        if states.aimType == "Body" then
            hum.AutoRotate = false
            local lookAtPos = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
            if (lookAtPos - hrp.Position).Magnitude > 0.01 then
                local targetCFrame = CFrame.lookAt(hrp.Position, lookAtPos)
                hrp.CFrame = hrp.CFrame:Lerp(targetCFrame, lerpFactor)
            end
        elseif states.aimType == "Camera" then
            hum.AutoRotate = false
            local targetCamCFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
            camera.CFrame = camera.CFrame:Lerp(targetCamCFrame, lerpFactor)
            
            local lookAtPos = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
            if (lookAtPos - hrp.Position).Magnitude > 0.01 then
                hrp.CFrame = hrp.CFrame:Lerp(CFrame.lookAt(hrp.Position, lookAtPos), lerpFactor)
            end
        end
    else
        hum.AutoRotate = true
    end
end)
