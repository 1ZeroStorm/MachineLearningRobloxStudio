-- k means w/out objective function
local RepStorage = game:GetService("ReplicatedStorage")
local BevelPartModule = require(script.Parent.BevelPartModule)

local partsModel =  game.Workspace.Model3Dup

--[[
local centroidFolder = Instance.new('Folder')
centroidFolder.Parent = workspace
centroidFolder.Name = 'CentroidsFolder'
]]

local centroidsFolderContainer = {} -- [1] = centroidFolderK1, [2] = centroidFolderK2, etc.

local generatedPartsFolder = Instance.new('Folder')
generatedPartsFolder.Parent = workspace
generatedPartsFolder.Name = 'generatedPartsFolder'

local function distEuclidean(a, b) 
	return (a - b).Magnitude 
end

local function generateRandomPoints(model, k)
	local fullSize = model:GetExtentsSize()
	local centerCFrame = model:GetPivot()
	local centerPosition = centerCFrame.Position

	local lowestXPosition = math.huge
	local lowestYPosition = math.huge
	local lowestZPosition = math.huge

	local highestXPosition = -math.huge
	local highestYPosition = -math.huge
	local highestZPosition = -math.huge

	for i, part in pairs(partsModel:GetChildren()) do

		if part:FindFirstChildWhichIsA('Attachment')  then
			if part.position.X < lowestXPosition then
				lowestXPosition = part.position.X
			end
			if part.position.Y < lowestYPosition then
				lowestYPosition = part.position.Y
			end
			if part.position.Z < lowestZPosition then
				lowestZPosition = part.position.Z
			end
			if part.position.X > highestXPosition then
				highestXPosition = part.position.X
			end
			if part.position.Y > highestYPosition then
				highestYPosition = part.position.Y
			end
			if part.position.Z > highestZPosition then
				highestZPosition = part.position.Z
			end
		end
	end

	local rangeSize = Vector3.new(highestXPosition-lowestXPosition, highestYPosition-lowestYPosition, highestZPosition-lowestZPosition)
	for i = 1, k, 1 do
		local centroidPart = Instance.new('Part')
		centroidPart.Anchored = true
		centroidPart.Size = Vector3.new(0.1, 0.1, 0.1)
		centroidPart.Position = Vector3.new(

			lowestXPosition + math.random(0, rangeSize.X),
			lowestYPosition + math.random(0, rangeSize.Y),
			lowestZPosition + math.random(0, rangeSize.Z)

		)
		centroidPart.Parent = centroidsFolderContainer[k]
		centroidPart.Name = 'centroid_'..i

		local newHighlightCentroid = Instance.new('Highlight')
		newHighlightCentroid.Parent = centroidPart		

		local newattachment = Instance.new('Attachment')
		newattachment.Parent = centroidPart
		newattachment.Visible = false
	end

end

local function visualizeMagnitude(att1, att2)
	local beam = Instance.new('Beam')
	beam.Parent = att2.Parent
	beam.Attachment0 = att1
	beam.Attachment1 = att2
	beam.Width0 = 0.2
	beam.Width1 = 0.2
end

local function removeBeam(parent)
	for i, v in pairs(parent:GetChildren()) do
		if v:IsA('Beam') then
			v:Destroy()
		end
	end
end

local function compareMagnitude(model, k)

	local closestCentroidForEveryPart = {}
	local parts = {}

	for i, part in pairs(partsModel:GetChildren()) do
		table.insert(parts, part)
		if part:FindFirstChildWhichIsA('Attachment') then
			local att = part:FindFirstChildWhichIsA('Attachment')
			local closestCentroid = nil
			local closestMagnitude = math.huge

			for j, centroid in pairs(centroidsFolderContainer[k]:GetChildren()) do
				local magnitude = distEuclidean(att.WorldPosition, centroid.Position)
				if magnitude < closestMagnitude then
					closestMagnitude = magnitude
					closestCentroid = centroid
				end
			end

			closestCentroidForEveryPart[i] = closestCentroid
			visualizeMagnitude(att, closestCentroid.Attachment)

		end
	end
	return closestCentroidForEveryPart, parts
end

local function getcoordinateMeanAndUpdateCentroid(k)
	
	local centroidsReady = {}
	
	for l =1, math.huge, 1 do
		local closestCentroidForEveryPart, parts = compareMagnitude(partsModel, k)
		task.wait(1)
		
		for j, centroid in pairs(centroidsFolderContainer[k]:GetChildren()) do
			local sumPosition = Vector3.new(0, 0, 0)
			local count = 0


			for i, centroidClassified in pairs(closestCentroidForEveryPart) do
				
				if centroid == centroidClassified then
					sumPosition += parts[i].Position
					count += 1
				end
			end

			removeBeam(centroid)

			if count ~= 0 then
				local mean = sumPosition / count
				--print(mean)
				
				if math.abs((centroid.Position-mean).Magnitude) < 0.01 then
					centroidsReady[j] = centroid
				else
					
					centroid.Position = mean
				end
			else
				centroidsReady[j] = centroid
			end
		end
		--print('iteration: ', l)
		
		if #centroidsReady == #centroidsFolderContainer[k]:GetChildren() then
			return closestCentroidForEveryPart, parts
		end

	end
	
	
end


local function getRandomPositionInSphere(centroid, maxMagnitude)
	-- Random direction (unit vector)
	local randomDir = Vector3.new(
		math.random() - 0.5,
		math.random() - 0.5,
		math.random() - 0.5
	).Unit

	-- Random distance (0 to radius)
	local distance = math.random() * maxMagnitude

	return centroid.Position + randomDir * distance
end

local function getValidCentroids(closestCentroidForEveryPart)
	-- Function to return a table with unique values
	local seen = {}
	local result = {}
	for _, value in ipairs(closestCentroidForEveryPart) do
		if not seen[value] then
			seen[value] = true
			table.insert(result, value)
		end
	end
	return result

end

local function generateRockWithinRadius(closestCentroidForEveryPart, parts)
	local validCentroids = getValidCentroids(closestCentroidForEveryPart)
	print(validCentroids)
	for j, centroid in pairs(validCentroids) do
		local partsWithinCluster  = {}
		local maxMagnitude = -math.huge

		local maxSizeX = 1
		local maxSizeY = 1
		local maxSizeZ = 1

		for i, centroidClassified in pairs(closestCentroidForEveryPart) do
			if centroid == centroidClassified then
				table.insert(partsWithinCluster, parts[i])
			end
		end

		for _, part in pairs(partsWithinCluster) do
			if distEuclidean(part.Position, centroid.Position) > maxMagnitude then
				maxMagnitude = distEuclidean(part.Position, centroid.Position)
			end
			if part.Size.X > maxSizeX then maxSizeX = part.Size.X end
			if part.Size.Y > maxSizeY then maxSizeY = part.Size.Y end
			if part.Size.Z > maxSizeZ then maxSizeZ = part.Size.Z end

		end

		if maxSizeX < 6 then maxSizeX = 6 end
		if maxSizeY < 6 then maxSizeY = 6 end
		if maxSizeZ < 6 then maxSizeZ = 6 end

		--[[
		local newBeveledModel = BevelPartModule.new(workspace, getRandomPositionInSphere(centroid, maxMagnitude))
		newBeveledModel:resizeAll(Vector3.new(math.random(6,maxSizeX), math.random(6,maxSizeZ), math.random(6,maxSizeZ)))
		newBeveledModel:rotate(CFrame.Angles(math.rad(90),0, math.rad(math.random(0,90))))
		
		]]
		-- beveledModel



		local newPart = Instance.new('Part')
		newPart.Parent = game.Workspace
		newPart.Anchored = true
		newPart.Size = Vector3.new(math.random(2,maxSizeX), math.random(2,maxSizeZ), math.random(2,maxSizeZ))
		newPart.Position = getRandomPositionInSphere(centroid, maxMagnitude)
		newPart.Orientation = Vector3.new(0,math.random(0,90),90)



	end
end

local function silhouetteScore(closestCentroidForEveryPart, parts, k)
	local totalScore = 0
	-- closestCentroidForEveryPart:  [1] = centroid_2, [2] = centroid_2, [3] = centroid_1, [4] = centroid_1,
	-- parts: [1] = Rock_9, [2] = Rock_8, [3] = Rock_7, [4] = Rock_7, [5] = Rock_7,
	
	
	--print("closestCentroidForEveryPart", closestCentroidForEveryPart)
	--print('parts', parts)
	
	for i, centroid in pairs(centroidsFolderContainer[k]:GetChildren()) do
		local centroid_name = centroid.Name
		local partsWithinCluster = {} -- {part10, part5, part4, ... }
		local partsOutsideCluster = {} -- {part1, part2, part3, ... }
		
		
		for j, closestCentroid in pairs(closestCentroidForEveryPart) do
			if closestCentroid.Name == centroid_name then
				table.insert(partsWithinCluster, parts[j])
				--print(parts[j], " is in cluster ", centroid)
			else
				table.insert(partsOutsideCluster, parts[j])
				
			end
		end
		
		for i, part in pairs(partsWithinCluster) do
			local totalDistInside = 0
			for j, otherparts in pairs(partsWithinCluster) do
				if part ~= otherparts then
					--print("otherparts: ", otherparts)
					local distance = distEuclidean(part.Position, otherparts.Position)
					totalDistInside += distance
				end
			end
			
			-- variable A
			local avgDistInsideCluster = totalDistInside/#partsWithinCluster - 1
			
			local totalDistOutside = 0
			for j, otherparts in pairs(partsOutsideCluster) do
				if part ~= otherparts then
					local distance = distEuclidean(part.Position, otherparts.Position)
					totalDistOutside += distance
				end
			end
			
			--print('parts outside: ', partsOutsideCluster)
			--print('parts within: ', partsWithinCluster)
			
			--variable B
			local avgDistOutsideCluster
			
			if #partsOutsideCluster == 0 then
				avgDistOutsideCluster = 0
			else
				avgDistOutsideCluster = totalDistOutside/#partsOutsideCluster
			end
			
			local coef_formula = (avgDistOutsideCluster - avgDistInsideCluster)/math.max(avgDistInsideCluster, avgDistOutsideCluster)
			totalScore += coef_formula
			
		end
	end
	
	return totalScore/#parts
end

local function startKMeans(k)
	generateRandomPoints(partsModel, k)
	local closestCentroidForEveryPart, parts = getcoordinateMeanAndUpdateCentroid(k)
	-- closestCentroidForEveryPart = [centorid_1, centroid_2,...] (part instances)
	-- parts = [part1, part2, ...] (part instances)
	local score = silhouetteScore(closestCentroidForEveryPart, parts, k)
	
	--task.wait(3)
	--generateRockWithinRadius(closestCentroidForEveryPart, parts)
	return score
end


local maxK = 10

RepStorage.RemoteEvents.RemoteKmeans.OnServerEvent:Connect(function(plr)
	RepStorage.RemoteEvents.initGraph:FireAllClients(maxK)
	for k = 1, maxK, 1 do
		task.wait(2)
		local newCentroidFolder = Instance.new('Folder')
		newCentroidFolder.Parent = workspace
		newCentroidFolder.Name = 'centroidFolderK'..k
		
		centroidsFolderContainer[k] = newCentroidFolder
		local score = startKMeans(k)
		RepStorage.RemoteEvents.displayGraph:FireAllClients(score, k)
		print('silhouette score '..k..' :', score)

		
	end
end)
