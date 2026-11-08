--// Packages
const charm = require "@game/ReplicatedStorage/packages/charm"
const vide = require "@game/ReplicatedStorage/packages/vide"

--// Hook
return function<T>(callback: () -> T): () -> T
	const state = vide.source(callback())
	const unsubscribe = charm.subscribe(callback, function(value)
		task.defer(function()
			state(value)
		end)
	end)

	vide.cleanup(unsubscribe)
	return state
end
