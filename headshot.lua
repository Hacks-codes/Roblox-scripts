local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer

-- Modes: 
-- 0 = OFF
-- 1 = Direct Module Override
-- 2 = hookfunction Detour
-- 3 = hookmetamethod (__namecall)
local currentMode = 0 

local originalMeleeHitCheck = nil
local oldHookfunctionTarget = nil
local oldNamecall = nil

-- Utility to locate zombie parts
local function getZombieModel(part)
    if not part then return nil end
    local model = part.Parent
    for i = 1, 5 do
        if not model then break end
        if model:IsA("Model") and (model.Name == "m_Zombie" or model:FindFirstChild("Orig")) then
            return model
        end
        model = model.Parent
    end
    return nil
end

local function getZombieHead(zombieModel)
    if not zombieModel then return nil end
    for _, part in pairs(zombieModel:GetChildren()) do
        if part.Name == "Head" and (part:IsA("Part") or part:IsA("MeshPart")) then
            return part
        end
    end
    return nil
end

-- Custom Hit Logic for Modes 1 & 2
local function customMeleeHitCheck(self, origin, direction, raycastParams, hitEntities, isCharge)
    if currentMode == 0 then
        if originalMeleeHitCheck then
            return originalMeleeHitCheck(self, origin, direction, raycastParams, hitEntities, isCharge)
        end
        return 0
    end

    local rayResult = Workspace:Raycast(origin, direction, raycastParams)
    if rayResult then
        local hitPart = rayResult.Instance
        local zombieModel = getZombieModel(hitPart)
        if zombieModel then
            local orig = zombieModel:FindFirstChild("Orig")
            if orig then
                local head = getZombieHead(zombieModel)
                if head then
                    local zombieRef = orig.Value
                    local hitPos = head.Position
                    self.remoteEvent:FireServer("HitZombieM", zombieRef, hitPos, true, hitPos, "Head", Vector3.new(0, 1, 0))
                    return 1
                end
            end
        end
    end

    if originalMeleeHitCheck then
        return originalMeleeHitCheck(self, origin, direction, raycastParams, hitEntities, isCharge)
    end
    return 0
end

-- ==========================================
-- HOOK SETUP PROCEDURES
-- ==========================================
local weaponModule = ReplicatedStorage:FindFirstChild("Weapons") or ReplicatedStorage:FindFirstChild("Modules")
local meleeSystem = nil

if weaponModule then
    pcall(function()
        meleeSystem = require(weaponModule:FindFirstChild("MeleeSystem") or weaponModule)
    end)
end

-- Setup hookfunction (Mode 2)
if hookfunction and meleeSystem and type(meleeSystem.MeleeHitCheck) == "function" then
    oldHookfunctionTarget = meleeSystem.MeleeHitCheck
    hookfunction(meleeSystem.MeleeHitCheck, function(...)
        if currentMode == 2 then
            return customMeleeHitCheck(...)
        end
        return oldHookfunctionTarget(...)
    end)
end

-- Setup hookmetamethod __namecall (Mode 3)
if hookmetamethod and getnamecallmethod then
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()

        if currentMode == 3 and method == "FireServer" and args[1] == "HitZombieM" then
            -- Force the hit part parameter (index 6) to "Head"
            args[6] = "Head"
            return oldNamecall(self, unpack(args))
        end

        return oldNamecall(self, ...)
    end)
end

-- Apply Direct Override (Mode 1)
local function updateDirectOverride()
    if meleeSystem and type(meleeSystem.MeleeHitCheck) == "function" then
        if not originalMeleeHitCheck then
            originalMeleeHitCheck = meleeSystem.MeleeHitCheck
        end
        
        if currentMode == 1 then
            meleeSystem.MeleeHitCheck = customMeleeHitCheck
        else
            meleeSystem.MeleeHitCheck = originalMeleeHitCheck
        end
    end
end

-- ==========================================
-- DRAGGABLE TOGGLE UI CREATION
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MultiModeToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = lp:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 160, 0, 35)
toggleButton.Position = UDim2.new(0.05, 0, 0.2, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Default Red (OFF)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 13
toggleButton.Text = "Mode: OFF"
toggleButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = toggleButton

-- Mode Switcher
toggleButton.MouseButton1Click:Connect(function()
    currentMode = (currentMode + 1) % 4
    updateDirectOverride()

    if currentMode == 0 then
        toggleButton.Text = "Mode: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    elseif currentMode == 1 then
        toggleButton.Text = "Mode 1: Module Override"
        toggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    elseif currentMode == 2 then
        toggleButton.Text = "Mode 2: Hookfunction"
        toggleButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
    elseif currentMode == 3 then
        toggleButton.Text = "Mode 3: Namecall Hook"
        toggleButton.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
    end
end)

-- Draggable Logic
local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    toggleButton.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X, 
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleButton.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

toggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)
