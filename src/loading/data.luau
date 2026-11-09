--// Services
const RunService = game:GetService "RunService"

--// Packages
const backstage = require "@game/ReplicatedFirst/packages/backstage"

--// Setup
if RunService:IsRunning() then backstage.disable() end

--// End
return backstage.config("loading", {
	colors = {
		background = Color3.fromRGB(255, 255, 255),
		idle = Color3.fromRGB(176, 176, 184),
		dot = Color3.fromRGB(46, 125, 255),
	},

	dots = {
		count = 5,
		diameter = 35,

		spacing = 60,
		height = 60,
		rest = 0.75,
	},

	jump = {
		cycle = 1.25,
		duration = 0.55,

		rise = 0.35,
		stagger = 0.13,
		height = 0.8,
	},

	waiting = {
		height = 0.12,
		cycle = 1.8,
		duration = 0.55,
	},

	drift = {
		amount = 0.15,
		seconds = 2.9,
		stagger = 0.6,
	},

	fill = {
		seconds = 2,
		hold = 0.4,
	},

	finish = {
		dots_seconds = 0.1,
		fade_seconds = 3,
	},
}, {
	limits = {
		dots = {
			count = { min = 1, max = 8, step = 1 },
			diameter = { min = 4, max = 120, step = 1 },

			spacing = { min = 0, max = 200, step = 1 },
			height = { min = 10, max = 300, step = 1 },
			rest = { min = 0, max = 1, step = 0.01 },
		},

		jump = {
			cycle = { min = 0.2, max = 4, step = 0.01 },
			duration = { min = 0.05, max = 4, step = 0.01 },

			rise = { min = 0.05, max = 0.95, step = 0.01 },
			stagger = { min = 0, max = 1, step = 0.01 },
			height = { min = 0, max = 3, step = 0.01 },
		},

		waiting = {
			height = { min = 0, max = 1, step = 0.01 },
			cycle = { min = 0.2, max = 6, step = 0.01 },
			duration = { min = 0.05, max = 4, step = 0.01 },
		},

		drift = {
			amount = { min = 0, max = 1, step = 0.01 },
			seconds = { min = 0.2, max = 10, step = 0.1 },
			stagger = { min = 0, max = 3, step = 0.05 },
		},

		fill = {
			seconds = { min = 0.2, max = 10, step = 0.1 },
			hold = { min = 0, max = 3, step = 0.1 },
		},

		finish = {
			dots_seconds = { min = 0.05, max = 3, step = 0.01 },
			fade_seconds = { min = 0.05, max = 3, step = 0.01 },
		},
	},
})
