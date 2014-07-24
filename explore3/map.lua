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
		{0,1,0,0,1,0,2,2,2,0,1,0,0,0,0},
		{0,1,1,1,1,0,2,0,2,0,1,1,1,1,0},
		{0,1,0,0,1,0,2,2,2,0,0,0,0,1,0},
		{0,1,0,0,1,0,0,0,0,0,1,1,1,0,0},
		{0,0,0,0,0,1,1,1,1,0,0,0,0,0,0},
		{0,0,0,0,0,1,0,0,0,1,0,0,0,0,0},
		{0,0,0,0,0,1,0,0,0,1,0,0,0,0,0},
		{0,0,0,0,0,1,1,1,1,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	}
	world = {{currentMap}} --all maps!
	worldPos = {1,1} --x,y
		
	yLen = #(currentMap)
	xLen = #(currentMap[1])
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
	
	xMargin = 0
	yMargin = 0
end

function triggerScreenShiftTo(tmi) --"target map index"
	worldDest = tmi
	nextMap = getMap(worldDest)

	--moving horizontally or vertically?
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

function drawBGTiles()
	love.graphics.draw(tilesetBatchFramesCurrent[spriteState + 1], xOffsetCurrent + xMargin, yOffsetCurrent + yMargin)
	if screenShifting then
		love.graphics.draw(tilesetBatchFramesNext[spriteState + 1], xOffsetNext + xMargin, yOffsetNext + yMargin)
		-- print("ping")
	end
end

function makeRandomMap()
	m = {}
	if math.random() < (score / 1000) then -- tee hee
		m = {
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			{0,2,2,2,0,0,0,2,2,2,0,0,0,0,0},
			{0,2,0,0,2,0,2,0,0,0,2,0,0,0,0},
			{0,2,2,2,0,0,2,0,0,0,2,0,1,1,0},
			{0,2,0,0,2,0,2,0,0,0,2,0,0,0,0},
			{0,2,2,2,0,0,0,2,2,2,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			{0,2,0,0,2,0,2,0,0,2,0,2,2,2,0},
			{0,2,2,0,2,0,2,0,0,2,0,2,0,0,0},
			{0,2,0,2,2,0,2,0,0,2,0,0,2,0,0},
			{0,2,0,0,2,0,2,0,0,2,0,0,0,2,0},
			{0,2,0,0,2,0,0,2,2,0,0,2,2,2,0},
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