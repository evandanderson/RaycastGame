----------------------------------------------------------------
--Raycasting gun script
--Last updated 05/16/2020
----------------------------------------------------------------

--Define reference variables
local players = game:GetService("Players")
local debris = game:GetService("Debris")
local replicated = game:GetService("ReplicatedStorage")
local actions = game:GetService("ContextActionService")
local player = players.LocalPlayer
local playerModel = game.Workspace:WaitForChild(players.LocalPlayer.Name)
local event = replicated:WaitForChild("ClientEvent")
local config = require(script.Parent:WaitForChild("Configuration"))
local gun = script.Parent

--Set gun variables
local equipped = false
local canFire = true
local firing = false
local reloading = false
ammo = config.maxAmmo

----------------------------------------------------------------
--//GetAllPlayerModels// From the list of players, find each player model and return a table consisting of all models
--//Parameters// none
----------------------------------------------------------------
local GetAllPlayerModels = function()
	local playerList = players:GetPlayers()
	local playerModels = {}
	table.foreach(playerList,function(i)
		if game.Workspace:FindFirstChild(playerList[i].Name) then
			playerModels[i] = game.Workspace[playerList[i].Name]
		end
	end)
	return playerModels
end

----------------------------------------------------------------
--//GetHumanoid// Determine if the part is the child of a parent with a humanoid
--//Parameters// (Part)
----------------------------------------------------------------
local GetHumanoid = function(part)
	if part and part:FindFirstAncestorOfClass("Model") and part:FindFirstAncestorOfClass("Model"):FindFirstChild("Humanoid") then
		return part:FindFirstAncestorOfClass("Model").Humanoid
	else
		return nil
	end
end

----------------------------------------------------------------
--//CreateRay// Create a physical part given origin and target parameters and orient the part in 3D space toward the target
--//Parameters// (Vector3, Vector3, BrickColor)
----------------------------------------------------------------
local CreateRay = function(origin,target,color) --CreateRay function creates a physical part given the Vector3
	local rayPart = replicated.Ray:Clone()
	rayPart.BrickColor = color
	rayPart.Size = Vector3.new(config.rayProperties.width,config.rayProperties.width,(target-origin).Magnitude)
	rayPart.CFrame = CFrame.new(Vector3.new((target.X+origin.X)/2,(target.Y+origin.Y)/2,(target.Z+origin.Z)/2),target)
	rayPart.Parent = game.Workspace
	debris:AddItem(rayPart,config.rayProperties.despawnTime)
end

----------------------------------------------------------------
--//Raycast// Use origin and target values to create a new ray while calulcating spread, and send player damage to server
--//Parameters// (Vector3, Vector3)
----------------------------------------------------------------
local Raycast = function(origin,target)
	local offset = math.random(-(target-origin).Magnitude,(target-origin).Magnitude)*config.spread/10 --Randomly determine spread between acceptable values
	target = Vector3.new(target.X + offset,target.Y + offset,target.Z + offset)
	local direction = (target-origin).unit
	local ray = Ray.new(origin,direction*config.rayProperties.maxLength)
	local part, intersect = workspace:FindPartOnRay(ray,playerModel) --Set new target to end of ray or the position of the part that intersects it
	local humanoid = GetHumanoid(part)
	if humanoid then
		local targetPlayer = players:GetPlayerFromCharacter(humanoid.Parent)
		if not (targetPlayer and not config.doTeamDamage and targetPlayer.Team == player.Team) and humanoid.Health > 0 then --Unless team damage is enabled and players are on same team, damage player
			event:FireServer({["Function"] = "Damage", ["Humanoid"] = humanoid, ["Damage"] = config.damage,["Health"] = humanoid.Health})
		end
	end
	local color = config.rayProperties.defaultColor
	if config.rayProperties.useTeamColor then 
		color = player.TeamColor 
	end
	CreateRay(origin,intersect,color)
	event:FireServer({["Function"] = "Ray", ["Origin"] = origin, ["Target"] = target, ["Color"] = color}) --Create client rays
end

----------------------------------------------------------------
--//Reload// Set ammo to config.maxAmmo and update Gui accordingly
--//Parameters// none
----------------------------------------------------------------
local Reload = function()
	reloading = true
	ammo = 0
	for i = 1, config.maxAmmo do
		wait(config.reloadTime/config.maxAmmo)
		ammo = i
	end
	reloading = false
end

----------------------------------------------------------------
--//CheckWall// Create ray to determine if a part is present between the player and the target
--//Parameters// (Vector3,Vector3,Part)
----------------------------------------------------------------
local CheckWall = function(origin,target,body)
	local wallRay = Ray.new(body.Position,(origin-body.Position).unit*((origin-body.Position).Magnitude)) --Create ray to determine if a wall exists between player head and gun barrel
	local wall = workspace:FindPartOnRayWithIgnoreList(wallRay,GetAllPlayerModels())
	local normalRay = Ray.new(origin,(target-origin).unit*((target-origin).Magnitude))
	local normalPart,normalIntersect = workspace:FindPartOnRay(normalRay,playerModel)
	local playerRay = Ray.new(body.Position,(normalIntersect-body.Position).unit*((normalIntersect-body.Position).Magnitude)) --Create ray to determine if any part is between the player head and target
	local playerPart, playerIntersect = workspace:FindPartOnRayWithIgnoreList(playerRay,GetAllPlayerModels())
	if not wall and (playerIntersect-normalIntersect).Magnitude < 0.01  then --If no wall exists and both player and normal rays intersect at the same point towards the target
		return nil
	else --Something is obstructing the shot, do not shoot and check again
		return false
	end
end

----------------------------------------------------------------
--//KeyListener// Respond to key events binded by ContextActionService given the action name and its input state 
--//Parameters// (String,Enum)
----------------------------------------------------------------
local KeyListener = function(action,inputState)
	if action == "Reload" and inputState == Enum.UserInputState.Begin and not reloading and ammo < config.maxAmmo then
		Reload()
	end
end

----------------------------------------------------------------
--//Fire// Check all necessary requirements for raycasting and pass the origin and target values to raycasting functions
--//Parameters// (PlayerMouse)
----------------------------------------------------------------
local Fire = function(mouse)
	canFire = false
	local origin = gun.Handle.Position
	local target = mouse.Hit.Position
	local check = CheckWall(origin,target,playerModel.HumanoidRootPart)
	if check == nil then --If the ray does not intersect any part between origin and target, the line of sight is clear
		Raycast(origin,target)
		ammo = ammo - 1
		if ammo == 0 and config.autoReload then --Magazine empty, reload
			Reload()
		else --If the ammo is greater than 0, wait for the duration of the firerate and continue to shoot
			wait(1/(config.fireRate/60))
		end
	else
		wait() --A wall was found, do not shoot and do not wait for firerate
	end
	canFire = true
end

----------------------------------------------------------------
--//Equip// Called when the gun is equipped
--//Parameters// none
----------------------------------------------------------------
local Equip = function()
	equipped = true
	local mouse = player:GetMouse()
	actions:BindAction("Reload",KeyListener,false,Enum.KeyCode.R)
	mouse.Button1Down:Connect(function()
		firing = true --Mouse is being held down, automtic fire is enabled
		if canFire then
			if config.mode == "auto" then
				while firing and ammo > 0 and mouse and not reloading and playerModel.Humanoid.Health > 0 do
					Fire(mouse)
				end
			elseif config.mode == "semi" then
				if ammo > 0 and mouse and not reloading and playerModel.Humanoid.Health > 0 then
					Fire(mouse)
				end
			elseif config.mode == "burst" and playerModel.Humanoid.Health > 0 then
				--Burst mode
			end
		end
	end)
	mouse.Button1Up:Connect(function()
		firing = false
	end)
end

----------------------------------------------------------------
--//Unequip// Called when the gun is unequipped
--//Parameters// none
----------------------------------------------------------------
local Unequip = function()
	equipped = false
	firing = false
	player:GetMouse():Destroy()
	actions:UnbindAction("Reload")
end

script.Parent.Equipped:Connect(Equip)
script.Parent.Unequipped:Connect(Unequip)

event.OnClientEvent:Connect(function(data)
	if player ~= data.Player and data.Function == "Ray" then
		CreateRay(data.Origin,data.Target,data.Color)
	end
end)