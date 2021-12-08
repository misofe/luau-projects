local PS = game:GetService("Players") 
local RS = game:GetService("ReplicatedStorage") 
local RF = game:GetService("ReplicatedFirst") 
local L = game:GetService("Lighting")
--
local OnDestroyed = require(RS["ClientModule"]["util"]["corecii_ondestroyed"])
local Instance2 = require(RS["ClientModule"]["util"]["colbert_instance2"])
local player = PS.LocalPlayer
--
local VM = {}
VM.__index = VM
--
function set(tool: Tool)
	print("set!")
	assert((player.Character:FindFirstChild("Humanoid").Health > 0), "Error: Unable to set ViewModel to character "..player.Name)
	local newVM = RS["Storage"]["VM"]["VM"]:Clone()
	if not workspace:FindFirstChild("VM") then 
		local vmdebris = Instance.new("Folder")
		vmdebris.Parent = workspace
		vmdebris.Name = "VM"
	end
	newVM.Parent = workspace.VM
	newVM.Name = player.Name
	player.Character:FindFirstChild("Humanoid").Died:Connect(function()
		newVM:Destroy()
	end)
	local connection = game["Run Service"].RenderStepped:Connect(function(delta)
		--workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(workspace.CurrentCamera.CFrame, 0.1) --noob code
		--newVM["Head"].CFrame = newVM["Head"].CFrame:Lerp(workspace.CurrentCamera.CFrame, delta*10)
		newVM["Head"].CFrame = workspace.CurrentCamera.CFrame
	end)
	local motor = Instance2.new("Motor6D", newVM["Head"])
	motor.Part0 = newVM["Head"]
	motor.Part1 = tool:FindFirstChild("Handle", true) --we need to make sure it has a HANDLE!!111!
	motor.C0 = CFrame.new(1, -1, -2) --adjust if needed
	for __, base in pairs(tool:GetDescendants()) do 
		if base:IsA("BasePart") then 
			base.CanCollide = false
		end
	end
	local modeltool = tool:FindFirstChildOfClass("Model")
	modeltool.Parent = newVM
	local track
	if RS["Library"]["GunEngine"]["Animations"]:FindFirstChild(tool.Name) then
		if RS["Library"]["GunEngine"]["Animations"]:FindFirstChild(tool.Name):FindFirstChild("Equip") then
			local animtrack = newVM:FindFirstChildOfClass("Humanoid")["Animator"]:LoadAnimation(RS["Library"]["GunEngine"]["Animations"][tool.Name]["Equip"])
			animtrack:Play()
			track = animtrack
		end
	end
	return newVM, connection, motor, modeltool, track
end
function VM.new(tool)
	local character = player.Character
	assert((character:FindFirstChild("Humanoid").Health == 0) or character, "Error: Unable to set ViewModel to character "..player.Name)
	local Destroyal = Instance.new("BindableEvent")
	local self = setmetatable({
		Destroyed = Destroyal.Event;
		Cache = {
			Character = player.Character;
			Tool = tool;
		}
	}, VM)
	--tool.AncestryChanged:Connect(function()
	--	if not tool:IsDescendantOf(game) then
	--		Destroyal:Fire()
	--	end
	--end)
	local vmcloned, connection, mainmotor, modeltool, track = set(tool)
	self.Cache.VM = vmcloned
	self.Cache.MainMotor = mainmotor
	if track then 
		track.Stopped:Connect(function()
			if RS["Library"]["GunEngine"]["Animations"]:FindFirstChild(tool.Name) then
				if RS["Library"]["GunEngine"]["Animations"]:FindFirstChild(tool.Name):FindFirstChild("Hold") then 
					local animtrack = vmcloned:FindFirstChildOfClass("Humanoid")["Animator"]:LoadAnimation(RS["Library"]["GunEngine"]["Animations"][tool.Name]["Hold"])
					animtrack:Play()
				end
			end
		end)
	end
	character:FindFirstChild("Humanoid").Died:Connect(function()
		connection:Disconnect()
		self = {}
		tool:Destroy()
	end)
	tool.Unequipped:Connect(function()
		modeltool.Parent = tool
		connection:Disconnect()
		if self.Cache.VM then 
			self.Cache.VM:Destroy() 
		end
		self.Cache.VM = nil
	end)
	return self
end
function VM:SetRotation(newRotation)
	self["Cache"].MainMotor.C0 *= newRotation
	return newRotation
end
function VM:GetCFrame()
	return self["Cache"].MainMotor.C0
end
function VM:SetCFrame(newCFrame)
	self["Cache"].MainMotor.C0 = newCFrame
end
function VM:Destroy()
	for i, v in pairs(self.Cache) do 
		v = nil
	end
	self = {}
end

return VM
