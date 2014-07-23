require "map"

function love.load()
  love.window.setTitle('Löaf 2D')

	initTileSystem()
	
	initHero()
	
	math.randomseed(os.time())
	
  love.window.setMode(xLen * tileSize + xMargin, yLen * tileSize + yMargin)
	
	interaction = false
end

function love.update(dt)
	animateBG(dt)
	
	animateHero(dt)
	
	if screenShift then
		-- if map needs to be moved
		shiftTiles(dt)
	end
	if heroShifting then
		-- animate hero's moving
		shiftHero(dt)
	end
	
	if not screenShift and not heroShifting then --maybe more later, probably simplify!
		-- allow player to move hero
		interactionType, direction = getTargetTileTypeIfDirectionKeyPressed()

		if interactionType then 
			-- print(interaction)
			interact(interactionType, direction)
		end
	
		-- if interaction --then
			if interactionType == "clear"
	
			-- if type 
			and string.find(interactionType, "map ") 
			and not screenShift then
				print("ping"..interactionType)
				triggerScreenShift(interactionType)
		
				--the right spot!
				heroGridDest = {(heroGridDest[1] - 1) % xLen + 1, (heroGridDest[2] - 1) % yLen + 1}
		
				heroShiftCountdown = (xLen-1) * tileSize ---? not really, but should work...
				print(heroShiftCountdown)
				direction = interactionType
			-- end
		end
	end
end

function love.draw()
	drawBGTiles()
	
	drawHero()
	
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
	if heroShifting then love.graphics.print(direction, 10, 26) end
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
	
	heroSpeed = 100
end

function getTargetTileTypeIfDirectionKeyPressed()
	if not love.keyboard.isDown('w','a','s','d') then
		return nil
	end

	--someday make the LAST-PRESSED key be the direction the hero moves, allowing many to be pressed at once? lock others until keyReleased()? hm
	-- numKeysPressed = 0
	direction = nil
	
	if love.keyboard.isDown('d') then
		heroGridDest = {heroGridPos[1] + 1, heroGridPos[2]}
		direction = "right"
		-- numKeysPressed = numKeysPressed + 1
	end
	if love.keyboard.isDown('a') then
		heroGridDest = {heroGridPos[1] - 1, heroGridPos[2]}
		-- numKeysPressed = numKeysPressed + 1
		direction = "left"
	end
	if love.keyboard.isDown('w') then
		heroGridDest = {heroGridPos[1], heroGridPos[2] - 1}
		-- numKeysPressed = numKeysPressed + 1
		direction = "up"
	end
	if love.keyboard.isDown('s') then
		heroGridDest = {heroGridPos[1], heroGridPos[2] + 1}
		-- numKeysPressed = numKeysPressed + 1
		direction = "down"
	end

	
	-- return direction, type
	return tileType(heroGridDest), direction
end

function tileType(xy)
	type = "clear"

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
	-- o = heroSpeed * dt
	
	xDelta = 0
	yDelta = 0
	
	-- definitely a simpler way to do this with heroGridPos and heroGridDest
	if direction == "right" then
		-- heroX = heroX + heroSpeed * dt
		xDelta = heroSpeed * dt
	elseif direction == "left" then
		-- heroX = heroX - heroSpeed * dt
		xDelta = -heroSpeed * dt
	elseif direction == "up" then
		-- heroY = heroY - heroSpeed * dt
		
		yDelta = -heroSpeed * dt
	
		-- print(yDelta)
	elseif direction == "down" then
		-- heroY = heroY + heroSpeed * dt
		yDelta = heroSpeed * dt
		
	elseif direction == "map right" then		
		-- heroX = heroX - ((xLen - 1)/xLen) * scrollSpeed * dt
		xDelta = 0 - ((xLen - 1)/xLen) * scrollSpeed * dt
		-- heroX = heroX + heroSpeed * dt
		-- print("map right!")
	elseif direction == "map left" then
		-- heroX = heroX + scrollSpeed * dt
		xDelta = 0 + ((xLen - 1)/xLen) * scrollSpeed * dt
	elseif direction == "map up" then
		-- heroY = heroY + scrollSpeed * dt
	
	print(yDelta)
		yDelta = 0 + ((yLen - 1)/yLen) * scrollSpeed * dt
	elseif direction == "map down" then
		-- heroY = heroY - scrollSpeed * dt
		yDelta =  0 - ((yLen - 1)/yLen) * scrollSpeed * dt
	end
	
	heroX = heroX + xDelta
	heroY = heroY + yDelta
	
	--maybe heavy-handed; could probably simplify
	-- print("before "..heroY)
	heroShiftCountdown = heroShiftCountdown - math.abs(xDelta + yDelta)
	-- print("after  "..heroY)
	
	--"arrive(heroGridDest)"
	if heroShiftCountdown <= 0 then
		heroShiftCountdown = 0
		
		--finalize and snap to grid
		heroGridPos = heroGridDest
		setHeroXY()
		
		--HACKY
		type, direction = getTargetTileTypeIfDirectionKeyPressed()
		if not heroGridDest == heroGridPos then
			heroShifting = true
			-- direction = type
		end
	end
end

function interact(i, dir)
	print(i.."ping")
	--start movement
	if i == "clear" then
		if dir == "right" 
		or dir == "left"
		or dir == "up" 
		or dir == "down" then
			direction = i
			heroShiftCountdown = tileSize
			heroShifting = true
		end
	end

	if i == "map right" 
	or i == "map left"
	or i == "map up" 
	or i == "map down" then
		--??????
		direction = i
		heroShiftCountdown = tileSize
		heroShifting = true
	end
	
	-- collision or multiple directions; "nope, sorry"
	if type	== "plant" then--or numKeysPressed > 1	then
		heroGridDest = heroGridPos
		heroShiftCountdown = 0
		direction = nil
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