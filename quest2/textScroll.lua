-- functions called from main
-- maybe these should all be moved to event behaviors manager? or even a separate text display manager that is used by multiple things

function initTextEngine()
	textSpeed = 100 --TODO user setting
	--TODO i guess load font and stuff here?
end

function updateScrollingText(dt)
	if lineScrolling then
		textLineCursor = textLineCursor + textSpeed*dt --TODO make this customizable by user
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

-- called from cutscene manager
function startTextScroll(lines)
	textScrolling = true --probably the best place for this. hope it doesn't blow stuff up later.
	textLines = lines
		
	textLineIndex = 1
	addTextLine()
end

------------------------------------------------------------------------------------------------------

-- called from main, but probably not its final form or home...
function keyPressedDuringText(key)
	if key == " " then --actually just any key?? TODO consider, experiment :]
		if lineScrolling then
			displayText = textCurrentLineWhole
			lineScrolling = false
		else
			-- queue up next line if extant, otherwise wrap up!
			textLineIndex = textLineIndex + 1
			if textLineIndex > #textLines then --slightly hacky...? hm
				-- it's over!!
				finishTextScroll()
			else
				-- next line
				addTextLine()
			end
		end
	end
end

function addTextLine()
	displayText = "" --best place for this! trust me.
	textCurrentLineWhole = textLines[textLineIndex]
	textLineCursor = 0
	lineScrolling = true
end

function finishTextScroll() -- in case you want to add more to this later, like an animation or sfx
	textScrolling = false
	lineScrolling = false
end