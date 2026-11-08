--// Services
const ServerStorage = game:GetService "ServerStorage"

--// Packages
const backstage = require "@game/ReplicatedStorage/packages/backstage"

--// Data
const backstage_data = require "@game/ReplicatedStorage/data/backstage"

--// Variables
const server_modules = ServerStorage.server_modules
const entries = {
	server_modules.profile,
	server_modules.client_ready,
}

--// Private Functions
const function load()
	const start_time = os.clock()
	local success_count = 0
	local fail_count = 0

	for _, module in entries do
		const module_start = os.clock()
		const success, error_message = pcall(require, module)
		const module_time = (os.clock() - module_start) * 1e3

		if success then
			success_count += 1
			print((`[✅] Loaded {module.Name} (%.2fms)`):format(module_time))
		else
			fail_count += 1
			warn(`[❌] Failed to load {module.Name}: {error_message}`)
		end
	end

	const total_time = (os.clock() - start_time) * 1e3
	const output = "[🚀] Server initialized in %.2fms | Success: %d | Failed: %d"

	print(output:format(total_time, success_count, fail_count))
end

--// End
backstage.start { port = backstage_data.port }
load()
