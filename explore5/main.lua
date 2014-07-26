require "map"
require "hero"

function love.load()
  love.window.setTitle('Löaf 2D')

	initTileSystem()
	
	initHero()
	
	math.randomseed(os.time())
	
  love.window.setMode(xLen * tileSize + xMargin, yLen * tileSize + yMargin)
	
	targetTileType = nil
	
	score = 0
	
	paused = false
	mapBlinkTime = 0
	mapBlinkState = 0
	mapBlinkFrameLength = 0.2
end

function love.update(dt)
	if paused then
		mapBlinkTime = mapBlinkTime + dt
		if mapBlinkTime > mapBlinkFrameLength then
			mapBlinkState = (mapBlinkState + 1) % 2
			mapBlinkTime = 0
		end
	else
		animateBG(dt)
		animateHero(dt)

		-- move map if needed
		if screenShifting then
			shiftTiles(dt)
		end
	
		-- move hero if needed
		if heroShifting then
			-- don't forget: lots happens here, including heroArrive and arrivalInteraction.
			shiftHero(dt * heroShiftSpeed)
		end
	
		if not screenShifting and not heroShifting and not paused then --simplify/condense? TODO
			-- allow player to move hero
			setHeroGridTargetAndTileTypeIfDirectionKeyPressed()
			heroGo()
		end
	end
end

function love.draw()
	drawMap()
	if not screenShifting then drawEvents() end
	
	drawHero()
	
	if paused then
		drawPauseOverlay()
		-- debug.debug() --whoa.
		-- print(math.random())
	end
	
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
  love.graphics.print("SCORE: "..score, 10, 26)
	love.graphics.print(" x="..worldPos.x.." y="..worldPos.y, tileSize * xLen - 96, 10)
	love.graphics.print(" x="..heroGridPos.x.." y="..heroGridPos.y, tileSize * xLen - 96, 26)
end

function love.keypressed(key)
	if key == "q" then
		love.event.quit()
		return
	end
	if key == " " and not screenShifting and not heroShifting then
		paused = not paused
		return
	end
end

------------------------------------------------------------------------------------------------------

function tileType(xy) --WHY did you do this this way??
	_type = "clear"

	if xy.x == xLen + 1 then
		--somewhat redundant as these values are translated immediately in heroGo() to the more useful worldDest. fine for now, though
		_type = "east edge"
	elseif xy.y == yLen + 1 then
		_type = "south edge"
	else
		if not currentMap.tiles[xy.y] then
			_type = "north edge"
		elseif not currentMap.tiles[xy.y][xy.x] then
			_type = "west edge"
		else
			-- regular tile, so what _type is it?
			if currentMap.tiles[xy.y][xy.x] == 1 then -- water
				_type = "collide"
			elseif currentMap.tiles[xy.y][xy.x] == 3 then -- stone
				_type = "collide"
			else
				--theoretically clear on the tile level, now a quick check at event collision:
				if currentMap.events[xy.y][xy.x] then
					if currentMap.events[xy.y][xy.x].collide then 
						_type = "collide" 
					end
				end
			end
		end
	end
	
	return _type
end

function arrivalInteraction() --"arrived at tile; is something supposed to happen?"

	-- a cute, TEMPORARY interaction with flower tiles. final game engine will ONLY process events here. TODO to remove :,(
	if currentMap.tiles[heroGridPos.y][heroGridPos.x] == 2 then
		score = score + 1
		-- score = score - 1 --stepping on flowers now reduces your score, mwahahaha!
		currentMap.tiles[heroGridPos.y][heroGridPos.x] = 0
	end
	
	event = currentMap.events[heroGridPos.y][heroGridPos.x]
	if event then
		if event.type == "item" then
			paused = true
			currentMap.events[heroGridPos.y][heroGridPos.x] = nil
		end
		--play sfx? TODO kiind of a big deal
	end		
		
	updateTilesetBatchCurrent()
end

function love.quit()
end

function drawPauseOverlay()
	--dark overlay
  love.graphics.setColor(0, 0, 0, 100)
  love.graphics.rectangle('fill', 0, 0, xLen * tileSize, yLen * tileSize)
	
	--"map"... pretty arbitrary, obvs TODO define & refine
  love.graphics.setColor(191, 191, 127, 255)
  love.graphics.rectangle('fill', (xLen * tileSize / 3) - 30, (xLen * tileSize / 3) - 30, (yLen * tileSize / 3) + 60, (yLen * tileSize / 3) + 60)
	
	--then the world map :o
	for y = -10, 10 do
		for x = -10, 10 do
	-- for y = worldPos.y-10, worldPos.y+10 do
	-- 	for x = worldPos.x-10, worldPos.x+10 do
			if world[y] and world[y][x] then
				if world[y][x] == currentMap and mapBlinkState == 1 then
					love.graphics.setColor(0,0,0,0) -- invisible, like imhotep
				elseif world[y][x].mapType == "start" then 
					love.graphics.setColor(223,223,255,255)
				elseif world[y][x].mapType == "random" then 
					love.graphics.setColor(95,223,95,255)
				elseif world[y][x].mapType == "bonus" then 
					love.graphics.setColor(223,31,223,255)
				else 
					print("unknown map type encountered at "..x..", "..y)
				end

				love.graphics.rectangle('fill', (xLen * tileSize / 2) + x * 10 - 4, (yLen * tileSize / 2) + y * 10 - 4, 8, 8)
				--centered on currentMap
				-- love.graphics.rectangle('fill', (xLen * tileSize / 2) + (x - worldPos.x) * 10, (yLen * tileSize / 2) + (y - worldPos.y) * 10, 8, 8)
			end
		end
	end

	-- and a helpful note ~
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("TOGGLE MAP WITH SPACE", (tileSize * xLen - 150)/2, (tileSize * yLen) - 26)
end