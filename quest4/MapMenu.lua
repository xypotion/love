MapMenu = class(Menu2D)

function MapMenu:_init()
	self.super:_init()
	
	self.pos = {x = screenWidth/4, y = screenHeight/4}
	
	self.options = world --TODO current Z-slice; remember to also restrict based on current location? i.e. can only quicktravel from overworld?
	
	self.cursor = {
		pos = {x=worldPos.x,y=worldPos.y},
		screenPosDelta = {x=20,y=20},
	}
	
	self:updateCursorScreenPos()
end

function MapMenu:draw()
	-- drawMapMenu()
	
	--"map" backdrop... pretty arbitrary, obvs TODO define & refine later ART NEEDED
  love.graphics.setColor(191, 191, 127, 255)
  love.graphics.rectangle('fill', screenWidth/4, screenHeight/4, screenHeight/2, screenHeight/2) --whatever for now TODO
	
	--the actual minimap
	drawMiniMap({x = screenWidth/4, y = screenHeight/4}, 4)

	-- and a helpful note ~
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("TOGGLE MAP WITH M", (screenWidth - 150)/2, (screenHeight) - 26, 0, zoom, zoom)
end

function MapMenu:keyPressed(key)
	-- self.super:keyPressed(key) --THIS DOESN'T WORK, AAHH. WHYY LUA, WHY ARE YOU AWFUL SOMETIMES
	self.super.keyPressed(self, key) --AND THIS DOES WORK. GOOD, BUT AAAHH
	
	if key == "m" then
		if worldPos.x ~= self.cursor.pos.x or worldPos.y ~= self.cursor.pos.y then
			--TODO prompt to confirm, default no (?)
			self:confirm()
		else
			self:cancel()
		end
	end
end

function MapMenu:drawCursor()
	love.graphics.setColor(255,255,0,255)
	love.graphics.rectangle("fill", self.cursor.screenPos.x + 4, self.cursor.screenPos.y + 4, 8*zoom, 8*zoom, 0, zoom/12, zoom/12) -- hack? TODO? or ok? :)
end

function MapMenu:confirmOK()
	ping ("map seen?")
	return self:choice().seen
end

function MapMenu:confirm()
	-- local dest = self.super.confirm(self)
	-- tablePrint(dest)
	if self:confirmOK() then
		startFastTravelTo({wx=self.cursor.pos.x,wy=self.cursor.pos.y})
	end
	
	self.super.confirm(self)
end

-- in confirm?
-- 		startFastTravelTo({wx=p.x,wy=p.y})--,mx=world[p.y][p.x].fastTravelTargetPos.x,my=world[p.y][p.x].lastEntryPos.y})


---------------------------------------------------------------------------------------------------------------------

--may still want to move this eventually, but it's fine for now
function drawMiniMap(pos, scale)
	local cellSize = 4 * zoom * scale
	local cellGap = 1 * zoom * scale --maybe not necessary? i dunno
	
	for y = -10, 10 do
		for x = -10, 10 do
			if world[y] and world[y][x] then
				if world[y][x].seen then
					-- TODO replace colors with small images (by mapType) for each cell. don't worry about hackyness for now, it's gonna get scrapped. ART NEEDED
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