--[[
- initializers for background tiles & tile system
- basic generation, nested-table-based storage, scrolling, and animation for certain tiles
- uses SpriteBatch to improve performance
]] 

function explore(key)
	if not screenShift then		
		if key == "d" then
			worldX = worldX + 1
			nextMap = getMap()
			screenShift = "right"
			xOffsetNext = xLen * tileSize
			offsetCountdown = xOffsetNext
		elseif key == "a" then
			worldX = worldX - 1
			nextMap = getMap()
			screenShift = "left"
			xOffsetNext = 0 - xLen * tileSize
			offsetCountdown = math.abs(xOffsetNext) -- slightly hacky...
		elseif key == "w" then
			worldY = worldY - 1
			nextMap = getMap()
			screenShift = "up"
			yOffsetNext = 0 - yLen * tileSize
			offsetCountdown = math.abs(yOffsetNext) -- slightly hacky...
		elseif key == "s" then
			worldY = worldY + 1
			nextMap = getMap()
			screenShift = "down"
			yOffsetNext = yLen * tileSize
			offsetCountdown = yOffsetNext
		end
		
		if screenShift then
			updateTilesetBatchNext()
		end
	end
end

function animateBG(dt)
	time = time + dt
	if time > frameLength then
		time = 0
		spriteState = (spriteState + 1) % 2
	end
end

function drawBGTiles()
	love.graphics.draw(tilesetBatchFramesCurrent[spriteState + 1], xOffsetCurrent + xMargin, yOffsetCurrent + yMargin)
	if screenShift then
		love.graphics.draw(tilesetBatchFramesNext[spriteState + 1], xOffsetNext + xMargin, yOffsetNext + yMargin)
	end
end

function initTileSystem()
	tileSize = 32
	
	--for animation
	time = 0
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
		{0,1,1,1,1,0,2,2,2,0,1,1,1,1,0},
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
	screenShift = nil
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
			love.graphics.newQuad(0,0,32,32,64,128),
			love.graphics.newQuad(0,32,32,32,64,128),
			love.graphics.newQuad(0,64,32,32,64,128)
		},
		{
			love.graphics.newQuad(32,0,32,32,64,128),
			love.graphics.newQuad(0,32,32,32,64,128),
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

function shiftTiles(dt)
	o = (scrollSpeed * dt)
	
	if screenShift == "right" then
		xOffsetNext = xOffsetNext - o
		xOffsetCurrent = xOffsetCurrent - o
	elseif screenShift == "left" then
		xOffsetNext = xOffsetNext + o
		xOffsetCurrent = xOffsetCurrent + o
	elseif screenShift == "up" then
		yOffsetNext = yOffsetNext + o
		yOffsetCurrent = yOffsetCurrent + o
	elseif screenShift == "down" then
		yOffsetNext = yOffsetNext - o
		yOffsetCurrent = yOffsetCurrent - o
	end
	
	offsetCountdown = offsetCountdown - o
	if offsetCountdown <= 0 then
		currentMap = nextMap
		nextMap = nil
		screenShift = nil

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
	  for y=1, xLen do
	    for x=1, yLen do
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