--// Packages
const vide = require "@game/ReplicatedStorage/packages/vide"

--// Hook
return function<T>(read: () -> T, scale: number, period: number?, damping: number?)
	const value, adjust = vide.spring(function()
		return 1
	end, period, damping)

	local seeded = false
	local last: T? = nil

	vide.effect(function()
		const current = read()
		if seeded and current ~= last then adjust { position = scale, velocity = 0 } end

		last = current
		seeded = true
	end)

	return value
end
