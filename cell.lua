Cell = {}
Cell.__index = Cell

-- math.random works better if the seed is set outside the function that is called in a loop
math.randomseed(os.time())

function Cell.create(image)
   local cell = {}             -- our new object
   setmetatable(cell,Cell)
   cell.x = math.random(0, 99)
   cell.y = math.random(0, 99)

   cell.r = math.random(0, 255)
   cell.g = math.random(0, 255)
   cell.b = math.random(0, 255)

   cell.source = image

  -- target colour to move towards
	 cell.targetColor = {255, 0, 255}

   local moveRand = math.random(1, 5)

   if moveRand == 1 then
   	cell.moveType = "bright"
   elseif moveRand == 2 then
	cell.moveType = "dark"
   elseif moveRand == 3 then
	cell.moveType = "red"
   elseif moveRand == 4 then
   	cell.moveType = "blue"
   else
   	cell.moveType = "green"
   end


   local drawRand = math.random(1, 3)

   if drawRand == 1 then
   	cell.drawType = "set"
   elseif drawRand == 2 then
   	cell.drawType = "add"
   else
   	cell.drawType = "subtract"
   end

   cell.lastLocations = {}
   cell.lastLocationsMax = 5

   cell.id = -1

   return cell
end

function Cell:move(canvas, collisionMatrix, cellModel)
	self.x = math.clamp(self.x, 1, 99)
	self.y = math.clamp(self.y, 1, 99)

	local lastX = self.x
	local lastY = self.y

	self:hillClimb(canvas)

	self:checkCollisions(collisionMatrix, cellModel, lastX, lastY)

	if table.getn(self.lastLocations) > self.lastLocationsMax then
		table.remove(self.lastLocations, 1)
	end
end

-- canvas is an imageData object
function Cell:paint(canvas)
	self.r, self.g, self.b = self.source:getPixel(self.x, self.y)
	local canr, cang, canb = canvas:getPixel(self.x, self.y)

	local newR = 0
	local newG = 0
	local newB = 0

	if self.drawType == "set" then
		newR = self.r
		newG = self.g
		newB = self.b
	elseif self.drawType == "add" then
		newR, newG, newB = self:add(self.r, self.g, self.b, canr, cang, canb)
	elseif self.drawType == "subtract" then
		newR, newG, newB = self:subtract(self.r, self.g, self.b, canr, cang, canb)
	end

	canvas:setPixel(self.x, self.y, newR, newG, newB, 255)
end

function Cell:hillClimb(canvas)
	-- look at the nearby kernel
	-- determine which direction to move in based on move type

	-- get starting pixel
	newX = -1
	newY = -1

	local newr, newg, newb = canvas:getPixel(self.x, self.y)

	-- set closest colour distance to max (~441)
	local closestColorDistance = math.sqrt((255)^2+(255)^2+(255^2))

	for x = -1, 1 do
		for y = -1, 1 do
			if not self:inLastLocations(x, y) then -- this isn't actually helping the way I think it is
				if self.x + x < 99 and self.y + y < 99 and self.y + y > 0 and self.x + x > 0 then
					-- compare with r, g, b
					-- if we have found something better based on the type, replace
					local r, g, b = canvas:getPixel(self.x + x, self.y + y)
					local foundBetter = false

					if self.moveType == "bright" then
						foundBetter = self:brighter(r, g, b, newr, newg, newb)

					elseif self.moveType == "dark" then
						foundBetter = self:darker(r, g, b, newr, newg, newb)

					elseif self.moveType == "red" then
						foundBetter = self:redder(r, newr)

					elseif self.moveType == "green" then
						foundBetter = self:greener(g, newg)

					elseif self.moveType == "blue" then
						foundBetter = self:bluer(b, newb)
					end

					if foundBetter then
						-- set newX and newY
						newX = x
						newY = y

						-- to introduce some randomness, maybe break here
						local chance = math.random(0, 100)
						if chance > 50 then -- this should probably be significantly reduced, but currently performs well
							break
						end
					end

					if self.moveType == "target" then
						-- if the color distance between the current pixel in the kernel and the target color
						-- is less than the closest colour distance
						if self:colorDistance(r, g, b, self.targetColor[1], self.targetColor[2], self.targetColor[3]) < closestColorDistance then
							-- set the newX and newY, since it's closer to the target colour
							closestColorDistance = self:colorDistance(r, g, b, self.targetColor[1], self.targetColor[2], self.targetColor[3])
							closestX = x
							closestY = y
						end
					end
				end
			end
		end
		local chance = math.random(0, 100)
		if chance < 20 then
			break
		end

	end

	-- now we have newX and newY set to what we want
	-- so we can move to those locations
	if self.moveType == "target" then
		self.x = self.x + closestX
		self.x = math.clamp(self.x, 0, 99)

		self.y = self.y + closestY
		self.y = math.clamp(self.y, 0, 99)
	else
		self.x = self.x + newX
		self.x = math.clamp(self.x, 0, 99)

		self.y = self.y + newY
		self.y = math.clamp(self.y, 0, 99)
	end


	-- add this location to the list of last locations so we won't go back to this point for the next few steps
	local location = {self.y, self.x}
	table.insert(self.lastLocations, location)

end

-- check if a given location is in the last few locations visited
function Cell:inLastLocations(x, y)
	local newLocation = {self.x + x, self.y + y}

	for i = 1, table.getn(self.lastLocations) do
		if self.lastLocations[i] == newLocation then
			return true
		end
	end

	return false
end

-- returns true if rgb1 is brighter than rgb2
function Cell:brighter(r1, g1, b1, r2, g2, b2)
	-- average the values for all colours, check
	local av1 = (r1 + g1 + b1) / 3
	local av2 = (r2 + g2 + b2) / 3

	if av1 >= av2 then
		return true
	else
		return false
	end
end

-- returns true if rgb1 is darker than rgb2
function Cell:darker(r1, g1, b1, r2, g2, b2)
	-- average the values for all colours, check
	local av1 = (r1 + g1 + b1) / 3
	local av2 = (r2 + g2 + b2) / 3

	if av1 <= av2 then
		return true
	else
		return false
	end
end

function Cell:redder(r1, r2)
	if r1 >= r2 then
		return true
	else
		return false
	end
end

function Cell:greener(g1, g2)
	if g1 >= g2 then
		return true
	else
		return false
	end
end

function Cell:bluer(b1, b2)
	if b1 >= b2 then
		return true
	else
		return false
	end
end

function Cell:colorDistance(r1, g1, b1, r2, g2, b2)
		-- check distance for R G B
	d = math.sqrt((r2-r1)^2+(g2-g1)^2+(b2-b1)^2)
	return d
end

-- maybe also add edges, maybe even watersheds if feeling ambitious



-- Painting Functions

function Cell:add(r, g, b, cr, cg, cb)
	r = r + cr
	g = g + cg
	b = b + cb

	math.clamp(r, 0, 255)
	math.clamp(g, 0, 255)
	math.clamp(b, 0, 255)

	return r, g, b

end

function Cell:subtract(r, g, b, cr, cg, cb)
	r = r - cr
	g = g - cg
	b = b - cb

	math.clamp(r, 0, 255)
	math.clamp(g, 0, 255)
	math.clamp(b, 0, 255)
	return r, g, b
end

function Cell:over(r, g, b, cr, cg, cb)

end




function Cell:checkCollisions(collisionMatrix, cellModel, lastX, lastY)
	-- go to collisionMatrix[x][y]
	-- if value there is 0, no collisions
		-- write our id there
		-- go to collisionMatrix[lastX, lastY] and set to 0
	-- if non-zero value, collision
		-- reproduce

	-- if self = last, will destroy self
		self.x = math.clamp(self.x, 1, 99)
		self.y = math.clamp(self.y, 1, 99)

		lastX = math.clamp(lastX, 1, 99)
		lastY = math.clamp(lastY, 1, 99)

	if self.x == lastX and self.y == lastY then
		--alert = alert .. "self collision with " .. self.id
		return
	end

	if collisionMatrix[self.x][self.y] == 0 then
		collisionMatrix[self.x][self.y] = self.id
	else
		local cellIndex = collisionMatrix[self.x][self.y]
		if(cellModel[cellIndex] ~= -1) then
			self:reproduce(cellModel[cellIndex], cellModel)
		end
	end

	collisionMatrix[lastX][lastY] = 0
end

function Cell:reproduce(otherParent, cellModel)
	-- randomly select one of their draw modes
	-- combine their images based on that draw modes
	-- create child with that image
	-- child inherits other draw modes
	-- parent cells are destroyed
	-- entry in collision matrix is now for child
	-- parents are not removed from the cell model, but they are set to null?
	-- this isn't ideal, but it's more efficient than getting all the other cells to update their indices
	-- can grow exponentially? But does have an upper bound so we cool.

	-- n + n/2 + n/4 + n/8...
	-- Sum of n/2^i, while 2^i <= n
	local move = ""
	local draw = ""
	local draw2 = ""
	local id = table.getn(cellModel) + 1

	local chance = math.random(0, 100)
	if chance < 50 then
		draw = self.drawType
		draw2 = otherParent.drawType
		move = self.moveType
	else
		draw = otherParent.drawType
		draw2 = self.drawType
		move = otherParent.moveType
	end

	local img = self:combineImages(self.source, otherParent.source, draw)
	local childCell = Cell.create(img)

	childCell.id = id
	childCell.drawType = draw2
	childCell.x = self.x
	childCell.y = self.y

	table.insert(cellModel, childCell)

	-- remove parents
	cellModel[self.id] = -1
	cellModel[otherParent.id] = -1

end

function Cell:combineImages(img1, img2, mode)
	result = img1

	for x = 1, 99 do
		for y = 1, 99 do
			local r1, g1, b1 = img1:getPixel(x, y)
			local r2, g2, b2 = img2:getPixel(x, y)
			local newR, newG, newB = 0

			if mode == "set" then
				newR = r1
				newG = g1
				newB = b1
			elseif mode == "add" then
				newR, newG, newB = self:add(r1, g1, b1, r2, g2, b2)
			elseif mode == "subtract" then
				newR, newG, newB = self:subtract(r1, g1, b1, r2, g2, b2)
			end

			result:setPixel(x, y, newR, newG, newB, 255)

		end
	end

	return result
end

-- Utility functions

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

