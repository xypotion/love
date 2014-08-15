--[[
- initializers for background tiles & tile system
- basic generation, nested-table-based storage, scrolling, and animation for certain tiles
- uses SpriteBatch to improve performance
]] 

function initMapSystem()
	screenShifting = false
	xOffsetCurrent = 0
	yOffsetCurrent = 0
	xOffsetNext = 0
	yOffsetNext = 0
	offsetCountdown = 0
	
	world = loadMapData()
		
	currentMap = world[worldPos.y][worldPos.x]
	
	initMapSpriteBatchFrames()
	
	updateMapSpriteBatchFramesCurrent()
	
	loadLocalActors()
end

------------------------------------------------------------------------------------------------------

function initMapSpriteBatchFrames()
	mapSpriteBatchFramesCurrent = {}
	mapSpriteBatchFramesNext = {}
	for i=1, 2 do --TODO don't have 2 hard-coded? or do and accept it. it's the NUMBER OF FRAMES the map tiles can animate with
		--TODO fetch image properly
		mapSpriteBatchFramesCurrent[i] = love.graphics.newSpriteBatch(images.mapChipsets[1], xLen * yLen)
		mapSpriteBatchFramesNext[i] = love.graphics.newSpriteBatch(images.mapChipsets[1], xLen * yLen)
	end
	
	scrollSpeed = 500 * zoom
end

-- TODO make this more consistent and concise with respect to actual map data
	-- like i guess at least refer to some tile-type-to-collision matrix at a higher level
function tileType(tile)
	
	--quick hack, figure out later if there's a better way TODO
	if not tile then
		return false
	end
	
	_type = "clear"
	if tile.x == xLen + 1 then
		
		--somewhat redundant as these values are translated immediately in heroGo() to the more useful worldDest. fine for now, though
		_type = "east edge"
	elseif tile.y == yLen + 1 then
		_type = "south edge"
	else
		if not currentMap.tiles[tile.y] then
			_type = "north edge"
		elseif not currentMap.tiles[tile.y][tile.x] then
			_type = "west edge"
		else
			
			-- visible tile, so what _type is it?
			if currentMap.tiles[tile.y][tile.x] == 3 then -- water
				_type = "collide"
			elseif currentMap.tiles[tile.y][tile.x] == 6 then -- stone
				_type = "collide"
			elseif currentMap.tiles[tile.y][tile.x] == 7 then -- stone
				_type = "collide"
			else
				
				--theoretically clear on the tile level, now a check actor collision. GLOBAL ACTORS NEVER COLLIDE OR INTERACT
				localActor = getLocalActorByPos(tile)
				if localActor and localActor.collide then
					_type = "collide"
				end
 			end
		end
	end
	
	return _type
end

function triggerScreenShiftTo(tmi) --"target map index"
	worldDest = tmi
	
	nextMap = getMap(worldDest)

	--shifting horizontally or vertically?
	if worldDest.x == worldPos.x then
		yOffsetNext = (worldDest.y - worldPos.y) * yLen * tileSize
	elseif worldDest.y == worldPos.y then
		xOffsetNext = (worldDest.x - worldPos.x) * xLen * tileSize
	else
		print("something has gone very wrong in triggerScreenShiftTo()")
	end

	offsetCountdown = math.abs(xOffsetNext + yOffsetNext)
	
	updateMapSpriteBatchFramesNext()
	
	screenShifting = true
end

function shiftTiles(dt)
	xDelta = (worldPos.x - worldDest.x) * scrollSpeed * dt
	yDelta = (worldPos.y - worldDest.y) * scrollSpeed * dt
	
	xOffsetCurrent = xOffsetCurrent + xDelta
	yOffsetCurrent = yOffsetCurrent + yDelta
	xOffsetNext = xOffsetNext + xDelta
	yOffsetNext = yOffsetNext + yDelta
	
	offsetCountdown = offsetCountdown - math.abs(xDelta + yDelta)
	
	if offsetCountdown <= 0 then
		mapArrive()
		updateMapSpriteBatchFramesCurrent()
	end
end

function mapArrive()
	currentMap = nextMap
	worldPos = worldDest
	nextMap = nil
	screenShifting = nil

	xOffsetNext = 0
	xOffsetCurrent = 0
	yOffsetNext = 0
	yOffsetCurrent = 0
	offsetCountdown = 0
	
	-- loadCurrentMapEvents()
	loadLocalActors()
end

function updateMapSpriteBatchFramesCurrent()
	updateMapSpriteBatchFrames(mapSpriteBatchFramesCurrent, currentMap.tiles)
end

function updateMapSpriteBatchFramesNext()
	updateMapSpriteBatchFrames(mapSpriteBatchFramesNext, nextMap.tiles)
end

function updateMapSpriteBatchFrames(t, _tiles)
	for f=1, 2 do --TODO don't have f (frame) hard-coded to 1-2? or do and accept it. maybe check a "master" anikey for map animation
									--kind of need a master anikey for spriteBatch animation ticks anyway, since you can't check individual tiles for that!
	  t[f]:bind()
	  t[f]:clear()
	  for y=1, yLen do
	    for x=1, xLen do
				if type(mapTileQuads[_tiles[y][x]]) == "table" then
		      t[f]:add(mapTileQuads[_tiles[y][x]][f], (x-1)*tileSize, (y-1)*tileSize)
				else
		      t[f]:add(mapTileQuads[_tiles[y][x]], (x-1)*tileSize, (y-1)*tileSize)
				end
	    end
	  end
	  t[f]:unbind()
	end
end

function drawMap()
	love.graphics.draw(mapSpriteBatchFramesCurrent[anikeys.map.frame], xOffsetCurrent + xMargin, yOffsetCurrent + yMargin)
	
	if screenShifting then
		love.graphics.draw(mapSpriteBatchFramesNext[anikeys.map.frame], xOffsetNext + xMargin, yOffsetNext + yMargin)
	end
end

function getGridPosInFrontOfActor(a)
	local pos = {}
	
	if a.facing == "s" then
		pos = {x = a.currentPos.x, y = a.currentPos.y + 1}
	elseif a.facing == "n" then
		pos = {x = a.currentPos.x, y = a.currentPos.y - 1}
	elseif a.facing == "e" then
		pos = {x = a.currentPos.x + 1, y = a.currentPos.y}
	elseif a.facing == "w" then
		pos = {x = a.currentPos.x - 1, y = a.currentPos.y}
	else
		print "ERROR: actor's facing not n/e/w/s. what's the bizness?"
	end
	
	return pos
end

------------------------------------------------------------------------------------------------------

function getMap(tmi) --"target map index"
	if world[tmi.y] and world[tmi.y][tmi.x] then
		return world[tmi.y][tmi.x]
	else
		if not world[tmi.y] then
			world[tmi.y] = {}
		end
		
		m = makeMap("random"); print("making a random map on the fly?!")
		-- TODO replace with whole map loader module!

		world[tmi.y][tmi.x] = m
		return m
	end
end