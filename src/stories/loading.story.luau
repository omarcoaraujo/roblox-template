--// Services
const ReplicatedFirst = game:GetService "ReplicatedFirst"

--// Packages
const backstage = require(ReplicatedFirst.packages.backstage)
const vide = require(ReplicatedFirst.packages.vide)

--// Data
const backstage_data = require "@game/ReplicatedStorage/data/backstage"

--// Modules
const loading_store = require(ReplicatedFirst.loading.store)

--// Utils
const convert_to_frame = require "./utils/convert_to_frame"

--// Components
const loading = require(ReplicatedFirst.loading.components.loading)

--// Constants
const FILL_SECONDS = 8
const HOLD_SECONDS = 0.4
const RESTART_SECONDS = 1.5

--// Functions
const function replay()
	while true do
		loading_store.reset()
		local shown = 0

		while shown < 1 do
			shown = math.min(shown + task.wait() / FILL_SECONDS, 1)
			loading_store.progress(shown)
		end

		task.wait(HOLD_SECONDS)
		loading_store.finish()
		task.wait(RESTART_SECONDS)
	end
end

--// Story
return function(target: Instance)
	const destroy = vide.mount(function()
		return convert_to_frame(loading())
	end, target)

	const close_window = backstage.embed(target, {
		port = backstage_data.port,
		vide = vide,
	})

	const thread = task.spawn(replay)
	return function()
		pcall(task.cancel, thread)
		close_window()
		destroy()
	end
end
