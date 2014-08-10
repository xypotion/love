function initEventSprites()
	
	--for sprite animation
	timeEventSpriteAnim = 0
	eventSpriteAnimState = 0
	eventSpriteFrameLength = .32

	--spritesheet for event-layer sprites
	--image loading + quads TODO use images w/ metadata for this? could the quad tables themselves manage their own animation with counters?? :O
	-- sprites = love.graphics.newImage("img/sprites1.png")
	-- spriteQuads = {
	-- 	map = love.graphics.newQuad(0*tileSize,0*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
	-- 	rock = love.graphics.newQuad(1*tileSize,0*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
	-- 	hole = love.graphics.newQuad(2*tileSize,0*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
	-- 	ladder = love.graphics.newQuad(3*tileSize,0*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
	-- 	gold = love.graphics.newQuad(0*tileSize,1*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
	-- 	elf = { --trying this way for now
	-- 		love.graphics.newQuad(0*tileSize,3*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
	-- 		love.graphics.newQuad(1*tileSize,3*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
	-- 	}
	-- }
end

function drawEvents()
	-- this SEEMS processor-intensive but didn't hurt framerate in dev...? definitely willing to refactor events' table structure if it gets heavy, though TODO
	for y, row in pairs(currentMap.events) do
		for x, e in pairs(row) do
			if e.spriteQuad then 
				-- if it's animated, .sprite will be a table!
				-- OR it'll always be a table, just use current frame as a key; for non-animated sprites, this will always be 1 :)
				if e.anikey then
					love.graphics.draw(e.spriteImage, e.spriteQuad[e.anikey.frame], (x-1) * tileSize, (y-1) * tileSize) --TODO make this cleaner?
				else
					love.graphics.draw(e.spriteImage, e.spriteQuad, (x-1) * tileSize, (y-1) * tileSize)
				end
			else
				--stand-in for missing event sprites
				love.graphics.setColor(0,255,255,255)
				love.graphics.rectangle('line', (x-1) * tileSize + 4, (y-1) * tileSize + 4, tileSize - 8, tileSize - 8)
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------

function interactWith(event)
			print "ping interaction func"
			
	--TODO probably unnecessary, all of this
	-- bs = event.interactionBehavior -- "behavior script"
	-- if not bs then
	-- 	return false
	-- else
		startScript(event)
	-- end
end

function startFacingInteraction()
	
	--TODO i feel like this is the wrong place for this, but maybe whatever
	lookinAt = {}
	if facing == "s" then
		lookinAt.x = heroGridPos.x
		lookinAt.y = heroGridPos.y+1
	elseif facing == "n" then
		lookinAt.x = heroGridPos.x
		lookinAt.y = heroGridPos.y-1
	elseif facing == "e" then
		lookinAt.x = heroGridPos.x+1
		lookinAt.y = heroGridPos.y
	elseif facing == "w" then
		lookinAt.x = heroGridPos.x-1
		lookinAt.y = heroGridPos.y
	end
	
	-- get event if any
	if currentMap.events[lookinAt.y] and currentMap.events[lookinAt.y][lookinAt.x] then 
		interactWith(currentMap.events[lookinAt.y][lookinAt.x])
	else 
		return false
	end
end

-- function getEventByPosition(x,y)
-- 	return currentMap.events[y][x]
-- end

function getEventByPosition(pos)
	if pos.x and pos.y then
		return currentMap.events[pos.y][pos.x]
	else
		return currentMap.events[pos[2]][pos[1]]
	end
end