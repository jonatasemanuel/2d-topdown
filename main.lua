require("player")
require("world")

function love.load()
	World:load()
	--BkgImage:load()
	player = Player:new(World.world)
end

function love.update(dt)
	World.world:update(dt)
	Player:update(dt)
end

function love.draw()
	-- BkgImage:draw()
	Player:draw()
	World:draw()
end
