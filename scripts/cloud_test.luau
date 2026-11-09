--// Modules
const fs = require "@lute/fs"
const json = require "@std/json"
const net = require "@lute/net"
const process = require "@lute/process"
const task = require "@lute/task"

--// Constants
const API = "https://apis.roblox.com"
const POLL_SECONDS = 3

const POLL_ATTEMPTS = 100
const PENDING = { QUEUED = true, PROCESSING = true }

--// Variables
const api_key = process.env.ROBLOX_API_KEY
const universe_id = process.env.ROBLOX_TEST_UNIVERSE_ID
const place_id = process.env.ROBLOX_TEST_PLACE_ID

--// Functions
const function fail(message: string): never
	print(`error: {message}`)
	return process.exit(1)
end

const function read_file(path: string)
	const handle = fs.open(path)
	const contents = fs.read(handle)

	fs.close(handle)
	return contents
end

const function call(url: string, method: string, body: string?, content_type: string?)
	const headers = { ["x-api-key"] = api_key }
	if content_type then headers["Content-Type"] = content_type end

	const response = net.client.request(url, { method = method, body = body, headers = headers })
	if not response.ok then fail(`{method} {url} failed with {response.status}\n{response.body}`) end

	return json.deserialize(response.body)
end

const function create_task(version: string, script_path: string)
	const url =
		`{API}/cloud/v2/universes/{universe_id}/places/{place_id}/versions/{version}/luau-execution-session-tasks`
	const body = json.serialize { script = read_file(script_path) }

	return call(url, "POST", body, "application/json")
end

const function await_task(path: string)
	for _ = 1, POLL_ATTEMPTS do
		const current = call(`{API}/cloud/v2/{path}`, "GET")
		if not PENDING[current.state] then return current end
		task.wait(POLL_SECONDS)
	end

	return fail(`task never settled after {POLL_ATTEMPTS * POLL_SECONDS}s`)
end

const function print_logs(path: string)
	const logs = call(`{API}/cloud/v2/{path}/logs`, "GET")

	for _, entry in logs.luauExecutionSessionTaskLogs or {} do
		for _, message in entry.messages or {} do
			print(message)
		end
	end
end

const function main()
	const version = process.args[2] or fail "usage: cloud_test <place version> <script>"
	const script_path = process.args[3] or fail "usage: cloud_test <place version> <script>"

	if not (api_key and universe_id and place_id) then
		fail "ROBLOX_API_KEY, ROBLOX_TEST_UNIVERSE_ID and ROBLOX_TEST_PLACE_ID must be set"
	end

	const created = create_task(version, script_path)
	print(`created task {created.path}`)

	const finished = await_task(created.path)
	print_logs(finished.path)

	if finished.state ~= "COMPLETE" then fail(`task {finished.state}: {json.serialize(finished.error)}`) end
	print "suite passed"
end

--// End
main()
