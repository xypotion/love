--[[
- initializers for background tiles & tile system
- basic generation, nested-table-based storage, scrolling, and animation for certain tiles
- uses SpriteBatch to improve performance
]] 

function initTileSystem()
	
	--for tile animation
	timeBG = 0
	spriteState = 0
	frameLength = .4
	
	world = {{makeMap("start")}} --all maps! also Y-X-INDEXED like map.tiles and ["events"], NOT X-Y
	worldPos = {x=1,y=1} --you have to start at 1,1 :( TODO i guesschange this, but it'll be ugly
	
	currentMap = world[worldPos.y][worldPos.x]
	
	-- some "quests" :)
	for i=1,3 do
		math.randomseed(os.time()+i) --trust me, this is necessary. ugh.
		_x = math.random(-2,2) * 2
		_y = math.random(-2,2) * 2
		makeMapAt(_x, _y, "bonus")
		addEventAt(_x, _y, 2, 5, {type="item", sprite="gold"})
		addEventAt(_x, _y, 14, 5, {type="item", sprite="gold"})
	end
	
	screenShifting = nil
	xOffsetCurrent = 0
	yOffsetCurrent = 0
	xOffsetNext = 0
	yOffsetNext = 0
	offsetCountdown = 0
	
	--chipset & quads for background (spriteBatches made in updateTilesetBatchCurrent using chipset)
	chipset = love.graphics.newImage("chipset2.png")
	initTileQuads()
	
	tilesetBatchFramesCurrent = {}
	tilesetBatchFramesNext = {}
	for i=1, #tileQuads do
		tilesetBatchFramesCurrent[i] = love.graphics.newSpriteBatch(chipset, xLen * yLen)
		tilesetBatchFramesNext[i] = love.graphics.newSpriteBatch(chipset, xLen * yLen)
	end
	
	updateTilesetBatchCurrent()

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
	if not world[wy] then
		world[wy] = {}
	end
	
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
	m = {}
	m.tiles = {
		{6,6,6,6,6,6,6,6,6,6,6,6,6,6,6},
		{6,6,6,5,5,5,5,5,5,5,5,5,6,6,6},
		{6,6,5,5,5,5,5,5,5,5,5,5,5,6,6},
		{6,5,5,4,3,4,3,4,3,4,3,4,5,5,6},
		{6,5,4,3,4,3,4,3,4,3,4,3,4,5,6},
		{6,4,3,4,3,4,3,4,3,4,3,4,3,4,6},
		{6,4,4,3,4,3,4,3,4,3,4,3,4,4,6},
		{6,4,3,4,3,4,3,4,3,4,3,4,3,4,6},
		{6,4,4,3,4,3,4,3,4,3,4,3,4,4,6},
		{6,4,3,4,3,4,3,4,3,4,3,4,3,4,6},
		{6,4,4,3,4,3,4,3,4,3,4,3,4,4,6},
		{6,6,3,4,3,4,3,4,3,4,3,4,3,6,6},
		{6,6,6,3,4,3,4,3,4,3,4,3,6,6,6},
		{6,6,6,6,6,6,6,4,6,6,6,6,6,6,6},
		{6,6,6,6,6,6,6,4,6,6,6,6,6,6,6},
	}
	m.mapType = "start"
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
		{0,4,0,2,2,2,0,0,2,0,0,2,0,4,0},
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

function makeRandomMap()
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
	
	return m
end

--oh yes.
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