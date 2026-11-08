--// Packages
const vide = require "@game/ReplicatedFirst/packages/vide"

--// Constants
const BASE_RESOLUTION = Vector2.new(1920, 1080)
const DOMINANT_AXIS = 0.5
const MAX_ASPECT_RATIO = 16 / 9

--// Variables
const camera = workspace.CurrentCamera
const current_scale = vide.source(1)

--// Functions
const function use_px()
	const viewport_size = vide.source(Vector2.new(0, 0))
	const clamped_size = vide.derive(function()
		const ratio = math.min(viewport_size().X / viewport_size().Y, MAX_ASPECT_RATIO)
		return Vector2.new(viewport_size().Y * ratio, viewport_size().Y)
	end)

	vide.effect(function()
		const x_scale = math.log(clamped_size().X / BASE_RESOLUTION.X, 2)
		const y_scale = math.log(clamped_size().Y / BASE_RESOLUTION.Y, 2)

		const raw_scale = 2 ^ math.lerp(x_scale, y_scale, DOMINANT_AXIS)
		current_scale(raw_scale ^ 0.5)
	end)

	vide.cleanup(camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		viewport_size(camera.ViewportSize)
	end))

	viewport_size(camera.ViewportSize)
end

const function px(x: number)
	return function()
		return math.round(x * current_scale())
	end
end

const function udim(scale: number, offset: number)
	return function()
		return UDim.new(scale, px(offset)())
	end
end

const function udim2(x_scale: number, x_offset: number, y_scale: number, y_offset: number)
	return function()
		return UDim2.new(x_scale, px(x_offset)(), y_scale, px(y_offset)())
	end
end

--// End
return setmetatable({
	use_px = use_px,
	set_scale = current_scale,

	udim = udim,
	udim2 = udim2,
}, {
	__call = function(_, value: number)
		return px(value)
	end,
})
