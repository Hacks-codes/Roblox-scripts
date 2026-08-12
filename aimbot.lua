Local function getService(name)
    Local service = game:GetService(name)
    Return cloneref and cloneref(service) or service
End

Local Players = getService("Players")
Local RunService = getService("RunService")
Local CoreGui = getService("CoreGui")
Local UserInputService = getService("UserInputService")
Local Workspace = getService("Workspace")

Local lp = Players.LocalPlayer

Local function getRandomName()
    Local str = ""
    For i = 1, math.random(8, 14) do
        Str = str .. String.char(math.random(97, 122))
    End
    Return str
End

Local function getGuiParent()
    If gethui then return gethui() end
    Local ok, res = pcall(function() return CoreGui:FindFirstChild("RobloxGui") end)
    If ok and res then return res end
    Return lp:WaitForChild("PlayerGui")
End

-- Screen Container
Local screenGui = Instance.new("ScreenGui")
ScreenGui.Name = getRandomName()
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = getGuiParent()

-- Main Panel
Local frame = Instance.new("Frame")
Frame.Name = getRandomName()
Frame.Size = UDim2.new(0, 190, 0, 246) -- Expanded slightly to accommodate new options
Frame.Position = UDim2.new(0.5, -95, 0.4, -123)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 1
Frame.BorderColor3 = Color3.fromRGB(60, 60, 60)
Frame.Visible = false
Frame.Active = true
Frame.Parent = screenGui

-- Mobile Touch / Mouse Dragging Helper
Local function makeDraggable(guiObject, targetFrame)
    Local dragging, dragStart, startPos
    GuiObject.InputBegan:Connect(function(input)
        If input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = targetFrame.Position
        End
    End)

    UserInputService.InputChanged:Connect(function(input)
        If dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Local delta = input.Position - dragStart
            TargetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        End
    End)

    UserInputService.InputEnded:Connect(function(input)
        If input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        End
    End)
End

-- Header Bar
Local header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 22)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Header.BorderSizePixel = 0
Header.Parent = frame
MakeDraggable(header, frame)

Local title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -22, 1, 0)
Title.Position = UDim2.new(0, 6, 0, 0)
Title.Text = "Precision Aim Engine"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = header

Local closeBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -22, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 11
CloseBtn.Parent = header
CloseBtn.MouseButton1Click:Connect(function() frame.Visible = false end)

-- Main Menu Toggle Button
Local menuToggleBtn = Instance.new("TextButton")
MenuToggleBtn.Name = getRandomName()
MenuToggleBtn.Size = UDim2.new(0, 45, 0, 24)
MenuToggleBtn.Position = UDim2.new(0.01, 0, 0.2, 0)
MenuToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MenuToggleBtn.BorderSizePixel = 1
MenuToggleBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
MenuToggleBtn.Text = "MENU"
MenuToggleBtn.TextColor3 = Color3.fromRGB(0, 220, 220)
MenuToggleBtn.Font = Enum.Font.SourceSansBold
MenuToggleBtn.TextSize = 11
MenuToggleBtn.Active = true
MenuToggleBtn.Parent = screenGui

MakeDraggable(menuToggleBtn, menuToggleBtn)
MenuToggleBtn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

-- Standalone Floating Aimlock Toggle Button
Local quickAimBtn = Instance.new("TextButton")
QuickAimBtn.Name = getRandomName()
QuickAimBtn.Size = UDim2.new(0, 55, 0, 24)
QuickAimBtn.Position = UDim2.new(0.01, 0, 0.26, 0)
QuickAimBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
QuickAimBtn.BorderSizePixel = 1
QuickAimBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
QuickAimBtn.Text = "AIM: OFF"
QuickAimBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
QuickAimBtn.Font = Enum.Font.SourceSansBold
QuickAimBtn.TextSize = 10
QuickAimBtn.Active = true
QuickAimBtn.Visible = false
QuickAimBtn.Parent = screenGui

MakeDraggable(quickAimBtn, quickAimBtn)

-- Feature States
Local states = {
    AimLock = false,
    AimMode = "Body",
    SeparateBtnVisible = false,
    AimRange = 5,
    UnlockCam = false,
    SmoothAim = false,
    Smoothness = 0.2 -- Lerp factor (lower = smoother/slower, higher = faster)
}

Local function createToggleBtn(text, pos, onClick)
    Local btn = Instance.new("TextButton")
    Btn.Name = getRandomName()
    Btn.Size = UDim2.new(1, -8, 0, 22)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Btn.BorderSizePixel = 1
    Btn.BorderColor3 = Color3.fromRGB(60, 60, 60)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 11
    Btn.Parent = frame
    Btn.MouseButton1Click:Connect(function() onClick(btn) end)
    Return btn
End

-- Synchronized Aimlock Controller Function
Local mainAimBtn
Local function setAimlockState(enabled)
    States.aimLock = enabled
    Local stateTxt = states.aimLock and "ON" or "OFF"
    Local activeColor = states.aimLock and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(200, 200, 200)

    If mainAimBtn then
        MainAimBtn.Text = "Aim Lock: " .. StateTxt
        MainAimBtn.TextColor3 = activeColor
    End

    QuickAimBtn.Text = "AIM: " .. StateTxt
    QuickAimBtn.TextColor3 = activeColor

    If not states.aimLock then
        Local char = lp.Character
        Local hum = char and char:FindFirstChildOfClass("Humanoid")
        If hum then hum.AutoRotate = true end
    End
End

MainAimBtn = createToggleBtn("Aim Lock: OFF", UDim2.new(0, 4, 0, 28), function()
    SetAimlockState(not states.aimLock)
End)

QuickAimBtn.MouseButton1Click:Connect(function()
    SetAimlockState(not states.aimLock)
End)

-- Separate Floating Button Toggle Option
CreateToggleBtn("Aim Lock Button: OFF", UDim2.new(0, 4, 0, 54), function(btn)
    States.separateBtnVisible = not states.separateBtnVisible
    QuickAimBtn.Visible = states.separateBtnVisible
    Btn.Text = "Aim Lock Button: " .. (states.separateBtnVisible and "ON" or "OFF")
    Btn.TextColor3 = states.separateBtnVisible and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(200, 200, 200)
End)

-- Custom Aim Range Container
Local rangeContainer = Instance.new("Frame")
RangeContainer.Size = UDim2.new(1, -8, 0, 22)
RangeContainer.Position = UDim2.new(0, 4, 0, 80)
RangeContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
RangeContainer.BorderSizePixel = 1
RangeContainer.BorderColor3 = Color3.fromRGB(60, 60, 60)
RangeContainer.Parent = frame

Local rangeLabel = Instance.new("TextLabel")
RangeLabel.Size = UDim2.new(0.65, 0, 1, 0)
RangeLabel.Position = UDim2.new(0, 4, 0, 0)
RangeLabel.Text = "Aim Range (Studs):"
RangeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
RangeLabel.Font = Enum.Font.SourceSans
RangeLabel.TextSize = 11
RangeLabel.TextXAlignment = Enum.TextXAlignment.Left
RangeLabel.BackgroundTransparency = 1
RangeLabel.Parent = rangeContainer

Local rangeBox = Instance.new("TextBox")
RangeBox.Size = UDim2.new(0.3, 0, 1, -4)
RangeBox.Position = UDim2.new(0.67, 0, 0, 2)
RangeBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
RangeBox.BorderSizePixel = 1
RangeBox.BorderColor3 = Color3.fromRGB(80, 80, 80)
RangeBox.Text = "5"
RangeBox.TextColor3 = Color3.fromRGB(0, 220, 220)
RangeBox.Font = Enum.Font.SourceSansBold
RangeBox.TextSize = 11
RangeBox.ClearTextOnFocus = false
RangeBox.Parent = rangeContainer

RangeBox.FocusLost:Connect(function()
    Local val = tonumber(rangeBox.Text)
    If val and val > 0 then
        States.aimRange = val
    Else
        RangeBox.Text = tostring(states.aimRange)
    End
End)

-- Aim Mode Switcher
CreateToggleBtn("Aim Mode: Body", UDim2.new(0, 4, 0, 106), function(btn)
    States.aimMode = (states.aimMode == "Body") and "Camera" or "Body"
    Btn.Text = "Aim Mode: " .. States.aimMode

    Local char = lp.Character
    Local hum = char and char:FindFirstChildOfClass("Humanoid")
    If hum then hum.AutoRotate = true end
End)

-- Smooth Aim Toggle
CreateToggleBtn("Smooth Aim: OFF", UDim2.new(0, 4, 0, 132), function(btn)
    States.smoothAim = not states.smoothAim
    Btn.Text = "Smooth Aim: " .. (states.smoothAim and "ON" or "OFF")
    Btn.TextColor3 = states.smoothAim and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(200, 200, 200)
End)

-- Unlock Zoom
CreateToggleBtn("Unlock Cam Zoom: OFF", UDim2.new(0, 4, 0, 158), function(btn)
    States.unlockCam = not states.unlockCam
    Btn.Text = "Unlock Cam Zoom: " .. (states.unlockCam and "ON" or "OFF")
    Btn.TextColor3 = states.unlockCam and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(200, 200, 200)
    If not states.unlockCam and lp then
        Lp.CameraMaxZoomDistance = 128
        Lp.CameraMinZoomDistance = 0.5
    End
End)

-- Unload Script
Local mainLoopConnection
Local disableBtn = Instance.new("TextButton")
DisableBtn.Name = getRandomName()
DisableBtn.Size = UDim2.new(1, -8, 0, 22)
DisableBtn.Position = UDim2.new(0, 4, 0, 184)
DisableBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
DisableBtn.BorderSizePixel = 1
DisableBtn.BorderColor3 = Color3.fromRGB(100, 20, 20)
DisableBtn.Text = "UNLOAD SCRIPT"
DisableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DisableBtn.Font = Enum.Font.SourceSansBold
DisableBtn.TextSize = 11
DisableBtn.Parent = frame

DisableBtn.MouseButton1Click:Connect(function()
    If mainLoopConnection then
        MainLoopConnection:Disconnect()
        MainLoopConnection = nil
    End

    If lp then
        Lp.CameraMaxZoomDistance = 128
        Lp.CameraMinZoomDistance = 0.5
        Local char = lp.Character
        Local hum = char and char:FindFirstChildOfClass("Humanoid")
        If hum then hum.AutoRotate = true end
    End

    ScreenGui:Destroy()
End)

-- Strict Bomber Filter
Local function isBomber(zombie)
    If not zombie then return false end
    Local zType = tostring(zombie:GetAttribute("Type") or "")
    Local zName = zombie.Name:lower()

    If zType == "Barrel" or zType == "Bomber" or zType == "Igniter" or zName:find("barrel") or zName:find("bomber") or zName:find("igniter") then
        Return true
    End

    If zombie:FindFirstChild("Barrel") or zombie:FindFirstChild("Bomb") or zombie:FindFirstChild("Powder") or zombie:FindFirstChild("PowderBarrel") then
        Return true
    End

    Return false
End

-- Dynamic Range Target Acquisition
Local function getTargetHead(hrp)
    Local zombiesFolder = Workspace:FindFirstChild("Zombies")
    If not zombiesFolder then return nil end

    Local closestHead = nil
    Local shortestDist = states.aimRange

    For _, zombie in ipairs(zombiesFolder:GetChildren()) do
        If not isBomber(zombie) then
            Local zHead = zombie:FindFirstChild("Head") or zombie:FindFirstChild("HumanoidRootPart")
            If zHead and zombie.Parent then
                Local dist = (hrp.Position - zHead.Position).Magnitude
                If dist <= shortestDist then
                    ShortestDist = dist
                    ClosestHead = zHead
                End
            End
        End
    End

    Return closestHead
End

-- RenderStepped Main Loop
MainLoopConnection = RunService.RenderStepped:Connect(function()
    If states.unlockCam and lp then
        Lp.CameraMaxZoomDistance = 10000
        Lp.CameraMinZoomDistance = 0
    End

    Local char = lp.Character
    Local hrp = char and char:FindFirstChild("HumanoidRootPart")
    Local hum = char and char:FindFirstChildOfClass("Humanoid")
    Local camera = Workspace.CurrentCamera

    If not states.aimLock or not hrp or not hum then
        If hum then hum.AutoRotate = true end
        Return
    End

    Local targetHead = getTargetHead(hrp)

    If targetHead then
        Local headPos = targetHead.Position

        If states.aimMode == "Body" then
            Hum.AutoRotate = false
            Local lookAtPos = Vector3.new(headPos.X, hrp.Position.Y, headPos.Z)
            If (lookAtPos - hrp.Position).Magnitude > 0.01 then
                Local targetCFrame = CFrame.lookAt(hrp.Position, lookAtPos)
                If states.smoothAim then
                    Hrp.CFrame = hrp.CFrame:Lerp(targetCFrame, states.smoothness)
                Else
                    Hrp.CFrame = targetCFrame
                End
            End
        Elseif states.aimMode == "Camera" then
            Hum.AutoRotate = true
            If camera then
                Local targetCFrame = CFrame.lookAt(camera.CFrame.Position, headPos)
                If states.smoothAim then
                    Camera.CFrame = camera.CFrame:Lerp(targetCFrame, states.smoothness)
                Else
                    Camera.CFrame = targetCFrame
                End
            End
        End
    Else
        Hum.AutoRotate = true
    End
End)
