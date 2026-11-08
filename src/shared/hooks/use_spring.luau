--// Packages
const ripple = require "@game/ReplicatedStorage/packages/ripple"
const vide = require "@game/ReplicatedStorage/packages/vide"

--// Hook
return function<T>(initial_value: T, initial_options: ripple.SpringOptions<T>?): (() -> T, ripple.Spring<T>)
	const spring = ripple.createSpring(initial_value, initial_options)
	const value = vide.source(initial_value)

	if not (initial_options and initial_options.start == false) then spring:start() end
	const disconnect = spring:onChange(value)

	vide.cleanup(function()
		disconnect()
		spring:stop()
	end)

	return value, spring
end
