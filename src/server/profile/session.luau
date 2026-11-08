--// Server Packages
const profile_store = require "@game/ServerStorage/server_packages/profile_store"

--// Modules
const migrations = require "./migrations"
const net = require "@game/ReplicatedStorage/shared/network/server"
const template = require "./template"

--// Types
export type player_data = net.player_types_data
export type profile_session = profile_store.Profile<player_data>

--// Variables
const players_store = profile_store.New("players", template)

--// Functions
const function get_key(user_id: number)
	return tostring(user_id)
end

const function await_load(player: Player): profile_session
	const self = players_store:StartSessionAsync(get_key(player.UserId), {
		Cancel = function()
			return not player.Parent
		end,
	})

	assert(self, `failed to start profile session for {player.Name}`)
	self:AddUserId(player.UserId)

	self:Reconcile()
	migrations.migrate(self.Data)

	self.OnSessionEnd:Connect(function()
		player:Kick "Profile session end - Please rejoin!"
	end)

	if not player.Parent then
		self:EndSession()
		error(`{player.Name} left before profile session started`)
	end

	return self :: any
end

--// End
return table.freeze {
	await_load = await_load,
}
