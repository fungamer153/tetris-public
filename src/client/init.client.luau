-- Tetris UI Script

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player.PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 440) -- Adjust the size of the game board
Frame.Position = UDim2.new(0.5, 0, 0.5, 0) -- Center the frame
Frame.AnchorPoint = Vector2.new(.5, .5)
Frame.BackgroundTransparency = 0.5
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.Parent = ScreenGui

local blockSize = 20 -- Adjust the size of each cell
local gridWidth = Frame.Size.X.Offset / blockSize
local gridHeight = Frame.Size.Y.Offset / blockSize

local grid = {}
local currentAngle = 0

local startX = 5
local startY = 18

local shapes = {
	T_Block = {		
		Pivot = {2, 2};
		
		[0] = {
			{0, 1, 0},
			{1, 1, 1},
			{0, 0, 0}	
		};
		
		[90] = {
			{0, 1, 0},
			{1, 1, 0},
			{0, 1, 0}	
		};
		
		[180] = {
			{0, 0, 0},
			{1, 1, 1},
			{0, 1, 0}	
		};
		
		[270] = {
			{0, 1, 0},
			{0, 1, 1},
			{0, 1, 0}	
		};
	}
}

local shape = shapes["T_Block"]

local function createCell(x, y)
	local cell = Instance.new("TextLabel")
	cell.Size = UDim2.new(0, blockSize, 0, blockSize)
	cell.Position = UDim2.new(0, x * blockSize, 0, y * blockSize)
	cell.BackgroundTransparency = 0.5
	cell.BackgroundColor3 = Color3.new(1, 1, 1)
	cell.Parent = Frame
	return cell
end

local function clearGrid()
	for _, child in pairs(Frame:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
end

local function updateGrid(grid)
	clearGrid()
		
	for y = 1, #grid do
		for x = 1, #grid[y] do
			if grid[y][x] == 1 or grid[y][x] == 2 then
				createCell(x - 1, gridHeight - y)
			end
		end
	end
end

local function generateTBlock(grid, X, Y)
	if X then startX = X end
	if Y then startY = Y end
	
	-- Set default values if not provided
	local rotatedShape = shape[currentAngle]
	local blockWidth = #rotatedShape[1]
	local blockHeight = #rotatedShape
	local xFill = shape["Pivot"][1]
		
	-- Clear the entire grid
	for y = 1, gridHeight do
		for x = 1, gridWidth do
			if grid[y][x] ~= 2 then
				grid[y][x] = 0
			end
		end
	end
		
	-- Draw the new shape
	for y = 1, blockHeight do
		for x = 1, blockWidth do
			grid[startY + y][startX - x + xFill] = rotatedShape[y][x]
		--	print(grid[startY + y][startX - x + xFill], startY + y)
		end
	end
	
	--for y = 1, blockHeight do
	--	for x = 1, blockWidth do
	--		grid[(startY + y) - 1][startX + x - 1] = shape[blockHeight - (y - 1)][x]
	--	end
	--end
	
	updateGrid(grid)
end

local function rotateBlock(grid)
	--local startX, startY = findTBlockPosition(grid)

	-- Find the center of the shape

	-- Copy the current shape to a temporary variable
	currentAngle += 90
	if currentAngle == 360 then
		currentAngle = 0
	end
	
	if startX == 1 then
		startX = 2
	elseif startX == math.round(gridWidth) then
		startX = math.round(gridWidth) - 1
	end
	
	--local rotatedShape = shapes["T_Block"][currentAngle]
	-- Calculate the new starting position after rotation
	--local newStartX = math.max(1, math.min(gridWidth - #rotatedShape[1] + 1, startX))
	--local newStartY = math.max(1, math.min(gridHeight - #rotatedShape + 1, startY))

	-- Check if the rotated shape can fit in the grid
	local canRotate = true
	--for y = 1, #rotatedShape do
	--	for x = 1, #rotatedShape[1] do
	--		if rotatedShape[y][x] == 1 then
	--			--if newStartX + x - 1 < 1 or newStartX + x - 1 > gridWidth or newStartY + y - 1 > gridHeight then
	--			--	canRotate = false
	--			--	break
	--			--elseif grid[newStartY + y - 1][newStartX + x - 1] == 1 then
	--			--	canRotate = false
	--			--	break
	--			--end
	--		end
	--	end
	--	if not canRotate then
	--		break
	--	end
	--end
		
	-- Rotate the block if it can fit in the grid
	if canRotate then
		--	generateTBlock(grid, startX, startY, true) -- Clear the block at the previous position
		--shape = rotatedShape
		generateTBlock(grid, startX, startY)
	end
end


local function moveBlockLeft(grid)
	local rotatedShape = shape[currentAngle]
	local canMove = true

	local rotatedShape = shape[currentAngle]
	local blockWidth = #rotatedShape[1]
	local blockHeight = #rotatedShape

	local differenceY = blockHeight - shape["Pivot"][1]
	local differenceX = blockWidth - shape["Pivot"][1]

	for i = 1, blockHeight do		
		for x = 1, blockWidth do
			local leftCorner = {startY + differenceY, startX - differenceX + (x - 1)}
			local value = grid[leftCorner[1] + (i - 1)][leftCorner[2]] 

			if value == 1 and leftCorner[2] <= 1 then
				canMove = false
				break
			end
		end
	end

	if canMove then
		generateTBlock(grid, startX - 1, startY)
		--generateTBlock(grid, startX - 2, startY, true) -- Clear the block at the previous position
	end	
end

local function moveBlockRight(grid)
	local rotatedShape = shape[currentAngle]
	local canMove = true
	
	local rotatedShape = shape[currentAngle]
	local blockWidth = #rotatedShape[1]
	local blockHeight = #rotatedShape
	
	local differenceY = blockHeight - shape["Pivot"][1]
	local differenceX = blockWidth - shape["Pivot"][1]
		
	for i = 1, blockHeight do		
		for x = 1, blockWidth do
			local rightCorner = {startY + differenceY, startX + differenceX - (x - 1)}
			local value = grid[rightCorner[1] + (i - 1)][rightCorner[2]] 

			if value == 1 and rightCorner[2] >= math.round(gridWidth) then
				canMove = false
				break
			end
		end
	end
		
	if canMove then
		generateTBlock(grid, startX + 1, startY)
	end	
end

local function moveBlockDown(grid)
	local rotatedShape = shape[currentAngle]
    local canMoveDown = true
	
	local blockWidth = #rotatedShape[1]
	local blockHeight = #rotatedShape
	
	local differenceY = blockHeight - shape["Pivot"][1]
	local differenceX = blockWidth - shape["Pivot"][1]
    local rightCorner = {startY - differenceY, startX + differenceX}

	for i = 1, blockHeight do		
		for x = 1, blockWidth do
			local value = grid[rightCorner[1] + (i - 1)][rightCorner[2] - (x - 1)] 

			if value == 1 and rightCorner[2] <= 1 then
				canMoveDown = false
				break
			end
		end
	end
	
	--print(canMoveDown)
    -- Move the block down if it can
    if canMoveDown then
        generateTBlock(grid, startX, startY - 1, true) -- Clear the block at the previous position
    else
        -- Block reached the bottom, respawn at the top
        generateTBlock(grid)
    end
end

local function handleKeyPress(input)
	if input.KeyCode == Enum.KeyCode.A then
		moveBlockLeft(grid)
	elseif input.KeyCode == Enum.KeyCode.D then
		moveBlockRight(grid)
	end
	
	if input.KeyCode == Enum.KeyCode.W then
		rotateBlock(grid)
	end
end

UserInputService.InputBegan:Connect(handleKeyPress)

--function findTBlockPosition(grid)
--	local pivot = shape["Pivot"]
--	local reconstructedShape = {}
	
--	for y = 1, gridHeight do
--		for x = 1, gridWidth do
--			if grid[y][x] == 1 then
--				reconstructedShape[#reconstructedShape + 1] = {}
--				--return x, y
--			end
--		end
--	end
--end

-- Initialize the grid and spawn a T-shaped block

for y = 1, gridHeight do
	grid[y] = {}
	for x = 1, gridWidth do
		grid[y][x] = 0
	end
end

generateTBlock(grid)

while task.wait(.5) do
	moveBlockDown(grid)
end

-- Uncomment the line below if you want to update the grid periodically
-- game:GetService("RunService").Heartbeat:Connect(function() update() end)
