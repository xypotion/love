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
		-- if map needs to be moved
		shiftTiles(dt)
	elseif heroShift then
		-- animate hero's moving
		shiftHero(dt)
	else --[[if not screenShift then]]
		-- allow player to move hero
		heroShift = getHeroShiftDirectionIfDirectionKeyPressed()
	end
end

function love.draw()
	drawBGTiles()
	
	drawHero()
	
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
	if heroShift then love.graphics.print(heroShift, 10, 26) end
	love.graphics.print(" x="..worldX.." y="..worldY, tileSize * xLen - 96, 10)
	love.graphics.print(" x="..heroGridPos[1].." y="..heroGridPos[2], tileSize * xLen - 96, 26)
end

function love.keypressed(key)
	if key == "q" then
		love.event.quit()
		return
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
	
	heroGridPos = {6,6} --x,y
	heroGridDest = heroGridPos
	setHeroXY()
	
	heroSpeed = 256
end

function getHeroShiftDirectionIfDirectionKeyPressed()
	if not love.keyboard.isDown('w','a','s','d') then
		return nil
	end

	--someday make the LAST-PRESSED key be the direction the hero moves, allowing many to be pressed at once? lock others until keyReleased()? hm
	numKeysPressed = 0
	direction = nil
	
	if love.keyboard.isDown('d') then
		direction = "right"
		heroGridDest = {heroGridPos[1] + 1, heroGridPos[2]}
		heroShiftCountdown = tileSize
		numKeysPressed = numKeysPressed + 1
	end
	if love.keyboard.isDown('a') then
		direction = "left"
		heroGridDest = {heroGridPos[1] - 1, heroGridPos[2]}
		heroShiftCountdown = tileSize
		numKeysPressed = numKeysPressed + 1
	end
	if love.keyboard.isDown('w') then
		direction = "up"
		heroGridDest = {heroGridPos[1], heroGridPos[2] - 1}
		heroShiftCountdown = tileSize
		numKeysPressed = numKeysPressed + 1
	end
	if love.keyboard.isDown('s') then
		direction = "down"
		heroGridDest = {heroGridPos[1], heroGridPos[2] + 1}
		heroShiftCountdown = tileSize
		numKeysPressed = numKeysPressed + 1
	end
	
	-- collision or multiple directions; "nope, sorry"
	type = tileType(heroGridDest)
	if type	== "plant" or numKeysPressed > 1	then
		heroGridDest = heroGridPos
		heroShiftCountdown = 0
		direction = nil
	end
	
	if type and string.find(type, "map ") and not screenShift then
		print(type)
		triggerScreenShift(type)
		
		heroGridDest = {(heroGridDest[1] - 1) % xLen + 1, (heroGridDest[2] - 1) % yLen + 1}
		heroShiftCountdown = tileSize
		direction = "?"
	end
	
	return direction
end

function tileType(xy)
	type = nil

	if xy[1] == xLen + 1 then
		type = "map right" --trying to go beyond right edge
	elseif xy[2] == yLen + 1 then
		type = "map down" --trying to go beyond bottom
	else
		if not currentMap[xy[2]] then
			type = "map up" --nothing at currentMap[0]
		elseif not currentMap[xy[2]][xy[1]] then
			type = "map left" --nothing at currentMap[y][0]
		else
			if currentMap[xy[2]][xy[1]] == 2 then
				type = "plant"
			end
		end
	end
	
	return type
end

function shiftHero(dt)
	o = heroSpeed * dt
	
	-- definitely a simpler way to do this with heroGridPos and heroGridDest
	if heroShift == "right" then
		heroX = heroX + o -- margin still maybe unnecessary? or are you trying to simplify drawHero()?
	elseif heroShift == "left" then
		heroX = heroX - o
	elseif heroShift == "up" then
		heroY = heroY - o
	elseif heroShift == "down" then
		heroY = heroY + o
	end
	
	--maybe heavy-handed; could probably simplify
	heroShiftCountdown = heroShiftCountdown - o
	if heroShiftCountdown <= 0 then
		heroShiftCountdown = 0
		-- heroShift = nil
		
		--finalize and snap to grid
		heroGridPos = heroGridDest
		setHeroXY()
		
		heroShift = getHeroShiftDirectionIfDirectionKeyPressed()
	end
end

function setHeroXY()
		heroX = (heroGridPos[1] - 1) * tileSize + xMargin
		heroY = (heroGridPos[2] - 1) * tileSize + yMargin
end

function animateHero(dt)
	-- could actually see setting the current quad in here to simplify drawHero(), especially after implementing directional sprites
	heroTime = heroTime + dt
	if heroTime > heroFrameLength then
		heroSpriteState = (heroSpriteState + 1) % 2
		heroTime = 0
	end
end

function drawHero()
	love.graphics.draw(heroImage, heroQuads[heroSpriteState + 1], heroX, heroY)
end

function love.quit()
end