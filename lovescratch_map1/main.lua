function love.load()
	tileSize = 32
	
	math.randomseed(os.time())
	
	--for animation
	time = 0
	spriteState = 0
	frameLength = .4
	
	--chipset & quads for background
	chipset = love.graphics.newImage("chipset2.png")
	quads = {
		water0 = love.graphics.newQuad(0,0,32,32,64,128),
		water1 = love.graphics.newQuad(32,0,32,32,64,128),
		dirt1 = love.graphics.newQuad(0,32,32,32,64,128),
		rock1 = love.graphics.newQuad(0,64,32,32,64,128),
	}
	
	xMargin = 10
	yMargin = 40
	
	-- starting tiles
	map = {
		{
			{
				{0,0,0,0,0,0,0,0,0,0},
				{0,1,2,1,0,0,0,0,0,0},
				{0,2,2,2,0,0,0,0,0,0},
				{0,1,2,1,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0},
				{0,1,2,1,0,0,0,0,0,0},
				{0,2,2,2,0,0,0,0,0,0},
				{0,1,2,1,0,0,0,0,0,0},
				{0,0,0,0,0,0,0,0,0,0}
			}
		}
	}
	worldX = 1
	worldY = 1
		
	yLen = #(map[1][1])
	xLen = #(map[1][1][1])
	currentMap = map[1][1]
	screenShift = nil
	xOffsetCurrent = 0
	offsetCountdown = 0
	
	scrollSpeed = 256
end

function love.update(dt)
	time = time + dt
	if time > frameLength then
		time = 0
		spriteState = (spriteState + 1) % 2
	end
	
	if screenShift then
		o = (scrollSpeed * dt)
		
		if screenShift == "right" then
			xOffsetNext = xOffsetNext - o
			xOffsetCurrent = xOffsetCurrent - o
		elseif screenShift == "left" then
			xOffsetNext = xOffsetNext + o
			xOffsetCurrent = xOffsetCurrent + o
		end
		
		offsetCountdown = offsetCountdown - o
		if offsetCountdown <= 0 then
			currentMap = nextMap
			nextMap = nil
			screenShift = nil

			xOffsetNext = 0
			xOffsetCurrent = 0
			offsetCountdown = 0
			
			-- print("ping")
		end
	end
end

function love.draw()
	for y=1, yLen do
		for x=1, xLen do
			q = nil
			if currentMap[y][x] == 0 then q = quads["water"..spriteState]
			elseif currentMap[y][x] == 1 then q = quads["dirt1"]
			elseif currentMap[y][x] == 2 then q = quads["rock1"]
			end
			
			love.graphics.draw(chipset, q, (x-1)*tileSize + xOffsetCurrent+ xMargin, (y-1)*tileSize + yMargin)
		end
	end
	
	if screenShift then
		for y=1, yLen do
			for x=1, xLen do
				q = nil
				if nextMap[y][x] == 0 then q = quads["water"..spriteState]
				elseif nextMap[y][x] == 1 then q = quads["dirt1"]
				elseif nextMap[y][x] == 2 then q = quads["rock1"]
				end
			
				love.graphics.draw(chipset, q, (x-1)*tileSize + xOffsetNext+ xMargin, (y-1)*tileSize + yMargin)
			end
		end
	end
	
	love.graphics.rectangle("line", xMargin - 1, yMargin - 1, tileSize * xLen, tileSize * yLen)

  -- love.graphics.setColor(0, 255, 0, 255)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

function love.keypressed(key)
	if key == "q" then
		love.event.quit()
	end
	
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
		end
	end
end

-----------------

function getMap()
	if map[worldY][worldX] then
		return map[worldY][worldX]
	else
		m = make4x4Map()
		map[worldY][worldX] = m
		-- print("made a map at x="..worldX.." y="..worldY)
		return m
	end
end

function make4x4Map()
	m = {}
	for y=1, yLen do
		m[y] = {}
		for x=1, xLen do
			m[y][x] = math.random(0,2)
		end
	end
	
	return m
end