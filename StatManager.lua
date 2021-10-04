data = {
	["Players"] = {}
}

AddPlayer = function(player)
	data.Players[player.UserId] = {
		["Name"] = player.DisplayName;
		["Kills"] = 0;
		["Assists"] = 0;
		["Deaths"] = 0;
		["Matches"] = 0;
		["Rating"] = 0;
	}
end

EditPlayer = function(id, playerstats)
	table.foreach(playerstats,function(stat)
		print(data.Players[id][stat])
		data.Players[id][stat] = playerstats[stat]
	end)
end

game.Players.PlayerAdded:Connect(function(player)
	if not data.Players[player.UserId] then
		AddPlayer(player)
	end
end)