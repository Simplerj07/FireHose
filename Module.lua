local module = {}

local ts = game:GetService("TweenService")
local twinfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
local minValue = 0
local maxValue = 100
local minSize = Vector3.new(2.502, 0.1, 0.5)
local maxSize = Vector3.new(2.502, 0.6, 0.5)

function module.changeSize(partsFolder, WaterValue)
    WaterValue.Changed:Connect(function(value)
        value = math.clamp(value, 0, 100)

        local parts = partsFolder:GetChildren()
        table.sort(parts, function(a, b)
            local aNum = tonumber(a.Name)
            local bNum = tonumber(b.Name)
            return aNum and bNum and aNum < bNum or aNum
        end)

        local delay = 0.07
        local t = (value - minValue) / (maxValue - minValue)
        local newSize = minSize:Lerp(maxSize, t)

        for _, part in pairs(parts) do
            if tonumber(part.Name) then
                local goal = {Size = newSize}
                ts:Create(part, twinfo, goal):Play()
                wait(delay)
            end
        end
    end)
end

return module
