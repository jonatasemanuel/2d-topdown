require("world")

Player = {}

function Player:load() end

function Player:new(world)
	local self = self or {}
	self.x = 50
	self.y = love.graphics.getWidth() / 2
	self.width = 16
	self.height = 32

	-- status
	self.health = 100
	self.maxHealth = 100
	self.speed = 500
	self.damage = 30

	self.inventory = {}

	self.isColliding = nil
	self.attackRange = 75
	self.isAttacking = false

	self.world = world

	self.physics = {}
	self.physics.world = world
	self.physics.body = love.physics.newBody(self.physics.world, self.x, self.y, "dynamic")
	self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
	self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape, 1)
	self.physics.body:setFixedRotation(true)

	-- self.physics.body:setGravityScale(20)

	self.physics.fixture:setUserData("player")

	self.draw = function()
		love.graphics.polygon("fill", self.physics.body:getWorldPoints(self.physics.shape:getPoints()))
	end

	return self
end

function Player:takeDamage(amount)
	self.health = self.health - amount
	if self.health <= 0 then
		print("u die fucking stupid")
		-- reset game or respawn or game over idk
	end
end

function Player:useItem(item)
	if self.inventory[item] and self.inventory[item] > 0 then
		if item == "supplies" then
			self.health = math.min(self.maxHealth, self.health + 25)
			print("25 hp")
			print(self.health)
		end
		self.inventory[item] = self.inventory[item] - 1
	else
		print("you dont have any: " .. item .. "!")
	end
end

function Player:addToInventory(item)
	if not self.inventory[item] then
		self.inventory[item] = 0
	end
	self.inventory[item] = self.inventory[item] + 1
	print("collected: " .. item .. ". total: " .. self.inventory[item])
end

function Player:interact()
	local px, py = self.physics.body:getPosition()

	for _, obj in ipairs(World.destructibles) do
		local ox, oy = obj.body:getPosition()
		local distance = math.sqrt((px - ox) ^ 2 + (py - oy) ^ 2)

		if distance <= self.attackRange then
			if obj.type == "chest" then
				World:destroyDestructible(obj.fixture)
			end
		end
	end
end

function Player:meleeAttack()
	local px, py = self.physics.body:getPosition()

	for _, obj in ipairs(World.destructibles) do
		local ox, oy = obj.body:getPosition()
		local distance = math.sqrt((px - ox) ^ 2 + (py - oy) ^ 2)

		if distance <= self.attackRange then
			if obj.type == "barrel" then
				Player:takeDamage(50)
				print("live Remaining: ", self.health)
			end
			obj.health = obj.health - self.damage
			print(obj.type .. " took " .. self.damage .. " damage! Remaining health: " .. obj.health)

			if obj.health <= 0 then
				World:destroyDestructible(obj.fixture)
			end
		end
	end
end

function Player:update(dt)
	Player:move(dt)
end

function Player:move(dt)
	local vx, vy = 0, 0

	function love.keypressed(key)
		if key == "space" then
			Player:meleeAttack()
		end
		if key == "e" then
			Player:interact()
		end
		if key == "h" then
			Player:useItem("supplies")
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

	-- Debug collision
	print("Collision Detected: A =", userDataA and userDataA.type, "B =", userDataB and userDataB.type)

	if a == Player.physics.fixture and World:isDestructible(userDataB) then
		Player.isColliding = b
	elseif b == Player.physics.fixture and World:isDestructible(userDataA) then
		Player.isColliding = a
	end
end

function endContact(a, b, coll)
	local userDataA = a:getUserData()
	local userDataB = b:getUserData()

	print("end contat: A =", userDataA, "B =", userDataB)

	if Player.isColliding == a or Player.isColliding == b then
		Player.isColliding = nil
	end
end

function Player:draw()
	-- love.graphics.polygon("fill", self.physics.body:getWorldPoints(self.physics.shape:getPoints()))

	-- range of melee atack
	--[[ local px, py = self.physics.body:getPosition()
	love.graphics.setColor(1, 0, 0, 0.5)
	love.graphics.circle("line", px, py, self.attackRange)
	love.graphics.setColor(1, 1, 1) ]]

	local px, py = self.physics.body:getPosition()
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("fill", px - 25, py - 40, 50, 5)
	love.graphics.setColor(0, 1, 0)
	love.graphics.rectangle("fill", px - 25, py - 40, 50 * (self.health / self.maxHealth), 5)
	love.graphics.setColor(1, 1, 1)
end
