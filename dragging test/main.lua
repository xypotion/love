-- test for dragging (click, hold, move mouse) and scrolling with acceleration (via mouse wheel or trackpad)

function love.load()
	boxX, boxY = 300, 300
	xScrollAccel = 0
	yScrollAccel = 0
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
	
	--reset!
	boxX, boxY = 300, 300
end

function love.update(dt)
	--wtf is this even for?
	-- if love.mouse.isGrabbed() then
	-- 	print("grabbed?")
	-- end
	
	-- if love.mouse.isDown(1) then
	-- 	-- print("1 pressed")
	-- 	--fired by clicking OR dragging with 1 or 3 fingers. touching sometimes fires this once
	-- 	--dragging with 3 fingers also
	-- end
	--
	-- if love.mouse.isDown(2) then
	-- 	-- print("2 pressed")
	-- 	--fired by CLICKING with two fingers. touching with 2 fingers sometimes fires this once
	-- end
	--
	-- if love.mouse.isDown(3) then
	-- 	print("3 pressed")
	-- 	-- mac's trackpad does not fire this at all, it seems.
	-- end
	
	xScrollAccel = decay(xScrollAccel, dt)
	yScrollAccel = decay(yScrollAccel, dt)

	
	boxX = boxX + xScrollAccel
	boxY = boxY + yScrollAccel
end

function decay(n, dt)
	return n * (1 - dt * 10)
end

function love.draw()
	love.graphics.print("This was actually pretty easy. Click-and-drag and trackpad scrolling both work as you'd expect in OSX & Windows.\nScrolling is slightly slow in Windows.", 10, 10)
	
	love.graphics.rectangle("fill", boxX, boxY, 50, 50)
end

--none of this is necessary!
-- function love.mousepressed(x, y, b)
-- 	print("pressed", x, y, b)
-- 	dragging = true
-- end
--
-- function love.mousereleased(x, y, b)
-- 	print("released", x, y, b)
-- 	dragging = false
-- end

function love.mousemoved(x, y, dx, dy, istouch)
	-- print(x, y, dx, dy, istouch)
	if love.mouse.isDown(1) then
		boxX = boxX + dx
		boxY = boxY + dy
	end
end

function love.wheelmoved(x, y)
	-- print(x, y)
	
	xScrollAccel = xScrollAccel + x * 2
	yScrollAccel = yScrollAccel + y * 2
end