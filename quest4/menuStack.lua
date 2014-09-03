function initMenuSystem()
	menuStack = {}
end

function drawMenuStack()
	--dark overlay
  love.graphics.setColor(0, 0, 0, 127)
  love.graphics.rectangle('fill', 0, 0, screenWidth, screenHeight)
	
	--draw in rising order so top is drawn last
	--darken all menus but the top one? TODO if it actually looks good; don't if not
	for i=1,#menuStack do
		m = menuStack[i]
		m:draw()
	end
	
	Menu:top():drawCursor()
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
	Menu:top():keyPressed(key)
end

-- only here to give a hook in behavior scripts!
function addMenu(arg, ...)
	-- arg(...):add()
	Menu.add(arg)
end