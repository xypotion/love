--STORYTELLING a.k.a. cutscenes. these things will all mingle a lot in the final game, so make the algorithms very flexible!
function initCutsceneEngine()
	textSpeed = 100
end

function startFacingInteraction()
	
	--TODO i feel like this is the wrong place for this, but maybe whatever
	lookinAt = {}
	if facing == "s" then
		lookinAt.x = heroGridPos.x
		lookinAt.y = heroGridPos.y+1
	elseif facing == "n" then
		lookinAt.x = heroGridPos.x
		lookinAt.y = heroGridPos.y-1
	elseif facing == "e" then
		lookinAt.x = heroGridPos.x+1
		lookinAt.y = heroGridPos.y
	elseif facing == "w" then
		lookinAt.x = heroGridPos.x-1
		lookinAt.y = heroGridPos.y
	end
	
	-- get event if any
	if currentMap.events[lookinAt.y] and currentMap.events[lookinAt.y][lookinAt.x] then 
		interactWith(currentMap.events[lookinAt.y][lookinAt.x])
	else 
		return false
	end
end

------------------------------------------------------------------------------------------------------

function startScript(event)
	runningScript = true
	currentScript = event.interactionBehavior
	currentScriptLineIndex = 0
	
	-- runningScriptLine = true
	doNextScriptLine(currentScriptLineIndex)
end

function doNextScriptLine()
	--check if there is a next, update index and booleans (?), finish if none
	nextIndex = currentScriptLineIndex + 1
	
	if currentScript[nextIndex] then
		doCurrentScriptLine(nextIndex)
	else
		runningScriptLine = false
		runningScript = false
	end	
end

function doCurrentScriptLine(i)
	currentScriptLineIndex = i
	-- runningScriptLine = true
	
	print("do line "..i)
	
	line = currentScript[i]	
	_type = type(line)
	
	if _type == "function" then
		if bs[i](bs[i+1]) then
			currentScriptLineIndex = currentScriptLineIndex + 1 
			doNextScriptLine()
		end
			--...KINDA hacky, but kinda elegant too? hmm
			
	-- elseif _type == "string" then
	-- 	print(bs[i])
	-- 	startTextScroll(bs[i])
	-- elseif _type == "??" then
	end
	
end

------------------------------------------------------------------------------------------------------

-- shortcuts from eventDataRaw
-- maybe do validation here too? at least for arg types

function warp(dest)
	print ("warp")
	startWarpTo(dest)
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
end

--for testing; happens instantly, as item acquisition & flag/progress updating should
function scorePlus(amt)
	score = score + amt
	print "score up'd"
	-- doNextScriptLine()
	return true
end