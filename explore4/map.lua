--[[
- initializers for background tiles & tile system
- basic generation, nested-table-based storage, scrolling, and animation for certain tiles
- uses SpriteBatch to improve performance
]] 

function initTileSystem()
	tileSize = 32
	xMargin = 0
	yMargin = 0
	
	--for animation
	timeBG = 0
	spriteState = 0
	frameLength = .4
	
	-- starting tiles
	currentMap = {}
	currentMap.tiles = {
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,1,0,0,0,1,0,0,0,0,0},
		{0,0,0,0,0,1,0,1,0,1,0,0,0,0,0},
		{0,0,0,0,0,1,0,1,0,1,0,0,0,0,0},
		{0,0,0,0,0,0,1,0,1,0,0,0,0,0,0},
		{0,0,1,1,0,0,0,0,0,0,0,1,1,1,0},
		{0,1,0,0,1,0,2,2,2,0,1,0,0,0,0},
		{0,1,1,1,1,0,2,0,2,0,1,1,1,1,0},
		{0,1,0,0,1,0,2,2,2,0,0,0,0,1,0},
		{0,1,0,0,1,0,0,0,0,0,1,1,1,0,0},
		{0,0,0,0,0,1,1,1,1,0,0,0,0,0,0},
		{0,0,0,0,0,1,0,0,0,1,0,0,0,0,0},
		{0,0,0,0,0,1,0,0,0,1,0,0,0,0,0},
		{0,0,0,0,0,1,1,1,1,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	}
	currentMap.mapType = "start"
	-- currentMap["last arrival tile"] --last tile hero ARRIVED at this map on, for when you implement fast-travel TODO
	
	world = {{currentMap}} --all maps! also Y-X-INDEXED like map.tiles and ["events"], NOT X-Y
	worldPos = {1,1} --x,y.events
	
	yLen = #(currentMap.tiles)
	xLen = #(currentMap.tiles[1])
	screenShifting = nil
	xOffsetCurrent = 0
	yOffsetCurrent = 0
	xOffsetNext = 0
	yOffsetNext = 0
	offsetCountdown = 0
	
	scrollSpeed = 500
	
	--chipset & quads for background	
	chipset = love.graphics.newImage("chipset2.png")
	frameQuads = {
		{
			love.graphics.newQuad(0,32,32,32,64,128),
			love.graphics.newQuad(0,0,32,32,64,128),
			love.graphics.newQuad(0,64,32,32,64,128)
		},
		{
			love.graphics.newQuad(0,32,32,32,64,128),
			love.graphics.newQuad(32,0,32,32,64,128),
			love.graphics.newQuad(0,64,32,32,64,128)
		}
	}
	
	tilesetBatchFramesCurrent = {}
	tilesetBatchFramesNext = {}
	for i=1, #frameQuads do
		tilesetBatchFramesCurrent[i] = love.graphics.newSpriteBatch(chipset, xLen * yLen)
		tilesetBatchFramesNext[i] = love.graphics.newSpriteBatch(chipset, xLen * yLen)
	end
	
	updateTilesetBatchCurrent()

	--events, basic
	currentMap.events = emptyMapGrid()
	addEventAt(1,1,3,3,{type = "item", item = "map"}) -- gotta start somewhere
	addEventAt(1,1,13,13,{type = "sign", collide = true})
end

function triggerScreenShiftTo(tmi) --"target map index"
	worldDest = tmi
	nextMap = getMap(worldDest)

	--shifting horizontally or vertically?
	if worldDest[1] == worldPos[1] then
		yOffsetNext = (worldDest[2] - worldPos[2]) * yLen * tileSize
	elseif worldDest[2] == worldPos[2] then
		xOffsetNext = (worldDest[1] - worldPos[1]) * xLen * tileSize
	else
		print("something has gone very wrong in triggerScreenShiftTo()")
	end

	offsetCountdown = math.abs(xOffsetNext + yOffsetNext)
	
	updateTilesetBatchNext()
	
	screenShifting = true
end

function shiftTiles(dt)
	xDelta = (worldPos[1] - worldDest[1]) * scrollSpeed * dt
	yDelta = (worldPos[2] - worldDest[2]) * scrollSpeed * dt
	
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
	for f=1, #frameQuads do
	  t[f]:bind()
	  t[f]:clear()
	  for y=1, yLen do
	    for x=1, xLen do
	      t[f]:add(frameQuads[f][m[y][x] + 1], (x-1)*tileSize, (y-1)*tileSize)
	    end
	  end
	  t[f]:unbind()
	end
end

function getMap(tmi) --"target map index"
	if world[tmi[2]] and world[tmi[2]][tmi[1]] then
		return world[tmi[2]][tmi[1]]
	else
		if not world[tmi[2]] then
			world[tmi[2]] = {}
		end
		m = makeRandomMap()
		world[tmi[2]][tmi[1]] = m
		-- print("made a map at x="..worldX.." y="..worldY)
		return m
	end
end

function animateBG(dt)
	timeBG = timeBG + dt
	if timeBG > frameLength then
		timeBG = 0
		spriteState = (spriteState + 1) % 2
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
			love.graphics.setColor(0,255,255,255)
			love.graphics.rectangle('line', (x-1) * tileSize + 4, (y-1) * tileSize + 4, tileSize - 8, tileSize - 8)
		end
	end
end

------------------------------------------------------------------------------------------------------

-- map.tiles is an array of arrays; this just makes a blank one the same size as that (for something like .events) 
function emptyMapGrid()
	t = {}
	for y = 1,(yLen) do
		t[y] = {}
	end
	
	return t
end

function addMapAt(wx,wy,_type)
	-- inspect type and generate/conjure a map, obvs
end

function addEventAt(wx,wy,mx,my,event)
	-- make sure map exists
	if not world[wy] then
		print("error in addEventAt()")
		print("tried to add '"..event.type.."' to world["..wy.."]["..wx.."], a non-existent map")
		return false
	end
	if not world[wy][wx] then
		print("error in addEventAt()")
		print("tried to add '"..event.type.."' to world["..wy.."]["..wx.."], a non-existent map")
		return false
	end
	
	-- should never happen if you use emptyMapGrid() properly
	if not world[wy][wx].events or not world[wy][wx].events[my] then
		print("error in addEventAt()")
		print("tried to add '"..event.type.."' to world["..wy.."]["..wx.."][\"events\"]["..my.."]["..my.."] but the [\"events\"] table is malformed")
		return false
	end
	
	-- should never happen... but could if you're sloppy with random placement
	if world[wy][wx].events[my][mx] then
		print("error in addEventAt()")
		print("tried to add '"..event.type.."' to world["..wy.."]["..wx.."][\"events\"]["..my.."]["..my.."] but there's already an event there!")
		return false
	end
	-- ...i guess also check to make sure the tile is clear so items/battles don't end up in rocks? bleh. TODO
		
	world[wy][wx].events[my][mx] = event -- whew, made it.
	return true
end

------------------------------------------------------------------------------------------------------

function makeRandomMap()
	if math.random() < (score / 1000) then -- tee hee
		m = makeBonusMap()
	else
		m = {}
		m.tiles = {}
		for y=1, yLen do
			m.tiles[y] = {}
			for x=1, xLen do
				m.tiles[y][x] = 2- math.floor(math.random(0,80) ^ 0.25)
			end
		end
	
		m.mapType = "random"
	end

	-- kinda the wrong place for this now TODO
	m.events = emptyMapGrid()
	
	return m
end

function makeBonusMap()
	m = {}
	m.tiles = {
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,2,2,2,0,0,0,2,2,0,0,0,0},
		{0,0,0,2,0,0,2,0,2,0,0,2,0,0,0},
		{0,0,0,2,2,2,0,0,2,0,0,2,0,0,0},
		{0,0,0,2,0,0,2,0,2,0,0,2,0,0,0},
		{0,0,0,2,2,2,0,0,0,2,2,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,2,0,0,2,0,2,0,0,2,0,2,2,2,0},
		{0,2,2,0,2,0,2,0,0,2,0,2,0,0,0},
		{0,2,0,2,2,0,2,0,0,2,0,0,2,0,0},
		{0,2,0,0,2,0,2,0,0,2,0,0,0,2,0},
		{0,2,0,0,2,0,0,2,2,0,0,2,2,2,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	}
	m.tiles = replaceSome0sWith1s(m.tiles)
	m.mapType = "bonus"
	return m
end

--oh yeah.
function replaceSome0sWith1s(m)
	t = {}
	for key,row in pairs(m) do
		t[key] = {}
		for k,cell in pairs(row) do
			if cell == 0 then
				t[key][k] = math.random(0,1)
			else
				t[key][k] = m[key][k]
			end
		end
	end
	return t
end
	