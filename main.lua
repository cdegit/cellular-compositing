require "Cell"

imageData = {}
image = {}

image1Cells = {}
image2Cells = {}
image3Cells = {}

alert = ""

function love.load()
	--love.window.setMode(150, 150)

	imageData = generateEdgeImage(love.image.newImageData("church.jpg"))
	image = love.graphics.newImage(imageData)

	-- for i = 1, 10 do
	-- 	local tempCell = Cell.create(love.image.newImageData("space.png"))
	-- 	table.insert(image1Cells, tempCell)
	-- end

	-- for i = 1, 10 do
	-- 	local tempCell = Cell.create(love.image.newImageData("space2.png"))
	-- 	table.insert(image2Cells, tempCell)
	-- end

	-- for i = 1, 10 do
	-- 	local tempCell = Cell.create(love.image.newImageData("white.png"))
	-- 	table.insert(image3Cells, tempCell)
	-- end
end

function love.draw()

	love.graphics.print(alert, 0, 200)

	-- for i = 1, 10 do
	-- 	local tempCell = image1Cells[i]
	-- 	tempCell:move(love.image.newImageData("lion.png"))
	-- 	tempCell:paint(imageData)
	-- end

	-- for i = 1, 10 do
	-- 	local tempCell = image2Cells[i]
	-- 	tempCell:move(love.image.newImageData("lion.png"))
	-- 	tempCell:paint(imageData)
	-- end

	-- for i = 1, 10 do
	-- 	local tempCell = image3Cells[i]
	-- 	tempCell:move(love.image.newImageData("lion.png"))
	-- 	tempCell:paint(imageData)
	-- end


	image:refresh()
	love.graphics.draw(image, 0, 0)
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