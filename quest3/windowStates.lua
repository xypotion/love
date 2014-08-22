-- just what it sounds like. initializes and manages various window modes/sizes
-- TODO implement fullscreen. bleh.

function initWindowStates()
	windowStates = {
		{
			z = 1,
			flags = {
				fullscreen = false, 
				fullscreentype = "desktop",
				highdpi = false
			}
		},
		{
			z = 3,
			flags = {
				fullscreen = false, 
				fullscreentype = "desktop",
				highdpi = true
			}
		}	
	}
	
	updateWindowStateSettings()
	
  love.window.setTitle('Löaf 2D')
end

function updateWindowStateSettings()
	
	windowModeFlags = windowStates[windowState + 1].flags
	zoom = windowStates[windowState + 1].z
	tileSize = 32 * zoom
	
	--TODO apply zoom somehow if these are still used later
	xMargin = 0
	yMargin = 0
	xRightMargin = tileSize * 5
	yBottomMargin = 0--64
	
	screenWidth = xLen * tileSize + xMargin + xRightMargin
	screenHeight = yLen * tileSize + yMargin + yBottomMargin
	
	if(windowModeFlags.highdpi) then
	  love.window.setMode(screenWidth/2, screenHeight/2, windowModeFlags)
	else
	  love.window.setMode(screenWidth, screenHeight, windowModeFlags)
	end
end

function updateZoomRelativeStuff() --TODO this is so broken, lol. fiiix
	--so many quads to resize ~
	makeQuads()
	
	--the main visible things gotta change immediately
	updateMapSpriteBatchFramesCurrent()
	loadLocalActors()
	
	-- setActorXY(globalActors.hero)
	initHero()
	
	scrollSpeed = 500 * zoom -- inelegant TODO
	
end