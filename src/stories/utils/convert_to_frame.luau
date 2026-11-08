--// Packages
const vide = require "@game/ReplicatedStorage/packages/vide"

--// End
return function(screen_gui: ScreenGui)
	return vide.create "Frame" {
		Name = screen_gui.Name,
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,
		screen_gui:GetChildren(),
	}
end
