require "actorDirector"

--actor manager, for moving hero and other actors in cutscenes and out.
--actual translator functions found in actorDirector; this file just interfaces with main, cutscene, and others

--TODO would it be ok to have a shortcut to globalActors.hero just called hero? :S

function initActorManager()
	globalActors = {}
	localActors = {}
	actorsShifting = 0
	
	globalActors.waiter = {}
end

function drawAllActors()
	drawActors(localActors)
	drawActors(globalActors)
end

function drawGlobalActors()
	drawActors(globalActors)
end

function drawActors(actors)
	for id,a in pairs(actors) do
		if a.image and a.quads then
			if a.facing then -- TODO slightly hacky. maybe it's OK? ehh. 
				--since characters (the only actors with facings) alo emote and do other stuff, call this drawComplexActor?
				drawDirectionalActor(a)
			else
				drawActor(a)
			end
		end
	end
end

function drawActor(actor)
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(actor.image, actor.quads[actor.anikey.frame], actor.screenX, actor.screenY, 0, 1, 1)
end

function drawDirectionalActor(actor)
	love.graphics.setColor(255,255,255,255)	
	-- tablePrint(actor)
	love.graphics.draw(actor.image, actor.quads[actor.facing][actor.anikey.frame], actor.screenX, actor.screenY, 0, 1, 1)
end

-- called by map.mapArrive and map.init
-- can theoretically be called if events need to be reloaded when something changes on the screen, but scripts may handle that (not sure yet)
function loadLocalActors()
	localActors = {}
	
	print ("loadLocalActors")
	
	--load 'em
	for i,ePointer in pairs(currentMap.eventPointers) do
		la = loadLocalActor(ePointer)
		localActors[i] = la
		
		setActorXY(la)
		
		print(i.."'s x, y = "..la.currentPos.x..", "..la.currentPos.y)
		
		--TODO localActorsByName[name] = la
		--TODO localActorsByPos[getNumericPos(la.pos)] = la
		--...if you want/need shortcuts like that
	end
	

end

function moveActors(dt)
	for name,actor in pairs(globalActors) do
		if actor.translatorFunction then
			moveActor(actor, dt)
		end
	end

	for name,actor in pairs(localActors) do
		if actor.translatorFunction then
			moveActor(actor, dt)
		end
	end
end

function moveActor(actor, dt)
	actor.translatorFunction(actor, dt) -- this apparently works! but TODO can you use : or class notation somehow? hm

	if actor.distanceFromTarget <= 0 then
		actor.finishFunction(actor)
	end
end

function setActorXY(actor)
	actor.screenX = (actor.currentPos.x - 1) * tileSize + xMargin
	actor.screenY = (actor.currentPos.y - 1) * tileSize + yMargin
end

--checks actors first, then currentMap.events
function getActorByName(name)
	local thing = globalActors[name]
	if not thing then
		for k,v in pairs(localActors) do
			if v and v.name and v.name == name then
				thing = v
			end
		end
	end
	
	return thing
end

function getLocalActorByPos(pos)
	actor = nil
	
	for i,la in pairs(localActors) do
		if la.currentPos.x == pos.x and la.currentPos.y == pos.y then
			actor = la
		end
	end
	
	return actor
end

--TODO still not sure if this is the right place for this... TODO ...or if it's even necessary??
function interactWith(actor)
	print "ping interaction func"
			
	startScript(actor)
end