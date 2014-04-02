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

mousedown = false

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
	-- handle mouse dragging
	if mousedown then
		-- just add some cells for now
		local tempCell = Cell.create(love.image.newImageData("space.png"))
		tempCell.drawType = "set"
		tempCell.id = table.getn(cellModel) + 1
		tempCell.x = math.round(love.mouse.getX() / 5) -- this needs to get mapped into the coordinate system for the image itself
		tempCell.y = math.round(love.mouse.getY() / 5)
		table.insert(cellModel, tempCell)
	end

	-- scale the image so it's easier to see
	love.graphics.push()
	love.graphics.scale(5)

	local actualCells = 0

	for i = 1, table.getn(cellModel) do
		local tempCell = cellModel[i]
		if tempCell ~= -1 then
			tempCell:move(moveImage, collisionMatrix, cellModel)
			tempCell:paint(imageData)
			actualCells = actualCells + 1
		end
	end

	image:refresh()
	love.graphics.draw(image, 0, 0)
	love.graphics.pop()

	love.graphics.circle("line", love.mouse.getX(), love.mouse.getY(), 10, 100)

	alert = actualCells .. " / " .. table.getn(cellModel)
	love.graphics.print(alert, 0, 500)
end

function love.mousepressed(x, y, button)
	if button == "l" then
		mousedown = true
	end
end

function love.mousereleased(x, y, button)
	if button == "l" then
		mousedown = false
	end
end