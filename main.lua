require "Cell"

imageData = {}
image = {}

image1Cells = {}
image2Cells = {}
image3Cells = {}

cellCount = 5
cellModel = {}

collisionMatrix = {}

alert = ""

function love.load()
	love.window.setMode(500, 600)

	imageData = love.image.newImageData("colors.png")
	image = love.graphics.newImage(imageData)
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
		if tempCell ~= NULL then
			tempCell:move(love.image.newImageData("colors.png"), collisionMatrix, cellModel)
			tempCell:paint(imageData)
			alert = alert .. tempCell.id
			alert = alert .. "\n"
		end
	end

	image:refresh()
	love.graphics.draw(image, 0, 0)
	love.graphics.pop()

	love.graphics.print(alert, 0, 500)
	alert = ""
end