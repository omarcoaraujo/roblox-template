--// Packages
const backstage = require "@game/ReplicatedStorage/packages/backstage"

--// End
return backstage.config("camera", {
	intro = {
		back = 25,
		height = 12,

		blur = 40,
		duration = 2.5,
	},
}, {
	limits = {
		intro = {
			back = { min = 0, max = 80, step = 1 },
			height = { min = 0, max = 60, step = 1 },

			blur = { min = 0, max = 56, step = 1 },
			duration = { min = 0.5, max = 8, step = 0.1 },
		},
	},

	hints = {
		intro = {
			back = "How far behind the player the camera starts",
			height = "How far above the player the camera starts",

			blur = "Blur size when the game opens",
			duration = "Seconds the camera takes to settle behind the player",
		},
	},
})
