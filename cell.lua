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
   cell.moveType = "dark"
   cell.drawType = "set"

   cell.lastLocations = {}
   cell.lastLocationsMax = 5

   return cell
end

function Cell:move(canvas)
	self.x = math.clamp(self.x, 0, 99)
	self.y = math.clamp(self.y, 0, 99)

	self:hillClimb(canvas)

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
	newX = 0
	newY = 0

	local newr, newg, newb = canvas:getPixel(self.x, self.y)

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
	self.x = self.x + newX
	self.x = math.clamp(self.x, 0, 99)

	self.y = self.y + newY
	self.y = math.clamp(self.y, 0, 99)

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