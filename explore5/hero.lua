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
	
	heroGridPos = {x=8,y=8} --x,y
	heroGridTarget = heroGridPos
	setHeroXY()
	
	heroWalkSpeed = 200
	
	facing = "s" -- for south
end

function shiftHero(speed)
	xDelta = (heroGridTarget.x - heroGridPos.x) * speed
	yDelta = (heroGridTarget.y - heroGridPos.y) * speed
	
	heroX = heroX + xDelta
	heroY = heroY + yDelta
	
	heroDistanceFromTarget = heroDistanceFromTarget - math.abs(xDelta + yDelta)
	
	if heroDistanceFromTarget <= 0 then
		heroArrive()
	end
end

function setHeroGridTargetAndTileTypeIfDirectionKeyPressed()
	--someday make the LAST-PRESSED key be the direction the hero moves, allowing many to be pressed at once? lock others until keyReleased()? hm, TODO
	numKeysPressed = 0
	f = facing
	
	if love.keyboard.isDown('d', "right") then
		heroGridTarget = {x=heroGridPos.x + 1, y=heroGridPos.y}
		numKeysPressed = numKeysPressed + 1
		f = "e"
	end
	if love.keyboard.isDown('a', "left") then
		heroGridTarget = {x=heroGridPos.x - 1, y=heroGridPos.y}
		numKeysPressed = numKeysPressed + 1
		f = "w"
	end
	if love.keyboard.isDown('w', "up") then
		heroGridTarget = {x=heroGridPos.x, y=heroGridPos.y - 1}
		numKeysPressed = numKeysPressed + 1
		f = "n"
	end
	if love.keyboard.isDown('s', "down") then
		heroGridTarget = {x=heroGridPos.x, y=heroGridPos.y + 1}
		numKeysPressed = numKeysPressed + 1
		f = "s"
	end
	
	-- too many keys; never mind!
	if numKeysPressed > 1 then
		heroGridTarget = heroGridPos
		f = facing
	end

	-- get & set destination tile type
	if heroGridTarget ~= heroGridPos then
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
	elseif targetTileType and string.find(targetTileType, "edge") then --set up screen shift ~
		--gotta change that target tile! time to fly to the far side of the map
		heroGridTarget = {x=(heroGridTarget.x - 1) % xLen + 1, y=(heroGridTarget.y - 1) % yLen + 1}
		heroShifting = true
		
		--we moving horizontally or vertically?
		if heroGridTarget.x == heroGridPos.x then
			heroShiftSpeed = scrollSpeed / yLen
			heroDistanceFromTarget = (yLen - 1) * tileSize
		elseif heroGridTarget.y == heroGridPos.y then
			heroShiftSpeed = scrollSpeed / xLen
			heroDistanceFromTarget = (xLen - 1) * tileSize
		else
			print("something has gone very wrong in heroGo()")
		end
		
		--and shift that screen, don't forget ~
		if targetTileType == "east edge" then
			triggerScreenShiftTo({x = worldPos.x + 1, y = worldPos.y})
		elseif targetTileType == "west edge" then
			triggerScreenShiftTo({x = worldPos.x - 1, y = worldPos.y})
		elseif targetTileType == "north edge" then
			triggerScreenShiftTo({x = worldPos.x, y = worldPos.y - 1})
		elseif targetTileType == "south edge" then
			triggerScreenShiftTo({x = worldPos.x, y = worldPos.y + 1})
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
	heroX = (heroGridPos.x - 1) * tileSize + xMargin
	heroY = (heroGridPos.y - 1) * tileSize + yMargin
end

function animateHero(dt)
	-- could actually see setting the current quad in here to simplify drawHero(), especially after implementing directional sprites. TODO
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