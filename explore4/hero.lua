--[[
- mostly hero input and navigation
]]

function initHero()
	heroImage = love.graphics.newImage("directional-man1.1.png")
	heroQuads = {}
	
	heroQuads["s"] = {
		love.graphics.newQuad(0,0,32,32,256,32),
		love.graphics.newQuad(32,0,32,32,256,32)
	}
	heroQuads["n"] = {
		love.graphics.newQuad(64,0,32,32,256,32),
		love.graphics.newQuad(96,0,32,32,256,32)
	}
	heroQuads["w"] = {
		love.graphics.newQuad(128,0,32,32,256,32),
		love.graphics.newQuad(160,0,32,32,256,32)
	}
	heroQuads["e"] = {
		love.graphics.newQuad(192,0,32,32,256,32),
		love.graphics.newQuad(224,0,32,32,256,32)
	}
	
	heroFrameLength = .16
	heroTime = 0
	heroSpriteState = 1
	
	heroGridPos = {8,8} --x,y
	heroGridTarget = heroGridPos
	setHeroXY()
	
	heroWalkSpeed = 200
	
	facing = "s" -- for south
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
	f = facing
	
	if love.keyboard.isDown('d', "right") then
		heroGridTarget = {heroGridPos[1] + 1, heroGridPos[2]}
		numKeysPressed = numKeysPressed + 1
		f = "e"
	end
	if love.keyboard.isDown('a', "left") then
		heroGridTarget = {heroGridPos[1] - 1, heroGridPos[2]}
		numKeysPressed = numKeysPressed + 1
		f = "w"
	end
	if love.keyboard.isDown('w', "up") then
		heroGridTarget = {heroGridPos[1], heroGridPos[2] - 1}
		numKeysPressed = numKeysPressed + 1
		f = "n"
	end
	if love.keyboard.isDown('s', "down") then
		heroGridTarget = {heroGridPos[1], heroGridPos[2] + 1}
		numKeysPressed = numKeysPressed + 1
		f = "s"
	end
	
	-- too many keys; never mind!
	if numKeysPressed > 1 then
		heroGridTarget = heroGridPos
		f = facing
	end

	-- get & set destination tile type
	if not (heroGridTarget == heroGridPos) then
		targetTileType = tileType(heroGridTarget)
	end
	
	facing = f
end

--checks targetTileType and actually kicks off the movement if "clear"
--...OR does something else if ttt != "clear"
function heroGo()
	if targetTileType == "clear" then
		heroShifting = true
		heroShiftSpeed = heroWalkSpeed
		heroDistanceFromTarget = tileSize
	elseif targetTileType == "collide" then -- for now...
		-- sound effect or something
	elseif targetTileType and string.find(targetTileType, "edge") then
		--set up screen shift ~
		--gotta change that target tile! time to fly to the far side of the map
		heroGridTarget = {(heroGridTarget[1] - 1) % xLen + 1, (heroGridTarget[2] - 1) % yLen + 1}
		heroShifting = true
		
		--we moving horizontally or vertically?
		if heroGridTarget[1] == heroGridPos[1] then
			heroShiftSpeed = scrollSpeed / yLen
			heroDistanceFromTarget = (yLen - 1) * tileSize
		elseif heroGridTarget[2] == heroGridPos[2] then
			heroShiftSpeed = scrollSpeed / xLen
			heroDistanceFromTarget = (xLen - 1) * tileSize
		else
			print("something has gone very wrong in heroGo()")
		end
		
		--and shift that screen, don't forget ~
		if targetTileType == "east edge" then
			triggerScreenShiftTo({worldPos[1] + 1, worldPos[2]})
		elseif targetTileType == "west edge" then
			triggerScreenShiftTo({worldPos[1] - 1, worldPos[2]})
		elseif targetTileType == "north edge" then
			triggerScreenShiftTo({worldPos[1], worldPos[2] - 1})
		elseif targetTileType == "south edge" then
			triggerScreenShiftTo({worldPos[1], worldPos[2] + 1})
		end
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
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(heroImage, heroQuads[facing][heroSpriteState + 1], heroX, heroY)
end