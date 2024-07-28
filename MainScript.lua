local Configurations = workspace.Settings
local TruckTouch = workspace.TouchTruck
local TrcukAttach = workspace.TruckAttach
local TruckAttachment = TrcukAttach.Attachment
local hoseModule = require(game.ReplicatedStorage.WaterModule)
local Inflate = workspace.Inflator.ClickDetector
local Deflate = workspace.Deflator.ClickDetector
local Sechosetruck = workspace.SecHoseCouplingTrck
local WaterValue = workspace.WaterValue


local isConstraintCreated = false

local function connectSections(coupling1, coupling2)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = coupling1
	weld.Part1 = coupling2
	weld.Parent = coupling1
end

local function setupCoupling(coupling)
	coupling.Touched:Connect(function(hit)
		if hit.Name == "Coupling" and hit.Parent ~= coupling.Parent then
			local alreadyConnected = false
			for _, constraint in ipairs(coupling:GetChildren()) do
				if constraint:IsA("WeldConstraint") and (constraint.Part0 == hit or constraint.Part1 == hit) then
					alreadyConnected = true
					break
				end
			end

			if not alreadyConnected then
				connectSections(coupling, hit)
			end
		end
	end)
end

for _, section in pairs(game.Workspace:GetChildren()) do
	if section:IsA("Folder") and (section.Name:match("^SectionHoseCoupling") or section.Name:match("^SecHoseCouplingTrck")) then
		for _, part in pairs(section:GetChildren()) do
			if part.Name == "Coupling" then
				setupCoupling(part)
			end
		end
	end
end

local function onTouched(hit)
	if hit.Name == "Attach" and not isConstraintCreated then
		print(hit.Name .. " touched TruckTouch.")
		local ballsocket = Instance.new("BallSocketConstraint")
		ballsocket.Attachment0 = TruckAttachment
		ballsocket.Attachment1 = hit.TruckAtatchment
		ballsocket.TwistLimitsEnabled = true
		ballsocket.UpperAngle = 0
		ballsocket.TwistLowerAngle = 40
		ballsocket.TwistUpperAngle = 40
		hit.CanCollide = false
		ballsocket.Parent = TrcukAttach
		isConstraintCreated = true
		Configurations.ConnectedTruck.Value = true
	end
end

Inflate.MouseClick:Connect(function()
	if Configurations.ConnectedTruck.Value then
		for i = 1, 100 do
			hoseModule.changeSize(Sechosetruck, WaterValue)
			WaterValue.Value = i
			wait(0.1) -- Adjust this value to control the speed of filling up
		end
	else
		print("The hose is not connected to the truck.")
	end
end)


Deflate.MouseClick:Connect(function()
	for i = 100, 1, -1 do
		hoseModule.changeSize(Sechosetruck, WaterValue)
		WaterValue.Value = i
		wait(0.1) -- Adjust this value to control the speed of deflating
	end
end)

-- Connect the function to the Touched event
TruckTouch.Touched:Connect(onTouched)
