--// Modules
const net = require "@game/ReplicatedStorage/shared/network/server"

--// Types
type migration = { target_version: number, migrate: (data: any) -> () }

--// Constants
const MIGRATIONS = {} :: { migration }
const CURRENT_VERSION = #MIGRATIONS + 1

--// Functions
const function migrate(data: net.player_types_data)
	for _, migration in MIGRATIONS do
		if data.version >= migration.target_version then continue end

		migration.migrate(data)
		data.version = migration.target_version
	end
end

--// End
return table.freeze {
	CURRENT_VERSION = CURRENT_VERSION,
	migrate = migrate,
}
