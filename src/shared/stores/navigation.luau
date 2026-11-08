--// Packages
const charm = require "@game/ReplicatedStorage/packages/charm"

--// Types
export type screen = string

--// Variables
const queue = {} :: { screen }
const current_screen = charm.atom<<screen>> "none"

--// Functions
const function toggle(screen: screen)
	const current = current_screen()
	current_screen(if current == screen then "none" else screen)
	table.clear(queue)
end

const function close()
	current_screen "none"
	table.clear(queue)
end

const function push_front(screen: screen)
	table.insert(queue, 1, screen)
end

const function push_back(screen: screen)
	table.insert(queue, screen)
end

const function get_next(): screen?
	return queue[1]
end

const function next()
	const next_screen = get_next() or "none"
	current_screen(next_screen)
	table.remove(queue, 1)
end

const function enqueue(screen: screen)
	if current_screen() == "none" then
		current_screen(screen)
	else
		push_back(screen)
	end
end

--// End
return table.freeze {
	current_screen = current_screen,
	toggle = toggle,
	close = close,

	next = next,
	enqueue = enqueue,
	push_front = push_front,
}
