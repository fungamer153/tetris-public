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

local currentColor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
local blockSize = 20 -- Adjust the size of each cell
local gridWidth = Frame.Size.X.Offset / blockSize
local gridHeight = Frame.Size.Y.Offset / blockSize

local grid = {}
local currentAngle = 0
local shape

local gameRunning = true
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
	};

    L_Block = {		
		Pivot = {2, 2};
		
		[0] = {
			{1, 0, 0},
			{1, 1, 1},
			{0, 0, 0}	
		};
		
		[90] = {
			{0, 1, 0},
			{0, 1, 0},
			{1, 1, 0}	
		};
		
		[180] = {
			{0, 0, 0},
			{1, 1, 1},
			{0, 0, 1}	
		};
		
		[270] = {
			{0, 1, 1},
			{0, 1, 0},
			{0, 1, 0}	
		};
	};

    O_Block = {		
		Pivot = {2, 2};
		
		[0] = {
			{0, 1, 1},
			{0, 1, 1},
			{0, 0, 0}	
		};
		
		[90] = {
			{0, 1, 1},
			{0, 1, 1},
			{0, 0, 0}	
		};
		
		[180] = {
			{0, 1, 1},
			{0, 1, 1},
			{0, 0, 0}	
		};
		
		[270] = {
			{0, 1, 1},
			{0, 1, 1},
			{0, 0, 0}	
		};
	};
}

local pastColorsTable = {}

local function createCell(x, y, value)
	local pastColor = pastColorsTable[x + y]
	local cell = Instance.new("Frame")
	cell.Size = UDim2.new(0, blockSize, 0, blockSize)
	cell.BorderSizePixel = 0
	cell.Position = UDim2.new(0, x * blockSize, 0, y * blockSize)
	cell.BackgroundTransparency = 0.5
	cell.Parent = Frame

	print(value)
	if value == 2 then
		cell.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	elseif value == 1 then
		cell.BackgroundColor3 = currentColor
	end

	return cell
end

function randomBlock()
    local fakeTable = {}

    for block,_ in shapes do
        table.insert(fakeTable, block)
    end

    return shapes[fakeTable[math.random(1, #fakeTable)]]
end

function clearGrid()
	for _, child in pairs(Frame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

function updateGrid(grid)
	clearGrid()
		
	for y = 1, #grid do
		for x = 1, #grid[y] do
			if grid[y][x] == 1 or grid[y][x] == 2 then
				createCell(x - 1, gridHeight - y, grid[y][x])
			end
		end
	end
end

function generateTBlock(grid, X, Y)
	if X then startX = X end
	if Y then startY = Y end
	
	-- Set default values if not provided
	local rotatedShape = shape[currentAngle]
	local blockWidth = #rotatedShape[1]
	local blockHeight = #rotatedShape
	local xFill = shape["Pivot"][1]
    local yFill = shape["Pivot"][2]

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
            if startY - y + yFill > 0 and rotatedShape[y][x] ~= 0 then
                grid[startY - y + yFill][startX - x + xFill] = rotatedShape[y][x]                
            end
		end
	end
	
	updateGrid(grid)
end

local function rotateBlock(grid)
	local canRotate = true
	currentAngle += 90

	if currentAngle == 360 then
		currentAngle = 0
	end
	
	if startX == 1 then
		startX = 2
	elseif startX == math.round(gridWidth) then
		startX = math.round(gridWidth) - 1
	end

	if canRotate then
		generateTBlock(grid, startX, startY)
	end
end


function moveBlockLeft(grid)
	local rotatedShape = shape[currentAngle]
	local canMove = true

	local rotatedShape = shape[currentAngle]
	local blockWidth = #rotatedShape[1]
	local blockHeight = #rotatedShape

	local differenceY = blockHeight - shape["Pivot"][1]
	local differenceX = blockWidth - shape["Pivot"][1]
    local leftCorner = {startY + differenceY, startX - differenceX}

	for x = 1, blockWidth do		
		for y = 1, blockHeight do
			local xShift = leftCorner[2] + (x - 1)
			local value = grid[leftCorner[1] - (y - 1)][xShift]
			if value == 1 and xShift <= 1 then
				canMove = false
				break
			end
		end
	end

	if canMove then
		generateTBlock(grid, startX - 1, startY)
	end	
end

local function moveBlockRight(grid)
	local canMove = true
	local rotatedShape = shape[currentAngle]
	local blockWidth = #rotatedShape[1]
	local blockHeight = #rotatedShape
	
	local differenceY = blockHeight - shape["Pivot"][1]
	local differenceX = blockWidth - shape["Pivot"][1]
    local rightCorner = {startY + differenceY, startX + differenceX}

	for x = 1, blockWidth do		
		for y = 1, blockHeight do
			local xShift = rightCorner[2] - (x - 1)
			local value = grid[rightCorner[1] - (y - 1)][xShift]
			if value == 1 and xShift >= math.round(gridWidth) then
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

    for y = 1, blockHeight do
        for x = 1, blockWidth do
            if rightCorner[1] + (y - 1) > 0 then
                local value = grid[rightCorner[1] + (y - 1)][rightCorner[2] - (x - 1)]

                if (value == 1 and rightCorner[1] + (y - 1) == 1) then
                    canMoveDown = false
                elseif value == 1 then
                    if grid[(rightCorner[1] + (y - 1)) - 1][rightCorner[2] - (x - 1)] == 2 then
                        canMoveDown = false
                    end
                end 
            end
        end
    end

    -- Move the block down if it can
    if canMoveDown then
        generateTBlock(grid, startX, startY - 1, true) -- Clear the block at the previous position
    else
        print("Reached bottom")
		if startY >= 18 then gameRunning = false return end

		for y = 1, gridHeight do
            for x = 1, gridWidth do
                if grid[y][x] == 1 then
                    grid[y][x] = 2
					pastColorsTable[x + y] = Color3.new(currentColor.R, currentColor.G, currentColor.B)
                end
            end
        end
		
		startX = 5
        startY = 18

		print(pastColorsTable)
        -- Block reached the bottom, respawn at the top
		currentColor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
        shape = randomBlock()
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

for y = 1, gridHeight do
	grid[y] = {}
	for x = 1, gridWidth do
		grid[y][x] = 0
	end
end

--shape = shapes["T_Block"]
shape = randomBlock()
generateTBlock(grid)

while gameRunning do
	task.wait(.5)
	moveBlockDown(grid)
end
