-- initializes and manages pause menu/overlay
-- may eventually become the whole status menu controller, but we'll cross that bridge when we come to it

function initPauseMenuSystem()
	paused = false
end

function updatePauseScreen(dt)
	tickAniKey(anikeys.minimap, dt)
end

function drawPauseOverlay()
	--dark overlay
  love.graphics.setColor(0, 0, 0, 100)
  love.graphics.rectangle('fill', 0, 0, screenWidth, screenHeight)

	love.graphics.setColor(255,255,255,255)
	love.graphics.print("PAUSED", screenWidth/3, screenHeight/3, 0, zoom, zoom)
end

function togglePause()
	if paused then
		paused = false
		-- TODO audio resume
	else
		paused = true
		-- TODO audio pause
	end
end

----------------------------------------------------------------------------------------------------
-- TODO move below to menu manager of some kind. super doesn't belong here anymore

function drawMapMenu()
	--dark overlay
  love.graphics.setColor(0, 0, 0, 100)
  love.graphics.rectangle('fill', 0, 0, screenWidth, screenHeight)
	
	--"map" backdrop... pretty arbitrary, obvs TODO define & refine later
  love.graphics.setColor(191, 191, 127, 255)
  love.graphics.rectangle('fill', screenWidth/4, screenHeight/4, screenHeight/2, screenHeight/2) --whatever for now TODO
	
	--the actual minimap
	drawMiniMap({x = screenWidth/4, y = screenHeight/4}, 4)

	-- and a helpful note ~
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("TOGGLE MAP WITH M", (screenWidth - 150)/2, (screenHeight) - 26, 0, zoom, zoom)
end

function drawMiniMap(pos, scale)
	local cellSize = 4 * zoom * scale
	local cellGap = 1 * zoom * scale --maybe not necessary? i dunno
	
	for y = -10, 10 do
		for x = -10, 10 do
			if world[y] and world[y][x] then
				if world[y][x].seen then
					-- TODO replace colors with small images (by mapType) for each cell. don't worry about hackyness for now, it's gonna get scrapped
					if world[y][x] == currentMap and anikeys.minimap.frame == 1 then
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
				else
					love.graphics.setColor(127,127,127,255)
				end

				love.graphics.rectangle('fill', pos.x + x * (cellSize + cellGap), pos.y + y * (cellSize + cellGap), cellSize, cellSize)
				-- or, centered on currentMap (have to also change bounds of y & x above):
				-- love.graphics.rectangle('fill', (xLen * tileSize / 2) + (x - worldPos.x) * 10, (yLen * tileSize / 2) + (y - worldPos.y) * 10, 8, 8)
			end
		end
	end
end