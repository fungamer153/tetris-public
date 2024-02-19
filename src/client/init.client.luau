--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

--// Directories
local player: Player = Players.LocalPlayer

--// Variables
local currentColor: Color3 = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
local blockSize: IntValue = 20 -- Adjust the size of each cell
local gridWidth: IntValue
local gridHeight: IntValue

local Frame: Frame
local grid: table = {}
local currentAngle: IntValue = 0
local shape: table

local gameRunning: boolean = true
local startX: IntValue = 5
local startY: IntValue = 18

--// Shapes
local shapes: table = {
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

--// Functions

-- Creates new block
function createVisualGrid()
	local ScreenGui: ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Parent = player.PlayerGui

	Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(0, 220, 0, 440) -- Adjust the size of the game board
	Frame.Position = UDim2.new(0.5, 0, 0.5, 0) -- Center the frame
	Frame.AnchorPoint = Vector2.new(.5, .5)
	Frame.BackgroundTransparency = 0.5
	Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Frame.Parent = ScreenGui

	gridWidth = Frame.Size.X.Offset / blockSize
    gridHeight = Frame.Size.Y.Offset / blockSize

	for y: IntValue = 1, gridHeight do
		grid[y] = {}
		for x: IntValue = 1, gridWidth do
			grid[y][x] = 0
		end
	end

	shape = randomBlock()
	generateBlock(grid)
end

function createCell(x: IntValue, y: IntValue, value: IntValue)
	local cell = Instance.new("Frame")
	cell.Size = UDim2.new(0, blockSize, 0, blockSize)
	cell.BorderSizePixel = 0
	cell.Position = UDim2.new(0, x * blockSize, 0, y * blockSize)
	cell.BackgroundTransparency = 0.5
	cell.Parent = Frame

	if value == 2 then
		cell.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	elseif value == 1 then
		cell.BackgroundColor3 = currentColor
	end

	return cell
end

-- Get a new random shape
function randomBlock()
    local fakeTable = {}

    for block,_ in shapes do
        table.insert(fakeTable, block)
    end

    return shapes[fakeTable[math.random(1, #fakeTable)]]
end

-- Clears the whole grid
function clearGrid()
	for _, child in pairs(Frame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

-- Visualizes the grid from table to UI
function updateGrid(grid: table)
	clearGrid()
		
	for y = 1, #grid do
		for x = 1, #grid[y] do
			if grid[y][x] == 1 or grid[y][x] == 2 then
				createCell(x - 1, gridHeight - y, grid[y][x])
			end
		end
	end
end

-- Creates a new movable block object
function generateBlock(grid: table, x: IntValue, y: IntValue)
	if x then startX = x end
	if y then startY = y end
	
	-- Set default values if not provided
	local rotatedShape: table = shape[currentAngle]
	local blockWidth: IntValue = #rotatedShape[1]
	local blockHeight: IntValue = #rotatedShape
	local xFill: IntValue = shape["Pivot"][1]
    local yFill: IntValue = shape["Pivot"][2]

	-- Clear the entire grid
	for y: IntValue = 1, gridHeight do
		for x: IntValue = 1, gridWidth do
			if grid[y][x] ~= 2 then
				grid[y][x] = 0
			end
		end
	end

	-- Draw the new shape
	for y: IntValue = 1, blockHeight do
		for x: IntValue = 1, blockWidth do
            if startY - y + yFill > 0 and rotatedShape[y][x] ~= 0 then
                grid[startY - y + yFill][startX - x + xFill] = rotatedShape[y][x]                
            end
		end
	end
	
	updateGrid(grid)
end

-- Rotate the current shape
function rotateBlock(grid: table)
	local canRotate: boolean = true
	currentAngle += 90

	if currentAngle == 360 then
		currentAngle = 0
	end
	
	-- If we are trying to rotate too close to the border then bounce back the block
	if startX == 1 then
		startX = 2
	elseif startX == math.round(gridWidth) then
		startX = math.round(gridWidth) - 1
	end

	if canRotate then
		generateBlock(grid, startX, startY)
	end
end

-- Move blocks
function moveBlockLeft(grid: table)
	local canMove: boolean = true

	local rotatedShape: table = shape[currentAngle]
	local blockWidth: IntValue = #rotatedShape[1]
	local blockHeight: IntValue = #rotatedShape

	-- Getting the pivot point
	local differenceY: IntValue = blockHeight - shape["Pivot"][1]
	local differenceX: IntValue = blockWidth - shape["Pivot"][1]
    local leftCorner: table = {startY + differenceY, startX - differenceX}

	for x: IntValue = 1, blockWidth do		
		for y: IntValue = 1, blockHeight do
			local xShift: IntValue = leftCorner[2] + (x - 1)
			local value: IntValue = grid[leftCorner[1] - (y - 1)][xShift]

			if value == 1 and xShift <= 1 then
				canMove = false
				break
			end
		end
	end

	if canMove then
		generateBlock(grid, startX - 1, startY)
	end	
end

-- Move blocks
function moveBlockRight(grid: table)
	local canMove: boolean = true
	local rotatedShape: table = shape[currentAngle]
	local blockWidth: IntValue = #rotatedShape[1]
	local blockHeight: IntValue = #rotatedShape

	-- Getting the pivot point
	local differenceY: IntValue = blockHeight - shape["Pivot"][1]
	local differenceX: IntValue = blockWidth - shape["Pivot"][1]
    local rightCorner: table = {startY + differenceY, startX + differenceX}

	for x: IntValue = 1, blockWidth do		
		for y: IntValue = 1, blockHeight do
			local xShift: IntValue = rightCorner[2] - (x - 1)
			local value: IntValue = grid[rightCorner[1] - (y - 1)][xShift]

			if value == 1 and xShift >= math.round(gridWidth) then
				canMove = false
				break
			end
		end
	end
		
	if canMove then
		generateBlock(grid, startX + 1, startY)
	end	
end

-- Shift block down
function moveBlockDown(grid: table)
	local rotatedShape: table = shape[currentAngle]
    local canMoveDown: boolean = true
	
	local blockWidth: IntValue = #rotatedShape[1]
	local blockHeight: IntValue = #rotatedShape
	
	local differenceY: IntValue = blockHeight - shape["Pivot"][1]
	local differenceX: IntValue = blockWidth - shape["Pivot"][1]
    local rightCorner: IntValue = {startY - differenceY, startX + differenceX}

    for y: IntValue = 1, blockHeight do
        for x: IntValue = 1, blockWidth do
            if rightCorner[1] + (y - 1) > 0 then
                local value: IntValue = grid[rightCorner[1] + (y - 1)][rightCorner[2] - (x - 1)]

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
        generateBlock(grid, startX, startY - 1, true) -- Clear the block at the previous position
    else
        print("Reached bottom")
		if startY >= 18 then gameRunning = false return end

		for y: IntValue = 1, gridHeight do
			local fullRow: boolean = true
			
			-- Turn any current moving blocks to placed blocks
            for x: IntValue = 1, gridWidth do
                if grid[y][x] == 1 then
                    grid[y][x] = 2
				elseif grid[y][x] == 0 then
					-- If a row has 0 gaps then It's full to remove
					fullRow = false
                end
            end

			if fullRow then
				-- Go up in each row to move each block down by 1 row
				for x: IntValue = 1, gridWidth do
					if grid[y][x] == 2 then
						grid[y][x] = 0
						
						for falseY: IntValue = 1, (gridHeight - y) - 1 do
							if grid[y + falseY][x] then
								if grid[y + falseY][x] == 2 or grid[y + falseY][x] == 1 then
									grid[y + falseY][x] = 0
									grid[y + (falseY - 1)][x] = 2
								end
							end
						end
					end
				end
			end
        end
		
		-- Reset the position for the next block
		startX = 5
        startY = 18

        -- Block reached the bottom, respawn at the top
		currentColor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
        shape = randomBlock()
        generateBlock(grid)
    end
end

function handleKeyPress(input)
	if input.KeyCode == Enum.KeyCode.A then
		moveBlockLeft(grid)
	elseif input.KeyCode == Enum.KeyCode.D then
		moveBlockRight(grid)
	end
	
	if input.KeyCode == Enum.KeyCode.W then
		rotateBlock(grid)
	end
end

--// Events
createVisualGrid()
UserInputService.InputBegan:Connect(handleKeyPress)

while gameRunning do
	task.wait(.5)
	moveBlockDown(grid)
end
