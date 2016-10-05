function love.load()
	doubleClickTimeout = 0.25 --should be player-customizable
	doubleClickTimer = 0
	lastMouseRelease = {}
	cursorCounter = 1
end

function love.update(dt)
	doubleClickTimer = doubleClickTimer + dt
end

function love.mousereleased(x, y, b)
	--set last mouse release position; rest timer
	lastMouseRelease = {x=x, y=y, b=b}
	doubleClickTimer = 0
end

function love.mousepressed(x, y, b)
	if doubleClickTimer <= doubleClickTimeout
	and lastMouseRelease.x == x
	and lastMouseRelease.y == y
	and lastMouseRelease.b == b then
		print("double clicked!")
		setRandomCursor()
	end
end

-- local cursorTypes = {"arrow", "ibeam", "wait", "waitarrow", "crosshair", "sizenwse", "sizenesw", "sizewe", "sizens", "sizeall", "no", "hand"}
local cursorTypes = {"arrow", "ibeam", "crosshair", "no", "hand"}

function setRandomCursor()
	cursorCounter = cursorCounter + 1
	local ct = cursorTypes[(cursorCounter - 1) % #cursorTypes + 1]
	local c = love.mouse.getSystemCursor(ct)
	love.mouse.setCursor(c)
	print(ct)
end