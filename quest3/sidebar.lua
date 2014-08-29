--everything that happens on the sidebar

--TODO decide if you're even using this, lol. maybe ask for opinions :/

function initSidebar()
	--?
end

function updateSidebar(dt)
	--?
end

function drawSidebar()
	love.graphics.setColor(95,95,63,255)
	love.graphics.rectangle("fill", screenWidth - xRightMargin, 0, xRightMargin, screenHeight)
	love.graphics.setColor(15,15,15,255)
	love.graphics.rectangle("line", screenWidth - xRightMargin, 0, xRightMargin, screenHeight) --TODO this basically looks like shit, change to 2x fill rect
	
	--minimap TODO position correctly
	drawMiniMap({x=screenWidth - xRightMargin + 10*zoom, y=10*zoom}, 2)
end