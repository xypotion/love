function love.load()
	counter = 0
	
	local bubble = love.graphics.newImage("big bubble.png") -- http://www.freeiconspng.com/uploads/bubble-png-9.png
	psystem = love.graphics.newParticleSystem(bubble, 100)

	psystem:setParticleLifetime(2, 9)
	psystem:setEmissionRate(5)
	psystem:setSizeVariation(0.5)
	-- psystem:setSpeed(50)
	psystem:setLinearAcceleration(-120, -20, 20, 20) -- Random movement in all directions.
	psystem:setColors(255, 255, 255, 0, 255, 255, 255, 255) -- Fade to transparency.
	
	psystem:setTangentialAcceleration(0, 100)
	-- psystem:setRadialAcceleration(0, 100)
	
	-- psystem:setSpin(0, 10)
	psystem:setSizes(0.015625, 0.125)
	
	-- psystem:setQuads(
	--   love.graphics.newQuad(0,0,8,8,16,16),
	--   love.graphics.newQuad(0,8,8,8,16,16),
	--   love.graphics.newQuad(0,0,8,8,16,16),
	--   love.graphics.newQuad(0,8,8,8,16,16),
	--   love.graphics.newQuad(0,0,8,8,16,16),
	--   love.graphics.newQuad(0,8,8,8,16,16),
	--   love.graphics.newQuad(0,0,8,8,16,16),
	--   love.graphics.newQuad(0,8,8,8,16,16)
	-- )
end
 
function love.draw()
	-- Draw the particle system at the center of the game window.
	love.graphics.draw(psystem, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5)
end
 
function love.update(dt)
	if paused then return end
	
	-- counter = counter + dt
	-- psystem:moveTo(counter, 300)
	
	psystem:update(dt)
	-- psystem:update(dt) --double
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "space" then
		paused = not paused
	end
end