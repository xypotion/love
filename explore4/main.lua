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
end

function love.update(dt)
	animateBG(dt)
	
	animateHero(dt)

	-- move map if needed
	if screenShifting then
		shiftTiles(dt)
	end
	
	-- move hero if needed
	if heroShifting then
		shiftHero(dt * heroShiftSpeed)
	end
	
	if not screenShifting and not heroShifting then --simplify? 
		-- allow player to move hero
		setHeroGridTargetAndTileTypeIfDirectionKeyPressed()
		heroGo()
	end
end

function love.draw()
	drawBGTiles()
	drawHero()
	
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
  love.graphics.print("SCORE: "..score, 10, 26)
	love.graphics.print(" x="..worldPos[1].." y="..worldPos[2], tileSize * xLen - 96, 10)
	love.graphics.print(" x="..heroGridPos[1].." y="..heroGridPos[2], tileSize * xLen - 96, 26)
end

function love.keypressed(key)
	if key == "q" then
		love.event.quit()
		return
	end
end

------------------------------------------------------------------------------------------------------

function tileType(xy)
	type = "clear"

	if xy[1] == xLen + 1 then
		--somewhat redundant as these values are translated immediately in heroGo() to the more useful worldDest. fine for now, though
		type = "east edge"
	elseif xy[2] == yLen + 1 then
		type = "south edge"
	else
		if not currentMap[xy[2]] then
			type = "north edge"
		elseif not currentMap[xy[2]][xy[1]] then
			type = "west edge"
		else
			if currentMap[xy[2]][xy[1]] == 1 then
				type = "collide"
			end
		end
	end
	
	return type
end

function arrivalInteraction()
	--"arrived at tile; is something supposed to happen?"
	--change later to check event layer, not map (or not primarily)
	if currentMap[heroGridPos[2]][heroGridPos[1]] == 2 then
		score = score + 1
		--play sfx
		
		currentMap[heroGridPos[2]][heroGridPos[1]] = 0
		updateTilesetBatchCurrent()
	end
end

function love.quit()
end