require("world")

Player = {}

function Player:load(world)
	-- self.world:setCallbacks(beginContact, endContact)
end

function Player:new(world)
	local self = self or {}
	self.x = 50
	self.y = love.graphics.getWidth() / 2
	self.width = 16
	self.height = 32
	self.speed = 500
	-- self.jumpCount = 0
	-- self.isGrounded = false

	self.world = world

	self.physics = {}
	self.physics.world = world
	self.physics.body = love.physics.newBody(self.physics.world, self.x, self.y, "dynamic")
	self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
	self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape, 1)
	self.physics.body:setFixedRotation(true)

	-- self.physics.body:setGravityScale(20)
	self.physics.fixture:setUserData("player")

	-- self.draw = function()
	-- 	love.graphics.rectangle("fill", self.physics.body:getX(), self.physics.body:getY(), self.width, self.height)
	-- end

	return self
end

function Player:update(dt)
	Player:move(dt)
end

function Player:move(dt)
	local vx, vy = 0, 0

	-- Move the physics body by applying velocity
	if love.keyboard.isDown("w") then
		vy = vy - self.speed
	end
	if love.keyboard.isDown("a") then
		vx = vx - self.speed
	end
	if love.keyboard.isDown("s") then
		vy = vy + self.speed
	end
	if love.keyboard.isDown("d") then
		vx = vx + self.speed
	end

	-- Update the physics body's velocity
	self.physics.body:setLinearVelocity(vx, vy)
end

function beginContact(a, b, coll)
	local userDataA = a:getUserData()
	local userDataB = b:getUserData()

	if userDataA == "player" or userDataB == "player" then
		print("collision detected")
	end
end

function endContact(a, b, coll) end

function Player:draw()
	love.graphics.polygon("fill", self.physics.body:getWorldPoints(self.physics.shape:getPoints()))
end
