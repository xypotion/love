-- never mind, i guess!

function love.load()
	-- print "helloo"
	
	tileSize = 32
	
	heroImage = love.graphics.newImage("man7.png")
	heroQuad = love.graphics.newQuad(0,0,32,32,32,32)
	
	facing = 0
	heroSpriteState = 1	
	heroTime = 0
	heroFrameLength = 0.5
end

function love.update(dt)
	if free then
		facing = facing + dt
	end
end

function love.draw()
	love.graphics.rectangle("fill", 0,0, 400, 400)
	
	-- love.graphics.scale(2,2) -- nope ;_; still fuzzy. oh, well.
	
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(heroImage, heroQuad, 100, 100, facing, 1, 1)
end

function love.keypressed(key)
	if key == "q" then
		love.event.quit()
	end
	
	if key == "m" then
		loadMario()
	end
end

function loadMario()
	free = false
	
	
end