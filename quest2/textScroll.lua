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


-- cool but a little messy. can we optimize at all?

-- called from event/sprite interaction, not sure where yet; starts the whole text-display comman chain
function startTextScroll(lines)
	textScrolling = true -- maybe not here?
	textLines = lines
	
	--TODO this is hacky, but i like the flexibility? make up your mind, i guess
	
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
	if key == " " then --actually just any key?? TODO consider, experiment :]
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
				-- doNextScriptLine() --TODO TODO TODO hack hack hack
			else
				
				-- TODO actually where the scene's next piece will go; not necessarily text, you know?
				addTextLine()
			end
		end
	end
end