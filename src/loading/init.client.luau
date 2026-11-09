--// Services
const Players = game:GetService "Players"
const ReplicatedFirst = game:GetService "ReplicatedFirst"

--// Packages
const vide = require "@game/ReplicatedFirst/packages/vide"

--// Modules
const config = require "@self/data"
const loading_store = require "@self/store"

--// Components
const loading = require "@self/components/loading"

--// Constants
const GATE_TIMEOUT = 30
const MAX_DELTA = 1 / 30

--// Variables
const player = Players.LocalPlayer
const gates = {
	function()
		if game:IsLoaded() then return end
		game.Loaded:Wait()
	end,

	function()
		if player:GetAttribute "client_loaded" then return end
		player:GetAttributeChangedSignal("client_loaded"):Wait()
	end,
}

--// Functions
const function fill()
	local open = 0

	for _, gate in gates do
		task.spawn(function()
			gate()
			open += 1
		end)
	end

	const deadline = os.clock() + GATE_TIMEOUT
	local shown = 0

	while shown < 1 do
		const delta = math.min(task.wait(), MAX_DELTA)

		if os.clock() >= deadline and open < #gates then
			warn(`[loading] {#gates - open} gate(s) never opened, letting the player through`)
			open = #gates
		end

		shown = math.min(shown + delta / config.fill.seconds, open / #gates)
		loading_store.progress(shown)
	end
end

const function load()
	ReplicatedFirst:RemoveDefaultLoadingScreen()

	const player_gui = player:WaitForChild "PlayerGui"
	const destroy = vide.mount(loading, player_gui)

	fill()
	task.wait(config.fill.hold)
	loading_store.finish()

	player:SetAttribute("loading_finished", true)
	destroy()
end

--// End
load()
