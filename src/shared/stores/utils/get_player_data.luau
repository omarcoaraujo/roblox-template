--// Services
const RunService = game:GetService "RunService"

--// Modules
const net = require "@game/ReplicatedStorage/shared/network/client"

--// End
if not pcall(RunService.IsEdit, RunService) then
	return net.player.get_data.invoke() :: net.player_types_data
else
	return require "../__mocks__/player_data" :: net.player_types_data
end
