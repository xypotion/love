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
	
	--minimap
	drawMiniMap({x=screenWidth - xRightMargin/2, y=xRightMargin/2}, 2)
end