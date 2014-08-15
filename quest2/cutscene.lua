--STORYTELLING a.k.a. cutscenes. these things will all mingle a lot in the final game, so make the algorithms very flexible!

function startScript(event)
	runningScript = true
	currentScript = event.interactionBehavior
	csli = 1 -- "current script line index"
	
	doNextScriptLine()
	
	-- event.spriteId = newEvent(eventDataRaw[1])
end

function doNextScriptLine()
	if currentScript[csli] then
		line = currentScript[csli]	
		_type = type(line)
	
		-- read closely, because this is weird!
		if _type == "function" then
			-- if it's a function, do it and pass the NEXT script element as the argument...
			-- ...and then check the return value. if it's true, recurse to have the next script line start instantly.
			if currentScript[csli](currentScript[csli+1]) then
				csli = csli + 2
				doNextScriptLine()
			else
				csli = csli + 2
			end
		else
			print("ERROR, "..type(currentScript[csli]).." found in event script where there should have been a function.")
			print(currentScript[csli])
			runningScriptLine = false
			runningScript = false
		end
	else
		runningScriptLine = false
		runningScript = false
		print "SCRIPT OVER"
	end	
end

------------------------------------------------------------------------------------------------------

-- shortcuts used in eventDataRaw; each either does something instantly or sets up an animation for the next
-- each returns...
	-- true if it happens instantly and needs to trigger the next script line immediately
	-- false if it wants the script to wait until its action is done
-- TODO maybe do validation here, too? for arg types? (?)
	
-- slightly hacky, but it works!
function wait(sec)
	globalActors.waiter.translatorFunction = waitTranslator
	globalActors.waiter.finishFunction = stopActor
	globalActors.waiter.distanceFromTarget = sec
	
	actorsShifting = actorsShifting + 1
	
	return false
end

function warp(dest)
	print ("warp")
	startWarpTo(dest)
	
	return false
end

function say(dialog)
	print "say"
	if type(dialog) == "table" then
		startTextScroll(dialog)
	elseif type(dialog) == "string" then
		startTextScroll({dialog})
	else
		print("ERROR in say(), argument must be string or table of strings")
	end
	
	return false
end

-- function walk(args) --TODO
-- 	-- event name
-- 	-- direction
-- 	-- number of steps
-- 	-- run next line, true or false
-- end

--TODO suuper for testing. i guess emotion should be passed as an arg? or not? i dunno
--TODO i want timed (variable? always 1sec? eh) AND permanent (so no one has to wait!) versions of all emoters
function shock(name)
	actor = getActorByName(name)
	
	actor.emotion = "shock"
	
	return true
end
function noEmote(name)
	actor = getActorByName(name)
	
	actor.emotion = nil
	
	return true
end

function hop(name)--, continue)
	actor = getActorByName(name)
	
	if not actor then 
		print("don't know an actor called "..name)
		return false
	end
	
	actor.translatorFunction = hopTranslator
	actor.finishFunction = actorArrive
	actor.timeElapsed = 0
	actor.distanceFromTarget = 0
	actor.targetPos = actor.currentPos
	actorsShifting = actorsShifting + 1
	
	return false --TODO use passed variable so this can do either
end

--ehh. later. TODO
-- function hopAndWait(eventName)
-- 	return hop(eventName, false)
-- end

function hop_(name)
	return hop(name, true)
end

--for testing (kind of); happens instantly. may use in final game?
function vanish(name)
	actor = getActorByName(name)
	
	if actor then
		print("found "..name)
		actor.currentPos.x = -100 --whatever
		setActorXY(actor)
	end
	
	return true
end

--for testing; happens instantly, as item acquisition & flag/progress updating should
function scorePlus(amt)
	score = score + amt
	print( "score up'd by "..amt)
	return true
end