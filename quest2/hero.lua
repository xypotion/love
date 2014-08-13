--[[
- mostly hero input and navigation
]]

function initHero()
	-- TODO this is all a little hacky, but i think fine for now. hero walk sprite will have to be able to change on the fly eventually
	actors.hero = {
		image = heroDirectionalImage, --TODO
		quads = heroQuads, --TODO i guess make this less redundant
		anikey = anikeys.hero,
		currentPos = heroGridPos,
		targetPos = heroGridPos,
		distanceFromTarget = 0,
		speed = 200 * zoom, --TODO update at zoom? or will that be a bigger task? (all actors' speeds have to adapt to zoom)
		facing = 's',
		screenX = 0,
		screenY = 0
	}
	
	heroGridPos = nil
	
	-- heroGridTarget = heroGridPos
	setActorXY(actors.hero)
	
	-- heroWalkSpeed = 200 * zoom --TODO actually needs to be updated at zoom
end

-- TODO will eventually have to abstract parts of this when you add wandering townsfolk (i guess)
function setHeroGridTargetAndTileTypeIfDirectionKeyPressed()
	--someday make the LAST-PRESSED key be the direction the hero moves, allowing many to be pressed at once? lock others until keyReleased()? hm, TODO
	
	if love.keyboard.isDown('d', "right") and not love.keyboard.isDown('a','w','s','left','up','down') then
		actors.hero.facing = "e"
		actors.hero.targetPos = getGridPosInFrontOfActor(actors.hero)
	end
	if love.keyboard.isDown('a', "left") and not love.keyboard.isDown('d','w','s','right','up','down') then
		actors.hero.facing = "w"
		actors.hero.targetPos = getGridPosInFrontOfActor(actors.hero)
	end
	if love.keyboard.isDown('w', "up") and not love.keyboard.isDown('a','d','s','left','right','down') then
		actors.hero.facing = "n"
		actors.hero.targetPos = getGridPosInFrontOfActor(actors.hero)
	end
	if love.keyboard.isDown('s', "down") and not love.keyboard.isDown('a','w','d','left','up','right') then
		actors.hero.facing = "s"
		actors.hero.targetPos = getGridPosInFrontOfActor(actors.hero)
	end
	
	-- get & set destination tile type
	if actors.hero.targetPos ~= actors.hero.currentPos then -- how did this ever work? :o
		targetTileType = tileType(actors.hero.targetPos)
		if targetTileType == "collide" then
			actors.hero.targetPos = nil
		end
	end
end

function setActorDest()
	-- eh? will need later i guess
end

--essentially a hero-specific action trigger, like walk() and hop() etc. in cutscene.lua and scripted in cutscenes :)
function heroGo()
	if targetTileType == "clear" then
		actors.hero.distanceFromTarget = tileSize
		
		actorsShifting = actorsShifting + 1
		actors.hero.translatorFunction = walk
		actors.hero.finishFunction = heroArrive
	elseif targetTileType == "collide" then -- for now...
		-- sound effect or something
	elseif targetTileType and string.find(targetTileType, "edge") then --set up screen shift ~
		--gotta change that target tile! time to fly to the far side of the map
		actors.hero.targetPos = {x=(actors.hero.targetPos.x - 1) % xLen + 1, y=(actors.hero.targetPos.y - 1) % yLen + 1}
		actorsShifting = actorsShifting + 1
		actors.hero.translatorFunction = screenWalk
		actors.hero.finishFunction = heroArrive

		--we moving horizontally or vertically? TODO is this necessary? :S
		if actors.hero.currentPos.x == actors.hero.targetPos.x then
			actors.hero.distanceFromTarget = (yLen - 1) * tileSize
		elseif actors.hero.currentPos.y == actors.hero.targetPos.y then
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

function heroArrive(actor) --TODO why the arg?
	actorArrive(actor)
	targetTileType = nil

	arrivalInteraction()
end