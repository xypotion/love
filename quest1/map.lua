--[[
- initializers for background tiles & tile system
- basic generation, nested-table-based storage, scrolling, and animation for certain tiles
- uses SpriteBatch to improve performance
]] 

function initMapSystem()
	
	screenShifting = nil
	xOffsetCurrent = 0
	yOffsetCurrent = 0
	xOffsetNext = 0
	yOffsetNext = 0
	offsetCountdown = 0
	
	--for tile animation
	timeBG = 0
	spriteState = 0
	frameLength = .4
	
	world = loadMapData()
		
	currentMap = world[worldPos.y][worldPos.x]
	
	--chipset & quads for background (spriteBatches made in updateTilesetBatchCurrent using chipset)
	chipset = love.graphics.newImage("img/chipset2.png")
	initTileQuads()
	
	tilesetBatchFramesCurrent = {}
	tilesetBatchFramesNext = {}
	for i=1, #tileQuads do
		tilesetBatchFramesCurrent[i] = love.graphics.newSpriteBatch(chipset, xLen * yLen)
		tilesetBatchFramesNext[i] = love.graphics.newSpriteBatch(chipset, xLen * yLen)
	end
	
	updateTilesetBatchCurrent()
end 

-- TODO delete me!
--[[
	...
	-- some "quests" :)
	for i=1,3 do
		math.randomseed(os.time()+i) --trust me, this is necessary. ugh.
		_x = math.random(-2,2) * 2
		_y = math.random(-2,2) * 2
		makeMapAt(_x, _y, "bonus")
		addEventAt(_x, _y, 2, 5, {type="item", sprite="gold"})
		addEventAt(_x, _y, 14, 5, {type="item", sprite="gold"})
	end
	...
	tilesetBatchFramesCurrent = {}
	tilesetBatchFramesNext = {}
	for i=1, #tileQuads do
		tilesetBatchFramesCurrent[i] = love.graphics.newSpriteBatch(chipset, xLen * yLen)
		tilesetBatchFramesNext[i] = love.graphics.newSpriteBatch(chipset, xLen * yLen)
	end
	...
	--events, basic
	currentMap.events = emptyMapGrid()
	addEventAt(1,1,3,3,{type = "item", sprite = "map"}) -- gotta start somewhere
	addEventAt(1,1,13,13,{type = "rock", sprite = "rock", collide = true})
	
	--the cave ~
	makeMapAt(99,99,"cave")
	addEventAt(99,99,8,4,{type = "warp", sprite = "ladder", destination = {wx=1,wy=1,mx=13,my=12}})	
	addEventAt(99,99,8,3,{type = "rock", sprite = "ladder", collide = true})	
	addEventAt(99,99,8,14,{type = "npc", sprite = "elf", collide = true})	
	
	--FOR TESTING TEXT & SCENE INTERACTION
	addEventAt(1,1,8,5,{type = "npc", sprite = "elf", collide = true})	
end
]]

------------------------------------------------------------------------------------------------------

function initTileQuads()
	tileQuads = {
		{
			love.graphics.newQuad(0*tileSize,1*tileSize,1*tileSize,1*tileSize,2*tileSize,4*tileSize), --0: grass
			love.graphics.newQuad(0*tileSize,0*tileSize,1*tileSize,1*tileSize,2*tileSize,4*tileSize), --1: water FRAME 1
			love.graphics.newQuad(0*tileSize,2*tileSize,1*tileSize,1*tileSize,2*tileSize,4*tileSize), --2: flower
			love.graphics.newQuad(1*tileSize,1*tileSize,1*tileSize,1*tileSize,2*tileSize,4*tileSize), --3: dirt a
			love.graphics.newQuad(1*tileSize,2*tileSize,1*tileSize,1*tileSize,2*tileSize,4*tileSize), --4: dirt b
			love.graphics.newQuad(0*tileSize,3*tileSize,1*tileSize,1*tileSize,2*tileSize,4*tileSize), --5: solid stone
			love.graphics.newQuad(1*tileSize,3*tileSize,1*tileSize,1*tileSize,2*tileSize,4*tileSize), --6: DARkness
		},
		{
			love.graphics.newQuad(0*tileSize,1*tileSize,1*tileSize,1*tileSize,2*tileSize,4*tileSize),
			love.graphics.newQuad(1*tileSize,0*tileSize,1*tileSize,1*tileSize,2*tileSize,4*tileSize), --1: water FRAME 2
			love.graphics.newQuad(0*tileSize,2*tileSize,1*tileSize,1*tileSize,2*tileSize,4*tileSize), --2: flower
			love.graphics.newQuad(1*tileSize,1*tileSize,1*tileSize,1*tileSize,2*tileSize,4*tileSize), --3: dirt a
			love.graphics.newQuad(1*tileSize,2*tileSize,1*tileSize,1*tileSize,2*tileSize,4*tileSize), --4: dirt b
			love.graphics.newQuad(0*tileSize,3*tileSize,1*tileSize,1*tileSize,2*tileSize,4*tileSize), --5: solid stone
			love.graphics.newQuad(1*tileSize,3*tileSize,1*tileSize,1*tileSize,2*tileSize,4*tileSize), --6: DARkness
		}
	}
	
	scrollSpeed = 500 * zoom
end

-- TODO make this more consistent and concise with respect to actual map data
function tileType(tile)
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
			if currentMap.tiles[tile.y][tile.x] == 1 then -- water
				_type = "collide"
			elseif currentMap.tiles[tile.y][tile.x] == 5 then -- stone
				_type = "collide"
			elseif currentMap.tiles[tile.y][tile.x] == 6 then -- stone
				_type = "collide"
			else
				
				--theoretically clear on the tile level, now a quick check at event collision:
				-- TODO maybe make this call out to a different manager? it works like this, but i don't like it
				if currentMap.events[tile.y][tile.x] then
					if currentMap.events[tile.y][tile.x].collide then 
						_type = "collide"
					end
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
	
	updateTilesetBatchNext()
	
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
		updateTilesetBatchCurrent()
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
end

function updateTilesetBatchCurrent()
	updateTilesetBatch(tilesetBatchFramesCurrent, currentMap.tiles)
end

function updateTilesetBatchNext()
	updateTilesetBatch(tilesetBatchFramesNext, nextMap.tiles)
end

function updateTilesetBatch(t, m)
	for f=1, #tileQuads do
	  t[f]:bind()
	  t[f]:clear()
	  for y=1, yLen do
	    for x=1, xLen do
	      t[f]:add(tileQuads[f][m[y][x] + 1], (x-1)*tileSize, (y-1)*tileSize)
	    end
	  end
	  t[f]:unbind()
	end
end

function animateBG(dt)
	timeBG = timeBG + dt
	if timeBG > frameLength then
		timeBG = 0
		spriteState = (spriteState + 1) % 2
	end
end

function animateEventSprites(dt)
	timeEventSpriteAnim = timeEventSpriteAnim + dt
	if timeEventSpriteAnim > eventSpriteFrameLength then
		timeEventSpriteAnim = 0
		eventSpriteAnimState = (eventSpriteAnimState + 1) % 2
	end
end

function drawMap()
	love.graphics.draw(tilesetBatchFramesCurrent[spriteState + 1], xOffsetCurrent + xMargin, yOffsetCurrent + yMargin)
	if screenShifting then
		love.graphics.draw(tilesetBatchFramesNext[spriteState + 1], xOffsetNext + xMargin, yOffsetNext + yMargin)
	end
end

function drawEvents()
	-- this SEEMS processor-intensive but didn't hurt framerate in dev...? definitely willing to refactor events' table structure if it gets heavy, though TODO
	for y, row in pairs(currentMap.events) do
		for x, cell in pairs(row) do
			if spriteQuads[cell.sprite] then 
				if type(spriteQuads[cell.sprite]) == "table" then
					love.graphics.draw(sprites, spriteQuads[cell.sprite][eventSpriteAnimState + 1], (x-1) * tileSize, (y-1) * tileSize) --TODO make this cleaner?
				else
					love.graphics.draw(sprites, spriteQuads[cell.sprite], (x-1) * tileSize, (y-1) * tileSize)
				end
			else
				--stand-in event sprites
				love.graphics.setColor(0,255,255,255)
				love.graphics.rectangle('line', (x-1) * tileSize + 4, (y-1) * tileSize + 4, tileSize - 8, tileSize - 8)
			end
		end
	end
end

------------------------------------------------------------------------------------------------------

-- eventually this will only be used when the world is loaded? unless you need to optimize or something :/
function makeMapAt(wx,wy,_type) -- inspect type then generate/conjure a map
	-- if not world[wy] then
	-- 	world[wy] = {}
	-- end
	
	if world[wy][wx] then
		print("error in addEventAt()")
		print("tried to add a/n ".._type.." to world["..wy.."]["..wx.."], but a map already exists there!")
		return false
	else
		world[wy][wx] = makeMap(_type)
	end
	
	return true			
end

function replaceEventAt(wx,wy,mx,my,event)
	return makeEventAt(wx,wy,mx,my,event,true)
end

function addEventAt(wx,wy,mx,my,event)
	return makeEventAt(wx,wy,mx,my,event,false)
end

function makeEventAt(wx,wy,mx,my,event,replace)
	-- make sure map exists
	if not world[wy] or not world[wy][wx] then
		print("error in addEventAt()")
		print("tried to add a/n "..event.type.." to world["..wy.."]["..wx.."], a non-existent map")
		return false
	end
	
	-- should never happen if you use emptyMapGrid() properly
	if not world[wy][wx].events or not world[wy][wx].events[my] then
		print("error in addEventAt()")
		print("tried to add a/n "..event.type.." to world["..wy.."]["..wx.."][\"events\"]["..my.."]["..my.."] but the [\"events\"] table is malformed")
		return false
	end
	
	-- should never happen... but could if you're sloppy with random placement
	if not replace and world[wy][wx].events[my][mx] then
		print("error in addEventAt()")
		print("tried to add a/n "..event.type.." to world["..wy.."]["..wx.."][\"events\"]["..my.."]["..my.."] but there's already an event there!")
		return false
	else
		
	end
	-- ...i guess also check to make sure the tile is clear so items/battles don't end up in rocks? bleh. TODO
		
	world[wy][wx].events[my][mx] = event -- whew, made it.
	return true
end

------------------------------------------------------------------------------------------------------

function getMap(tmi) --"target map index"
	if world[tmi.y] and world[tmi.y][tmi.x] then
		return world[tmi.y][tmi.x]
	else
		if not world[tmi.y] then
			world[tmi.y] = {}
		end
		
		-- that cute part :3
		if math.random() < score / 10000 then
			m = makeMap("bonus")
		else
			m = makeMap("flat")
		end
		-- TODO replace with whole map loader module!

		world[tmi.y][tmi.x] = m
		return m
	end
end