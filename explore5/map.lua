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
	
	--TODO i guess make this not hard-coded somehow? or just do :|
	yLen = 15--#(currentMap.tiles)
	xLen = 15--#(currentMap.tiles[1])
	
	world = {{makeMap("start")}} --all maps! also Y-X-INDEXED like map.tiles and ["events"], NOT X-Y
	worldPos = {x=1,y=1} --you have to start at 1,1 :( TODO i guesschange this, but it'll be ugly
	
	currentMap = world[worldPos.y][worldPos.x]
	
	-- some "quests" :)
	for i=1,4 do
		math.randomseed(os.time()+i) --trust me, this is necessary. ugh.
		makeMapAt(math.random(-3,3) * 2, math.random(-3,3) * 2, "bonus")
	end
	
	screenShifting = nil
	xOffsetCurrent = 0
	yOffsetCurrent = 0
	xOffsetNext = 0
	yOffsetNext = 0
	offsetCountdown = 0
	
	scrollSpeed = 500
	
	--chipset & quads for background (spriteBatches made in updateTilesetBatchCurrent using chipset)
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
	
	--spritesheet for event-layer sprites
	sprites = love.graphics.newImage("sprites1.png")
	spriteQuads = {
		map = love.graphics.newQuad(0,0,32,32,128,128),
		rock = love.graphics.newQuad(32,0,32,32,128,128),
	}

	--events, basic
	currentMap.events = emptyMapGrid()
	addEventAt(1,1,3,3,{type = "item", item = "map"}) -- gotta start somewhere
	addEventAt(1,1,13,13,{type = "rock", item = "rock"--[[meh]], collide = true})
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
			if spriteQuads[cell.item] then
				love.graphics.draw(sprites, spriteQuads[cell.item], (x-1) * tileSize, (y-1) * tileSize)
			else
				love.graphics.setColor(0,255,255,255)
				love.graphics.rectangle('line', (x-1) * tileSize + 4, (y-1) * tileSize + 4, tileSize - 8, tileSize - 8)
			end
		end
	end
end

------------------------------------------------------------------------------------------------------

-- eventually this will only be used when the world is loaded? unless you need to optimize or something :/
function makeMapAt(wx,wy,_type) -- inspect type then generate/conjure a map
	if not world[wy] then
		world[wy] = {}
	end
	
	if world[wy][wx] then
		print("error in addEventAt()")
		print("tried to add '".._type.."' to world["..wy.."]["..wx.."], but a map already exists there!")
		return false
	else
		world[wy][wx] = makeMap(_type)
	end
	
	return true			
end

function addEventAt(wx,wy,mx,my,event)
	-- make sure map exists
	if not world[wy] or not world[wy][wx] then
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

function getMap(tmi) --"target map index"
	if world[tmi.y] and world[tmi.y][tmi.x] then
		return world[tmi.y][tmi.x]
	else
		if not world[tmi.y] then
			world[tmi.y] = {}
		end
		
		-- the cute part. TODO remove this in final game? lol, obviously
		if math.random() < score / 10000 then
			m = makeMap("bonus")
		else
			m = makeMap("random")
		end

		world[tmi.y][tmi.x] = m
		return m
	end
end

function makeMap(_type)	
	if _type == "start" then
		m = makeStartMap()
	elseif _type == "random" then 
		m = makeRandomMap()
	elseif _type == "bonus" then 
		m = makeBonusMap()	
	elseif _type == "cave" then 
		m = makeCaveMap()	
	else
		print("ERROR in makeMap: unknown map type encountered.")
		return nil
	end
	
	--just a little check for myself :3 TODO keep this up-to-date whenever you add new map attributes!
	if m.mapType and m.events and m.tiles then
		return m
	else
		print("ERROR in makeMap: some necessary map attributes missing from generated map")
		return nil
	end	
end

function makeStartMap()
	m = {}
	m.tiles = {
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
	m.mapType = "start"
	m.events = emptyMapGrid()
	
	return m
end

function makeCaveMap()
	return makeStartMap()
end

function makeRandomMap()
	-- if math.random() < (score / 1000) then -- tee hee
	-- 	m = makeBonusMap()
	-- else
		m = {}
		m.tiles = {}
		for y=1, yLen do
			m.tiles[y] = {}
			for x=1, xLen do
				m.tiles[y][x] = 2- math.floor(math.random(0,80) ^ 0.25)
			end
		end
	
		m.mapType = "random"
		m.events = emptyMapGrid()
	-- end

	-- kinda the wrong place for this now TODO
	
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
	m.events = emptyMapGrid()
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

-- map.tiles is an array of arrays; this just makes a blank one the same size as that (for something like .events) 
function emptyMapGrid()
	t = {}
	for y = 1,(yLen) do
		t[y] = {}
	end
	
	return t
end