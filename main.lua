require "Cell"

imageData = {}
image = {}

moveImage = {}

image1Cells = {}
image2Cells = {}
image3Cells = {}

cellCount = 50
cellModel = {}

moveType = ""

collisionMatrix = {}

alert = ""

redFillMode = "line"
greenFillMode = "line"
blueFillMode = "line"

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

		-- local tempCell = Cell.create(img)
		-- tempCell.id = i
		-- table.insert(cellModel, tempCell)
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

	local buttonY = 510
	local buttonWidth = 50
	local buttonHeight = 25

	local redButtonX = 100
	local greenButtonX = 220
	local blueButtonX = 160

	if mousedown then
		-- just add some cells for now

		-- check if user clicked a button
		if buttonY < love.mouse.getY() and love.mouse.getY() < buttonY + buttonHeight then
			-- red button
			if redButtonX < love.mouse.getX() and love.mouse.getX() < redButtonX + buttonWidth then
				moveType = "red"
				redFillMode = "fill"
				greenFillMode = "line"
				blueFillMode = "line"
			end
			-- green button
			if greenButtonX < love.mouse.getX() and love.mouse.getX() < greenButtonX + buttonWidth then
				moveType = "green"
				redFillMode = "line"
				greenFillMode = "fill"
				blueFillMode = "line"
			end
			-- blue button
			if blueButtonX < love.mouse.getX() and love.mouse.getX() < blueButtonX + buttonWidth then
				moveType = "blue"
				redFillMode = "line"
				greenFillMode = "line"
				blueFillMode = "fill"
			end

		-- check if the user is painting inside the image
		elseif 0 <= love.mouse.getY() and love.mouse.getY() <= 500 and 0 <= love.mouse.getX() and love.mouse.getX() <= 500 then
			local tempCell = Cell.create(love.image.newImageData("space.png"))

			if moveType ~= "" then
				tempCell.moveType = moveType
			end

			tempCell.drawType = "set"
			tempCell.id = table.getn(cellModel) + 1
			tempCell.x = math.round(love.mouse.getX() / 5) -- this needs to get mapped into the coordinate system for the image itself
			tempCell.y = math.round(love.mouse.getY() / 5)
			table.insert(cellModel, tempCell)

		-- if the user didn't click a button and isn't painting, reset the selection
		else
				moveType = ""
				redFillMode = "line"
				greenFillMode = "line"
				blueFillMode = "line"
		end
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

	-- draw buttons
	love.graphics.setColor(255,0,0,255)
	love.graphics.rectangle(redFillMode, redButtonX, buttonY, buttonWidth, buttonHeight)
	love.graphics.setColor(0,255,0,255)
	love.graphics.rectangle(greenFillMode, greenButtonX, buttonY, buttonWidth, buttonHeight)
	love.graphics.setColor(0,0,255,255)
	love.graphics.rectangle(blueFillMode, blueButtonX, buttonY, buttonWidth, buttonHeight)
	-- reset colours after drawing buttons
	love.graphics.setColor(255,255,255,255)

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