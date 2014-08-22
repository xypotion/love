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
	-- true if it happens instantly and needs to trigger the next script line immediately (e.g. scorePlus_, shock_, vanish)
	-- false if it wants the script to wait until its action is done (e.g. wait, hop, say)
	-- CONVENTION: foo returns false (as in "do foo."), foo_ returns true (as in "do foo and...")
	
-- TODO just a proof of concept. change line 22 above to check return value more deeply
function stop(arg)
	runningScriptLine = false
	runningScript = false
	print "SCRIPT STOPPED MANUALLY"
	
	return false
end

-- TODO just a proof of concept. change line 22 above to check return value more deeply
function skip(lines)
	print("SKIPPING "..lines.." LINES")
	csli = csli + lines * 2
	
	return true
end

-- TODO just a proof of concept. change line 22 above to check return value more deeply
function choose(args)
	local prompt = {args[1]}
	
	for i=2,#args do
		prompt[i] = args[i]
	end
	
	-- return say(prompt)
	startPromptAndMenuScroll(prompt)
	
	return false
end
	
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
	actorsShifting = actorsShifting + 1
	startWarpTo(dest)
	
	return false
end

--TODO sayUpper and sayLower to explicitly state where the text box goes (for cutscenes). allow to calculate if not specified (for overworld objects)
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

-- TODO is it possible to have emotes that rest automatically and don't hold up scripts? like shockFor1Sec_()? (probably, but later)

function shock_(name)
	actor = getActorByName(name)
	
	actor.emotion = "shock"
	
	return true
end

function noEmote_(name)
	actor = getActorByName(name)
	
	actor.emotion = nil
	
	return true
end

function hop(name, continue) -- continue = nil if not passed, and that's ok...? lua's so weird.
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
	
	return continue 
end
function hop_(name)
	return hop(name, true)
end

function vanish_(name)
	actor = getActorByName(name)
	
	if actor then
		print("found "..name)
		actor.currentPos.x = -100 -- whatever.
		setActorXY(actor)
	end
	
	return true
end

-- obvs for testing, but who knows? might morph into incrementProgress() or something in final game. :)
function scorePlus_(amt)
	score = score + amt
	print( "score up'd by "..amt)
	return true
end