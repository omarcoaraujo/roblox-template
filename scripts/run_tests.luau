--// Services
const ReplicatedStorage = game:GetService "ReplicatedStorage"

--// Packages
const jest = require(ReplicatedStorage.packages.jest)

--// Variables
const has_process_service, ProcessService = pcall(game.GetService, game, "ProcessService")

--// Functions
const function run()
	const root = ReplicatedStorage.tests
	const status, result = jest.runCLI(root, { verbose = true, ci = true, passWithNoTests = true }, { root })
		:awaitStatus()

	if status == "Rejected" then print(result) end
	const passed = status == "Resolved" and result.results.success

	if has_process_service then ProcessService:ExitAsync(if passed then 0 else 1) end
	if not passed then error("test suite failed", 0) end

	return result.results
end

--// End
return run()
