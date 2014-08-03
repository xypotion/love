require "map"
require "hero"
require "eventSprites"
require "cutscene"

require "script/eventScripts"

function love.load()
	--basic stuff
	
	--TODO i guess make this not hard-coded somehow? or just do and accept it :|
	yLen = 15--#(currentMap.tiles)
	xLen = 15--#(currentMap.tiles[1])
	
	windowStates = {
		{
			z = 1,
			flags = {
				fullscreen = false, 
				fullscreentype = "desktop",
				highdpi = false
			}
		},
		{
			z = 3,
			flags = {
				fullscreen = false, 
				fullscreentype = "desktop",
				highdpi = true
			}
		}	
	}
	
	-- fullscreen = false
	windowState = 1
	updateWindowStateSettings()
	
  love.window.setTitle('Löaf 2D')
	
	-- initialize and load data
	-- load map art, hero art, event art, GUI assets
	loadAllEvents()
	-- map data
	-- item data
	-- player progress, inventory, party data
	-- 

	--initialize other game parts
	initTileSystem()
	initEventSprites()
	initHero()
	initCutsceneEngine()
	
	math.randomseed(os.time())
	
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
		animateEventSprites(dt)
		animateHero(dt)


		--MOVEMENT
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
		
		--STORYTELLING TODO use the general scene flag, not just text scrolling. but whatever for now.
		if textScrolling then
			updateScrollingText(dt)
		end
	
		if not screenShifting and not heroShifting and not paused and not warping and not dewarping and not textScrolling then -- TODO simplify/condense
			-- allow player to move hero
			setHeroGridTargetAndTileTypeIfDirectionKeyPressed()
			heroGo()
		end
	end
end

function love.draw()
	-- love.graphics.setFont(18*zoom)
	
	drawMap()
	if not screenShifting then drawEvents() end
	
	drawHero()
	
	if paused then
		drawPauseOverlay()
		-- debug.debug() --whoa.
		-- print(math.random())
	end
	
	if textScrolling then
		drawScrollingText()
	end
	
	--black screen for fadeouts, e.g. when warping
	love.graphics.setColor(0, 0, 0, blackOverlayOpacity)
  love.graphics.rectangle('fill', 0, 0, xLen * tileSize, yLen * tileSize)
	
	--debug junk
	if score >= 300 then
		love.graphics.setColor(255, 0, 255, 255)
	else
		love.graphics.setColor(255, 255, 255, 255)
	end
  love.graphics.print("SCORE: "..score, 10, 26, 0, zoom, zoom)
	
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10, 0, zoom, zoom)
	love.graphics.print("x="..worldPos.x.." y="..worldPos.y, tileSize * xLen - 96, 10, 0, zoom, zoom)
	love.graphics.print("x="..heroGridPos.x.." y="..heroGridPos.y, tileSize * xLen - 96, 26, 0, zoom, zoom)
end

function love.keypressed(key)
	if key == "q" then
		love.event.quit()
		return
	end
	--things that only work when game is in a neutral state!
	if not screenShifting and not heroShifting and not warping and not dewarping and not textScrolling then
		--pause
		if key == "m" then
			paused = not paused
			return
		end
	
		--cycle through zoom settings
		if key == "z" then
			windowState = (windowState + 1) % #windowStates
			updateWindowStateSettings()
	
			--TODO is this a good place for this? hm
			updateZoomRelativeStuff()
		end
		
		if key == " " then 
			startFacingInteraction()
		end
	
		--TODO make this compatible with zoom settings. kinda whatever.
		-- if key == "f" then
		-- 	fullscreen = not fullscreen
		--   -- love.window.setMode(xLen * tileSize + xMargin, yLen * tileSize + yMargin, windowModeFlags)
		-- 	updateWindowStateSettings()
		-- end
	-- end
	
	elseif textScrolling then
		-- TODO advance to end of line and halt
		keyPressedDuringText(key)
	end
	
			
	--shh!
	if key == "0" and love.keyboard.isDown("3") then
		score = score + 150
		return
	end
end

------------------------------------------------------------------------------------------------------

function updateWindowStateSettings()
	
	windowModeFlags = windowStates[windowState + 1].flags
	zoom = windowStates[windowState + 1].z
	tileSize = 32 * zoom
	
	--TODO apply zoom somehow if these are still used later
	xMargin = 0
	yMargin = 0
	xRightMargin = 0--256
	yBottomMargin = 0--64
	
	screenWidth = xLen * tileSize + xMargin + xRightMargin
	screenHeight = yLen * tileSize + yMargin + yBottomMargin
	
	if(windowModeFlags.highdpi) then
	  love.window.setMode(screenWidth/2, screenHeight/2, windowModeFlags)
	else
	  love.window.setMode(screenWidth, screenHeight, windowModeFlags)
	end
end

function updateZoomRelativeStuff()
	initTileQuads()
	updateTilesetBatchCurrent()
	
	initEventSprites()
	
	initHeroQuads()
	setHeroXY()
end

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
			
			-- visible tile, so what _type is it?
			if currentMap.tiles[xy.y][xy.x] == 1 then -- water
				_type = "collide"
			elseif currentMap.tiles[xy.y][xy.x] == 5 then -- stone
				_type = "collide"
			elseif currentMap.tiles[xy.y][xy.x] == 6 then -- stone
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
			replaceEventAt(1,1,13,13,{type = "warp", sprite = "hole", destination = {wx=99,wy=99,mx=8,my=8}})
			world[1][1].mapType = "hole"
		end
	end
	
	-- check for event interaction
	event = currentMap.events[heroGridPos.y][heroGridPos.x]
	if event and event.type ~= "battle" then
		eventInteraction(event)
	end
		
	updateTilesetBatchCurrent() --? TODO might be a better place for this. seems to be here for (1) warping and (2) picking flowers. lolz
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
			if world[y] and world[y][x] then
				-- TODO this but probably not with hard-coded colors.
					-- actually, this will probably end up using small images for each cell. don't worry about hackyness for now, it's gonna get scrapped
				if world[y][x] == currentMap and mapBlinkState == 1 then
					love.graphics.setColor(0,0,0,0) -- invisible, like imhotep
				elseif world[y][x].mapType == "start" then 
					love.graphics.setColor(223,223,255,255)
				elseif world[y][x].mapType == "random" then 
					love.graphics.setColor(95,223,95,255)
				elseif world[y][x].mapType == "bonus" then 
					love.graphics.setColor(223,31,223,255)
				elseif world[y][x].mapType == "flat" then 
					love.graphics.setColor(64,96,64,255)
				elseif world[y][x].mapType == "hole" then 
					love.graphics.setColor(0,0,0,255)
				elseif world[y][x].mapType == "cave" then 
					love.graphics.setColor(63,63,31,255)
				else 
					print("unknown map type encountered at "..x..", "..y)
				end

				love.graphics.rectangle('fill', (xLen * tileSize / 2) + (x * 10 - 4) * zoom, (yLen * tileSize / 2) + (y * 10 - 4) * zoom, 8 * zoom, 8 * zoom)
				--centered on currentMap
				-- love.graphics.rectangle('fill', (xLen * tileSize / 2) + (x - worldPos.x) * 10, (yLen * tileSize / 2) + (y - worldPos.y) * 10, 8, 8)
			end
		end
	end

	-- and a helpful note ~
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("TOGGLE MAP WITH M", (tileSize * xLen - 150)/2, (tileSize * yLen) - 26, 0, zoom, zoom)
end


------------------------------------------------------------------------------------------------------

function startWarpTo(wmc) --"world + map coordinates"
	warping = true
	
	--set destination
	worldDest = {x=wmc.wx,y=wmc.wy}
	nextMap = getMap(worldDest)
	
	heroGridTarget = {x=wmc.mx,y=wmc.my}
end

function startDewarp()
	--switch out maps
	-- worldPos = worldDest
	mapArrive()
	-- heroGridPost = heroGridDest
	heroArrive()
	
	facing = "s"
	
	warping = false
	dewarping = true
end