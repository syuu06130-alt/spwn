local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- リモートの取得（提供されたログに基づく）
local remoteFunction = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")

-- 設定
local ITEM_NAME = "PalletLightBrown" -- ログにあったアイテム名
local SPAWN_DISTANCE = 5 -- 自分の何スタッド前に出すか
local isSpamming = false -- ON/OFFの状態

-- UI作成
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UICornerBtn = Instance.new("UICorner")

ScreenGui.Name = "PalletSpawnerMini"
ScreenGui.Parent = game.CoreGui

-- メインフレーム（サイズを小さくしました：150x80）
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 150, 0, 80) -- かなりコンパクトに設定
MainFrame.Active = true
MainFrame.Draggable = true -- ドラッグ可能

UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- タイトル
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.BackgroundTransparency = 1.000
TitleLabel.Position = UDim2.new(0, 0, 0, 5)
TitleLabel.Size = UDim2.new(1, 0, 0, 20)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Pallet Spawner"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12.000

-- トグルボタン
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- 最初は赤（OFF）
ToggleButton.Position = UDim2.new(0.1, 0, 0.4, 0)
ToggleButton.Size = UDim2.new(0.8, 0, 0.45, 0)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14.000

UICornerBtn.CornerRadius = UDim.new(0, 6)
UICornerBtn.Parent = ToggleButton

-- スポーン処理関数
local function spawnItem()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        -- 自分の位置(CFrame)を取得し、向いている方向へ少し(SPAWN_DISTANCE)進めた位置を計算
        local hrpCFrame = character.HumanoidRootPart.CFrame
        local spawnPos = hrpCFrame * CFrame.new(0, 1, -SPAWN_DISTANCE) -- Yに1足して少し浮かせ、Zで前に出す
        
        -- リモート実行 (pcallでエラー落ち防止)
        pcall(function()
            remoteFunction:InvokeServer(ITEM_NAME, spawnPos)
        end)
    end
end

-- ボタンのクリックイベント
ToggleButton.MouseButton1Click:Connect(function()
    isSpamming = not isSpamming
    
    if isSpamming then
        ToggleButton.Text = "ON (Spamming)"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 255, 60) -- 緑
    else
        ToggleButton.Text = "OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- 赤
    end
end)

-- ループ処理（task.spawnでメインスレッドを止めないように実行）
task.spawn(function()
    while true do
        if isSpamming then
            spawnItem()
        end
        -- サーバー負荷とクラッシュ防止のため、ごく短い待機時間を入れます
        -- InvokeServerはサーバーからの返答を待つため、wait()よりtask.wait()が安全です
        task.wait() 
    end
end)
