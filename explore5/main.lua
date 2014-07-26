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
	
	rockTriggered = false
	
	warping = false
	dewarping = false
	fadeTime = 0.5 --seconds to fade screen in or out
	blackOverlayOpacity = 0
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

		if dewarping then
			blackOverlayOpacity = blackOverlayOpacity - math.ceil(dt * 255 / fadeTime)
			
			--? not just mapArrive...
			if blackOverlayOpacity < 0 then --haaaack TODO do it right
				blackOverlayOpacity = 0
				dewarping = false
			end
		elseif warping then
			blackOverlayOpacity = blackOverlayOpacity + math.ceil(dt * 255 / fadeTime)
			if blackOverlayOpacity > 255 then --haaaack TODO do it right
				blackOverlayOpacity = 255
				startDewarp()
			end
		end
	
		if not screenShifting and not heroShifting and not paused and not warping and not dewarping then -- TODO simplify/condense
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
	
	--black screen for fadeouts, e.g. when warping
	love.graphics.setColor(0, 0, 0, blackOverlayOpacity)
  love.graphics.rectangle('fill', 0, 0, xLen * tileSize, yLen * tileSize)
	
	--debug junk
	if score >= 300 then
		love.graphics.setColor(255, 0, 255, 255)
	end
  love.graphics.print("SCORE: "..score, 10, 26)
	
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
	love.graphics.print(" x="..worldPos.x.." y="..worldPos.y, tileSize * xLen - 96, 10)
	love.graphics.print(" x="..heroGridPos.x.." y="..heroGridPos.y, tileSize * xLen - 96, 26)
end

function love.keypressed(key)
	if key == "q" then
		love.event.quit()
		return
	end
	if key == " " and not screenShifting and not heroShifting and not warping and not dewarping then --TODO simplify/condense
		paused = not paused
		return
	end
	if key == "0" and love.keyboard.isDown("3") then --shh!
		score = score + 150
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
		
		if not rockTriggered and score >= 300 then
			rockTriggered = true
			-- replaceEventAt(1,1,13,13,{type = "warp", sprite = "hole", destination = {wx=99,wy=99,mx=8,my=8}})
			replaceEventAt(1,1,8,6,{type = "warp", sprite = "hole", destination = {wx=99,wy=99,mx=8,my=8}})
			print "HOLE"
		end
	end
	
	--sprite interaction; rough and super hacky for now; TODO a whole fetch structure is needed for this
	event = currentMap.events[heroGridPos.y][heroGridPos.x]
	if event then
		if event.type == "item" and event.sprite == "map" then
			paused = true
			currentMap.events[heroGridPos.y][heroGridPos.x] = nil
		elseif event.type == "warp" then
			print "WARP"
			startWarpTo(event.destination)
		end
		
		--play sfx? TODO sound is kiind of a big deal
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

------------------------------------------------------------------------------------------------------

function startWarpTo(wmc) --"world + map coordinates"
	warping = true
	print "START WARP"
end

function startDewarp()

	--switch out maps
	
	warping = false
	dewarping = true
	print "START DEWARP"
end