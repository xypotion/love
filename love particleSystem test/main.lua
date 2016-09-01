function love.load()
	local bubble = love.graphics.newImage("bubble.png")
	psystem = love.graphics.newParticleSystem(bubble, 100)

	psystem:setParticleLifetime(2, 9)
	psystem:setEmissionRate(50)
	psystem:setSizeVariation(0.5)
	psystem:setLinearAcceleration(-120, -20, 20, 20) -- Random movement in all directions.
	psystem:setColors(255, 255, 255, 255, 0, 0, 255, 0) -- Fade to transparency.
	
	psystem:setTangentialAcceleration(0, 100)
	-- psystem:setRadialAcceleration(0, 100)
end
 
function love.draw()
	-- Draw the particle system at the center of the game window.
	love.graphics.draw(psystem, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5)
end
 
function love.update(dt)
	psystem:update(dt)
end