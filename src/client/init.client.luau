--// Services
local UIS = game:GetService("UserInputService")

--// Directories

--// Variables
local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local tetrisHolder = playerGui:WaitForChild("Tetris").Holder

local squareSize = 35
local spaceSize = 2
local lastMove = 0

local futureX = 0
local futureY = 55
local currentShape = nil

--// Functions
function validateMove(futureXPos: number, futureYPos: number)
    if futureXPos <= -148 or futureXPos >= 185  then
        return false
    elseif futureYPos >= 684 then
        return false
    else
        return true
    end
end

function rotateShape()
    currentShape.Rotation = currentShape.Rotation + 90
end

function onInputBegan(input, _gameProcessed)
    currentShape = tetrisHolder.Sample

	if input.UserInputType == Enum.UserInputType.Keyboard and currentShape then
        lastMove = tick()

        if input.KeyCode == Enum.KeyCode.A then
            futureX = currentShape.Position.X.Offset - (squareSize + spaceSize)
        elseif input.KeyCode == Enum.KeyCode.D then
            futureX = currentShape.Position.X.Offset + (squareSize + spaceSize)
        elseif input.KeyCode == Enum.KeyCode.S then
            futureY = currentShape.Position.Y.Offset + squareSize + spaceSize
        elseif input.KeyCode == Enum.KeyCode.W then
            rotateShape()
        else
            return
        end

        if not validateMove(futureX, futureY) then return end
        currentShape.Position = UDim2.new(.45, futureX, 0, futureY)
        print(currentShape.Position.X.Offset)
	end
end

--// Events
UIS.InputBegan:Connect(onInputBegan)

while task.wait(.5) do
    if currentShape and tick() - lastMove > .5 then
        if not validateMove(futureX, futureY) then return end
        futureY = currentShape.Position.Y.Offset + squareSize + spaceSize
        currentShape.Position = UDim2.new(.45, futureX, 0, futureY)
    end
end
