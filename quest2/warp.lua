-- simple "warp" manager. didn't want to mingle it with map.lua, since that does enough already

function initWarpSystem()
	warping = false
	dewarping = false
	fadeTime = 0.5 --seconds to fade screen in or out
	blackOverlayOpacity = 0
end

-- should be the only thing needed to call from behavior manager. other functions handle the rest internally or from main
function startWarpTo(wmc) --"world + map coordinates"
	warping = true
	
	--set destination
	worldDest = {x=wmc.wx,y=wmc.wy}
	nextMap = getMap(worldDest)
	
	globalActors.hero.targetPos = {x=wmc.mx,y=wmc.my}
end

function warpUpdate(dt)
	if dewarping then
		blackOverlayOpacity = blackOverlayOpacity - math.ceil(dt * 255 / fadeTime)
		
		if blackOverlayOpacity < 0 then 

	showGlobals("wa")
			blackOverlayOpacity = 0
			dewarping = false
			--and we've arrived.
		end
	elseif warping then
		blackOverlayOpacity = blackOverlayOpacity + math.ceil(dt * 255 / fadeTime)
		
		if blackOverlayOpacity > 255 then
			blackOverlayOpacity = 255
			startDewarp()
		end
	end
end

function startDewarp()
	--switch out maps
	mapArrive()
	heroArrive() --fine as long as you don't land on something that interacts??
	
	globalActors.hero.facing = "s"
	
	warping = false
	dewarping = true
end