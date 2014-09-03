--everything that happens on the sidebar

--TODO decide if you're even using this, lol. maybe ask for opinions :/ (dustin and i both think a top-bar would be better!)
--so TODO change to be a top bar then rename :)

function initSidebar()
	--TODO put sidebar stuff here, not in windowStates! 
	--...OR nix this file and put it in windowStates (maybe renamed), after all. drawSidebar() isn't worth a whole separate file (yet!)
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
	drawMiniMap({x=screenWidth - xRightMargin + 10*zoom, y=10*zoom}, 1)
end