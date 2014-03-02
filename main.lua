require "Cell"

imageData = {}
image = {}

image1Cells = {}
image2Cells = {}
image3Cells = {}

alert = ""

function love.load() 
	--love.window.setMode(150, 150)

	imageData = love.image.newImageData("gradient4.png")
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
		local tempCell = Cell.create(love.image.newImageData("white.png"))
		table.insert(image3Cells, tempCell)
	end		
end

function love.draw()

	love.graphics.print(alert, 0, 200)

	for i = 1, 10 do
		local tempCell = image1Cells[i]
		tempCell:move(love.image.newImageData("gradient4.png"))
		tempCell:paint(imageData)
	end	

	for i = 1, 10 do
		local tempCell = image2Cells[i]
		tempCell:move(love.image.newImageData("gradient4.png"))
		tempCell:paint(imageData)
	end	

	for i = 1, 10 do
		local tempCell = image3Cells[i]
		tempCell:move(love.image.newImageData("gradient4.png"))
		tempCell:paint(imageData)
	end		


	image:refresh()
	love.graphics.draw(image, 0, 0)
end