Cell = {}
Cell.__index = Cell

function Cell.create(image)
   local cell = {}             -- our new object
   setmetatable(cell,Cell)  
   math.randomseed(os.time())
   cell.x = math.random(0, 99)
   cell.y = math.random(0, 99)

   cell.r = math.random(0, 255)
   cell.g = math.random(0, 255)
   cell.b = math.random(0, 255)

   cell.source = image
   return cell
end

function Cell:move()
	self.x = self.x + math.round(math.random(-1, 1))
	self.x = math.clamp(self.x, 0, 99)

	self.y = self.y + math.round(math.random(-1, 1))
	self.y = math.clamp(self.y, 0, 99)
end

-- canvas is an imageData object
function Cell:paint(canvas)
	self.r, self.g, self.b = self.source:getPixel(self.x, self.y)
	canvas:setPixel(self.x, self.y, self.r, self.g, self.b, 255)
end

function math.round(input)
	lower = math.floor(input)
	if input - lower >= 0.5 then
		return math.ceil(input)
	else
		return lower
	end
end

function math.clamp(input, min_val, max_val)
	if input < min_val then
		input = min_val
	elseif input > max_val then
		input = max_val
	end
	return input
end