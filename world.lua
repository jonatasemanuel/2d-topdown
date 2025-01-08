World = {}

function World:load()
	self.world = love.physics.newWorld(0, 0, true)

	self.world:setCallbacks(beginContact, endContact)

	-- Initialize tables
	self.walls = {}
	self.destructibles = {}

	-- Add walls
	World:addWall(100, 100, 600, 20)
	World:addWall(100, 200, 400, 20)
	World:addWall(600, 100, 20, 300)

	-- Add destructible objects
	World:createDestructible(150, 200, 50, 50, "tree")
	World:createDestructible(250, 200, 50, 50, "barrel")
	World:createDestructible(350, 200, 50, 50, "crate")
end

function World:addWall(x, y, width, height)
	local wall = {}
	wall.body = love.physics.newBody(self.world, x + width / 2, y + height / 2, "static")
	wall.shape = love.physics.newRectangleShape(width, height)
	wall.fixture = love.physics.newFixture(wall.body, wall.shape)
	wall.fixture:setUserData(wall) -- Store the wall object in UserData

	table.insert(self.walls, wall)
end

function World:createDestructible(x, y, width, height, type)
	local obj = {}
	obj.body = love.physics.newBody(self.world, x + width / 2, y + height / 2, "static")
	obj.shape = love.physics.newRectangleShape(width, height)
	obj.fixture = love.physics.newFixture(obj.body, obj.shape)
	obj.type = type
	obj.fixture:setUserData(obj) -- Store the destructible object in UserData

	table.insert(self.destructibles, obj)
end

function World:isDestructible(userData)
	-- Define the destructible types
	local destructibleTypes = { tree = true, barrel = false, crate = true }

	-- Check if userData is a string or has a type field
	if type(userData) == "table" and userData.type then
		return destructibleTypes[userData.type] ~= nil
	end

	-- Not destructible
	return false
end

function World:destroyDestructible(fixture)
	for i, obj in ipairs(self.destructibles) do
		if obj.fixture == fixture then
			-- Destroy the physics body and remove from the table
			obj.body:destroy()
			table.remove(self.destructibles, i)
			print(obj.type .. " the biggest loot box ever")
			break
		end
	end
end

function World:update(dt)
	self.world:update(dt)
end

function World:draw()
	-- Draw walls
	for _, wall in ipairs(self.walls) do
		love.graphics.setColor(0, 1, 0)
		love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
	end

	-- Draw destructible objects
	for _, obj in ipairs(self.destructibles) do
		if obj.type == "tree" then
			love.graphics.setColor(0.5, 0.5, 0.5)
		elseif obj.type == "barrel" then
			love.graphics.setColor(1, 0, 0)
		elseif obj.type == "crate" then
			love.graphics.setColor(0.8, 0.5, 0.2)
		end
		love.graphics.polygon("fill", obj.body:getWorldPoints(obj.shape:getPoints()))
	end

	-- Reset color
	love.graphics.setColor(1, 1, 1)
end
