require "actorDirector"

--actor manager, for moving hero and other actors in cutscenes and out.
--actual translator functions found in actorDirector; this file just interfaces with main, cutscene, and others

function initActorManager()
	actors = {}
	actorsShifting = 0
	
	actors.waiter = {}
end

function drawActors()
	for id,a in pairs(actors) do
		if a.image and a.quads then
			drawActor(a)
		end
	end
end

function drawActor(actor)
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(actor.image, actor.quads[actor.facing][actor.anikey.frame], actor.screenX, actor.screenY, 0, 1, 1)
end

function moveActors(dt)
	for name,actor in pairs(actors) do
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

--actors and events are things... what? >_>
function getActorOrEventByName(name)
	local thing = actors[name]
	if not thing then
		thing = getEventByName(name)
	end
	
	return thing
end