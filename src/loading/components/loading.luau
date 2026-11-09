--// Services
const RunService = game:GetService "RunService"

--// Packages
const ripple = require "@game/ReplicatedFirst/packages/ripple"
const vide = require "@game/ReplicatedFirst/packages/vide"

--// Modules
const config = require "../data"
const loading_store = require "../store"

--// Utils
const px = require "../utils/px"

--// Constants
const DISPLAY_ORDER = 1e6
const ACTIVATE_PERIOD = 0.25
const ACTIVATE_DAMPING = 1

--// Functions
const function wave(elapsed: number, seconds: number)
	return math.sin(elapsed / seconds * math.pi * 2)
end

const function hop(elapsed: number, index: number, cycle: number, duration: number)
	const jump = config.jump
	const beat = (elapsed - index * jump.stagger) % cycle
	if beat > duration then return 0 end

	const alpha = beat / duration
	if alpha < jump.rise then return ripple.easing.sineOut(alpha / jump.rise) end
	return 1 - ripple.easing.backOut((alpha - jump.rise) / (1 - jump.rise))
end

const function lift_of(elapsed: number, index: number, activation: number)
	const waiting = config.waiting
	const jump = config.jump

	const waiting_hop = waiting.height * hop(elapsed, index, waiting.cycle, waiting.duration)
	const jump_hop = jump.height * hop(elapsed, index, jump.cycle, jump.duration)

	const drift = wave(elapsed + index * config.drift.stagger, config.drift.seconds)
	return waiting_hop * (1 - activation) + jump_hop * activation + config.drift.amount * drift
end

const function dot(elapsed: () -> number, index: number)
	const active = vide.spring(function()
		return if loading_store.progress() >= index / config.dots.count then 1 else 0
	end, ACTIVATE_PERIOD, ACTIVATE_DAMPING)

	const function activation()
		return math.clamp(active(), 0, 1)
	end

	return vide.create "Frame" {
		Name = `dot_{index}`,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BorderSizePixel = 0,

		BackgroundColor3 = function()
			return config.colors.idle:Lerp(config.colors.dot, activation())
		end,

		Size = function()
			const diameter = px(config.dots.diameter)() * (1 - loading_store.vanish())
			return UDim2.fromOffset(diameter, diameter)
		end,

		Position = function()
			const offset = (index - (config.dots.count + 1) / 2) * config.dots.spacing
			return UDim2.new(0.5, px(offset)(), config.dots.rest - lift_of(elapsed(), index, activation()), 0)
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

	vide.cleanup(RunService.PreRender:Connect(function(delta_time)
		elapsed(elapsed() + delta_time)
	end))

	const function dot_indexes()
		const list = {}

		for index = 1, config.dots.count do
			list[index] = index
		end

		return list
	end

	return vide.create "ScreenGui" {
		Name = "loading",
		DisplayOrder = DISPLAY_ORDER,

		IgnoreGuiInset = true,
		ResetOnSpawn = false,

		vide.create "Frame" {
			Name = "background",
			Size = UDim2.fromScale(1, 1),

			BorderSizePixel = 0,
			BackgroundTransparency = loading_store.fade,

			BackgroundColor3 = function()
				return config.colors.background
			end,

			vide.create "Frame" {
				Name = "dots",
				AnchorPoint = Vector2.new(0.5, 1),

				Position = UDim2.fromScale(0.5, 0.9),
				BackgroundTransparency = 1,

				Size = function()
					return UDim2.fromOffset(px(config.dots.spacing * config.dots.count)(), px(config.dots.height)())
				end,

				vide.indexes(dot_indexes, function(_, index)
					return dot(elapsed, index)
				end),
			},
		},
	}
end
