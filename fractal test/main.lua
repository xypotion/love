function love.load()
	love.window.setMode(512, 512)
	
	c1 = love.graphics.newCanvas(512, 512)
	c2 = love.graphics.newCanvas(512, 512)
	
	r = math.pi * 7 / 4
	a, b, counter = 0, 0, 0
end

function love.update(dt)
	mx, my = love.mouse.getPosition()
	
	r = r + dt
	counter = counter + dt
	
	a = 256 - math.cos(counter) * 256
	b = 256 - math.sin(counter) * 256
end

function love.draw()
	-- a little setup
	cNow = c1
	love.graphics.setCanvas(cNow)
	
	love.graphics.setColor(0, 0, 255)
	love.graphics.rectangle("fill", 0, 0, 512, 512)
	
	love.graphics.setColor(255, 0, 255)
	love.graphics.circle("fill", 32, 32, 16)
	
	
	cNow = c2
	love.graphics.setCanvas(cNow)
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", 0, 0, 512, 512)
	
	--the fun part
	-- drawTunnel()
	-- drawAntispinTunnel()
	-- drawWonkyTunnel()
	-- drawQuadSponge()
	drawLookingTunnel()
	
	--final draw
	love.graphics.setColor(255, 255, 255)
	love.graphics.setCanvas()
	love.graphics.draw(cNow)
end

function drawTunnel()
	for i = 1, 8 do		
		cNow = c2
		love.graphics.setCanvas(cNow)

		love.graphics.draw(c1, a, b, r, 0.70710678118656, 0.70710678118656)


		cNow = c1
		love.graphics.setCanvas(cNow)

		love.graphics.draw(c2, a, b, r, 0.70710678118656, 0.70710678118656)
	end
end

function drawWonkyTunnel()
	for i = 1, 8 do		
		cNow = c2
		love.graphics.setCanvas(cNow)

		love.graphics.draw(c1, a, b, r, 0.470710678118656, 0.70710678118656)


		cNow = c1
		love.graphics.setCanvas(cNow)

		love.graphics.draw(c2, a, b, r, 0.470710678118656, 0.70710678118656)
	end
end

function drawQuadSponge()
	for i = 1, 5 do
		-- love.graphics.setColor(32 * i, 32 * i, 32 * i)
		
		cNow = c2
		love.graphics.setCanvas(cNow)

		love.graphics.draw(c1, a/2, b/2, r, 0.35355339059328, 0.35355339059328)
		love.graphics.draw(c1, a/2, b/2+256, r, 0.35355339059328, 0.35355339059328)
		love.graphics.draw(c1, a/2+256, b/2, r, 0.35355339059328, 0.35355339059328)
		love.graphics.draw(c1, a/2+256, b/2+256, r, 0.35355339059328, 0.35355339059328)


		cNow = c1
		love.graphics.setCanvas(cNow)

		love.graphics.draw(c2, a/2, b/2, r, 0.35355339059328, 0.35355339059328)
		love.graphics.draw(c2, a/2, b/2+256, r, 0.35355339059328, 0.35355339059328)
		love.graphics.draw(c2, a/2+256, b/2, r, 0.35355339059328, 0.35355339059328)
		love.graphics.draw(c2, a/2+256, b/2+256, r, 0.35355339059328, 0.35355339059328)
	end
end

--???
function drawAntispinTunnel()
	for i = 1, 8 do		
		cNow = c2
		love.graphics.setCanvas(cNow)

		love.graphics.draw(c1, a, b, math.pi - r, 0.70710678118656, 0.70710678118656)


		cNow = c1
		love.graphics.setCanvas(cNow)

		love.graphics.draw(c2, a, b, r, 0.70710678118656, 0.70710678118656)
	end
end

function drawLookingTunnel()
	for i = 1, 21 do		
		cNow = c2
		love.graphics.setCanvas(cNow)

		love.graphics.draw(c1, mx, my, 0, 0.9, 0.9)


		cNow = c1
		love.graphics.setCanvas(cNow)

		love.graphics.draw(c2, mx, my, 0, 0.9, 0.9)
	end
end

--derp
function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end