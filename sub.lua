-- Pallet Spawner UI + AutoSpawn (統合版)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 既存UI削除（重複防止）
if PlayerGui:FindFirstChild("PalletSpawnerUI") then
    PlayerGui.PalletSpawnerUI:Destroy()
end

-- ScreenGui作成
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PalletSpawnerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- メインフレーム
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(1, 0.5)
Frame.Position = UDim2.new(1, -20, 0.5, 0)
Frame.Size = UDim2.new(0, 120, 0, 60)  -- 少し横幅広げて文字対応
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

-- ボタン
local SpawnButton = Instance.new("TextButton")
SpawnButton.Name = "SpawnBtn"
SpawnButton.Parent = Frame
SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SpawnButton.Size = UDim2.new(1, -12, 1, -12)
SpawnButton.Position = UDim2.new(0, 6, 0, 6)
SpawnButton.Font = Enum.Font.GothamBold
SpawnButton.Text = "Spawn Pallet"
SpawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnButton.TextSize = 14
SpawnButton.AutoButtonColor = true

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = SpawnButton

-- Remote取得
local SpawnRemote = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
local toyName = "PalletLightBrown"

-- AutoSpawn状態
local isAutoSpawning = false
local autoConnection

-- 単発スポーン関数
local function spawnSingle()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        SpawnButton.Text = "No Char!"
        task.wait(1)
        SpawnButton.Text = isAutoSpawning and "Auto ON" or "Spawn Pallet"
        return
    end

    local root = character.HumanoidRootPart
    local spawnCFrame = root.CFrame * CFrame.new(0, 5, -8)  -- 目の前少し上

    local success, result = pcall(function()
        return SpawnRemote:InvokeServer(toyName, spawnCFrame)
    end)

    if success then
        -- 成功フィードバック
        SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        SpawnButton.Text = "Success!"
        task.wait(0.4)
    else
        SpawnButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        SpawnButton.Text = "Error!"
        task.wait(0.8)
    end

    -- 文字と色を戻す
    if not isAutoSpawning then
        SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        SpawnButton.Text = "Spawn Pallet"
    end
end

-- AutoSpawnループ開始
local function startAuto()
    isAutoSpawning = true
    SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    SpawnButton.Text = "Auto ON"

    autoConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isAutoSpawning then return end
        pcall(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local cf = character.HumanoidRootPart.CFrame * CFrame.new(0, 5, -8)
                SpawnRemote:InvokeServer(toyName, cf)
            end
        end)
        task.wait(0.7)  -- スポーン間隔（調整可能）
    end)
end

-- AutoSpawn停止
local function stopAuto()
    isAutoSpawning = false
    if autoConnection then
        autoConnection:Disconnect()
        autoConnection = nil
    end
    SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    SpawnButton.Text = "Spawn Pallet"
end

-- 長押し検知（Auto切り替え）
local pressing = false
local pressTime = 0
local LONG_PRESS_TIME = 0.7

SpawnButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        pressing = true
        pressTime = 0

        -- 長押し監視
        spawn(function()
            while pressing and pressTime < LONG_PRESS_TIME do
                task.wait(0.1)
                pressTime += 0.1
            end

            if pressing and pressTime >= LONG_PRESS_TIME then
                if isAutoSpawning then
                    stopAuto()
                else
                    startAuto()
                end
            end
        end)
    end
end)

SpawnButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if pressing and pressTime < LONG_PRESS_TIME then
            -- 短押し = 1回だけスポーン
            spawnSingle()
        end
        pressing = false
    end
end)

-- 初回メッセージ
print("Pallet Spawner UI Loaded!")
print("短押し → 1個スポーン")
print("長押し(0.7秒) → Auto ON/OFF切り替え")
