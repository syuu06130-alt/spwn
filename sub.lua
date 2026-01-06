local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- --- 設定 ---
-- 注意: "PalletLightBrown" というIDが間違いの可能性があります。
-- まずはシンプルに "Pallet" を試してください。もしこれで出ない場合は名前を戻してください。
local TOY_NAME = "Pallet" 
local SPAWN_DISTANCE = 5 -- 自分の何スタッド前に出すか

-- --- GUIの初期化 (重複削除) ---
if PlayerGui:FindFirstChild("PalletSpawnerUI_Fixed") then
    PlayerGui.PalletSpawnerUI_Fixed:Destroy()
end

-- --- UI作成 ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PalletSpawnerUI_Fixed"
ScreenGui.ResetOnSpawn = false
-- 表示優先度を上げて、ゲームのUIの下に隠れないようにする
ScreenGui.DisplayOrder = 10 
ScreenGui.Parent = PlayerGui

-- メインフレーム
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(1, 0.5)
Frame.Position = UDim2.new(1, -20, 0.5, 0)
Frame.Size = UDim2.new(0, 120, 0, 50) -- 少し横幅を広げました
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

-- スポーンボタン
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

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = SpawnButton

-- --- パレットスポーン関数 ---
local function spawnPallet()
    -- task.spawnで別スレッド処理にすることで、UIのフリーズ(黒画面)を防ぐ
    task.spawn(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        -- RemoteFunctionの場所を探す
        local menuToys = ReplicatedStorage:FindFirstChild("MenuToys")
        local remote = menuToys and menuToys:FindFirstChild("SpawnToyRemoteFunction")

        if remote then
            -- 自分の正面の位置を計算
            local spawnCFrame = rootPart.CFrame * CFrame.new(0, 0, -SPAWN_DISTANCE)

            -- ボタンを「処理中」の色にする
            SpawnButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
            SpawnButton.Text = "Spawning..."

            -- pcallを使ってエラーが発生してもゲーム全体を落とさないようにする
            local success, result = pcall(function()
                -- InvokeServerはサーバーからの返事を待つため時間がかかることがある
                return remote:InvokeServer(TOY_NAME, spawnCFrame)
            end)

            if success then
                SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
                SpawnButton.Text = "Success!"
            else
                warn("スポーンエラー: " .. tostring(result))
                SpawnButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                SpawnButton.Text = "Failed"
            end

            -- 0.8秒後にボタンを戻す
            task.wait(0.8)
            SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            SpawnButton.Text = "Spawn Pallet"
        else
            warn("RemoteFunctionが見つかりません: ReplicatedStorage.MenuToys.SpawnToyRemoteFunction")
            SpawnButton.Text = "Remote Missing"
        end
    end)
end

-- --- イベント接続 ---
SpawnButton.Activated:Connect(spawnPallet)

-- 完了通知
print("Fixed Pallet Spawner Loaded!")
