-- ======= Auto Kill Global =======
if getgenv().AutoKillGlobal == nil then
	getgenv().AutoKillGlobal = false
end

getgenv().AutoKillGlobal = not getgenv().AutoKillGlobal

if getgenv().AutoKillGlobal then
	print("☠️ AutoKill Global ACTIVADO")

	local player = game.Players.LocalPlayer

	local function getHand()
		local char = player.Character or player.CharacterAdded:Wait()
		return char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
	end

	local hand -- guardamos la mano para reusar

	player.CharacterAdded:Connect(function(char)
		task.wait(1)
		hand = getHand()
	end)

	hand = getHand()

	task.spawn(function()
		while getgenv().AutoKillGlobal do
			if not hand or not hand:IsDescendantOf(workspace) then
				hand = getHand()
			end
			if hand and hand:IsDescendantOf(workspace) then
				for _, other in pairs(game.Players:GetPlayers()) do
					if other ~= player and other.Character then
						local targetPart = other.Character:FindFirstChild("HumanoidRootPart")
						if targetPart and targetPart:IsDescendantOf(workspace) then
							pcall(function()
								firetouchinterest(hand, targetPart, 0)
								task.wait(0.05)
								firetouchinterest(hand, targetPart, 1)
							end)
							task.wait(0.05)
						end
					end
				end
			else
				task.wait(0.5)
			end
			task.wait(0.1)
		end
		print("🛑 AutoKill Global DESACTIVADO")
	end)
else
	print("🛑 AutoKill Global DESACTIVADO")
end

-- ======= Auto Punch Toggle (local) =======
if _G.AutoPunchToggle == nil then
	_G.AutoPunchToggle = false
end

_G.AutoPunchToggle = not _G.AutoPunchToggle

if _G.AutoPunchToggle then
	warn("✅ Auto Punch ACTIVADO")
else
	warn("⛔ Auto Punch DESACTIVADO")
	return
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local backpack = player:WaitForChild("Backpack")
local character = player.Character or player.CharacterAdded:Wait()
local hand = "rightHand"

local function getMuscleEvent()
	return player:FindFirstChild("muscleEvent")
end

player.CharacterAdded:Connect(function(char)
	character = char
end)

player.ChildAdded:Connect(function(child)
	if child.Name == "Backpack" then
		backpack = child
	end
end)

task.spawn(function()
	while _G.AutoPunchToggle do
		local muscleEvent = getMuscleEvent()
		character = player.Character
		if character and character:FindFirstChild("Humanoid") and muscleEvent then
			local punchEquipped = character:FindFirstChild("Punch")
			local punchInBackpack = backpack:FindFirstChild("Punch")

			if not punchEquipped and punchInBackpack then
				character.Humanoid:EquipTool(punchInBackpack)
			end

			muscleEvent:FireServer("punch", hand)
		end
		task.wait(0.0001)
	end
end)

-- ======= Server Hop =======
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId

local function ServerHop()
	local servers = {}
	local req = syn and syn.request or http_request or request

	if not req then
		warn("Tu executor no soporta http requests.")
		return
	end

	local response = req({
		Url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Desc&limit=100"
	})

	if response and response.Body then
		local data = HttpService:JSONDecode(response.Body)
		for _, server in ipairs(data.data) do
			local playersNow = server.playing
			if playersNow >= 14 and playersNow <= 15 and server.id ~= game.JobId then
				table.insert(servers, server.id)
			end
		end
	end

	if #servers > 0 then
		local randomServer = servers[math.random(1, #servers)]
		print("🔁 Haciendo ServerHop automático a servidor con 14–15 jugadores...")
		TeleportService:TeleportToPlaceInstance(PlaceId, randomServer)
	else
		warn("⚠️ No se encontraron servidores con 14–15 jugadores. Intentando nuevamente en 10s...")
		task.wait(10)
		pcall(ServerHop)
	end
end

-- 🕒 ServerHop automático cada 40 s
task.spawn(function()
	while true do
		task.wait(40)
		pcall(ServerHop)
	end
end)

-- 💀 NUEVO: ServerHop instantáneo al morir
local function onCharacterAdded(char)
	local hum = char:WaitForChild("Humanoid")
	hum.Died:Connect(function()
		print("💀 Has muerto! Saltando de servidor inmediatamente (14–15 jugadores)...")
		task.wait(2)
		pcall(ServerHop)
	end)
end

if player.Character then onCharacterAdded(player.Character) end
player.CharacterAdded:Connect(onCharacterAdded)