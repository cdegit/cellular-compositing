require "Cell"

imageData = {}
image = {}

image1Cells = {}
image2Cells = {}
image3Cells = {}

currentCellId = 1
collisionMatrix = {}

alert = ""

function love.load()
	--love.window.setMode(150, 150)

	imageData = love.image.newImageData("colors.png")
	image = love.graphics.newImage(imageData)

	for i = 1, 10 do
		local tempCell = Cell.create(love.image.newImageData("space.png"))
		tempCell.id = currentCellId
		currentCellId = currentCellId + 1
		table.insert(image1Cells, tempCell)
	end

	for i = 1, 10 do
		local tempCell = Cell.create(love.image.newImageData("space2.png"))
		tempCell.id = currentCellId
		currentCellId = currentCellId + 1		
		table.insert(image2Cells, tempCell)
	end

	for i = 1, 10 do
		local tempCell = Cell.create(love.image.newImageData("white.png"))
		tempCell.id = currentCellId
		currentCellId = currentCellId + 1		
		table.insert(image3Cells, tempCell)
	end

	for x = 1, 100 do
		collisionMatrix[x] = {}
		for y = 1, 100 do 
			collisionMatrix[x][y] = 0
		end
	end
end

function love.draw()

	love.graphics.print(alert, 0, 200)

	for i = 1, 10 do
		local tempCell = image1Cells[i]
		tempCell:move(love.image.newImageData("colors.png"), collisionMatrix)
		tempCell:paint(imageData)
	end

	for i = 1, 10 do
		local tempCell = image2Cells[i]
		tempCell:move(love.image.newImageData("colors.png"), collisionMatrix)
		tempCell:paint(imageData)
	end

	for i = 1, 10 do
		local tempCell = image3Cells[i]
		tempCell:move(love.image.newImageData("colors.png"), collisionMatrix)
		tempCell:paint(imageData)
	end


	image:refresh()
	love.graphics.draw(image, 0, 0)
end