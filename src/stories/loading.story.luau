--// Services
const ReplicatedFirst = game:GetService "ReplicatedFirst"

--// Packages
const vide = require(ReplicatedFirst.packages.vide)

--// Utils
const convert_to_frame = require "./utils/convert_to_frame"

--// Components
const loading = require(ReplicatedFirst.loading.components.loading)

--// Story
return function(target: Instance)
	return vide.mount(function()
		return convert_to_frame(loading())
	end, target)
end
