-- LocalScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- UI重複防止
if PlayerGui:FindFirstChild("PalletSpawnerUI") then
	PlayerGui.PalletSpawnerUI:Destroy()
end

-- === UI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PalletSpawnerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.AnchorPoint = Vector2.new(1,0.5)
Frame.Position = UDim2.new(1,-20,0.4,0)
Frame.Size = UDim2.new(0,120,0,50)
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,8)

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(1,-10,1,-10)
Button.Position = UDim2.new(0,5,0,5)
Button.Text = "Spawn Pallet"
Button.Font = Enum.Font.GothamBold
Button.TextSize = 14
Button.TextColor3 = Color3.new(1,1,1)
Button.BackgroundColor3 = Color3.fromRGB(0,170,255)
Button.Parent = Frame

Instance.new("UICorner", Button).CornerRadius = UDim.new(0,6)

-- === RemoteEvent取得 ===
local remoteEvent
local menuToys = ReplicatedStorage:FindFirstChild("MenuToys")

if menuToys then
	remoteEvent = menuToys:FindFirstChildWhichIsA("RemoteEvent")
end

if not remoteEvent then
	warn("Spawn用RemoteEventが見つかりません")
	Button.Text = "Remote Error"
	return
end

-- === スポーン処理 ===
Button.Activated:Connect(function()
	-- Toy名だけ送る（位置は送らない）
	remoteEvent:FireServer("PalletLightBrown")

	-- 視覚フィードバック
	local old = Button.BackgroundColor3
	Button.BackgroundColor3 = Color3.fromRGB(0,255,100)
	task.delay(0.1, function()
		Button.BackgroundColor3 = old
	end)
end)

print("Pallet Spawner Loaded (FTAP Safe Version)")
