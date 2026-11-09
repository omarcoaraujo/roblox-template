--// Services
const ReplicatedStorage = game:GetService "ReplicatedStorage"

--// Packages
const scrim = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild "scrim")

--// End
scrim.run { specs = ReplicatedStorage:WaitForChild "playtests" }
