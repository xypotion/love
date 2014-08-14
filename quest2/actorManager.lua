--actor manager, for shifting hero and other actors in cutscenes and out

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

--TODO maybe rename
function shiftActors(dt)
	for name,actor in pairs(actors) do
		if actor.translatorFunction then
			shiftActor(actor, dt)
		end
	end
end

--TODO rename, maybe to moveActor or even just updateActor
function shiftActor(actor, dt)
	actor.translatorFunction(actor, dt) -- this apparently works! but TODO can you use : or class notation somehow? hm

	if actor.distanceFromTarget <= 0 then
		actor.finishFunction(actor)
	end
end

function actorArrive(actor)
	stopActor(actor)
	
	--finalize and snap to grid
	actor.currentPos = actor.targetPos
	setActorXY(actor)
end

function stopActor(actor)
	actor.distanceFromTarget = 0
	actorsShifting = actorsShifting - 1
	actor.translatorFunction = nil
	-- print (os.time())
end

function setActorXY(actor)
	actor.screenX = (actor.currentPos.x - 1) * tileSize + xMargin
	actor.screenY = (actor.currentPos.y - 1) * tileSize + yMargin
end

function getActorOrEventByName(name)
	thing = actors[name]
	if not thing then
		thing = getEventByName(name)
	end
	
	return thing
end

------------------------------------------------------------------------------------------------------

--translator functions! set up in cuscene.lua for actor-related lines of scripts, they make actors DO things during the update step

function updatePosAndDistance(actor,deltaPos,deltaDistance)
	--use me TODO
end

function incrementDistanceFromTarget(actor, deltaDistance) --TODO rename to decrement?
	actor.distanceFromTarget = actor.distanceFromTarget + deltaDistance
end

function incrementScreenPos(actor,xDelta,yDelta)
	actor.screenX = actor.screenX + xDelta
	actor.screenY = actor.screenY + yDelta
end

--should only ever be done with actors.waiter
function waitTranslator(actor, dt)
	incrementDistanceFromTarget(actor,-dt)
end

function walk(actor, dt)
	local xDelta = (actor.targetPos.x - actor.currentPos.x) * actor.speed * dt
	local yDelta = (actor.targetPos.y - actor.currentPos.y) * actor.speed * dt

	incrementDistanceFromTarget(actor, - math.abs(xDelta) - math.abs(yDelta))
	incrementScreenPos(actor, xDelta, yDelta)
end

--should only ever be used by hero, but why not abstract here in case...
function screenWalk(actor, dt)
	local xDelta = (actor.targetPos.x - actor.currentPos.x) * scrollSpeed / yLen * dt
	local yDelta = (actor.targetPos.y - actor.currentPos.y) * scrollSpeed / yLen * dt
	incrementDistanceFromTarget(actor, - math.abs(xDelta) - math.abs(yDelta))
	incrementScreenPos(actor, xDelta, yDelta)
end

function hopTranslator(actor, dt)
	actor.timeElapsed = actor.timeElapsed + dt --TODO maybe do this above? since it'll never change and may get used lots
	
	local yDelta = -(8 -(actor.timeElapsed * 32))
	incrementDistanceFromTarget(actor, - yDelta)
	incrementScreenPos(actor, 0, yDelta)
end