require "actorDirector"

--actor manager, for moving hero and other actors in cutscenes and out.
--actual translator functions found in actorDirector; this file just interfaces with main, cutscene, and others

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
			if a.complex then
				drawComplexActor(a)
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

function drawComplexActor(actor)
	love.graphics.setColor(255,255,255,255) --TODO i guess set this dynamically? lol
	if actor.emotion then
		frame = actor.anikey.frame % #(actor.quads[actor.emotion]) + 1
		love.graphics.draw(actor.image, actor.quads[actor.emotion][frame], actor.screenX, actor.screenY, 0, 1, 1)
	else
		-- tablePrint(actor)
		frame = actor.anikey.frame % #(actor.quads[actor.facing]) + 1
		love.graphics.draw(actor.image, actor.quads[actor.facing][frame], actor.screenX, actor.screenY, 0, 1, 1)
	end
end

-- called by map.mapArrive and map.init
-- can theoretically be called if events need to be reloaded when something changes on the screen, but scripts may handle that (not sure yet)
function loadLocalActors()
	localActors = {}
	
	-- print ("loadLocalActors")
	
	--load 'em
	for i,ePointer in pairs(currentMap.localActorPointers) do
		la = loadLocalActor(ePointer)
		localActors[i] = la
		
		setActorXY(la)
		
		-- print(i.."'s x, y = "..la.currentPos.x..", "..la.currentPos.y)
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
	actor.translatorFunction(actor, dt) -- TODO can you use : or class notation somehow? hm

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
	
	--could see being a bottleneck, but hasn't hurt performance so far
	for i,la in pairs(localActors) do
		if la.currentPos.x == pos.x and la.currentPos.y == pos.y then
			actor = la
		end
	end
	
	return actor
end

function interactWith(actor)
	print "ping interaction func"
			
	startScript(actor)
end