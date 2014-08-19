-- functions called from main
-- maybe these should all be moved to event behaviors manager? or even a separate text display manager that is used by multiple things

function initTextEngine()
	textSpeed = 60 --TODO user setting
	--TODO i guess load font and stuff here?
	
	textBoxPos = {}
	love.graphics.setFont(love.graphics.newFont(18))
	
	textColor = colors.white
	textBoxColor = colors.blue
end

function updateScrollingText(dt)
	if lineScrolling then
		textLineCursor = textLineCursor + textSpeed * dt
		displayText = textCurrentLineWhole:sub(0, textLineCursor)
		
		if displayText:len() >= textCurrentLineWhole:len() then
			lineScrolling = false
		end
	else
		--ready for next line. TODO blink an arrow?
	end
end

function drawScrollingText()
	love.graphics.setColor(textBoxColor.r,textBoxColor.g,textBoxColor.b,255)
	love.graphics.rectangle("fill", textBoxPos.x, textBoxPos.y, xLen*tileSize, yLen*tileSize)

	love.graphics.setColor(textColor.r,textColor.g,textColor.b,255)
	love.graphics.print(displayText, textBoxPos.x + textOffset, textBoxPos.y + textOffset, 0, zoom, zoom)
end

-- called from cutscene manager
function startTextScroll(lines)
	textScrolling = true --probably the best place for this. hope it doesn't blow stuff up later.
	textLines = lines
		
	textLineIndex = 1
	addTextLine()
	
	setTextBoxPosition()
end

function setTextBoxPosition()
	-- print("LOL WHERE DO I PUT IT")
	
	textBoxPos.x = 0 * zoom
	textBoxPos.y = (yLen - 3) * tileSize
	textOffset = 10 * zoom
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