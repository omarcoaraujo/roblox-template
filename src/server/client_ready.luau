--// Services
const Players = game:GetService "Players"

--// Modules
const net = require "@game/ReplicatedStorage/shared/network/server"

--// Variables
const ready_players = {} :: { [Player]: boolean }

--// Functions
const function is_ready(player: Player)
	return ready_players[player] == true
end

const function await_ready(player: Player)
	if is_ready(player) then return end

	while player.Parent and not is_ready(player) do
		task.wait()
	end
end

const function set_ready(player: Player)
	ready_players[player] = true
end

const function remove(player: Player)
	ready_players[player] = nil
end

--// Listeners
Players.PlayerRemoving:Connect(remove)
net.player.ready.on(set_ready)

--// End
return table.freeze {
	is_ready = is_ready,
	await_ready = await_ready,
}
