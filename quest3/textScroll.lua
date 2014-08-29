-- functions called from main
-- maybe these should all be moved to event behaviors manager? or even a separate text display manager that is used by multiple things

function initTextEngine()
	--TODO i guess load font and stuff here?
	
	textBoxPos = {}
	love.graphics.setFont(love.graphics.newFont(18))
	
	textColor = colors.white
	textBoxColor = colors.blue
	
	arrowImage = love.graphics.newImage("img/arrow4.png")
end

function updateScrollingText(dt)
	if lineScrolling then
		textLineCursor = textLineCursor + playerSettings.textSpeed * dt
		displayText = textCurrentLineWhole:sub(0, textLineCursor)
		
		if displayText:len() >= textCurrentLineWhole:len() then
			lineScrolling = false
		end
	end
	
	if menuNext and not lineScrolling then
		--a little hacky... obvs change if you shift this menu functionality to menuStack
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
	love.graphics.rectangle("fill", textBoxPos.x, textBoxPos.y, screenWidth - xRightMargin, 3*tileSize)
	love.graphics.setColor(223,223,223,255)
	love.graphics.rectangle("line", textBoxPos.x, textBoxPos.y, screenWidth - xRightMargin, 3*tileSize) --TODO this looks like shit, change to 2 fill rects

	love.graphics.setColor(textColor.r,textColor.g,textColor.b,255)
	love.graphics.print(displayText, textBoxPos.x + textOffset, textBoxPos.y + textOffset, 0, zoom, zoom)
	
	--TODO don't like any of this being here, really. IF this block doesn't get scrapped and lumped into menuStack, remember to refine graphical stuff here
	if menuWaiting then
		love.graphics.draw(arrowImage, textBoxPos.x, textBoxPos.y + (menuCursor + 0) * 21 * zoom, 0, zoom/12, zoom/12)

		if wholeMenu.hint then
			if showHint then
				love.graphics.print("* "..wholeMenu.hint, textBoxPos.x + textOffset, textBoxPos.y - 21 * zoom, 0, zoom, zoom)
			else
				love.graphics.print("* ", textBoxPos.x + textOffset, textBoxPos.y - 21 * zoom, 0, zoom, zoom)
			end
		end
	elseif not lineScrolling then
		-- blink little icon TODO use a graphic! ., .., ...,
		love.graphics.print(anikeys.map.frame - 1, screenWidth - xRightMargin - 25 * zoom, screenHeight - 25 * zoom, 0, zoom, zoom)
	end
end

function setTextBoxPosition()
	if globalActors.hero.currentPos.y > yLen / 1.5 then
		textBoxPos.y = 0
	else
		textBoxPos.y = (yLen - 3) * tileSize
	end
	
	textBoxPos.x = 0 * zoom
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
	-- change to use menuStack mechanics?
function startPromptAndMenuScroll(prompt)
	textScrolling = true
	textLines = {prompt[1].."                "} --stupid hack! but it works! 16 spaces on the prompt adds a little pause before showing choices
	--TODO kill stupid hack above and add a little pause before showing ANY menu. you'll probably want it

	menuNext = true
	wholeMenu = prompt
	showHint = false
		
	textLineIndex = 1
	addTextLine()
	
	setTextBoxPosition()
end

------------------------------------------------------------------------------------------------------

-- called from main, but probably not its final form or home...
function keyPressedDuringText(key)
	if menuWaiting then
		takeMenuInput(key)
	elseif playerSettings.anyKeyAdvancesText or key == " " then
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

function takeMenuInput(key)
	if key == "down" or key == "s" then
		menuCursor = (menuCursor % (#wholeMenu - 1)) + 1 -- looks weird but has to. it works.
	elseif key == "up" or key == "w" then
		menuCursor = ((menuCursor - 2) % (#wholeMenu - 1)) + 1 -- even worse. blech.
	elseif key == " " or key == "return" then
		finishTextScroll()
		
		skip(wholeMenu[menuCursor + 1][2])
		
		menuWaiting = false
		wholeMenu = nil
		menuCursor = nil
	elseif key == "h" then
		showHint = true
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