--// Services
const RunService = game:GetService "RunService"

--// Packages
const vide = require "@game/ReplicatedStorage/packages/vide"

--// Constants
const DEFAULT_SECONDS = 1

--// Hook
return function(active: (() -> boolean)?, seconds: number?)
	const rotation = vide.source(0)
	const degrees = 360 / (seconds or DEFAULT_SECONDS)

	vide.effect(function()
		if active and not active() then return end

		vide.cleanup(RunService.Heartbeat:Connect(function(delta_time: number)
			rotation((rotation() + delta_time * degrees) % 360)
		end))
	end)

	return rotation
end
