-- Pallet Spawner UI + 改良版（短押し連打OK + 目の前スポーン + UI上寄せ）

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 既存UI削除（重複防止）
if PlayerGui:FindFirstChild("PalletSpawnerUI") then
    PlayerGui.PalletSpawnerUI:Destroy()
end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PalletSpawnerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- メインフレーム（位置を上寄せ）
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(1, 0.5)
Frame.Position = UDim2.new(1, -20, 0.35, 0)  -- ← ここを0.35に変更（上寄り）
Frame.Size = UDim2.new(0, 130, 0, 65)
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

-- ボタン
local SpawnButton = Instance.new("TextButton")
SpawnButton.Name = "SpawnBtn"
SpawnButton.Parent = Frame
SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SpawnButton.Size = UDim2.new(1, -16, 1, -16)
SpawnButton.Position = UDim2.new(0, 8, 0, 8)
SpawnButton.Font = Enum.Font.GothamBold
SpawnButton.Text = "Spawn Pallet"
SpawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnButton.TextSize = 15
SpawnButton.AutoButtonColor = true

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = SpawnButton

-- Remoteとトイ名
local SpawnRemote = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
local toyName = "PalletLightBrown"

-- Auto状態
local isAutoSpawning = false
local autoConnection = nil

-- スポーン位置：目の前約7スタッド（安定して同じくらいの距離）
local SPAWN_DISTANCE = -7  -- マイナスで正面

local function getFrontCFrame()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    local root = character.HumanoidRootPart
    return root.CFrame * CFrame.new(0, 3, SPAWN_DISTANCE)  -- 少し上げて地面にめり込まないように
end

-- 1回スポーン関数（短押し用）
local function spawnSingle()
    local cf = getFrontCFrame()
    if not cf then
        SpawnButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        SpawnButton.Text = "No Character!"
        task.wait(0.8)
        if not isAutoSpawning then
            SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            SpawnButton.Text = "Spawn Pallet"
        end
        return
    end

    local success = pcall(function()
        SpawnRemote:InvokeServer(toyName, cf)
    end)

    if success then
        SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 255, 140)
        SpawnButton.Text = "Spawned!"
        task.wait(0.3)
    else
        SpawnButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        SpawnButton.Text = "Failed!"
        task.wait(0.6)
    end

    -- Auto中でなければ通常に戻す
    if not isAutoSpawning then
        SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        SpawnButton.Text = "Spawn Pallet"
    end
end

-- Auto開始
local function startAuto()
    isAutoSpawning = true
    SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    SpawnButton.Text = "Auto ON\n(長押しで停止)"

    autoConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isAutoSpawning then return end
        local cf = getFrontCFrame()
        if cf then
            pcall(function()
                SpawnRemote:InvokeServer(toyName, cf)
            end)
        end
        task.wait(0.7)  -- スポーン間隔（調整したいならここ変更）
    end)
end

-- Auto停止
local function stopAuto()
    isAutoSpawning = false
    if autoConnection then
        autoConnection:Disconnect()
        autoConnection = nil
    end
    SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    SpawnButton.Text = "Spawn Pallet"
end

-- 長押し検知
local pressing = false
local pressTime = 0
local LONG_PRESS_TIME = 0.7

SpawnButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        pressing = true
        pressTime = 0

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
            spawnSingle()  -- 短押し → 1回スポーン（連打何回でもOK！）
        end
        pressing = false
    end
end)

print("Pallet Spawner UI 改良版 Loaded!")
print("・短押し → 1個スポーン（連打OK）")
print("・長押し(0.7秒) → Auto ON/OFF")
print("・位置：目の前約7スタッド、UI上寄せ")
