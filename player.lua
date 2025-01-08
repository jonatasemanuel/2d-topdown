require("world")

Player = {}

function Player:load(world)
	-- self.world:setCallbacks(beginContact, endContact)
	self.attackTimer = 0
	self.attackDuration = 0.2
	self.isAttacking = false
end

function Player:new(world)
	local self = self or {}
	self.x = 50
	self.y = love.graphics.getWidth() / 2
	self.width = 16
	self.height = 32
	self.speed = 500
	self.isColliding = nil
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

function Player:meleeAttack()
	self.isAttacking = true

	self.attackTimer = self.attackDuration
end

function Player:updateAttack(dt)
	if self.isAttacking then
		self.attackTimer = self.attackTimer - dt
		if self.attackTimer <= 0 then
			self.isAttacking = false
		end
	end
end

function Player:update(dt)
	Player:move(dt)
end

function Player:move(dt)
	local vx, vy = 0, 0

	-- if love.keyboard.isDown("space") then
	-- 	self:meleeAttack()
	-- else
	-- 	self.isAttacking = false
	-- end
	function love.keypressed(key)
		if key == "space" and self.isColliding then
			World:destroyDestructible(self.isColliding)
			self.isColliding = nil
		end
	end

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

	-- Player.isColliding = true
	print(Player.isColliding)

	-- Debug collision
	print("Collision Detected: A =", userDataA and userDataA.type, "B =", userDataB and userDataB.type)

	-- Check if the player is attacking and colliding with a destructible object
	-- if Player.isColliding or Player.isAttacking then
	if a == Player.physics.fixture and World:isDestructible(userDataB) then
		Player.isColliding = b
	elseif b == Player.physics.fixture and World:isDestructible(userDataA) then
		Player.isColliding = a
	end
	-- if destructible then
	-- 	World:destroyDestructible(destructible)
	-- end
end

function endContact(a, b, coll)
	local userDataA = a:getUserData()
	local userDataB = b:getUserData()

	-- Player.isColliding = false
	print(Player.isColliding)

	print("end contat: A =", userDataA, "B =", userDataB)

	if Player.isColliding == a or Player.isColliding == b then
		Player.isColliding = nil
	end
end

function Player:draw()
	love.graphics.polygon("fill", self.physics.body:getWorldPoints(self.physics.shape:getPoints()))

	-- range of melee atack
	if self.isAttacking then
		local px, py = self.physics.body:getPosition()
		love.graphics.setColor(1, 0, 0, 0.5)
		love.graphics.circle("line", px, py, 50)
	end
end
