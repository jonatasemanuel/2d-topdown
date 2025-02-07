World = {}

function World:load()
	self.world = love.physics.newWorld(0, 0, true)

	self.world:setCallbacks(beginContact, endContact)

	-- Initialize tables
	self.walls = {}
	self.destructibles = {}

	-- load objects rules
	self.destructibleTypes = {
		tree = { health = 100, loot = "wood" },
		barrel = { health = 10, loot = "oil" },
		crate = { health = 15, loot = "supplies" },
		iron = { health = 300, loot = "supplies" },
		chest = { health = 100, loot = "big bount" },
	}

	-- Add walls
	World:addWall(100, 100, 600, 20)
	World:addWall(100, 200, 400, 20)
	World:addWall(600, 100, 20, 300)

	-- Add destructible objects
	World:createDestructible(150, 200, 50, 50, "tree")
	World:createDestructible(250, 200, 50, 50, "iron")
	World:createDestructible(350, 300, 50, 50, "crate")
	World:createDestructible(700, 200, 50, 50, "barrel")
	World:createDestructible(500, 200, 50, 50, "barrel")
	World:createDestructible(800, 100, 50, 50, "chest")
end

function World:addWall(x, y, width, height)
	local wall = {}
	wall.body = love.physics.newBody(self.world, x + width / 2, y + height / 2, "static")
	wall.shape = love.physics.newRectangleShape(width, height)
	wall.fixture = love.physics.newFixture(wall.body, wall.shape)
	self.type = "wall"
	wall.fixture:setUserData(wall) -- Store the wall object in UserData

	table.insert(self.walls, wall)
end

function World:createDestructible(x, y, width, height, type)
	local destructibleData = self.destructibleTypes[type]
	if not destructibleData then
		print("Invalid destructible type: " .. tostring(type))
		return nil
	end

	local obj = {}
	obj.body = love.physics.newBody(self.world, x + width / 2, y + height / 2, "static")
	obj.shape = love.physics.newRectangleShape(width, height)
	obj.fixture = love.physics.newFixture(obj.body, obj.shape)
	obj.type = type
	obj.health = destructibleData.health -- Assign health based on type
	obj.fixture:setUserData(obj)

	table.insert(self.destructibles, obj)
	return obj
end

function World:isDestructible(userData)
	if type(userData) == "table" and userData.type then
		return self.destructibleTypes[userData.type] or false
	end
	return false
end

function World:destroyDestructible(fixture)
	for i, obj in ipairs(self.destructibles) do
		if obj.fixture == fixture then
			-- Destroy the physics body and remove from the table
			local loot = self.destructibleTypes[obj.type].loot
			Player:addToInventory(loot)
			print("Loot: ", loot)
			obj.body:destroy()
			table.remove(self.destructibles, i)
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
		love.graphics.setColor(0.3, 0.7, 0.5)
		love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
	end

	-- Draw destructible objects
	for _, obj in ipairs(self.destructibles) do
		if obj.type == "tree" then
			love.graphics.setColor(0.5, 0.5, 0.5)
		elseif obj.type == "barrel" then
			love.graphics.setColor(1, 0, 1)
		elseif obj.type == "iron" then
			love.graphics.setColor(1, 0, 0)
		elseif obj.type == "chest" then
			love.graphics.setColor(0, 1, 1)
		elseif obj.type == "crate" then
			love.graphics.setColor(0.8, 0.5, 0.2)
		end

		-- Draw the destructible object
		love.graphics.polygon("fill", obj.body:getWorldPoints(obj.shape:getPoints()))

		-- Draw health above the object
		local x, y = obj.body:getPosition()
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("HP: " .. obj.health, x - 15, y - 30)
	end

	-- Reset color
	love.graphics.setColor(1, 1, 1)
end
