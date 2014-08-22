-- functions called from main
-- maybe these should all be moved to event behaviors manager? or even a separate text display manager that is used by multiple things

function initTextEngine()
	textSpeed = 60 --TODO user setting
	--TODO i guess load font and stuff here?
	
	textBoxPos = {}
	love.graphics.setFont(love.graphics.newFont(18))
	
	textColor = colors.white
	textBoxColor = colors.blue
	
	arrowImage = love.graphics.newImage("img/arrow3.png")
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
	
	--TODO cleanup
	if menuNext and not lineScrolling then
		ping "menu??"
		
		for i=2,#wholeMenu do
			displayText = displayText.."\n    "..wholeMenu[i][1]
		end
		
		menuNext = false
		menuWaiting = true
		menuCursor = 1
	end
end

function drawScrollingText()
	love.graphics.setColor(textBoxColor.r,textBoxColor.g,textBoxColor.b,255)
	love.graphics.rectangle("fill", textBoxPos.x, textBoxPos.y, xLen*tileSize, yLen*tileSize)

	love.graphics.setColor(textColor.r,textColor.g,textColor.b,255)
	love.graphics.print(displayText, textBoxPos.x + textOffset, textBoxPos.y + textOffset, 0, zoom, zoom)
	
	if menuWaiting then
		love.graphics.draw(arrowImage, textBoxPos.x, textBoxPos.y + (menuCursor + 0) * 21 * zoom, 0, zoom/12, zoom/12) --TODO hacko
	end
end

function setTextBoxPosition()
	--TODO make it go to the top of the screen when hero is at the bottom? except if it's only taking up the bottom 3 tiles onscreen, maybe it's ok...?
	
	textBoxPos.x = 0 * zoom
	textBoxPos.y = (yLen - 3) * tileSize
	textOffset = 6 * zoom
end

------------------------------------------------------------------------------------------------------

-- called from cutscene manager
function startTextScroll(lines)
	textScrolling = true --probably the best place for this. hope it doesn't blow stuff up later.
	textLines = lines
		
	textLineIndex = 1
	addTextLine()
	
	setTextBoxPosition()
end

--TODO gonna be really hacky and weird at first! this is my first attempt at menu mechanics! :O
function startPromptAndMenuScroll(prompt)
	textScrolling = true
	textLines = {prompt[1].."                "} --stupid hack! but it works! 16 spaces on the prompt adds a little pause before showing choices (TODO?)

	menuNext = true
	wholeMenu = prompt
		
	textLineIndex = 1
	addTextLine()
	
	setTextBoxPosition()
end

------------------------------------------------------------------------------------------------------

-- called from main, but probably not its final form or home...
function keyPressedDuringText(key)
	if menuWaiting then
		takeMenuInput(key)
	elseif key == " " or key == "return" then --actually just any key?? TODO consider, experiment :]
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

--TODO cleanup
function takeMenuInput(key)
	if key == "down" or key == "s" then
		menuCursor = (menuCursor % (#wholeMenu - 1)) + 1 -- looks weird but works.
	elseif key == "up" or key == "w" then
		menuCursor = ((menuCursor - 2) % (#wholeMenu - 1)) + 1 -- even worse. still works. blech.
	elseif key == " " or key == "return" then
		finishTextScroll()
		
		skip(wholeMenu[menuCursor + 1][2])
		
		menuWaiting = false
		wholeMenu = nil
		menuCursor = nil
	end
	
	-- print(menuCursor)
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