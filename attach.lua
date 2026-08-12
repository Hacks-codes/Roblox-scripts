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
frame.Size = UDim2.new(0, 190, 0, 142)
frame.Position = UDim2.new(0.5, -95, 0.4, -71)
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
title.Text = "Target Attach Engine"
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

-- Draggable Floating Menu Button
local menuToggleBtn = Instance.new("TextButton")
menuToggleBtn.Name = getRandomName()
menuToggleBtn.Size = UDim2.new(0, 45, 0, 24)
menuToggleBtn.Position = UDim2.new(0.01, 0, 0.2, 0)
menuToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
menuToggleBtn.BorderSizePixel = 1
menuToggleBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
menuToggleBtn.Text = "ATTACH"
menuToggleBtn.TextColor3 = Color3.fromRGB(0, 220, 220)
menuToggleBtn.Font = Enum.Font.SourceSansBold
menuToggleBtn.TextSize = 11
menuToggleBtn.Active = true
menuToggleBtn.Parent = screenGui

makeDraggable(menuToggleBtn, menuToggleBtn)
menuToggleBtn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

-- Feature States
local states = {
    attachEnabled = false,
    heightOffset = 3
}

local currentTarget = nil

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

-- Attach Enable/Disable Toggle
createToggleBtn("Target Attach: OFF", UDim2.new(0, 4, 0, 28), function(btn)
    states.attachEnabled = not states.attachEnabled
    btn.Text = "Target Attach: " .. (states.attachEnabled and "ON" or "OFF")
    btn.TextColor3 = states.attachEnabled and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(200, 200, 200)
    
    if not states.attachEnabled then
        currentTarget = nil
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.AutoRotate = true
        end
    end
end)

-- Custom Height Input Container
local heightContainer = Instance.new("Frame")
heightContainer.Size = UDim2.new(1, -8, 0, 22)
heightContainer.Position = UDim2.new(0, 4, 0, 54)
heightContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
heightContainer.BorderSizePixel = 1
heightContainer.BorderColor3 = Color3.fromRGB(60, 60, 60)
heightContainer.Parent = frame

local heightLabel = Instance.new("TextLabel")
heightLabel.Size = UDim2.new(0.65, 0, 1, 0)
heightLabel.Position = UDim2.new(0, 4, 0, 0)
heightLabel.Text = "Attach Height:"
heightLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
heightLabel.Font = Enum.Font.SourceSans
heightLabel.TextSize = 11
heightLabel.TextXAlignment = Enum.TextXAlignment.Left
heightLabel.BackgroundTransparency = 1
heightLabel.Parent = heightContainer

local heightBox = Instance.new("TextBox")
heightBox.Size = UDim2.new(0.3, 0, 1, -4)
heightBox.Position = UDim2.new(0.67, 0, 0, 2)
heightBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
heightBox.BorderSizePixel = 1
heightBox.BorderColor3 = Color3.fromRGB(80, 80, 80)
heightBox.Text = "3"
heightBox.TextColor3 = Color3.fromRGB(0, 220, 220)
heightBox.Font = Enum.Font.SourceSansBold
heightBox.TextSize = 11
heightBox.ClearTextOnFocus = false
heightBox.Parent = heightContainer

heightBox.FocusLost:Connect(function()
    local val = tonumber(heightBox.Text)
    if val then
        states.heightOffset = val
    else
        heightBox.Text = tostring(states.heightOffset)
    end
end)

-- Unload / Clean Up Script
local mainLoopConnection
local disableBtn = Instance.new("TextButton")
disableBtn.Name = getRandomName()
disableBtn.Size = UDim2.new(1, -8, 0, 22)
disableBtn.Position = UDim2.new(0, 4, 0, 80)
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
    if hum then
        hum.AutoRotate = true
    end

    screenGui:Destroy()
end)

-- Strict Bomber Check Engine
local function isBomber(zombie)
    if not zombie then return true end
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

-- Validate Target
local function isTargetValid(zombie)
    if not zombie or not zombie.Parent then return false end
    if isBomber(zombie) then return false end
    
    local zHead = zombie:FindFirstChild("Head") or zombie:FindFirstChild("HumanoidRootPart")
    return zHead ~= nil
end

-- Find Closest Non-Bomber Zombie
local function getClosestZombie(hrp)
    local zombiesFolder = workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return nil end

    local closest = nil
    local shortestDist = math.huge

    for _, zombie in ipairs(zombiesFolder:GetChildren()) do
        if not isBomber(zombie) then
            local zHead = zombie:FindFirstChild("Head") or zombie:FindFirstChild("HumanoidRootPart")
            if zHead and zombie.Parent then
                local dist = (hrp.Position - zHead.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = zombie
                end
            end
        end
    end

    return closest
end

-- RenderStepped Execution Loop
mainLoopConnection = RunService.RenderStepped:Connect(function()
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    -- Restore movement state when disabled or dead
    if not states.attachEnabled or not hrp or not hum then
        if hum then hum.AutoRotate = true end
        return
    end

    -- Acquire or update closest valid non-bomber target
    if not isTargetValid(currentTarget) then
        currentTarget = getClosestZombie(hrp)
    end

    -- Attachment & Lock Engine
    if currentTarget then
        local zHead = currentTarget:FindFirstChild("Head") or currentTarget:FindFirstChild("HumanoidRootPart")

        if zHead then
            hum.AutoRotate = false

            -- Freeze physics velocity to prevent physics glitches, fling resets, and body shaking
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero

            local targetHeadPos = zHead.Position
            local teleportPos = targetHeadPos + Vector3.new(0, states.heightOffset, 0)

            -- CFrame direct lookAt to prevent body tweaking or looking away
            hrp.CFrame = CFrame.lookAt(teleportPos, targetHeadPos)
        end
    else
        -- Fall back and restore natural character movement if no zombies are around
        hum.AutoRotate = true
    end
end)
