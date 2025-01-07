World = {}

function World:load()
	self.world = love.physics.newWorld(0, 0, true)

	-- local floor = {}
	-- floor.body = love.physics.newBody(self.world, love.graphics.getWidth() / 2, love.graphics.getHeight() - 17)
	-- floor.shape = love.physics.newRectangleShape(love.graphics.getWidth(), 1)
	-- floor.fixture = love.physics.newFixture(floor.body, floor.shape)
	--
	self.world:setCallbacks(beginContact, endContact)

	self.walls = {}

	World:addWall(100, 100, 600, 20)
	World:addWall(100, 400, 600, 20)
	World:addWall(100, 100, 20, 300)
	World:addWall(600, 100, 20, 300)
end

function World:addWall(x, y, width, height)
	local wall = {}
	wall.body = love.physics.newBody(self.world, width / 2, y + height / 2, "static")
	wall.shape = love.physics.newRectangleShape(width, height)
	wall.fixture = love.physics.newFixture(wall.body, wall.shape)
	table.insert(self.walls, wall)
end

function World:update(dt)
	self.world:update(dt)
end

function World:draw()
	for _, wall in ipairs(self.walls) do
		love.graphics.setColor(0, 1, 0)
		love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
		love.graphics.setColor(1, 1, 1)
	end
end
