--[[
- mostly hero input and navigation
]]

--called from love.load() AND from updateZoomRelativeStuff(), that's why this is a little more complex than you'd expect
function initHero()
	globalActors.hero = globalActors.hero or {} 
	
	globalActors.hero = {
		complex = true,
 		image = images.characters.hero, --TODO way down the road, will need to respect choice of leaders
		quads = quadSets.characters,
		anikey = anikeys.characters,
		speed = 200 * zoom,
		
		--the ones we want to keep if simply changing zoom (otherwise set to default)
		currentPos = globalActors.hero.currentPos or heroGridPos,
		facing = globalActors.hero.facing or "s"
	}

	setActorXY(globalActors.hero)
end

-- TODO will eventually have to abstract parts of this when you add wandering townsfolk (i guess). maybe start by separating the first block?
-- TODO changing flow to not use the global var targetTileType would be nice, too
function setHeroGridTargetAndTileTypeIfDirectionKeyPressed()
	
	if love.keyboard.isDown('d', "right") and not love.keyboard.isDown('a','w','s','left','up','down') then
		globalActors.hero.facing = "e"
	elseif love.keyboard.isDown('a', "left") and not love.keyboard.isDown('d','w','s','right','up','down') then
		globalActors.hero.facing = "w"
	elseif love.keyboard.isDown('w', "up") and not love.keyboard.isDown('a','d','s','left','right','down') then
		globalActors.hero.facing = "n"
	elseif love.keyboard.isDown('s', "down") and not love.keyboard.isDown('a','w','d','left','up','right') then
		globalActors.hero.facing = "s"
	end
	
	if not love.keyboard.isDown('d','a','w','s','right','left','up','down') then
		globalActors.hero.targetPos = nil
	else
		globalActors.hero.targetPos = getGridPosInFrontOfActor(globalActors.hero)
	end
	
	-- get & set destination tile type
	if globalActors.hero.targetPos and globalActors.hero.targetPos ~= globalActors.hero.currentPos then
		targetTileType = tileType(globalActors.hero.targetPos)
		if targetTileType == "collide" then
			globalActors.hero.targetPos = nil
		end
	end
end

function setActorDest()
	-- eh? will need later i guess
end

--essentially a hero-specific action trigger, like say() and hop(), etc in cutscene.lua and scripted in cutscenes
function heroGo()
	if targetTileType == "clear" then
		globalActors.hero.distanceFromTarget = tileSize
		
		actorsShifting = actorsShifting + 1
		globalActors.hero.translatorFunction = walk
		globalActors.hero.finishFunction = heroArrive
	elseif targetTileType == "collide" then -- for now...
		-- sound effect or something
	elseif targetTileType and string.find(targetTileType, "edge") then --set up screen shift ~ TODO this is kinda inelegant
		--gotta change that target tile! time to fly to the far side of the map
		globalActors.hero.targetPos = {x=(globalActors.hero.targetPos.x - 1) % xLen + 1, y=(globalActors.hero.targetPos.y - 1) % yLen + 1}
		actorsShifting = actorsShifting + 1
		globalActors.hero.translatorFunction = screenWalk
		globalActors.hero.finishFunction = heroArrive

		--we moving horizontally or vertically? i know it seems redundant... maybe TODO remove once you finally settle on a screen size
		if globalActors.hero.currentPos.x == globalActors.hero.targetPos.x then
			globalActors.hero.distanceFromTarget = (yLen - 1) * tileSize
		elseif globalActors.hero.currentPos.y == globalActors.hero.targetPos.y then
			globalActors.hero.distanceFromTarget = (xLen - 1) * tileSize
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
	actorArrive(globalActors.hero)
	targetTileType = nil

	arrivalInteraction()
	ping "HERO ARRIVE"
end

function startFacingInteraction()
	lookinAt = getLocalActorByPos(getGridPosInFrontOfActor(globalActors.hero))
	
	if lookinAt then 
		interactWith(lookinAt)
	else 
		return false
	end
end