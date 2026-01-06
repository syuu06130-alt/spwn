local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 既存のGUIがあれば削除（重複防止）
if PlayerGui:FindFirstChild("PalletSpawnerUI") then
    PlayerGui.PalletSpawnerUI:Destroy()
end

-- --- UI作成 (ScreenGui) ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PalletSpawnerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- --- メインフレーム ---
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(1, 0.5)
-- Positionの0.4の部分を調整することで高さを変えられます（0に近いほど上）
Frame.Position = UDim2.new(1, -20, 0.4, 0) 
Frame.Size = UDim2.new(0, 120, 0, 50)
Frame.Parent = ScreenGui

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
SpawnButton.Text = "Spawn Toy"
SpawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnButton.TextSize = 14
SpawnButton.AutoButtonColor = true

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = SpawnButton

-- --- スポーン処理関数 ---
local function spawnPallet()
    local character = LocalPlayer.Character
    if not character then return end
   
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- RemoteFunctionの取得
    local menuToys = ReplicatedStorage:FindFirstChild("MenuToys")
    local remote = menuToys and menuToys:FindFirstChild("SpawnToyRemoteFunction")

    if remote then
        -- 自分の目の前 7スタッド、少し地面にめり込まないよう高さ+1調整
        local spawnPos = rootPart.CFrame * CFrame.new(0, 0, -7)

        -- サーバーへリクエスト（無限に実行可能）
        -- 引数1: トイの名前 "PalletLightBrown"
        -- 引数2: 計算したCFrame
        task.spawn(function()
            remote:InvokeServer("PalletLightBrown", spawnPos)
        end)

        -- ボタンの視覚フィードバック（連打を邪魔しないよう一瞬だけ変更）
        local originalColor = SpawnButton.BackgroundColor3
        SpawnButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        task.delay(0.1, function()
            SpawnButton.BackgroundColor3 = originalColor
        end)
    else
        warn("RemoteFunctionが見つかりません。パスを確認してください。")
        SpawnButton.Text = "Error: No Remote"
    end
end

-- --- イベント接続 ---
SpawnButton.Activated:Connect(spawnPallet)

print("Infinite Toy Spawner Loaded! (Position: Right-Top)")
