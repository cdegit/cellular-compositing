require "Cell"

imageData = {}
image = {}

image1Cells = {}
image2Cells = {}
image3Cells = {}

function love.load() 
	love.window.setMode(150, 150)

	imageData = love.image.newImageData(100, 100)
	image = love.graphics.newImage(imageData)

	for i = 1, 10 do
		local tempCell = Cell.create(love.image.newImageData("space.png"))
		table.insert(image1Cells, tempCell)
	end

	for i = 1, 10 do
		local tempCell = Cell.create(love.image.newImageData("space2.png"))
		table.insert(image2Cells, tempCell)
	end	

	for i = 1, 10 do
		local tempCell = Cell.create(love.image.newImageData("lion.png"))
		table.insert(image3Cells, tempCell)
	end		
end

function love.draw()

	for i = 1, 10 do
		local tempCell = image1Cells[i]
		tempCell:move()
		tempCell:paint(imageData)
	end	

	for i = 1, 10 do
		local tempCell = image2Cells[i]
		tempCell:move()
		tempCell:paint(imageData)
	end	

	for i = 1, 10 do
		local tempCell = image3Cells[i]
		tempCell:move()
		tempCell:paint(imageData)
	end		


	image:refresh()
	love.graphics.draw(image, 0, 0)
end

function love.keypressed(key)
    if key == "e" then
        -- Modify the original ImageData and apply the changes to the Image.
        imageData:setPixel(10, 10, 255, 0, 0, 255)
        image:refresh()
    end
end