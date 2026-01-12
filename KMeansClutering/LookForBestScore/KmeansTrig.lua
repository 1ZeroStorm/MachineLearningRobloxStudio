-- Get the UserInputService
local RepStorage = game:GetService('ReplicatedStorage')
local UIS = game:GetService("UserInputService")

-- Example: Detect when a key is pressed
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end  -- Ignore if Roblox already handled it

	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.G then
			print('generating kmeans')
			RepStorage.RemoteEvents.RemoteKmeans:FireServer()
			
		elseif input.KeyCode == Enum.KeyCode.H then
			print('generating rocks from the lastest K')
		end
		
		
	end
end)
