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
	love.graphics.print(" x="..worldPos[1].." y="..worldPos[2], tileSize * xLen - 96, 10)
	love.graphics.print(" x="..heroGridPos[1].." y="..heroGridPos[2], tileSize * xLen - 96, 26)
end

function love.keypressed(key)
	if key == "q" then
		print("Q")
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

	if xy[1] == xLen + 1 then
		--somewhat redundant as these values are translated immediately in heroGo() to the more useful worldDest. fine for now, though
		_type = "east edge"
	elseif xy[2] == yLen + 1 then
		_type = "south edge"
	else
		if not currentMap.tiles[xy[2]] then
			_type = "north edge"
		elseif not currentMap.tiles[xy[2]][xy[1]] then
			_type = "west edge"
		else
			-- regular tile, so what _type is it?
			if currentMap.tiles[xy[2]][xy[1]] == 1 then -- water
				_type = "collide"
			elseif currentMap.tiles[xy[2]][xy[1]] == 3 then -- stone
				_type = "collide"
			else
				--theoretically clear on the tile level, now a quick check at event collision:
				if currentMap.events[xy[2]][xy[1]] then
					if currentMap.events[xy[2]][xy[1]].collide then 
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
	if currentMap.tiles[heroGridPos[2]][heroGridPos[1]] == 2 then
		score = score + 1
		-- score = score - 1 --stepping on flowers now reduces your score, mwahahaha!
		currentMap.tiles[heroGridPos[2]][heroGridPos[1]] = 0
	end
	
	event = currentMap.events[heroGridPos[2]][heroGridPos[1]]
	if event then
		if event.type == "item" then
			paused = true
			currentMap.events[heroGridPos[2]][heroGridPos[1]] = nil
		end
		--play sfx? TODO kiind of a big deal
	end		
		
	updateTilesetBatchCurrent()
end

function love.quit()
end

function drawPauseOverlay()
  love.graphics.setColor(0, 0, 0, 100)
  love.graphics.rectangle('fill', 0, 0, xLen * tileSize, yLen * tileSize)
	
	--then the world map :o
	for y = -10, 10 do
		for x = -10, 10 do
			if world[y] then
				if world[y][x] then
					if world[y][x] == currentMap and mapBlinkState == 1 then
						love.graphics.setColor(0,0,0,0) -- invisible, like imhotep
					elseif world[y][x].mapType == "start" then 
						love.graphics.setColor(223,223,0,255)
					elseif world[y][x].mapType == "random" then 
						love.graphics.setColor(127,191,127,255)
					elseif world[y][x].mapType == "bonus" then 
						love.graphics.setColor(223,31,223,255)
					else 
						print("unknown map type encountered at "..x..", "..y)
					end
					
					love.graphics.rectangle('fill', (xLen * tileSize / 2) + x * 10, (yLen * tileSize / 2) + y * 10, 8, 8)
				end
			end
		end
	end

	love.graphics.setColor(255,255,255,255)
	love.graphics.print("TOGGLE MAP WITH SPACE", (tileSize * xLen - 150)/2, (tileSize * yLen) - 26)
end