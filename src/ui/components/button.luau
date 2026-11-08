--// Packages
const vide = require "@game/ReplicatedStorage/packages/vide"

--// Constants
const PRESS_SCALE = 0.9
const HOVER_SCALE = 1.1

const SCALE_PERIOD = 0.15
const SCALE_DAMPING = 0.55

--// Types
type props<T> = {
	instance: T & GuiButton,
	on_press: (() -> ())?,

	target: GuiObject?,
	hover_scale: number?,
}

--// Component
return function<T>(props: props<T>)
	const state = vide.source(Enum.GuiState.Idle)

	vide.apply(props.target or props.instance) {
		vide.create "UIScale" {
			Scale = vide.spring(function()
				if state() == Enum.GuiState.Press then return PRESS_SCALE end
				if state() == Enum.GuiState.Hover then return props.hover_scale or HOVER_SCALE end

				return 1
			end, SCALE_PERIOD, SCALE_DAMPING),
		},
	}

	vide.apply(props.instance) {
		Activated = function()
			if props.on_press then props.on_press() end
		end,

		vide.changed("GuiState", state),
	}

	return props.instance
end
