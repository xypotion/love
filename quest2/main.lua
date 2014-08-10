require "windowStates"
require "pause"
require "map"
require "hero"
require "eventSprites"
require "cutscene"
require "warp"
require "textScroll"

require "script/saveLoader"
require "script/mapLoader"
require "script/eventLoader"
require "script/imgKey"

-- require "script/eventBehaviorScripts"

function love.load()	
	--TODO put these somewhere else
	yLen = 15--#(currentMap.tiles)
	xLen = 15--#(currentMap.tiles[1])
	
	loadSaveData() -- just the data values, not applying/drawing anything
	
	initWindowStates()
	
	-- initialize and load data
	-- load map art, hero art, event art, GUI assets
	-- loadAllEvents()
	-- map data
	-- item data
	-- player progress, inventory, party data
	-- 
	loadImages()
	-- setupAnimationKeys()

	--initialize other game parts
	initMapSystem()
	initEventSprites()
	initHero()
	initTextEngine()
	initWarpSystem()
	
	math.randomseed(os.time())
	
	initPauseMenuSystem()
end

function love.update(dt)
	if paused then
		updatePauseScreen(dt)
	else
		-- animateBG(dt)
		-- animateEventSprites(dt)
		-- animateHero(dt)
		tickAnimationKeys(dt)

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
		
		warpUpdate(dt)
		
		--STORYTELLING TODO use the general scene flag, not just text scrolling. but whatever for now.
		if textScrolling then
			updateScrollingText(dt)
		end
		
		-- if runningScript and not runningScriptLine then
		-- 	doNextScriptLine()
		-- end
	
		if not screenShifting and not heroShifting and not paused and not warping and not dewarping and not textScrolling then -- TODO simplify/condense
			if runningScript then
				if not runningScriptLine then
					print ("STARTING NEXT LINE")
					runningScriptLine = true
					doNextScriptLine()
				else
					print "DONE WITH SCRIPT LINE"
					runningScriptLine = false
				end
			else
				-- allow player to move hero/play normally
				setHeroGridTargetAndTileTypeIfDirectionKeyPressed()
				heroGo()
			end
		end
		
		-- if runningScript and not runningScriptLine then
		-- 	doNextScriptLine()
		-- elseif runningScript then --hack; you'll be lucky if this works
		-- 	-- doNextScriptLine()
		-- end
		
	end
end

function love.draw()
	drawMap()
	if not screenShifting then drawEvents() end
	
	drawHero()
	
	if paused then
		drawPauseOverlay()
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
	
	--commands that only work when game is in a neutral state!
	if not screenShifting and not heroShifting and not warping and not dewarping and not textScrolling and not runningScript then
		--pause
		if key == "m" then
			paused = not paused
			return
		end
	
		--cycle through zoom settings TODO eventually make a player option of this, but this is fine for dev
		if key == "z" then
			windowState = (windowState + 1) % #windowStates
			updateWindowStateSettings()
			updateZoomRelativeStuff()
		end
		
		if key == " " then 
			print "ping main"
			startFacingInteraction()
		end	
	elseif textScrolling then --if not else'd off the above, bad things happen. i don't love this here, but it works for now
		-- advance to end of line and halt
		keyPressedDuringText(key)
	end
	
	--shh!
	if key == "0" and love.keyboard.isDown("3") then
		score = score + 150
		return
	end
end

------------------------------------------------------------------------------------------------------

-- TODO where should this go? map? eventSprites? behavior manager?
function arrivalInteraction() --"arrived at tile; is something supposed to happen?"
	
	
	-----------------------------------
	-- a cute, TEMPORARY interaction with flower tiles. final game engine will ONLY process events here. TODO to remove :,(
	if currentMap.tiles[heroGridPos.y][heroGridPos.x] == 2 then
		score = score + 1
		-- score = score - 1 --stepping on flowers now reduces your score, mwahahaha!
		currentMap.tiles[heroGridPos.y][heroGridPos.x] = 1
		
		if not rockTriggered and score >= 300 then
			rockTriggered = true
			replaceEventAt(1,1,13,13,{type = "warp", sprite = "hole", destination = {wx=99,wy=99,mx=8,my=8}})
			world[1][1].mapType = "hole"
		end
	end
	-----------------------------------
	
	
	-- check for event interaction
	local event = currentMap.events[heroGridPos.y][heroGridPos.x]
	if event then
		interactWith(event)
	end
		
	updateMapSpriteBatchFramesCurrent() --? TODO might be a better place for this. seems to be here for (1) warping and (2) picking flowers. lolz
end

-- TODO auto-save here? meh. we'll see.
function love.quit()
end