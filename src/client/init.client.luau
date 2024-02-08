--// Services
local UIS = game:GetService("UserInputService")

--// Directories

--// Variables
local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local tetrisHolder = playerGui:WaitForChild("Tetris").Holder

local squareSize = 35
local spaceSize = 2

local futureX = 0
local futureY = 0

local gridWidth = 10
local gridHeight = 20
local yDifference = gridHeight / 0.075
local currentShape = nil

--// Functions
function validateMove(futureXPos: number, futureYPos: number)
    if futureXPos <= -185 or futureXPos >= 185  then
        return false
    elseif futureYPos >= 628 then
        return false
    else
        return true
    end
end

function onInputBegan(input, _gameProcessed)
    currentShape = tetrisHolder.Sample

	if input.UserInputType == Enum.UserInputType.Keyboard and currentShape then
        if input.KeyCode == Enum.KeyCode.A then
            futureX = currentShape.Position.X.Offset - (squareSize + spaceSize)
           -- currentShape.Position = UDim2.new(.5, currentShape.Position.X.Offset - (squareSize + spaceSize), 0, currentShape.Position.Y.Offset)
            print("A pressed")
        elseif input.KeyCode == Enum.KeyCode.D then
            futureX = currentShape.Position.X.Offset + (squareSize + spaceSize)
           -- currentShape.Position = UDim2.new(.5, currentShape.Position.X.Offset + (squareSize + spaceSize), 0, currentShape.Position.Y.Offset)
            print("D pressed")
        elseif input.KeyCode == Enum.KeyCode.S then
            futureY = currentShape.Position.Y.Offset + squareSize + spaceSize
           -- currentShape.Position = UDim2.new(.5, 0, 0, currentShape.Position.Y.Offset + squareSize + spaceSize)
            print("D pressed")
        end

        if not validateMove(futureX, futureY) then return end
        currentShape.Position = UDim2.new(.5, futureX, 0, futureY)
        print(currentShape.Position.X.Offset)
	end
end

--// Events
UIS.InputBegan:Connect(onInputBegan)
