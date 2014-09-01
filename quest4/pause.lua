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