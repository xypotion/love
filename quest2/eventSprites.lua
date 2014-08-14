-- function initEventSprites()
-- 	--for sprite animation
-- 	-- timeEventSpriteAnim = 0
-- 	-- eventSpriteAnimState = 0
-- 	-- eventSpriteFrameLength = .32
-- end

-- function drawEvents()
-- 	-- this SEEMS processor-intensive but didn't hurt framerate in dev...? definitely willing (LOL) to refactor events' table structure if it gets heavy
-- 	for y, row in pairs(currentMap.events) do
-- 		for x, e in pairs(row) do
-- 			if e.spriteQuad then
-- 				-- if it's animated, .sprite will be a table!
-- 				-- OR it'll always be a table, just use current frame as a key; for non-animated sprites, this will always be 1 :)
-- 				if e.anikey then
-- 					love.graphics.draw(e.spriteImage, e.spriteQuad[e.anikey.frame], (x-1) * tileSize, (y-1) * tileSize) --TODO make this cleaner?
-- 				else
-- 					love.graphics.draw(e.spriteImage, e.spriteQuad, (x-1) * tileSize, (y-1) * tileSize)
-- 				end
-- 			else
-- 				--stand-in for missing event sprites
-- 				love.graphics.setColor(0,255,255,255)
-- 				love.graphics.rectangle('line', (x-1) * tileSize + 4, (y-1) * tileSize + 4, tileSize - 8, tileSize - 8)
-- 			end
-- 		end
-- 	end
-- end

-----------------------------------------------------------------------------------------------------------

-- function getEventByPosition(x,y)
-- 	return currentMap.events[y][x]
-- end

function getEventByPosition(pos)
	if pos.x and pos.y then
		return currentMap.events[pos.y][pos.x]
	else
		return currentMap.events[pos[2]][pos[1]]
	end
end

function setEventByPosition(pos, val)
	if pos.x and pos.y then
		currentMap.events[pos.y][pos.x] = val
	else
		currentMap.events[pos[2]][pos[1]] = val
	end
end

function getEventPosByName(name)
	-- return currentMap.eventShortcuts[name] NO...? MAYBE? could save time. TODO watch performance and consider, because 2D loop below could be expensive
	-- e = currentMap.events[1]
	print "getEventPosByName!!"
	
	for yd,row in pairs(currentMap.events) do
		for xd,_e in pairs(row) do
			print ("getEventPosByName:".._e.name)
			if _e.name == name then
				pos = _e.currentPos
				break
			end
		end
	end
	
	return pos
end

function getEventByName(name)
	return(getEventByPosition(getEventPosByName(name)))
end

------------------------------------------------------------------------------------------------------
-- likely unnecessary but keeping around for now

-- function replaceEventAt(wx,wy,mx,my,event)
-- 	return makeEventAt(wx,wy,mx,my,event,true)
-- end
--
-- function addEventAt(wx,wy,mx,my,event)
-- 	return makeEventAt(wx,wy,mx,my,event,false)
-- end
--
-- function makeEventAt(wx,wy,mx,my,event,replace)
-- 	-- make sure map exists
-- 	if not world[wy] or not world[wy][wx] then
-- 		print("error in addEventAt()")
-- 		print("tried to add a/n "..event.type.." to world["..wy.."]["..wx.."], a non-existent map")
-- 		return false
-- 	end
--
-- 	-- should never happen if you use emptyMapGrid() properly
-- 	if not world[wy][wx].events or not world[wy][wx].events[my] then
-- 		print("error in addEventAt()")
-- 		print("tried to add a/n "..event.type.." to world["..wy.."]["..wx.."][\"events\"]["..my.."]["..my.."] but the [\"events\"] table is malformed")
-- 		return false
-- 	end
--
-- 	-- should never happen... but could if you're sloppy with random placement
-- 	if not replace and world[wy][wx].events[my][mx] then
-- 		print("error in addEventAt()")
-- 		print("tried to add a/n "..event.type.." to world["..wy.."]["..wx.."][\"events\"]["..my.."]["..my.."] but there's already an event there!")
-- 		return false
-- 	else
--
-- 	end
-- 	-- ...i guess also check to make sure the tile is clear so items/battles don't end up in rocks? bleh. TODO
--
-- 	world[wy][wx].events[my][mx] = event -- whew, made it.
-- 	return true
-- end