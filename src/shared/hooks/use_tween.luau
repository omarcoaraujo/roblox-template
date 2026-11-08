--// Packages
const ripple = require "@game/ReplicatedStorage/packages/ripple"
const vide = require "@game/ReplicatedStorage/packages/vide"

--// Hook
return function<T>(initial_value: T, initial_options: ripple.TweenOptions<T>?): (() -> T, ripple.Tween<T>)
	const tween = ripple.createTween(initial_value, initial_options)
	const value = vide.source(initial_value)

	if not (initial_options and initial_options.start == false) then tween:start() end
	const disconnect = tween:onChange(value)

	vide.cleanup(function()
		disconnect()
		tween:stop()
	end)

	return value, tween
end
