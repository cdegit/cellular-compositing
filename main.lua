require "Cell"

imageData = {}
image = {}

moveImage = {}

image1Cells = {}
image2Cells = {}
image3Cells = {}

cellCount = 50
cellModel = {}

collisionMatrix = {}

alert = ""

function love.load()
	love.window.setMode(500, 600)

	imageData = love.image.newImageData("colors.png")
	image = love.graphics.newImage(imageData)
	moveImage = love.image.newImageData("colors.png")

	-- to fix blurry image scaling
	image:setFilter( 'nearest', 'nearest' )

	for i = 1, cellCount do
		local img = love.image.newImageData("space.png")
		if i > 10 and i <= 20 then
			img = love.image.newImageData("space2.png")
		end
		if i > 20 then
			img = love.image.newImageData("white.png")
		end

		local tempCell = Cell.create(img)
		tempCell.id = i
		table.insert(cellModel, tempCell)
	end

	for x = 1, 101 do
		collisionMatrix[x] = {}
		for y = 1, 101 do
			collisionMatrix[x][y] = 0
		end
	end
end

function love.draw()
	-- scale the image so it's easier to see
	love.graphics.push()
	love.graphics.scale(5)

	for i = 1, table.getn(cellModel) do
		local tempCell = cellModel[i]
		if tempCell ~= -1 then
			tempCell:move(moveImage, collisionMatrix, cellModel)
			tempCell:paint(imageData)
		end
	end

	image:refresh()
	love.graphics.draw(image, 0, 0)
	love.graphics.pop()

	love.graphics.print(alert, 0, 500)
	alert = table.getn(cellModel)
end