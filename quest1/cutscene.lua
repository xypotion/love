--STORYTELLING a.k.a. cutscenes. these things will all mingle a lot in the final game, so make the algorithms very flexible!
function initCutsceneEngine()
	textSpeed = 100
end

--TODO some kind of universal flag needed here, or let results of this function (like text/animation/whatever) take care of that as needed?
function startFacingInteraction()
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
	
	-- print("here's lookin at "..lookinAt.x..", "..lookinAt.y)
	
	-- get event if any
	if currentMap.events[lookinAt.y] and currentMap.events[lookinAt.y][lookinAt.x] then 
		e = currentMap.events[lookinAt.y][lookinAt.x] 
	else 
		return false
	end
	
	if e.type == "npc" then --haaack TODO use listed behavior script! should be fully there in eventScripts.lua
		startTextScroll({"Hi! Did you know that my favorite number is "..
		  math.random(1,8)^math.random(1,8)+math.random(1,8).. --tee hee
			"?",
			-- some other event!, 
			"Well, now you know."})
	end
end

------------------------------------------------------------------------------------------------------

-- functions called from main
-- maybe these should all be moved to event behaviors manager? or even a separate text display manager that is used by multiple things

function updateScrollingText(dt)
	if lineScrolling then
		textLineCursor = textLineCursor + textSpeed*dt --TODO make this customizable
		displayText = textCurrentLineWhole:sub(0, textLineCursor)
		
		if displayText:len() >= textCurrentLineWhole:len() then
			lineScrolling = false
		end
	else
		--ready for next line. TODO blink an arrow?
	end
end

function drawScrollingText()
	love.graphics.print(displayText, 10, 200, 0, zoom, zoom)
end

------------------------------------------------------------------------------------------------------

-- cool but a little messy. can we optimize at all?

-- called from event/sprite interaction, not sure where yet; starts the whole text-display comman chain
function startTextScroll(lines)
	textScrolling = true -- maybe not here?
	textLines = lines
	
	textLineIndex = 1
	addTextLine()
end

function addTextLine()
	textCurrentLineWhole = textLines[textLineIndex]
	textLineCursor = 0
	lineScrolling = true
end

function finishTextScroll()
	textScrolling = false
end

-- called from main, but probably not its final form or home...
function keyPressedDuringText(key)
	if key == " " then --lol, actually just any key?? TODO consider, experiment :]
		if lineScrolling then
			-- finish immediately TODO
			displayText = textCurrentLineWhole
			lineScrolling = false
		else
			-- wipe current line, display next if applicable
			textLineIndex = textLineIndex + 1
			if textLineIndex > #textLines then
				-- it's over!!
				textScrolling = false
			else
				-- TODO actually where the scene's next piece will go; not necessarily text, you know?
				addTextLine()
			end
		end
	end
end