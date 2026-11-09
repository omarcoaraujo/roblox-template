--// Services
const Lighting = game:GetService "Lighting"
const Players = game:GetService "Players"
const RunService = game:GetService "RunService"
const TweenService = game:GetService "TweenService"

--// Data
const camera_tuning = require "@game/ReplicatedStorage/data/camera"

--// Constants
const RENDER_STEP_NAME = "camera_intro"
const RENDER_PRIORITY = Enum.RenderPriority.Camera.Value + 1

--// Variables
const player = Players.LocalPlayer
const camera = assert(workspace.CurrentCamera, "camera not found!")

const distance = Instance.new "NumberValue"
const blur = Instance.new "BlurEffect"

--// Functions
const function pull_back()
	const base = camera.CFrame
	const away = distance.Value
	const intro = camera_tuning.intro

	const flat_look = (base.LookVector * Vector3.new(1, 0, 1)).Unit
	const position = base.Position - flat_look * intro.back * away + Vector3.yAxis * intro.height * away

	const looking = CFrame.lookAt(position, camera.Focus.Position)
	camera.CFrame = base.Rotation:Lerp(looking.Rotation, math.clamp(away, 0, 1)) + position
end

const function open()
	const duration = camera_tuning.intro.duration
	const distance_info = TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	const blur_info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	const distance_tween = TweenService:Create(distance, distance_info, { Value = 0 })
	const blur_tween = TweenService:Create(blur, blur_info, { Size = 0 })

	distance_tween.Completed:Connect(function()
		RunService:UnbindFromRenderStep(RENDER_STEP_NAME)
		distance:Destroy()
		distance_tween:Destroy()
	end)

	blur_tween.Completed:Connect(function()
		blur:Destroy()
		blur_tween:Destroy()
	end)

	distance_tween:Play()
	blur_tween:Play()
end

const function sync_loading()
	if player:GetAttribute "loading_finished" ~= true then return end
	open()
end

--// Setup
distance.Value = 1
RunService:BindToRenderStep(RENDER_STEP_NAME, RENDER_PRIORITY, pull_back)

blur.Size = camera_tuning.intro.blur
blur.Parent = Lighting

--// Listeners
player:GetAttributeChangedSignal("loading_finished"):Once(sync_loading)
sync_loading()

--// End
return table.freeze {}
