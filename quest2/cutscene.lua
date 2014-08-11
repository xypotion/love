--STORYTELLING a.k.a. cutscenes. these things will all mingle a lot in the final game, so make the algorithms very flexible!

function startScript(event)
	runningScript = true
	currentScript = event.interactionBehavior
	csli = 1 -- "current script line index"
	
	doNextScriptLine()
	
	-- event.spriteId = newEvent(eventDataRaw[1])
end

function doNextScriptLine()
	--check if there is a next, update index and booleans (?), finish if none
	if currentScript[csli] then
		line = currentScript[csli]	
		_type = type(line)
	
		if _type == "function" then
			-- if it's a function, do it and pass the next script element as an argument...
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

-- shortcuts from eventDataRaw
-- return true if they happen instantly and need to trigger the next script line immediately
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
	
	print ""
	print(heroShifting)
	
	--TODO remove obvs. just trying to crash it
	foo = nil
	-- print(foo[0])
end

--kinda for testing, but should work. removes named event entirely
function vanish(eventName)
	print ("vanish")
	
	for k,v in pairs(currentMap.eventShortcuts) do
		print(k)
		print(v)
	end

	eventPos = currentMap.eventShortcuts[eventName]
	
	if eventPos and eventPos.x and eventPos.y then
		setEventByPosition(eventPos, nil)
	else
		print "no events here by that name."
		print(eventName)
	end
	
	return true
end

function walk(args)
	-- event name
	-- direction
	-- number of steps
	-- run next line, true or false
end

function hop(eventName)
	-- run next line, true or false
end

--* either of the above could have multiple versions, like hop() and hopAndWait()

--for testing; happens instantly, as item acquisition & flag/progress updating should
function scorePlus(amt)
	score = score + amt
	print( "score up'd by "..amt)
	return true
end