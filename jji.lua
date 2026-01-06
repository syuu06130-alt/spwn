local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 重複削除
if PlayerGui:FindFirstChild("PalletSpawnerUI") then
    PlayerGui.PalletSpawnerUI:Destroy()
end

-- --- UI作成 ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PalletSpawnerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(1, 0.5)
-- 0.35に設定（前回の0.4よりさらに少し上）
Frame.Position = UDim2.new(1, -20, 0.35, 0) 
Frame.Size = UDim2.new(0, 120, 0, 50)
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local SpawnButton = Instance.new("TextButton")
SpawnButton.Name = "SpawnBtn"
SpawnButton.Parent = Frame
SpawnButton.BackgroundColor3 = Color3.fromRGB(255, 85, 0) -- 目立つオレンジに変更
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

-- --- 座標計算と実行関数 ---
local function doSpawn()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local remote = ReplicatedStorage:FindFirstChild("MenuToys") 
                   and ReplicatedStorage.MenuToys:FindFirstChild("SpawnToyRemoteFunction")
    
    if not remote then 
        warn("RemoteFunctionが見つかりません")
        return 
    end

    -- 【修正】変な方向を向かないよう、水平方向の正面を計算
    -- root.CFrame.LookVector を使い、Y軸（上下）の影響を無視して水平に5～7スタッド前に出す
    local forwardVector = root.CFrame.LookVector * Vector3.new(1, 0, 1)
    local spawnPos = (root.Position + (forwardVector.Unit * 7)) + Vector3.new(0, 2, 0)
    
    -- 板が地面に埋まらないよう、少し上の角度に調整したCFrameを作成
    local finalCFrame = CFrame.new(spawnPos)

    -- 【修正】InvokeServerを別スレッドで実行し、ボタンが固まるのを防ぐ
    task.spawn(function()
        pcall(function()
            remote:InvokeServer("PalletLightBrown", finalCFrame)
        end)
    end)
end

-- --- クリックイベント ---
-- Activatedが反応しない場合を考慮し、MouseButton1Clickも併用
SpawnButton.MouseButton1Click:Connect(function()
    -- 視覚フィードバック
    SpawnButton.Text = "Spawning..."
    SpawnButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SpawnButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    
    doSpawn()
    
    task.wait(0.1)
    SpawnButton.Text = "Spawn Pallet"
    SpawnButton.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
    SpawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

print("Spawner Script Fixed & Loaded.")
