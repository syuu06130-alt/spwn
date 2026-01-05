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
-- 右側に配置 (アンカーポイントを右端に設定)
Frame.AnchorPoint = Vector2.new(1, 0.5) 
Frame.Position = UDim2.new(1, -20, 0.5, 0) -- 画面右端から20px離す
Frame.Size = UDim2.new(0, 100, 0, 50) -- サイズ：横100px, 縦50px (コンパクト)
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
SpawnButton.Size = UDim2.new(1, -10, 1, -10) -- フレームより少し小さく
SpawnButton.Position = UDim2.new(0, 5, 0, 5) -- 中央寄せ
SpawnButton.Font = Enum.Font.GothamBold
SpawnButton.Text = "Spawn Pallet"
SpawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnButton.TextSize = 14
SpawnButton.AutoButtonColor = true

-- ボタンの角を丸くする
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = SpawnButton

-- --- スポーン処理関数 ---
local function spawnPallet()
    -- キャラクターとHumanoidRootPartの取得確認
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- RemoteFunctionの場所
    local remote = ReplicatedStorage:FindFirstChild("MenuToys")
        and ReplicatedStorage.MenuToys:FindFirstChild("SpawnToyRemoteFunction")

    if remote then
        -- 自分の目の前 5スタッドの位置を計算
        -- CFrame.new(0, 0, -5) が「正面に5歩」の意味です
        local spawnPos = rootPart.CFrame * CFrame.new(0, 0, -5)
        
        -- Remoteを実行 (提供された引数に基づき修正)
        -- 第1引数: Toyの名前
        -- 第2引数: 出現させる場所(CFrame)
        remote:InvokeServer("PalletLightBrown", spawnPos)
        
        -- ボタンを押したフィードバック（少し色を変える）
        local originalColor = SpawnButton.BackgroundColor3
        SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        SpawnButton.Text = "Success!"
        task.wait(0.5)
        SpawnButton.BackgroundColor3 = originalColor
        SpawnButton.Text = "Spawn Pallet"
    else
        warn("RemoteFunctionが見つかりませんでした。パスを確認してください。")
        SpawnButton.Text = "Error"
    end
end

-- --- イベント接続 (PCクリック & モバイルタップ対応) ---
SpawnButton.Activated:Connect(spawnPallet)

-- 完了通知
print("Pallet Spawner Loaded!")
