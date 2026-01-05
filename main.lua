local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ScreenGui作成（自作UI）
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlankSpawnerGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Mobile/PCスケーリング対応
local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = screenGui

local aspectRatio = Instance.new("UIAspectRatioConstraint")
aspectRatio.AspectRatio = 16/9  -- 標準アスペクト比でMobile対応
aspectRatio.Parent = screenGui

-- 右側Frame（半透明、角丸）
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 120)
mainFrame.Position = UDim2.new(1, -230, 0.5, -60)
mainFrame.AnchorPoint = Vector2.new(1, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(100, 150, 255)
frameStroke.Thickness = 2
frameStroke.Parent = mainFrame

-- タイトル（オプション、シンプルに）
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Pallet Spawner"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Spawnボタン
local spawnButton = Instance.new("TextButton")
spawnButton.Size = UDim2.new(0.9, 0, 0.6, 0)
spawnButton.Position = UDim2.new(0.05, 0, 0.35, 0)
spawnButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
spawnButton.Text = "Spawn Pallet"
spawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnButton.TextScaled = true
spawnButton.Font = Enum.Font.GothamSemibold
spawnButton.BorderSizePixel = 0
spawnButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 10)
buttonCorner.Parent = spawnButton

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(0, 255, 0)
buttonStroke.Thickness = 1.5
buttonStroke.Parent = spawnButton

-- ホバー/クリックアニメーション（Tween）
local hoverTween = TweenService:Create(spawnButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 0)})
local clickTween = TweenService:Create(spawnButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0.85, 0, 0.55, 0)})
local normalTween = TweenService:Create(spawnButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 0)})

spawnButton.MouseEnter:Connect(function()
    hoverTween:Play()
end)

spawnButton.MouseLeave:Connect(function()
    normalTween:Play()
end)

spawnButton.MouseButton1Down:Connect(function()
    clickTween:Play()
end)

spawnButton.MouseButton1Up:Connect(function()
    spawnButton.Size = UDim2.new(0.9, 0, 0.6, 0)
end)

-- スポーン機能（ここを調整）
spawnButton.MouseButton1Click:Connect(function()
    spawnButton.Text = "Spawning..."
    spawnButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    
    -- RemoteEventを探してFireServer（調整必要）
    local spawnRemote = ReplicatedStorage:FindFirstChild("SpawnItem") or  -- 例1
                        ReplicatedStorage:FindFirstChild("ItemBuilder") or  -- 例2
                        ReplicatedStorage:FindFirstChild("PlaceToy") or     -- 例3
                        ReplicatedStorage:FindFirstChild("BuildingRemote")  -- 例4
    
    if spawnRemote and spawnRemote:IsA("RemoteEvent") then
        -- Plank Maker spawn例（IDまたは名前で調整）
        spawnRemote:FireServer("PlankMaker")  -- 文字列の場合
        -- または: spawnRemote:FireServer(6532318356)  -- IDの場合（音声でないモデルIDを確認）
        -- 位置指定例: spawnRemote:FireServer("PlankMaker", player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0))
        
        wait(1)
    else
        warn("Spawn Remote not found. Use RemoteSpy to find it.")
    end
    
    -- リセット
    wait(0.5)
    spawnButton.Text = "Spawn Pallet"
    normalTween:Play()
end)

-- ドラッグ機能（オプション、Mobileタッチ対応）
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

print("Plank Spawner GUI loaded successfully. Adjust Remote in script if needed.")
