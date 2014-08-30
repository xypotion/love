function initMenuSystem()
	menuStack = {}
end

function drawMenuStack()
	--draw in rising order so top is drawn last
	--darken all but the top one
	
	for i=1,#menuStack do
		m = menuStack[i]
		
		--TODO another REALLY good place to have a Menu class with many subclasses :/
		if m.drawType == "foo" then		
			love.graphics.setColor(i*16,i*18,i*20,255)
			love.graphics.rectangle("fill", menuStack[i].pos.x, menuStack[i].pos.y, menuStack[i].width, menuStack[i].height)
		elseif m.drawType == "minimap" then
			-- drawMiniMap(m.pos, 2)
			drawMapMenu() --TODO deconstruct me!
			love.graphics.setColor(255,255,0,255)
			love.graphics.rectangle("fill", m.cursorScreenPos.x + 4, m.cursorScreenPos.y + 4, 8*zoom, 8*zoom, 0, zoom/12, zoom/12) 
			--TODO use graphic that blinks, not a plain rectangle ART NEEDED
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
	local p = m.cursorPos
	
	if topMenu().navigationType == "2D" then
		if key == "d" or key == "right" then
			p.x = (p.x) % #(m.options[1]) + 1
		elseif key == "a" or key == "left" then
			p.x = (p.x - 2) % #(m.options[1]) + 1
		end
	end

	if key == "s" or key == "down" then
		p.y = (p.y) % #(m.options) + 1
	elseif key == "w" or key == "up" then
		p.y = (p.y - 2) % #(m.options) + 1
	end
	
	setCursorScreenPos()
	
	--TODO another REALLY good place to have a Menu class with many subclasses :/
	if key == " " then
		-- addMenu("foo")
		ping("CONFIRM")
		-- showGlobals("cript")
		
		if m.confirmOK and m.confirmOK(m) then
			ping("warping to that map!")
			
			popMenuOff()
			
			startFastTravelTo({wx=p.x,wy=p.y})--,mx=world[p.y][p.x].fastTravelTargetPos.x,my=world[p.y][p.x].lastEntryPos.y})
		end
	end
	
	if (key == "x" or key == "m") and #menuStack > 0 then
		popMenuOff()
	end
	
	ping("end of takeMenuStackInput")
end

------------------------------------------------------------------------------------------------------

function topMenu()
	return menuStack[#menuStack]
end

function setCursorScreenPos()
	m = menuStack[#menuStack]
	m.cursorScreenPos = m.cursorScreenPos or {} --in case it's unset
	
	m.cursorScreenPos.x = m.pos.x + m.cursorPos.x * m.cursorScreenPosDelta.x * zoom
	m.cursorScreenPos.y = m.pos.y + m.cursorPos.y * m.cursorScreenPosDelta.y * zoom
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
	
	--TODO another REALLY good place to have a Menu class with many subclasses :/
	if kind == "fast travel" then
		nm.drawType = "minimap" --may very well leave this in, since no other menu behaves like this one
		nm.navigationType = "2D"
		nm.confirmOK = function (menu) return world[menu.cursorPos.y][menu.cursorPos.x].seen end
		nm.options = world --necessary? hm TODO
		
		nm.pos = {x=screenWidth/4, y=screenHeight/4}
		nm.cursorPos = {x=worldPos.x,y=worldPos.y}
		nm.cursorScreenPosDelta = {x=20,y=20}
	elseif kind == "options" then
	elseif kind == "battle confirm" then
	elseif kind == "foo" then
		nm.drawType = "foo"
		nm.pos = {x=10*math.random(1,10)*zoom,y=10*math.random(1,10)*zoom}
		nm.width = 10*math.random(1,10)*zoom
		nm.height = 10*math.random(1,10)*zoom
		
		nm.cursorPos = {x=0,y=0}
		nm.cursorScreenPosDelta = {x=0,y=0}
		nm.options = {}
	else
		print("TRYING TO ADD MENU TYPE THAT DOESN'T EXIST", kind)
	end
	
	return nm
end

function popMenuOff()
	menuStack[#menuStack] = nil
end