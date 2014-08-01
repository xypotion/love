function initEventSprites()
	
	--for sprite animation
	timeEventSpriteAnim = 0
	eventSpriteAnimState = 0
	eventSpriteFrameLength = .32

	--spritesheet for event-layer sprites
	--image loading + quads TODO use images w/ metadata for this? could the quad tables themselves manage their own animation with counters?? :O
	sprites = love.graphics.newImage("sprites1.png")
	spriteQuads = {
		map = love.graphics.newQuad(0*tileSize,0*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
		rock = love.graphics.newQuad(1*tileSize,0*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
		hole = love.graphics.newQuad(2*tileSize,0*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
		ladder = love.graphics.newQuad(3*tileSize,0*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
		gold = love.graphics.newQuad(0*tileSize,1*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
		elf = { --trying this way for now
			love.graphics.newQuad(0*tileSize,3*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
			love.graphics.newQuad(1*tileSize,3*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
		}
	}
end

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