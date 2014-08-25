--everything that happens on the sidebar

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
	love.graphics.rectangle("line", screenWidth - xRightMargin, 0, xRightMargin, screenHeight) --TODO this basically looks like shit, change to 2 fill rects
	
	--minimap
	drawMiniMap({x=screenWidth - xRightMargin/2, y=xRightMargin/2}, 2)
end