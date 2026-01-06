local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 既存のGUIがあれば削除（重複防止）
if PlayerGui:FindFirstChild("PalletSpawnerUI") then
    PlayerGui.PalletSpawnerUI:Destroy()
end

-- --- UI作成 (ScreenGui) ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PalletSpawnerUI"
ScreenGui.ResetOnSpawn = false -- リスポーンしても消えない
ScreenGui.Parent = PlayerGui

-- --- メインフレーム (UIの土台) ---
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
-- 右側上部に配置
Frame.AnchorPoint = Vector2.new(1, 0.5)
Frame.Position = UDim2.new(1, -20, 0.3, 0) -- Y座標を0.3に変更（上寄り）
Frame.Size = UDim2.new(0, 100, 0, 50)
Frame.Parent = ScreenGui

-- 角を丸くする
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

-- --- スポーンボタン ---
local SpawnButton = Instance.new("TextButton")
SpawnButton.Name = "SpawnBtn"
SpawnButton.Parent = Frame
SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SpawnButton.Size = UDim2.new(1, -10, 1, -10)
SpawnButton.Position = UDim2.new(0, 5, 0, 5)
SpawnButton.Font = Enum.Font.GothamBold
SpawnButton.Text = "Spawn Pallet"
SpawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnButton.TextSize = 14
SpawnButton.AutoButtonColor = true

-- ボタンの角を丸くする
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = SpawnButton

-- スポーン中フラグ（連打防止用、ただし短時間）
local isSpawning = false

-- --- スポーン処理関数 ---
local function spawnPallet()
    -- 連打防止（アニメーション中のみ）
    if isSpawning then return end
    isSpawning = true
    
    -- キャラクターとHumanoidRootPartの取得確認
    local character = LocalPlayer.Character
    if not character then 
        isSpawning = false
        return 
    end
   
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then 
        isSpawning = false
        return 
    end
    
    -- RemoteFunctionの場所
    local remote = ReplicatedStorage:FindFirstChild("MenuToys")
        and ReplicatedStorage.MenuToys:FindFirstChild("SpawnToyRemoteFunction")
    
    if remote then
        -- 自分の目の前 7スタッドの位置を計算（5〜10の範囲内）
        local spawnPos = rootPart.CFrame * CFrame.new(0, 0, -7)
       
        -- Remoteを実行
        pcall(function()
            remote:InvokeServer("PalletLightBrown", spawnPos)
        end)
       
        -- ボタンを押したフィードバック
        local originalColor = SpawnButton.BackgroundColor3
        SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        SpawnButton.Text = "Spawned!"
        task.wait(0.3) -- 短縮
        SpawnButton.BackgroundColor3 = originalColor
        SpawnButton.Text = "Spawn Pallet"
    else
        warn("RemoteFunctionが見つかりませんでした。")
        SpawnButton.Text = "Error"
        task.wait(0.5)
        SpawnButton.Text = "Spawn Pallet"
    end
    
    isSpawning = false
end

-- --- イベント接続 (PCクリック & モバイルタップ対応) ---
SpawnButton.Activated:Connect(spawnPallet)

-- 完了通知
print("Pallet Spawner Loaded! - 無限スポーン対応版")
print("位置: 画面右上 | スポーン距離: 7スタッド")
