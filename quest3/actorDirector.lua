-- handles all the updating/shifting things that actors & events can do

------------------------------------------------------------------------------------------------------
--"stoppers" used frequently in actor.finishFunction

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
end

------------------------------------------------------------------------------------------------------
--the translators!

--should only ever be done with actors.waiter
function waitTranslator(actor, dt)
	decrementDistanceFromTarget(actor,dt)
end

function walk(actor, dt)
	local xDelta = (actor.targetPos.x - actor.currentPos.x) * actor.speed * dt
	local yDelta = (actor.targetPos.y - actor.currentPos.y) * actor.speed * dt

	decrementDistanceFromTarget(actor, math.abs(xDelta) + math.abs(yDelta))
	incrementScreenPos(actor, xDelta, yDelta)
end

--should only ever be used by hero, but why not abstract here in case...
function screenWalk(actor, dt)
	local xDelta = (actor.targetPos.x - actor.currentPos.x) * scrollSpeed / yLen * dt
	local yDelta = (actor.targetPos.y - actor.currentPos.y) * scrollSpeed / yLen * dt
	decrementDistanceFromTarget(actor, math.abs(xDelta) + math.abs(yDelta))
	incrementScreenPos(actor, xDelta, yDelta)
end

function hopTranslator(actor, dt)
	actor.timeElapsed = actor.timeElapsed + dt
	
	local yDelta = -(4 -(actor.timeElapsed * 16)) * zoom
	decrementDistanceFromTarget(actor, yDelta)
	incrementScreenPos(actor, 0, yDelta)
end

------------------------------------------------------------------------------------------------------
--helpers

function decrementDistanceFromTarget(actor, deltaDistance)
	actor.distanceFromTarget = actor.distanceFromTarget - deltaDistance
end

function incrementScreenPos(actor,xDelta,yDelta)
	actor.screenX = actor.screenX + xDelta
	actor.screenY = actor.screenY + yDelta
end