function initMenuSystem()
	menuStack = {}
end

function drawMenuStack()
	--draw in rising order so top is drawn last
	--darken all but the top one
	
	for i=1,#menuStack do
		-- drawMenu(menuStack[i])
		love.graphics.setColor(i*16,i*18,i*20,255)
		love.graphics.rectangle("fill", menuStack[i].pos.x, menuStack[i].pos.y, menuStack[i].width, menuStack[i].height)
	end
end

function updateMenuStack(dt)
	--i guess repeatedly scroll cursor if key held down? how to do delay...
		--keyDelayTimer! will count up on every update, and is reset to 0 when any key is released
		--...but do this later TODO not that important
	if keyDelayTimer >= keyRepeatDelay then
		takeMenuInput(" ")
	end
end

--called from keypressed AND from updateMenuStack when key is repeating
function takeMenuInput(key)
	--
	if key == " " then
		addMenu("foo")
	end
	
	if key == "x" and #menuStack > 0 then
		popMenuOff()
	end
end

------------------------------------------------------------------------------------------------------

function addMenu(kind)
	-- newMenu = {}
	
	if type(kind) == "table" then
		newMenu = kind
	elseif type(kind) == "string" then
		newMenu = makeMenu(kind)
	end
	
	menuStack[#menuStack + 1] = newMenu
end

function makeMenu(kind)
	newMenu = {}
	
	if kind == "options" then
	elseif kind == "battleConfirm" then
	elseif kind == "foo" then
		newMenu.pos = {x=10*math.random(1,10)*zoom,y=10*math.random(1,10)*zoom}
		newMenu.width = 10*math.random(1,10)*zoom
		newMenu.height = 10*math.random(1,10)*zoom
	end
	
	return newMenu
end

function popMenuOff()
	menuStack[#menuStack] = nil
end