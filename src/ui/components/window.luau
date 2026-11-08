--// Packages
const ripple = require "@game/ReplicatedStorage/packages/ripple"
const vide = require "@game/ReplicatedStorage/packages/vide"

--// Stores
const navigation_store = require "@game/ReplicatedStorage/shared/stores/navigation"

--// Components
const button = require "./button"

--// Hooks
const use_atom = require "@game/ReplicatedStorage/shared/hooks/use_atom"
const use_tween = require "@game/ReplicatedStorage/shared/hooks/use_tween"

--// Constants
const DURATION = 0.25
const SHUT_SCALE = 0.25
const SHUT_DROP = 0.25

const SCALE_EASING: ripple.Easing = "circOut"
const POSITION_EASING: ripple.Easing = "quartOut"

--// Types
type props = {
	instance: GuiObject,

	close: GuiButton?,
	on_close: (() -> ())?,
}

--// Component
return function(props: props)
	const content = assert(props.instance:FindFirstChild "content", "content not found!") :: Frame
	const current_screen = use_atom(navigation_store.current_screen)

	const origin = content.Position
	const shut = UDim2.new(origin.X.Scale, origin.X.Offset, origin.Y.Scale + SHUT_DROP, origin.Y.Offset)

	const scale, scale_tween = use_tween(SHUT_SCALE, { easing = SCALE_EASING, duration = DURATION })
	const position, position_tween = use_tween(shut, { easing = POSITION_EASING, duration = DURATION })

	const function is_open()
		return current_screen() == props.instance.Name
	end

	vide.effect(function()
		if is_open() then
			position_tween:setGoal(origin)
			scale_tween:setGoal(1)
			return
		end

		position_tween:setPosition(shut)
		position_tween:setGoal(shut)

		scale_tween:setPosition(SHUT_SCALE)
		scale_tween:setGoal(SHUT_SCALE)
	end)

	vide.apply(content) {
		Visible = is_open,
		Position = position,

		vide.create "UIScale" {
			Scale = scale,
		},
	}

	if props.close then button { instance = props.close, on_press = props.on_close or navigation_store.next } end
	return props.instance
end
