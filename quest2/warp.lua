-- simple "warp" manager. didn't want to mingle it with map.lua, since that does enough already

-- should be the only thing needed to call from behavior manager. other functions below handle the rest internally or from main
function startWarpTo(wmc) --"world + map coordinates"
	warping = true
	
	--set destination
	worldDest = {x=wmc.wx,y=wmc.wy}
	nextMap = getMap(worldDest)
	
	heroGridTarget = {x=wmc.mx,y=wmc.my}
end

-----------------------------------------------------------------------------

function initWarpSystem()
	warping = false
	dewarping = false
	fadeTime = 0.5 --seconds to fade screen in or out
	blackOverlayOpacity = 0
end

function warpUpdate(dt)
	if dewarping then
		blackOverlayOpacity = blackOverlayOpacity - math.ceil(dt * 255 / fadeTime)
		
		if blackOverlayOpacity < 0 then --haaaack TODO do it right
			blackOverlayOpacity = 0
			dewarping = false
			--and we've arrived.
		end
	elseif warping then
		blackOverlayOpacity = blackOverlayOpacity + math.ceil(dt * 255 / fadeTime)
		
		if blackOverlayOpacity > 255 then --haaaack TODO do it right
			blackOverlayOpacity = 255
			startDewarp()
		end
	end
end

function startDewarp()
	--switch out maps
	mapArrive()
	heroArrive()
	
	facing = "s"
	
	warping = false
	dewarping = true
end