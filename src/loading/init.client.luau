--// Services
const Players = game:GetService "Players"
const ReplicatedFirst = game:GetService "ReplicatedFirst"

--// Packages
const vide = require "@game/ReplicatedFirst/packages/vide"

--// Components
const loading = require "@self/components/loading"

--// Constants
const GATE_TIMEOUT = 30
const MIN_SECONDS = 1.5

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
const function open_gates()
	local open = 0
	const deadline = os.clock() + GATE_TIMEOUT

	for _, gate in gates do
		task.spawn(function()
			gate()
			open += 1
		end)
	end

	while open < #gates do
		if os.clock() >= deadline then
			warn(`[loading] {#gates - open} gate(s) never opened, letting the player through`)
			return
		end

		task.wait()
	end
end

const function load()
	ReplicatedFirst:RemoveDefaultLoadingScreen()
	const player_gui = player:WaitForChild "PlayerGui"

	const destroy = vide.mount(loading, player_gui)
	const started = os.clock()

	open_gates()
	task.wait(math.max(0, MIN_SECONDS - (os.clock() - started)))

	player:SetAttribute("loading_finished", true)
	destroy()
end

--// End
load()
