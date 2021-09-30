Services = require(game:GetService("ReplicatedStorage").Variables.Services)

Create = require(Services.ReplicatedStorage.Functions.Scripting.Create).Create

Create({ClassName = "RemoteEvent",Name = "ClientEvent",Parent = Services.ReplicatedStorage})
Create({ClassName = "Part",Name = "Ray",Material = "SmoothPlastic",CanCollide = false,Anchored = true,Parent = Services.ReplicatedStorage})
 
Services.ReplicatedStorage.ClientEvent.OnServerEvent:Connect(function(player,data)
    local character = player.Character
    if data.Function == "Damage" then
		data.Humanoid:TakeDamage(data.Damage)
		local victim = Services.Players:FindFirstChild(data.Humanoid.Parent.Name)
		if data.Health - data.Damage <= 0 then
			player.PlayerStats.Kills.Value = player.PlayerStats.Kills.Value + 1
			--player.PlayerStats.Damage.Value = player.PlayerStats.Damage.Value + data.Health
			Services.ReplicatedStorage.Events.PlayerStatEvent:FireAllClients(player,"Kills")
		else
			--player.PlayerStats.Damage.Value = player.PlayerStats.Damage.Value + data.Damage
		end
    elseif data.Function == "Ray" then
        Services.ReplicatedStorage.ClientEvent:FireAllClients({["Function"] = "Ray",["Player"] = player,["Origin"] = data.Origin,["Target"] = data.Target,["Color"] = data.Color})
    end
end)