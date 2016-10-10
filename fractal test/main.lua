function love.load()
	love.window.setMode(512, 512)
	
	c1 = love.graphics.newCanvas(512, 512)
	c2 = love.graphics.newCanvas(512, 512)
end

function love.draw()
	cNow = c1
	love.graphics.setCanvas(cNow)
	
	love.graphics.setColor(127, 127, 255)
	love.graphics.rectangle("fill", 0, 0, 512, 512)
	
	
	cNow = c2
	love.graphics.setCanvas(cNow)
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", 0, 0, 512, 512)
	
	love.graphics.draw(c1, 30, 30, 0.1, 0.9)

	
	cNow = c1
	love.graphics.setCanvas(cNow)
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(c2, 30, 30, 0.1, 0.9)
	
	--final draw
	love.graphics.setCanvas()
	love.graphics.draw(cNow)
end

--derp
function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end