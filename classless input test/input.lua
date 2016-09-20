--these callbacks might not be used as much as their passive versions, but their code should still go here
function love.keypressed(key)
	if DEBUG then
		if key == "escape" then
			love.event.quit()
		elseif key == "space" then
			paused = not paused
		elseif key == "z" then
			scale = scale % 2 + 1
			resizeWindowToScale()
		end
	end
	
	if not paused then
		if #focusStack > 0 then
			_G[focusStack[#focusStack].type].keypressed(focusStack[#focusStack], key)
		else
			--should never happen...
			print("no focused element to interact with")
		end
	end
end

function love.gamepadpressed(j, button)
end

------------------------------------------------------------------------------------------------------------------------------------

--sets states for game controls based on keyboard and gamepad button states. call from update()
function takeInput(dt)
	
end

------------------------------------------------------------------------------------------------------------------------------------

--true if either the mapped key or gamepad button is pressed
function keyOrButtonPressed(signature)
	if love.keyboard.isDown(KEYS[signtature]) or love.joystick.isDown(BUTTONS[signature]) then
		return true
	else
		return false
	end
end