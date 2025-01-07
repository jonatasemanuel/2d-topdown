BkgImage = {}

function BkgImage:load()
	BkgImage.image = love.graphics.newImage("sprites/bg2.png")
end

function BkgImage:draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(self.image)
end
