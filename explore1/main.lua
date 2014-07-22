require "map"

function love.load()
	initTileSystem()
	
	math.randomseed(os.time())
	
  love.window.setMode(xLen*tileSize + xMargin, yLen*tileSize + yMargin)
end

function love.update(dt)
	animateBG(dt)
	
	if screenShift then
		shiftTiles(dt)
	end
end

function love.draw()
	drawBGTiles()
	
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
	love.graphics.print(" x="..worldX.." y="..worldY, tileSize * xLen - 96, 10)
end

function love.keypressed(key)
	if key == "q" then
		love.event.quit()
		return
	end
	
	explore(key) -- change to a different trigger, obvs
end

------------------------------------------------------------------------------------------------------
