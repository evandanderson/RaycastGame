Services = require(game:GetService("ReplicatedStorage").Variables.Services)
LocalPlayer = Services.Players.LocalPlayer
PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
GameGui = PlayerGui:WaitForChild("GameGui")

Set = require(Services.ReplicatedStorage.Functions.Scripting.Set).Set
SortByDescendingValue = require(Services.ReplicatedStorage.Functions.Scripting.Sort).SortByDescendingValue

CreatePlayerEntry = function(player)
	local newEntry = GameGui.Leaderboard.Teams[player.Team.Name].Stats:Clone()
	Set(newEntry,{
		Name = player.Name;
		BackgroundTransparency = 1;
		Position = UDim2.new(0,0,0.1*table.getn(GameGui.Leaderboard.Teams[player.Team.Name].Players:GetChildren()),0);
		Size = UDim2.new(1,0,0.1,0);
		Parent = GameGui.Leaderboard.Teams[player.Team.Name].Players;
	})
	Set(newEntry.PlayerName,{Text = player.Name})
	Set(newEntry.Kills,{Text = player.PlayerStats.Kills.Value})
	Set(newEntry.Deaths,{Text = player.PlayerStats.Deaths.Value})
	UpdateLeaderboard()
end

DeletePlayerEntry = function(player)
	table.foreach(GameGui.Leaderboard.Teams:GetChildren(),function(i)
		for j,element in pairs(GameGui.Leaderboard.Teams:GetChildren()[i]:GetChildren()) do
			if element.Name == player.Name then
				element:Destroy()
			end
		end
	end)
	UpdateLeaderboard()
end

EditPlayerEntry = function(player)
	table.foreach(GameGui.Leaderboard.Teams:GetChildren(),function(i)
		for j,element in pairs(GameGui.Leaderboard.Teams:GetChildren()[i].Players:GetChildren()) do
			if element.Name == player.Name then
				element.Parent = GameGui.Leaderboard.Teams[player.Team.Name].Players
			end
		end
	end)
	UpdateLeaderboard()
end

PopulateLeaderboard = function()
	table.foreach(Services.Players:GetPlayers(),function(i)
		local playerEntryFound = false
		table.foreach(GameGui.Leaderboard.Teams:GetChildren(),function(j)
			table.foreach(GameGui.Leaderboard.Teams:GetChildren()[j].Players:GetChildren(),function(k)
				if GameGui.Leaderboard.Teams:GetChildren()[j].Players:GetChildren()[k].Name == Services.Players:GetPlayers()[i].Name then
					playerEntryFound = true
				end
			end)
		end)
		if not playerEntryFound then
			CreatePlayerEntry(Services.Players:GetPlayers()[i])
			UpdateLeaderboard()
		end
	end)
end

UpdateLeaderboard = function()
	table.foreach(GameGui.Leaderboard.Teams:GetChildren(),function(i)
		if table.getn(GameGui.Leaderboard.Teams:GetChildren()[i].Players:GetChildren()) > 0 then
			local playerElements = SortByDescendingValue(GameGui.Leaderboard.Teams:GetChildren()[i].Players:GetChildren(),{"Kills","Text"})
			for j,v in ipairs(playerElements) do
				playerElements[j]:TweenPosition(UDim2.new(0,0,0.1*(j-1),0),"Out","Quad","0.25",true)
			end
		end
	end)
end

UpdatePlayerStats = function(player,stat)
	GameGui.Leaderboard.Teams[player.Team.Name].Players[player.Name][stat].Text = player.PlayerStats[stat].Value
	UpdateLeaderboard()
end

Services.ReplicatedStorage.Events.PlayerJoinEvent.OnClientEvent:Connect(CreatePlayerEntry)
Services.ReplicatedStorage.Events.TeamChangeEvent.OnClientEvent:Connect(EditPlayerEntry)
Services.ReplicatedStorage.Events.PlayerStatEvent.OnClientEvent:Connect(UpdatePlayerStats)
PopulateLeaderboard()