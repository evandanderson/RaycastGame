Services = require(game:GetService("ReplicatedStorage").Variables.Services)
LocalPlayer = Services.Players.LocalPlayer
PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
GameGui = PlayerGui:WaitForChild("GameGui")
IntroGui = PlayerGui:WaitForChild("IntroGui")

Keybinds = {
	["Toggle Leaderboard"] = "Tab"
}

KeyListener = function(action,inputState)
	if LocalPlayer.PlayerSettings.PlayerGameState.Value ~= "Loading" then
		if action == "ToggleLeaderboard" then
			if inputState == Enum.UserInputState.Begin then
				GameGui.Leaderboard.Visible = true
			elseif inputState == Enum.UserInputState.End then
				GameGui.Leaderboard.Visible = false
			end
		elseif action == "EquipPrimary" then
			if LocalPlayer.Character and inputState == Enum.UserInputState.Begin then
				local humanoid = LocalPlayer.Character.Humanoid
				if not true then
					--toolEquipped = nil
					humanoid:UnequipTools()
				else
					--toolEquipped = tool
					humanoid:EquipTool(LocalPlayer.Backpack["Gun"])
				end
			end
		end
	end
end

Services.ContextActionService:BindAction("ToggleLeaderboard",KeyListener,false,Enum.KeyCode[Keybinds["Toggle Leaderboard"]])
Services.ContextActionService:BindAction("EquipPrimary",KeyListener,false,Enum.KeyCode.One)