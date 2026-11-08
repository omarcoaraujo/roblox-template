--// Services
const RunService = game:GetService "RunService"

--// Packages
const ripple = require "@game/ReplicatedFirst/packages/ripple"
const vide = require "@game/ReplicatedFirst/packages/vide"

--// Utils
const px = require "../utils/px"

--// Constants
const DISPLAY_ORDER = 1e6

const BACKGROUND = Color3.new(1, 1, 1)
const DOT_COLOR = Color3.fromRGB(46, 125, 255)

const DOT_COUNT = 3
const DOT_DIAMETER = 28
const DOT_SPACING = 44

const DOTS_HEIGHT = 80
const DOT_REST = 0.75

const DOT_CYCLE = 1.25
const DOT_HOP = 0.55
const DOT_RISE = 0.35

const DOT_STAGGER = 0.13
const DOT_HEIGHT = 0.8

const DOT_DRIFT = 0.15
const DOT_DRIFT_SECONDS = 2.9
const DOT_DRIFT_STAGGER = 0.6

--// Functions
const function wave(elapsed: number, seconds: number)
	return math.sin(elapsed / seconds * math.pi * 2)
end

const function hop(elapsed: number, index: number)
	const beat = (elapsed - index * DOT_STAGGER) % DOT_CYCLE
	if beat > DOT_HOP then return 0 end

	const alpha = beat / DOT_HOP
	if alpha < DOT_RISE then return ripple.easing.sineOut(alpha / DOT_RISE) end

	return 1 - ripple.easing.backOut((alpha - DOT_RISE) / (1 - DOT_RISE))
end

const function lift_of(elapsed: number, index: number)
	const drift = wave(elapsed + index * DOT_DRIFT_STAGGER, DOT_DRIFT_SECONDS)
	return DOT_HEIGHT * hop(elapsed, index) + DOT_DRIFT * drift
end

const function dot(elapsed: () -> number, index: number)
	const offset = (index - (DOT_COUNT + 1) / 2) * DOT_SPACING

	return vide.create "Frame" {
		Name = `dot_{index}`,
		AnchorPoint = Vector2.new(0.5, 0.5),

		BackgroundColor3 = DOT_COLOR,
		BorderSizePixel = 0,

		Size = function()
			return UDim2.fromOffset(px(DOT_DIAMETER)(), px(DOT_DIAMETER)())
		end,

		Position = function()
			return UDim2.new(0.5, px(offset)(), DOT_REST - lift_of(elapsed(), index), 0)
		end,

		vide.create "UICorner" {
			CornerRadius = UDim.new(0.5, 0),
		},
	}
end

--// Component
return function()
	px.use_px()

	const elapsed = vide.source(0)
	const dots = {}

	vide.cleanup(RunService.PreRender:Connect(function(delta_time)
		elapsed(elapsed() + delta_time)
	end))

	for index = 1, DOT_COUNT do
		table.insert(dots, dot(elapsed, index))
	end

	return vide.create "ScreenGui" {
		Name = "loading",
		DisplayOrder = DISPLAY_ORDER,

		IgnoreGuiInset = true,
		ResetOnSpawn = false,

		vide.create "Frame" {
			Name = "background",
			Size = UDim2.fromScale(1, 1),

			BackgroundColor3 = BACKGROUND,
			BorderSizePixel = 0,

			vide.create "Frame" {
				Name = "dots",
				AnchorPoint = Vector2.new(0.5, 0.5),

				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,

				Size = function()
					return UDim2.fromOffset(px(DOT_SPACING * DOT_COUNT)(), px(DOTS_HEIGHT)())
				end,

				dots,
			},
		},
	}
end
