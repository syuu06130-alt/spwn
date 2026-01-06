-- LocalScript
-- StarterPlayer > StarterPlayerScripts に入れるのがおすすめ

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- ▼ FTAPでToyを出すためのRemoteEvent
-- 多くの場合こんな名前。違ったら Explorer で確認してね
local spawnRemote =
	ReplicatedStorage:WaitForChild("RemoteEvents")
	:WaitForChild("SpawnToy")

-- ▼ 出したいToy名
local TOY_NAME = "PalletLightBrown"

-- 実行
spawnRemote:FireServer(TOY_NAME)
