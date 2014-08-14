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
	
	-- print("---LOCAL ACTORS--- there are "..#localActors.." of them")
	-- tablePrint(localActors)
	-- print("---GLOBAL ACTORS--- there are "..#globalActors.." of them")
	-- tablePrint(globalActors)
	
	-- drawActors({1,2,3,{4,5,6},7})--localActors)
	drawActors(localActors)
	-- drawActors({10,20,30,{40,50,60}})--globalActors)
	drawActors(globalActors)
	-- ping ("drawing all actors??")
	-- ping(false) --tee hee
end

function drawGlobalActors()
	drawActors(globalActors)
end

function drawActors(actors)

	-- actors = {1,2,3,{4,5,6}}

	-- tablePrint(actors)
	
	for id,a in pairs(actors) do
		-- ping ("drawing a generic actor")
		if a.image and a.quads then
			if a.facing then
				drawDirectionalActor(a)
		-- ping ("drawing a direc. actor")
			else
				drawActor(a)
			end
		end
	end
	
	-- ping ("DONE DRAWING THOSE ACTORS")
	-- ping ("THERE WERE "..#actors.." OF THEM")
end

function drawActor(actor)
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(actor.image, actor.quads[actor.anikey.frame], actor.screenX, actor.screenY, 0, 1, 1)
end

function drawDirectionalActor(actor)
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(actor.image, actor.quads[actor.facing][actor.anikey.frame], actor.screenX, actor.screenY, 0, 1, 1)
end

--used by map
function loadLocalActors()
	localActors = {}
	
	-- foo={1,2,3,4}
	
	print ("loadLocalActors")
	
	--load 'em
	-- print(#currentMap.eventPointers)
	for i,ePointer in pairs(currentMap.eventPointers) do --{}) do-- foo) do--
		
		
		la = loadLocalActor(ePointer)
		localActors[i] = la
		
		setActorXY(la)
		
		-- print(i.." = "..la.name)
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
	
	--and the same for events with names? TODO
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
		-- thing = getEventByName(name)
		for k,v in pairs(localActors) do
			if v and v.name and v.name == name then
				thing = v
			end
		end
	end
	
	return thing
end

function getLocalActorByPos(pos)
	-- actor = {} --TODO ugh. for tileType/collision. #hate
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