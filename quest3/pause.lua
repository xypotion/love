-- initializes and manages pause menu/overlay
-- may eventually become the whole status menu controller, but we'll cross that bridge when we come to it

function initPauseMenuSystem()
	paused = false
	mapBlinkTime = 0
	mapBlinkState = 0
	mapBlinkFrameLength = 0.2
end

function updatePauseScreen(dt)
	mapBlinkTime = mapBlinkTime + dt
	if mapBlinkTime > mapBlinkFrameLength then
		mapBlinkState = (mapBlinkState + 1) % 2
		mapBlinkTime = 0
	end
end

function drawPauseOverlay()
	--dark overlay
  love.graphics.setColor(0, 0, 0, 100)
  love.graphics.rectangle('fill', 0, 0, xLen * tileSize, yLen * tileSize)
	
	--"map"... pretty arbitrary, obvs TODO define & refine later
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
				-- or, centered on currentMap (have to also change bounds of y & x above):
				-- love.graphics.rectangle('fill', (xLen * tileSize / 2) + (x - worldPos.x) * 10, (yLen * tileSize / 2) + (y - worldPos.y) * 10, 8, 8)
			end
		end
	end

	-- and a helpful note ~
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("TOGGLE MAP WITH M", (tileSize * xLen - 150)/2, (tileSize * yLen) - 26, 0, zoom, zoom)
end