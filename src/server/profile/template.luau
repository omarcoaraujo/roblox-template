--// Modules
const migrations = require "./migrations"

--// End
return table.freeze {
	version = migrations.CURRENT_VERSION,
}
