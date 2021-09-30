Services = require(game:GetService("ReplicatedStorage").Variables.Services)

Create = require(Services.ReplicatedStorage.Functions.Scripting.Create).Create

AssignTeam = function(player)
	if table.getn(Services.Teams.Red:GetPlayers()) >  table.getn(Services.Teams.Blue:GetPlayers()) then
		player.Team = Services.Teams["Blue"]
	else
		player.Team = Services.Teams["Red"]
	end
end

CreatePlayerConfiguration = function(player)
	Create({ClassName = "Folder",Name = "PlayerStats",Parent = player})
	Create({ClassName = "IntValue",Name = "Kills",Parent = player.PlayerStats})
	Create({ClassName = "IntValue",Name = "Deaths",Parent = player.PlayerStats})
	Create({ClassName = "Folder",Name = "PlayerSettings",Parent = player})
	Create({ClassName = "StringValue",Name = "PlayerGameState",Value = "Loading",Parent = player.PlayerSettings})
	Create({ClassName = "Folder",Name = "Keybinds",Parent = player.PlayerSettings})
end

PlayerAdded = function(player)
	CreatePlayerConfiguration(player)
	AssignTeam(player)
	player.Changed:Connect(function(property)
		if property == "Team" then
			Services.ReplicatedStorage.Events.TeamChangeEvent:FireAllClients(player)
		end
	end)
	player.CharacterAdded:Connect(function(character)
		character.Humanoid.Died:Connect(function()
			player.PlayerStats.Deaths.Value = player.PlayerStats.Deaths.Value + 1
			Services.ReplicatedStorage.Events.PlayerStatEvent:FireAllClients(player,"Deaths")
		end)
	end)
	Services.ReplicatedStorage.Events.PlayerJoinEvent:FireAllClients(player)
end

Services.Players.PlayerAdded:Connect(PlayerAdded)