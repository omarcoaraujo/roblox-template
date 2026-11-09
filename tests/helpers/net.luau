--// Types
type handlers = { [string]: (...any) -> ...any }

--// Constants
const FIRE = {
	fire = true,
	fire_all = true,
	fire_list = true,
	fire_except = true,
}

const LISTEN = { on = true }

--// Functions
const function noop() end

const function stub(registry: handlers?, path: string?): any
	const handlers = registry or {}

	return setmetatable({}, {
		__index = function(self: any, key: string)
			const child = if path then `{path}.{key}` else key
			local value = nil :: any

			if FIRE[key] then
				value = noop
			elseif LISTEN[key] then
				value = function(handler: (...any) -> ...any)
					handlers[path or key] = handler
				end
			else
				value = stub(handlers, child)
			end

			rawset(self, key, value)
			return value
		end,
	})
end

--// End
return stub
