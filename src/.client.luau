--// Services
const Players = game:GetService "Players"
const ReplicatedStorage = game:GetService "ReplicatedStorage"
const RunService = game:GetService "RunService"

--// Packages
const backstage = require "@game/ReplicatedStorage/packages/backstage"
const charm = require "@game/ReplicatedStorage/packages/charm"
const vide = require "@game/ReplicatedStorage/packages/vide"

--// Data
const backstage_data = require "@game/ReplicatedStorage/data/backstage"

--// Modules
const net = require "@game/ReplicatedStorage/shared/network/client"

--// Variables
const player = Players.LocalPlayer
const player_gui = player.PlayerGui

const client_modules = ReplicatedStorage.client_modules
const entries = {} :: { ModuleScript }

--// Settings
_G.__DEV__ = RunService:IsStudio()

--// Private Functions
const function load()
	const start_time = os.clock()

	local success_count = 0
	local fail_count = 0

	local completed = 0
	const total = #entries

	for _, module in entries do
		task.spawn(function()
			const parent = module.Parent
			const module_start = os.clock()

			const success, error_message = pcall(require, module)
			const module_time = (os.clock() - module_start) * 1e3

			if success then
				success_count += 1
				if _G.__DEV__ then
					print((`[✅] Loaded {parent and parent.Name}/{module.Name} (%.2fms)`):format(module_time))
				end
			else
				fail_count += 1
				warn(`[❌] Failed to load {module.Name}: {error_message}`)
				warn(debug.traceback())
			end

			completed += 1
		end)
	end

	while completed < total do
		task.wait()
	end

	const total_time = (os.clock() - start_time) * 1e3
	const output = "[🎮] Client initialized in %.2fms | Success: %d | Failed: %d"

	net.player.ready.invoke()
	player:SetAttribute("client_loaded", true)
	print(output:format(total_time, success_count, fail_count))
end

--// End
backstage.start { vide = vide, charm = charm, port = backstage_data.port, key = Enum.KeyCode.H }
const app = require "@game/ReplicatedStorage/ui/app"

vide.root(load)
vide.mount(app, player_gui)
