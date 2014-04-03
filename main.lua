require "Cell"

imageData = {}
image = {}

moveImage = {}

image1Cells = {}
image2Cells = {}
image3Cells = {}

cellCount = 50
cellModel = {}

--how painted cells will move
moveType = ""

--default image to paint
paintImageData = love.image.newImageData("space.png")

collisionMatrix = {}

alert = ""

redFillMode = "line"
greenFillMode = "line"
blueFillMode = "line"
lionSelectedFill = 0

buttons = {}
buttons["red"] = {["x"] = 100, ["fillMode"] = "line", ["r"] = 255, ["g"] = 0, ["b"] = 0}
buttons["green"] = {["x"] = 220, ["fillMode"] = "line", ["r"] = 0, ["g"] = 255, ["b"] = 0}
buttons["blue"] = {["x"] = 160, ["fillMode"] = "line", ["r"] = 0, ["g"] = 0, ["b"] = 255}
--buttons["bright"] = {["x"] = 1, ["fillMode"] = "line"}
--buttons["dark"] = {["x"] = 1, ["fillMode"] = "line"}

buttonSpace = 10

mousedown = false

width = 500
height = 600

function love.load()

	love.window.setMode(width, height)

	imageData = love.image.newImageData("colors.png")
	image = love.graphics.newImage(imageData)
	moveImage = love.image.newImageData("colors.png")

	-- for use as a button
	lionImageData = love.image.newImageData("lion.png")
	lionImage = love.graphics.newImage(lionImageData)

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

	local lionX = 300
	local lionY = 510

	if mousedown then
		-- just add some cells for now

		-- check if user clicked a colour button
		if buttonY < love.mouse.getY() and love.mouse.getY() < buttonY + buttonHeight then
			-- red button
			if redButtonX < love.mouse.getX() and love.mouse.getX() < redButtonX + buttonWidth then
				-- set the button to a different fill style, change the movement type of the cell to be added
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

			for key, value in pairs(buttons) do
				value["fillMode"] = "line"
				if value["x"] < love.mouse.getX() and love.mouse.getX() < value["x"] + buttonWidth then
					value["fillMode"] = "fill"
					moveType = key
				end
			end

		-- check if user clicked the lion button
		elseif lionX <= love.mouse.getX() and  love.mouse.getX() <= lionX+50 and lionY <= love.mouse.getY() and  love.mouse.getY() <= lionY+50 then
			paintImageData = love.image.newImageData("lion.png")
			lionSelectedFill = 255

		-- check if the user is painting inside the image
		elseif 0 <= love.mouse.getX() and love.mouse.getX() <= width and 0 <= love.mouse.getY() and love.mouse.getY() <= height-100 then
			-- set paint image if it's set
			-- local tempCell

			local tempCell = Cell.create(paintImageData)

			if moveType ~= "" then
				tempCell.moveType = moveType
			end

			tempCell.drawType = "set"
			tempCell.id = table.getn(cellModel) + 1
			tempCell.x = math.round(love.mouse.getX() / 5) -- this needs to get mapped into the coordinate system for the image itself
			tempCell.y = math.round(love.mouse.getY() / 5)
			table.insert(cellModel, tempCell)

		-- if the user didn't click a button and isn't painting, reset to defaults
		else
				moveType = ""
				redFillMode = "line"
				greenFillMode = "line"
				blueFillMode = "line"
				paintImageData = love.image.newImageData("space.png")
				lionSelectedFill = 0
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

	-- draw colour buttons
	--love.graphics.setColor(255,0,0,255)
	--love.graphics.rectangle(redFillMode, redButtonX, buttonY, buttonWidth, buttonHeight)
	--love.graphics.setColor(0,255,0,255)
	--love.graphics.rectangle(greenFillMode, greenButtonX, buttonY, buttonWidth, buttonHeight)
	--love.graphics.setColor(0,0,255,255)
	--love.graphics.rectangle(blueFillMode, blueButtonX, buttonY, buttonWidth, buttonHeight)

	for key, value in pairs(buttons) do
		love.graphics.setColor(value["r"], value["g"], value["b"], 255)
		love.graphics.rectangle(value["fillMode"], value["x"], buttonY, buttonWidth, buttonHeight)
	end

	-- reset colours
	love.graphics.setColor(255,255,255,255)

	-- lion button
	love.graphics.push()
	love.graphics.scale(0.5)
	love.graphics.draw(lionImage, lionX*2, lionY*2)
	love.graphics.pop()

	-- lion button selected or not
	love.graphics.setColor(255,255,255,lionSelectedFill)
	love.graphics.rectangle("line", lionX, lionY, 50, 50)

	-- reset colours
	love.graphics.setColor(255,255,255, 255)

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


-- takes newImageData object as a parameter
function generateEdgeImage(image)
	-- create a copy of the image to return
	resultImage = image

	-- for each pixel
	for x = 2, 98, 1 do
		for y = 2, 98, 1 do
			-- set channel totals to 0 for each pixel
			rTotal = 0
			gTotal = 0
			bTotal = 0

			-- for the 3x3 kernel
			for i = -1, 1, 1 do
				for j = -1, 1, 1 do

					pixelX = x+i
					pixelY = y+j

					-- get the R G B values of the kernel's current pixel
					newR, newG, newB = image:getPixel(pixelX, pixelY)

					newR = newR/255
					newG = newG/255
					newB = newB/255

					-- if it's the middle pixel, multiply by 8
					if i==0 and j==0 then
						newR = newR * 8
						newG = newG * 8
						newB = newB * 8
					-- for the other pixels, multiply by -1
					else
						newR = newR * (-1)
						newG = newG * (-1)
						newB = newB * (-1)
					end
					-- add all the result values together
					rTotal = rTotal + newR
					gTotal = gTotal + newG
					bTotal = bTotal + newB
				end
			end

			-- make sure the values don't clip
			rTotal = (math.clamp(rTotal, 0, 1))*255
			gTotal = (math.clamp(gTotal, 0, 1))*255
			bTotal = (math.clamp(bTotal, 0, 1))*255
			-- alert = bTotal

			-- set the current pixel
			resultImage:setPixel(x, y, rTotal*255, gTotal*255, bTotal*255)
		end
	end
	return resultImage
end