--// Services
const Players = game:GetService "Players"

--// Packages
const vide = require "@game/ReplicatedStorage/packages/vide"

--// Constants
const DEFAULT_TYPE = Enum.ThumbnailType.HeadShot
const DEFAULT_SIZE = Enum.ThumbnailSize.Size150x150

--// Variables
const cache = {} :: { [string]: () -> string }

--// Functions
const function fetch(user_id: number, kind: Enum.ThumbnailType, size: Enum.ThumbnailSize)
	const key = `{user_id}:{kind.Name}:{size.Name}`
	if cache[key] then return cache[key] end

	const url = vide.source ""
	cache[key] = url

	task.spawn(function()
		const success, result = pcall(Players.GetUserThumbnailAsync, Players, user_id, kind, size)
		if not success then return end

		url(result)
	end)

	return url
end

const function clear(player: Player)
	for key in cache do
		if not string.find(key, `^{player.UserId}:`) then continue end
		cache[key] = nil
	end
end

--// Listeners
Players.PlayerRemoving:Connect(clear)

--// Hook
return function(user_id: (() -> number?) | number, kind: Enum.ThumbnailType?, size: Enum.ThumbnailSize?)
	return vide.derive(function()
		const id = vide.read(user_id)
		if not id then return Content.none end

		const url = fetch(id, kind or DEFAULT_TYPE, size or DEFAULT_SIZE)()
		return url ~= "" and Content.fromUri(url) or Content.none
	end)
end
