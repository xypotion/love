function initMenuSystem()
	menuStack = {}
	
	-- addMenu("fast travel")
end

function drawMenuStack()
	--draw in rising order so top is drawn last
	--darken all but the top one
	
	for i=1,#menuStack do
		m = menuStack[i]
		-- drawMenu(menuStack[i])
		if m.drawType == "foo" then		
			love.graphics.setColor(i*16,i*18,i*20,255)
			love.graphics.rectangle("fill", menuStack[i].pos.x, menuStack[i].pos.y, menuStack[i].width, menuStack[i].height)
		elseif m.drawType == "minimap" then
			drawMiniMap(m.pos, 2)
			love.graphics.setColor(i*16,i*18,i*20,255)
			love.graphics.draw(arrowImage, m.cursorScreenPos.x, m.cursorScreenPos.y, 0, zoom/12, zoom/12) --TODO hacko
		end
	end
end

function updateMenuStack(dt)
	--i guess repeatedly scroll cursor if key held down? how to do delay...
		--keyDelayTimer! will count up on every update, and is reset to 0 when any key is released
		--...but do this later TODO not that important
			
	-- if keyDelayTimer >= keyRepeatDelay then
		-- takeMenuInput(" ")
	-- end
end

--called from keypressed AND from updateMenuStack when key is repeating
function takeMenuStackInput(key)
	local m = topMenu()
	
	if topMenu().navigationType == "2D" then
		if key == "d" or key == "right" then
			m.cursorPos.x = (m.cursorPos.x) % #(m.options[1]) + 1
		elseif key == "a" or key == "left" then
			m.cursorPos.x = (m.cursorPos.x - 2) % #(m.options[1]) + 1
		end
	end

	if key == "s" or key == "down" then
		m.cursorPos.y = (m.cursorPos.y) % #(m.options) + 1
	elseif key == "w" or key == "up" then
		m.cursorPos.y = (m.cursorPos.y - 2) % #(m.options) + 1
	end
	
	setCursorScreenPos()
	
	--
	if key == " " then
		-- addMenu("foo")
		ping("CONFIRM")
		-- showGlobals("cript")
		
		--TODO check m.confirmOK
	end
	
	-- TODO only sometimes?
	if key == "x" and #menuStack > 0 then
		popMenuOff()
	end
end

------------------------------------------------------------------------------------------------------

function topMenu()
	return menuStack[#menuStack]
end

function setCursorScreenPos()
	m = menuStack[#menuStack]
	m.cursorScreenPos = m.cursorScreenPos or {} --in case it's unset
	
	m.cursorScreenPos.x = m.cursorPos.x * m.cursorOffset.x * zoom
	m.cursorScreenPos.y = m.cursorPos.y * m.cursorOffset.y * zoom
	
end

function addMenu(arg)
	local newMenu = {}
	
	if type(arg) == "table" then
		newMenu = arg
	elseif type(arg) == "string" then
		newMenu = makeMenu(arg)
	end
	
	menuStack[#menuStack + 1] = newMenu
	setCursorScreenPos()
end

function makeMenu(kind)
	local nm = {} --"new menu"
	
	if kind == "fast travel" then
		nm.drawType = "minimap"
		nm.navigationType = "2D"
		-- nm.confirmType = "fast travel"
		nm.confirmOK = function (pos) return world[pos.y][pos.x].lastEntryPos end
		nm.options = world --necessary? hm
		nm.cursorPos = {x=worldPos.x,y=worldPos.y}
		nm.cursorOffset = {x=10,y=10} --TODO hack for now
		
		nm.pos = {x=10*zoom, y=10*zoom}
		-- nm.width = 0
	elseif kind == "options" then
	elseif kind == "battle confirm" then
	elseif kind == "foo" then
		nm.drawType = "foo"
		nm.pos = {x=10*math.random(1,10)*zoom,y=10*math.random(1,10)*zoom}
		nm.width = 10*math.random(1,10)*zoom
		nm.height = 10*math.random(1,10)*zoom
	end
	
	return nm
end

function popMenuOff()
	menuStack[#menuStack] = nil
end