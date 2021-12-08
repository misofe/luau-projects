--[[
 ~# ZoneAtmos - Version 1.0 #~
@AstralNetwork [astralm#3434]

]]--

local module = {}
module.__index = module 
local L = game:GetService("Lighting")
local TS = game:GetService("TweenService")
--
local ZoneModule = require(script.Zone)
function module.set(zone: BasePart, zoneName: string, Settings: any)
	local Region = ZoneModule.new(zone)
	local self = setmetatable({
		Zone = zone;
		ZoneSettings = Settings;
		Status = false;
		OnEntered = Region.localPlayerEntered;
		OnExited = Region.localPlayerExited;
	}, module)
	Region.localPlayerEntered:Connect(function()
		for classname, classvalue in pairs(Settings) do --ignore warning 
			if L:FindFirstChildOfClass(classname) then
				local InstanceEffect = L:FindFirstChildOfClass(classname)
				for property, value in pairs(classvalue) do 
					local tween = TS:Create(InstanceEffect, TweenInfo.new(1), {[property] = value})
					tween:Play()
				end
			end
		end
	end)
	return self
end

return module
