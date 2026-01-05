local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- ScreenGui作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PalletSpawnerGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Mobile/PCスケーリング対応
local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = screenGui

local aspectRatio = Instance.new("UIAspectRatioConstraint")
aspectRatio.AspectRatio = 16/9
aspectRatio.Parent = screenGui

-- 右側Frame（小型化）
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 110, 0, 60)
mainFrame.Position = UDim2.new(1, -120, 0.5, -30)
mainFrame.AnchorPoint = Vector2.new(1, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(100, 150, 255)
frameStroke.Thickness = 1.5
frameStroke.Parent = mainFrame

-- タイトル（小型）
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Pallet Spawn"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Spawnボタン
local spawnButton = Instance.new("TextButton")
spawnButton.Size = UDim2.new(0.9, 0, 0.5, 0)
spawnButton.Position = UDim2.new(0.05, 0, 0.45, 0)
spawnButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
spawnButton.Text = "Spawn Pallet"
spawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnButton.TextScaled = true
spawnButton.Font = Enum.Font.GothamSemibold
spawnButton.BorderSizePixel = 0
spawnButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = spawnButton

-- ホバー/クリックアニメーション
local hoverTween = TweenService:Create(spawnButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 0)})
local normalTween = TweenService:Create(spawnButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 0)})

spawnButton.MouseEnter:Connect(function() hoverTween:Play() end)
spawnButton.MouseLeave:Connect(function() normalTween:Play() end)

-- スポーン機能
spawnButton.MouseButton1Click:Connect(function()
    spawnButton.Text = "Spawning..."
    spawnButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    
    local spawnRemote = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
    
    -- キャラクター更新（リスポーン対応）
    character = player.Character or player.CharacterAdded:Wait()
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- 目の前位置計算（前方5スタッド、高さ3スタッド）
    local spawnCFrame = humanoidRootPart.CFrame * CFrame.new(0, 3, -5)
    
    local success, result = pcall(function()
        return spawnRemote:InvokeServer("PalletLightBrown", spawnCFrame)
    end)
    
    if success then
        print("Pallet spawned successfully.")
    else
        warn("Spawn failed: " .. tostring(result))
    end
    
    wait(0.5)
    spawnButton.Text = "Spawn Pallet"
    normalTween:Play()
end)

-- ドラッグ機能（Mobileタッチ対応）
local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

print("Compact Pallet Spawner GUI loaded. Button spawns Pallet in front of you.")
