--[[
- initializers for background tiles & tile system
- basic generation, nested-table-based storage, scrolling, and animation for certain tiles
- uses SpriteBatch to improve performance
]] 

function initTileSystem()
	tileSize = 32
	
	--for animation
	timeBG = 0
	spriteState = 0
	frameLength = .4
	
	-- starting tiles
	currentMap = 
	{
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,1,0,0,0,1,0,0,0,0,0},
		{0,0,0,0,0,1,0,1,0,1,0,0,0,0,0},
		{0,0,0,0,0,1,0,1,0,1,0,0,0,0,0},
		{0,0,0,0,0,0,1,0,1,0,0,0,0,0,0},
		{0,0,1,1,0,0,0,0,0,0,0,1,1,1,0},
		{0,1,0,0,1,0,0,2,0,0,1,0,0,0,0},
		-- {0,1,1,1,1,0,2,2,2,0,1,1,1,1,0},
		{0,1,0,0,1,0,0,2,0,0,0,0,0,1,0},
		{0,1,0,0,1,0,0,0,0,0,1,1,1,0,0},
		{0,0,0,0,0,1,1,1,1,0,0,0,0,0,0},
		{0,0,0,0,0,1,0,0,0,1,0,0,0,0,0},
		{0,0,0,0,0,1,0,0,0,1,0,0,0,0,0},
		{0,0,0,0,0,1,1,1,1,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	}
	map = {{currentMap}}
	worldX = 1
	worldY = 1
		
	yLen = #(currentMap)
	xLen = #(currentMap[1])
	screenShiftingDirection = nil
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
	-- updateTilesetBatchNext()
	
	xMargin = 0
	yMargin = 0
end

function triggerScreenShift(direction)
	screenShiftingDirection = direction --?
	-- if not screenShift then
		if screenShiftingDirection == "east edge" then
			worldX = worldX + 1 --possibly move this to the end of shift(), for triggering music changes or whatever
			nextMap = getMap()
			screenShiftingDirection = "map right"
			xOffsetNext = xLen * tileSize
			offsetCountdown = xOffsetNext
		elseif screenShiftingDirection == "west edge" then
			worldX = worldX - 1
			nextMap = getMap()
			screenShiftingDirection = "map left"
			xOffsetNext = 0 - xLen * tileSize
			offsetCountdown = math.abs(xOffsetNext) -- slightly hacky...
		elseif screenShiftingDirection == "north edge" then
			worldY = worldY - 1
			nextMap = getMap()
			screenShiftingDirection = "map up"
			yOffsetNext = 0 - yLen * tileSize
			offsetCountdown = math.abs(yOffsetNext) -- slightly hacky...
		elseif screenShiftingDirection == "south edge" then
			worldY = worldY + 1
			nextMap = getMap()
			screenShiftingDirection = "map down"
			yOffsetNext = yLen * tileSize
			offsetCountdown = yOffsetNext
		else
			screenShiftingDirection = nil
		end
		
		updateTilesetBatchNext()
	-- end
end

function animateBG(dt)
	timeBG = timeBG + dt
	if timeBG > frameLength then
		timeBG = 0
		spriteState = (spriteState + 1) % 2
	end
end

function drawBGTiles()
	love.graphics.draw(tilesetBatchFramesCurrent[spriteState + 1], xOffsetCurrent + xMargin, yOffsetCurrent + yMargin)
	if screenShiftingDirection then
		love.graphics.draw(tilesetBatchFramesNext[spriteState + 1], xOffsetNext + xMargin, yOffsetNext + yMargin)
	end
end

function shiftTiles(dt)
	o = (scrollSpeed * dt)
	
	if screenShiftingDirection == "map right" then
		xOffsetNext = xOffsetNext - o
		xOffsetCurrent = xOffsetCurrent - o
	elseif screenShiftingDirection == "map left" then
		xOffsetNext = xOffsetNext + o
		xOffsetCurrent = xOffsetCurrent + o
	elseif screenShiftingDirection == "map up" then
		yOffsetNext = yOffsetNext + o
		yOffsetCurrent = yOffsetCurrent + o
	elseif screenShiftingDirection == "map down" then
		yOffsetNext = yOffsetNext - o
		yOffsetCurrent = yOffsetCurrent - o
	end
	
	offsetCountdown = offsetCountdown - o
	if offsetCountdown <= 0 then
		currentMap = nextMap
		nextMap = nil
		screenShiftingDirection = nil

		xOffsetNext = 0
		xOffsetCurrent = 0
		yOffsetNext = 0
		yOffsetCurrent = 0
		offsetCountdown = 0
		updateTilesetBatchCurrent()
		
		-- print("ping")
	end
end

function updateTilesetBatchCurrent()
	updateTilesetBatch(tilesetBatchFramesCurrent, currentMap)
end

function updateTilesetBatchNext()
	updateTilesetBatch(tilesetBatchFramesNext, nextMap)
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

function getMap()
	if map[worldY] and map[worldY][worldX] then
		return map[worldY][worldX]
	else
		if not map[worldY] then
			map[worldY] = {}
		end
		m = makeRandomMap()
		map[worldY][worldX] = m
		-- print("made a map at x="..worldX.." y="..worldY)
		return m
	end
end

function makeRandomMap()
	m = {}
	if math.random() < 0.01 then -- tee hee
		m = {
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,1,1,0,0,1,0,0,1,1,1,0,0},
			{0,0,1,0,0,0,1,0,1,0,0,1,0,0,0},
			{0,0,1,0,1,0,1,0,1,0,0,1,0,0,0},
			{0,0,0,1,1,0,0,1,0,0,0,1,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,1,0,0,0,1,0,1,1,1,0,1,0,0},
			{0,0,1,1,0,1,1,0,1,0,0,0,1,0,0},
			{0,0,1,0,1,0,1,0,1,1,0,0,1,0,0},
			{0,0,1,0,0,0,1,0,1,0,0,0,0,0,0},
			{0,0,1,0,0,0,1,0,1,1,1,0,1,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		}
	else
		for y=1, yLen do
			m[y] = {}
			for x=1, xLen do
				m[y][x] = 2- math.floor(math.random(0,80) ^ 0.25)
			end
		end
	end
	
	return m
end