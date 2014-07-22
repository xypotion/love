require "map"

function love.load()
  love.window.setTitle('Löaf 2D')

	initTileSystem()
	
	initHero()
	
	math.randomseed(os.time())
	
  love.window.setMode(xLen*tileSize + xMargin, yLen*tileSize + yMargin)
end

function love.update(dt)
	animateBG(dt)
	
	animateHero(dt)
	
	if screenShift then
		shiftTiles(dt)
	end
	
	if heroShift then
		shiftHero(dt)
	end
end

function love.draw()
	drawBGTiles()
	
	drawHero()
	
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
	love.graphics.print(" x="..worldX.." y="..worldY, tileSize * xLen - 96, 10)
end

function love.keypressed(key)
	if key == "q" then
		love.event.quit()
		return
	end
	
	-- change to a different trigger later, obvs
	-- explore(key)
	
	-- eventually put this in update, not keypressed!
	if not heroShift then
		triggerHeroShift(key)
	end
end

------------------------------------------------------------------------------------------------------

function initHero()
	heroImage = love.graphics.newImage("man7d.png")
	heroQuads = {
		love.graphics.newQuad(0,0,32,32,64,32),
		love.graphics.newQuad(32,0,32,32,64,32)
	}
	
	heroFrameLength = .4
	heroTime = 0
	heroSpriteState = 1
	
	heroHeight = 32
	heroWidth = 32
	
	heroGridPos = {6,6} --x,y
	heroGridDest = heroGridPos
	heroX = heroGridPos[1] * tileSize
	heroY = heroGridPos[2] * tileSize
	heroSpeed = 256
	heroGridMove = false
end

function shiftHero(dt)
	o = heroSpeed * dt
	
	-- definitely a simpler way to do this using heroGridPos and heroGridDest
	if heroShift == "right" then
		heroX = heroX + o + xMargin --still maybe unnecessary? or are you trying to simplify drawHero()?
	elseif heroShift == "left" then
		heroX = heroX - o + xMargin
	elseif heroShift == "up" then
		heroY = heroY - o + yMargin
	elseif heroShift == "down" then
		heroY = heroY + o + yMargin
	end
	
	--maybe heavy-handed; could probably simplify
	heroShiftCountdown = heroShiftCountdown - o
	if heroShiftCountdown <= 0 then
		heroShiftCountdown = 0
		heroShift = nil
		
		--finalize and snap to grid
		heroGridPos = heroGridDest
		heroX = heroGridPos[1] * tileSize + xMargin
		heroY = heroGridPos[2] * tileSize + yMargin
	end
end

function animateHero(dt)
	-- could actually see setting the current quad in here to simplify drawHero(), especially after implementing directionality
	heroTime = heroTime + dt
	if heroTime > heroFrameLength then
		heroSpriteState = (heroSpriteState + 1) % 2
		heroTime = 0
	end
end

function triggerHeroShift(key)
	if key == "d" then
		heroShift = "right"
		heroGridDest = {heroGridPos[1] + 1, heroGridPos[2]}
		heroShiftCountdown = tileSize
	elseif key == "a" then
		heroShift = "left"
		heroGridDest = {heroGridPos[1] - 1, heroGridPos[2]}
		heroShiftCountdown = tileSize
	elseif key == "w" then
		heroShift = "up"
		heroGridDest = {heroGridPos[1], heroGridPos[2] - 1}
		heroShiftCountdown = tileSize
	elseif key == "s" then
		heroShift = "down"
		heroGridDest = {heroGridPos[1], heroGridPos[2] + 1}
		heroShiftCountdown = tileSize
	end
end

function drawHero()
	love.graphics.draw(heroImage, heroQuads[heroSpriteState + 1], heroX, heroY)
end

function love.quit()
end