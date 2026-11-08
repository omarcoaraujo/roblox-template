--// Services
const Players = game:GetService "Players"

--// Modules
const net = require "@game/ReplicatedStorage/shared/network/server"
const session = require "@self/session"

--// Types
export type session = session.profile_session

--// Variables
const profiles = {} :: { [Player]: session }

--// Functions
const function find(player: Player): session.profile_session?
	return profiles[player]
end

const function expect(player: Player)
	return assert(find(player), "profile wasn't loaded")
end

const function await_find(player: Player)
	while player.Parent and not find(player) do
		task.wait()
	end

	return find(player)
end

const function await_expect(player: Player)
	return assert(await_find(player), "profile isn't loading/loaded")
end

const function find_data(player: Player)
	const profile = find(player)
	return profile and profile.Data or nil
end

const function get_data(player: Player)
	const profile = await_find(player)
	return profile and profile.Data or nil
end

const function process_player(player: Player)
	const success, profile = pcall(session.await_load, player)

	if not success then
		player:Kick "Failed to load your data - Please rejoin!"
		return
	end

	profiles[player] = profile

	while player:IsDescendantOf(Players) do
		player.AncestryChanged:Wait()
	end

	profile:EndSession()
end

const function setup()
	for _, player in Players:GetPlayers() do
		task.spawn(process_player, player)
	end
end

--// Listeners
Players.PlayerAdded:Connect(process_player)
net.player.get_data.on(get_data)

--// End
setup()
return table.freeze {
	find = find,
	expect = expect,

	await_find = await_find,
	await_expect = await_expect,

	find_data = find_data,
	get_data = get_data,
}
