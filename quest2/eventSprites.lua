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

function eventInteraction(e)	
	
	-- TODO a whole fetch & process structure is needed here
	
	-- ...so we'll hack it for now!
	event = currentMap.events[heroGridPos.y][heroGridPos.x]
	if event then
		if event.type == "item" and event.sprite == "map" then
			paused = true
			currentMap.events[heroGridPos.y][heroGridPos.x] = nil
		elseif event.type == "item" and event.sprite == "gold" then
			score = score + 50
			currentMap.events[heroGridPos.y][heroGridPos.x] = nil
		elseif event.type == "warp" then
			startWarpTo(event.destination)
		end

		--play sfx? TODO sound is kiind of a big deal
	end
end