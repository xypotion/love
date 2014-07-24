require "map"

function love.load()
  love.window.setTitle('Löaf 2D')

	initTileSystem()
	
	initHero()
	
	math.randomseed(205)--os.time())
	
  love.window.setMode(xLen * tileSize + xMargin, yLen * tileSize + yMargin)
	
	targetTileType = nil
	
	score = 0
end

function love.update(dt)
	animateBG(dt)
	
	animateHero(dt)

	-- move map if needed
	if screenShiftingDirection then
		shiftTiles(dt)
	end
	
	-- move hero if needed
	if heroShifting then
		shiftHero(dt * heroShiftSpeed)
	end
	
	if not screenShiftingDirection and not heroShifting then --simplify? 
		-- allow player to move hero
		setHeroGridTargetAndTileTypeIfDirectionKeyPressed()
		heroGo()
	end
end

function love.draw()
	drawBGTiles()
	
	drawHero()
	
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
  love.graphics.print("SCORE: "..score, 10, 26)
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
	
	-- heroGridPos = {7,7} --x,y
	heroGridPos = {2,2}
	heroGridTarget = heroGridPos
	setHeroXY()
	
	heroWalkSpeed = 200
end

function tileType(xy)
	type = "clear"

	if xy[1] == xLen + 1 then
		type = "east edge" --trying to go beyond right edge
	elseif xy[2] == yLen + 1 then
		type = "south edge" --trying to go beyond bottom
	else
		if not currentMap[xy[2]] then
			type = "north edge" --nothing at currentMap[0]
		elseif not currentMap[xy[2]][xy[1]] then
			type = "west edge" --nothing at currentMap[y][0]
		else
			if currentMap[xy[2]][xy[1]] == 1 then
				type = "collide"
			end
		end
	end
	
	return type
end

function shiftHero(speed)
	xDelta = (heroGridTarget[1] - heroGridPos[1]) * speed
	yDelta = (heroGridTarget[2] - heroGridPos[2]) * speed
	
	heroX = heroX + xDelta
	heroY = heroY + yDelta
	
	heroDistanceFromTarget = heroDistanceFromTarget - math.abs(xDelta + yDelta)
	
	if heroDistanceFromTarget <= 0 then
		heroArrive()
		setHeroGridTargetAndTileTypeIfDirectionKeyPressed()
		heroGo()
	end
end

function setHeroGridTargetAndTileTypeIfDirectionKeyPressed()
	--someday make the LAST-PRESSED key be the direction the hero moves, allowing many to be pressed at once? lock others until keyReleased()? hm
	numKeysPressed = 0
	
	if love.keyboard.isDown('d') then
		heroGridTarget = {heroGridPos[1] + 1, heroGridPos[2]}
		numKeysPressed = numKeysPressed + 1
	end
	if love.keyboard.isDown('a') then
		heroGridTarget = {heroGridPos[1] - 1, heroGridPos[2]}
		numKeysPressed = numKeysPressed + 1
	end
	if love.keyboard.isDown('w') then
		heroGridTarget = {heroGridPos[1], heroGridPos[2] - 1}
		numKeysPressed = numKeysPressed + 1
	end
	if love.keyboard.isDown('s') then
		heroGridTarget = {heroGridPos[1], heroGridPos[2] + 1}
		numKeysPressed = numKeysPressed + 1
	end
	
	-- too many keys; never mind!
	if numKeysPressed > 1 then
		heroGridTarget = heroGridPos
	end

	-- get & set type
	if not (heroGridTarget == heroGridPos) then
		targetTileType = tileType(heroGridTarget)
	end
end

function heroGo()
	if targetTileType == "clear" then
		heroShifting = true
		heroShiftSpeed = heroWalkSpeed
		heroDistanceFromTarget = tileSize
	elseif targetTileType == "collide" then -- for now...
		-- sound effect or something
	elseif targetTileType and string.find(targetTileType, "edge") then
		--gotta change that target!
		heroGridTarget = {(heroGridTarget[1] - 1) % xLen + 1, (heroGridTarget[2] - 1) % yLen + 1}
		
		heroShifting = true
		if heroGridTarget[1] == heroGridPos[1] then
			heroShiftSpeed = scrollSpeed / yLen
			heroDistanceFromTarget = (yLen - 1) * tileSize
		elseif heroGridTarget[2] == heroGridPos[2] then
			heroShiftSpeed = scrollSpeed / xLen
			heroDistanceFromTarget = (xLen - 1) * tileSize
		else
			print("something has gone very wrong in heroGo()")
		end
		
		triggerScreenShift(targetTileType)
	end
end

function heroArrive()
	heroDistanceFromTarget = 0
	heroShifting = false
	targetTileType = nil
	
	--finalize and snap to grid
	heroGridPos = heroGridTarget
	setHeroXY()
	
	arrivalInteraction()
end

function arrivalInteraction()
	--"arrived at tile; is something supposed to happen?"
	--change later to check event layer, not map (or not primarily)
	if currentMap[heroGridPos[2]][heroGridPos[1]] == 2 then
		score = score + 1
		--play sfx
		
		currentMap[heroGridPos[2]][heroGridPos[1]] = 0
		updateTilesetBatchCurrent()
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