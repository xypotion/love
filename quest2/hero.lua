--[[
- mostly hero input and navigation
]]

function initHero()
	actors = {
		hero = {
			image = heroDirectionalImage, --TODO
			quads = heroQuads, --TODO i guess make this less redundant
			anikey = anikeys.hero,
			currentPos = heroGridPos,
			targetPos = heroGridPos,
			distanceFromTarget = 0,
			speed = 200, --TODO update at zoom? or will that be a bigger task? (all actors' speeds have to adapt to zoom)
			facing = 's',
			screenX = 0,
			screenY = 0
		}
	}
	
	heroGridPos = nil
	
	-- heroGridTarget = heroGridPos
	setActorXY(actors.hero)
	
	heroWalkSpeed = 200 * zoom --TODO actually needs to be updated at zoom
end

function shiftActors(dt)
	for name,actor in pairs(actors) do
		shiftActor(actor, dt)
	end
end

function shiftActor(actor, dt)
	local xDelta = (actor.targetPos.x - actor.currentPos.x) * actor.speed * dt
	local yDelta = (actor.targetPos.y - actor.currentPos.y) * actor.speed * dt
	
	actor.screenX = actor.screenX + xDelta
	actor.screenY = actor.screenY + yDelta
	
	actor.distanceFromTarget = actor.distanceFromTarget - math.abs(xDelta + yDelta)
	
	if actor.distanceFromTarget <= 0 then
		heroArrive()
	end
end

function setHeroGridTargetAndTileTypeIfDirectionKeyPressed()
	--someday make the LAST-PRESSED key be the direction the hero moves, allowing many to be pressed at once? lock others until keyReleased()? hm, TODO
	-- numKeysPressed = 0
	-- f = actors.hero.facing
	
	if love.keyboard.isDown('d', "right") and not love.keyboard.isDown('a','w','s','left','up','down') then
		-- actors.hero.targetPos = {x=actors.hero.currentPos.x + 1, y=actors.hero.currentPos.y}
		-- numKeysPressed = numKeysPressed + 1
		actors.hero.facing = "e"
		actors.hero.targetPos = getGridPosInFrontOfActor(actors.hero)
	end
	if love.keyboard.isDown('a', "left") and not love.keyboard.isDown('d','w','s','right','up','down') then
		-- actors.hero.targetPos = {x=actors.hero.currentPos.x - 1, y=actors.hero.currentPos.y}
		-- numKeysPressed = numKeysPressed + 1
		actors.hero.facing = "w"
		actors.hero.targetPos = getGridPosInFrontOfActor(actors.hero)
	end
	if love.keyboard.isDown('w', "up") and not love.keyboard.isDown('a','d','s','left','right','down') then
		-- actors.hero.targetPos = {x=actors.hero.currentPos.x, y=actors.hero.currentPos.y - 1}
		-- numKeysPressed = numKeysPressed + 1
		actors.hero.facing = "n"
		actors.hero.targetPos = getGridPosInFrontOfActor(actors.hero)
	end
	if love.keyboard.isDown('s', "down") and not love.keyboard.isDown('a','w','d','left','up','right') then
		-- actors.hero.targetPos = {x=actors.hero.currentPos.x, y=actors.hero.currentPos.y + 1}
		-- numKeysPressed = numKeysPressed + 1
		actors.hero.facing = "s"
		actors.hero.targetPos = getGridPosInFrontOfActor(actors.hero)
	end
	
	-- too many keys; never mind!
	-- ...this is honestly a little lazy. i feel like the the numKeysPressed thing could be simplified (TODO?)
	-- if numKeysPressed > 1 then
	-- 	actors.hero.targetPos = actors.hero.currentPos
	-- 	f = actors.hero.facing
	-- end

	-- get & set destination tile type
	if actors.hero.targetPos ~= actors.hero.currentPos then -- how did this ever work? :o
		targetTileType = tileType(actors.hero.targetPos)
		if targetTileType == "collide" then
			actors.hero.targetPos = nil
		end
	end
	
	-- actors.hero.facing = f
end

function setActorDest()
	-- eh? will need later i guess
end

--checks targetTileType and actually kicks off the movement if "clear"
--...OR does something else if ttt != "clear"
function heroGo()
	
	if targetTileType == "clear" then
		heroShifting = true
		actors.hero.speed = heroWalkSpeed --WAIT MAYBE YOU ACTUALLY NEED THIS
		actors.hero.distanceFromTarget = tileSize
	
	elseif targetTileType == "collide" then -- for now...
		-- sound effect or something
	elseif targetTileType and string.find(targetTileType, "edge") then --set up screen shift ~
		--gotta change that target tile! time to fly to the far side of the map
		actors.hero.targetPos = {x=(actors.hero.targetPos.x - 1) % xLen + 1, y=(actors.hero.targetPos.y - 1) % yLen + 1}
		heroShifting = true
		
		--we moving horizontally or vertically?
		if actors.hero.targetPos.x == actors.hero.targetPos.x then
			actors.hero.speed = scrollSpeed / yLen
			actors.hero.distanceFromTarget = (yLen - 1) * tileSize
		elseif actors.hero.targetPos.y == actors.hero.targetPos.y then
			actors.hero.speed = scrollSpeed / xLen
			actors.hero.distanceFromTarget = (xLen - 1) * tileSize
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
	actorArrive(actors.hero)
	
	arrivalInteraction()
end

function actorArrive(actor) -- is this necessary?
	actor.distanceFromTarget = 0
	heroShifting = false
	targetTileType = nil
	
	--finalize and snap to grid
	actor.currentPos = actor.targetPos
	setActorXY(actor)
end

function setActorXY(actor)
	actor.screenX = (actor.currentPos.x - 1) * tileSize + xMargin
	actor.screenY = (actor.currentPos.y - 1) * tileSize + yMargin
end

function drawHero()
	-- love.graphics.setColor(255,255,255,255)
	-- love.graphics.draw(heroDirectionalImage, heroQuads[facing][heroQuads.anikey.frame], heroX, heroY, 0, 1, 1)
	drawActor(actors.hero)
end

function drawActor(actor)
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(actor.image, actor.quads[actor.facing][actor.anikey.frame], actor.screenX, actor.screenY, 0, 1, 1)
end