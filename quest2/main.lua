require "windowStates"
require "pause"
require "map"
require "hero"
require "cutscene"
require "warp"
require "textScroll"
require "actorManager"

require "script/saveLoader"
require "script/mapLoader"
require "script/eventLoader"
require "script/imgKey"

--TODO quite possibly better to use dofile() instead of require for large script files

-- require "script/eventBehaviorScripts"

function love.load()
	loadSaveData() -- just the data values, not applying/drawing anything
	
	--TODO put these somewhere else
	yLen = 15
	xLen = 15
	initWindowStates()
	
	-- initialize and load data
	-- load map art, hero art, event art, GUI assets
	loadImages() --actually does almost nothing now, haha
	
	--initialize other game parts
	initActorManager()
	initMapSystem()
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
		tickAnimationKeys(dt)

		--MOVEMENT
		-- move map if needed
		if screenShifting then
			shiftTiles(dt)
		end
	
		-- update/"shift" actors if needed
		if actorsShifting > 0 then
			-- don't forget: lots happens here, including heroArrive and arrivalInteraction.
			moveActors(dt)
		end
		
		warpUpdate(dt)
		
		if textScrolling then
			updateScrollingText(dt)
		end
	
		if not screenShifting and actorsShifting == 0 and not paused and not warping and not dewarping and not textScrolling then -- TODO simplify/condense?
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
	end
end

function love.draw()
	drawMap()
	
	if screenShifting then 
		drawGlobalActors()
	else
		drawAllActors()
	end
	
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
  love.graphics.print("ActorsShifting: "..actorsShifting, 10, 42, 0, zoom, zoom)
	
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10, 0, zoom, zoom)
	love.graphics.print("x="..worldPos.x.." y="..worldPos.y, tileSize * xLen - 96, 10, 0, zoom, zoom)
	love.graphics.print("x="..globalActors.hero.currentPos.x.." y="..globalActors.hero.currentPos.y, tileSize * xLen - 96, 26, 0, zoom, zoom) --zoom, zoom!
end

function love.keypressed(key)
	if key == "q" or key == "escape" then
		love.event.quit()
		return
	end
	
	--commands that only work when game is in a neutral state!
	if not screenShifting and actorsShifting == 0 and not warping and not dewarping and not textScrolling and not runningScript then
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
			print "ping main; keypressed finished"
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
	if currentMap.tiles[globalActors.hero.currentPos.y][globalActors.hero.currentPos.x] == 2 then
		score = score + 1
		currentMap.tiles[globalActors.hero.currentPos.y][globalActors.hero.currentPos.x] = 1
		updateMapSpriteBatchFramesCurrent()
	end
	-----------------------------------
	
	-- check for actor interaction. GLOBAL ACTORS NEVER COLLIDE OR INTERACT
	local event = getLocalActorByPos(globalActors.hero.currentPos)
	if event then
		ping ("found an event")
		interactWith(event)
	end
end

-- TODO auto-save here? meh. we'll see.
function love.quit()
end

-- NEVER PASS _G TO THIS
function tablePrint(table, offset)
	offset = offset or "  "
	
	for k,v in pairs(table) do
		if type(v) == "table" then
			print(offset.."sub-table ["..k.."]:")
			tablePrint(v, offset.."  ")
		else
			print(offset.."["..k.."] = "..tostring(v))
		end
	end	
end

function ping(msg)
	print("ping "..msg)
end

-- prints non-function values in _G whose keys contain str, or prints all non-function values if str not provided
function showGlobals(str)	
	for k,v in pairs(_G) do
		if not (type(v) == "function") then
			if str then
				if k:find(str) then
					print(k,v)
				end
			else
				print(k,v)
			end
		end
	end
end