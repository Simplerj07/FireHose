local HoseValues = workspace.HoseValues
local TruckTouch = workspace.TouchTruck
local TruckAttach = workspace.TruckAttach
local TruckAttachment = TruckAttach.Attachment
local hoseModule = require(game.ReplicatedStorage.WaterModule)
local Inflate = workspace.Inflator.ClickDetector
local Deflate = workspace.Deflator.ClickDetector
local Sechosetruck = workspace.SecHoseCouplingTrck
local WaterValue = HoseValues.WaterValue

local connectedHoseSections = {} -- Table to keep track of connected hose sections

local isConstraintCreated = false

local function connectSections(coupling1, coupling2)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = coupling1
	weld.Part1 = coupling2
	weld.Parent = coupling1

	-- Add the connected sections to the table
	table.insert(connectedHoseSections, coupling1.Parent)
	table.insert(connectedHoseSections, coupling2.Parent)
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
		ballsocket.Attachment1 = hit.TruckAttachment
		ballsocket.TwistLimitsEnabled = true
		ballsocket.UpperAngle = 0
		ballsocket.TwistLowerAngle = 40
		ballsocket.TwistUpperAngle = 40
		hit.CanCollide = false
		ballsocket.Parent = TruckAttach
		isConstraintCreated = true
		HoseValues.ConnectedTruck.Value = true

		-- Add the truck attachment section to the table
		table.insert(connectedHoseSections, hit.Parent)
	end
end

local function inflateHoseSections()
	if HoseValues.ConnectedTruck.Value then
		for i = 1, 100 do
			for _, hoseSection in ipairs(connectedHoseSections) do
				hoseModule.changeSize(hoseSection, WaterValue)
			end
			WaterValue.Value = i
			wait(0.1)
		end
	else
		print("The hose is not connected to the truck.")
	end
end

local function deflateHoseSections()
	for i = 100, 1, -1 do
		for _, hoseSection in ipairs(connectedHoseSections) do
			hoseModule.changeSize(hoseSection, WaterValue)
		end
		WaterValue.Value = i
		wait(0.1)
	end
end

Inflate.MouseClick:Connect(inflateHoseSections)
Deflate.MouseClick:Connect(deflateHoseSections)

TruckTouch.Touched:Connect(onTouched)
