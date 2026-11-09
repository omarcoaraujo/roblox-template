--// Variables
local next_user_id = 1

--// End
return function(name: string?): Player
	const user_id = next_user_id
	next_user_id += 1

	return {
		Name = name or `player_{user_id}`,
		UserId = user_id,

		Parent = game:GetService "Players",
		LoadCharacterAsync = function() end,
	} :: any
end
