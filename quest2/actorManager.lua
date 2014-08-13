--actor manager, for shifting hero and other actors in cutscenes and out

function initActorManager()
	actors = {}
	actorsShifting = 0
end

function shiftActors(dt)
	for name,actor in pairs(actors) do
		shiftActor(actor, dt)
	end
end

function shiftActor(actor, dt)
	deltaPos, dist = actor.translatorFunction(actor, dt) -- this apparently works! but TODO can you use : or class notation somehow? hm
	
	-- print(deltaPos.y)
	
	actor.screenX = actor.screenX + deltaPos.x
	actor.screenY = actor.screenY + deltaPos.y
	actor.distanceFromTarget = dist--deltaPos.distanceFromTarget
		
	if actor.distanceFromTarget <= 0 then -- er, maybe... TODO
		actor.finishFunction(actor)--heroArrive()
	end
end

function actorArrive(actor) -- is this necessary?
	actor.distanceFromTarget = 0
	actorsShifting = actorsShifting - 1
	targetTileType = nil
	-- actor.translatorFunction = nil --TODO aha! you do need a screenWalk translatorFunction!
	
	--finalize and snap to grid
	actor.currentPos = actor.targetPos
	setActorXY(actor)
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

function drawActors()
	for id,a in pairs(actors) do
		drawActor(a)
	end
end

function drawActor(actor)
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(actor.image, actor.quads[actor.facing][actor.anikey.frame], actor.screenX, actor.screenY, 0, 1, 1)
end

------------------------------------------------------------------------------------------------------

--translator functions!
--seems almost too abstracted & genericized, huh? but you NEED this for cutscenes, trust me.

function walk(actor, dt)
	local xDelta = (actor.targetPos.x - actor.currentPos.x) * actor.speed * dt
	local yDelta = (actor.targetPos.y - actor.currentPos.y) * actor.speed * dt
	local d = actor.distanceFromTarget - math.abs(xDelta) - math.abs(yDelta)
	
	return {x=xDelta, y=yDelta}, d--istanceFromTarget=d} --lol
end

--should only ever be used by hero, but why not abstract here in case...
function screenWalk(actor, dt)
	local xDelta = (actor.targetPos.x - actor.currentPos.x) * scrollSpeed / yLen * dt
	local yDelta = (actor.targetPos.y - actor.currentPos.y) * scrollSpeed / yLen * dt
	local d = actor.distanceFromTarget - math.abs(xDelta) - math.abs(yDelta)
	
	return {x=xDelta, y=yDelta}, d--istanceFromTarget=d} --lol
end

function hopTranslator(actor, dt)
	actor.timeElapsed = actor.timeElapsed + dt
	
	local yDelta = -(8 -(actor.timeElapsed * 32))
	local d = actor.distanceFromTarget - yDelta
	
	return {x=0, y=yDelta}, d
end