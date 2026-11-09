--// Packages
const vide = require "@game/ReplicatedFirst/packages/vide"

--// Modules
const config = require "./data"

--// Variables
const progress = vide.source(0)
const vanish = vide.source(0)
const fade = vide.source(0)

--// Functions
const function run(target: typeof(vanish), seconds: number)
	local elapsed = 0

	while elapsed < seconds do
		elapsed += task.wait()
		target(math.min(elapsed / seconds, 1))
	end

	target(1)
end

const function finish()
	run(vanish, config.finish.dots_seconds)
	run(fade, config.finish.fade_seconds)
end

const function reset()
	progress(0)
	vanish(0)
	fade(0)
end

--// End
return table.freeze {
	progress = progress,
	vanish = vanish,
	fade = fade,

	finish = finish,
	reset = reset,
}
