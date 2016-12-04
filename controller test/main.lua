function love.load()
    local joysticks = love.joystick.getJoysticks()

		-- check to make sure one was found
    if joysticks[1] then
			joystick = joysticks[1]
		else
			print("no joystick found :'(")
			love.event.quit()
		end
		
		numButtons = joystick:getButtonCount()
		buttons = {}
 
    position = {x = 400, y = 300}
    speed = 300
		
		colorBG = {0,0,0}
		colorCircle = {0,0,255}
		
		lastbutton = "none"
		
		customizing = false
		
		-- keyMap = {"a"="left"}
end
 
function love.update(dt)
    if not joystick then 
			-- "controller doesn't exist!"
			return
		end
 
    if joystick:isGamepadDown("dpleft") then
        position.x = position.x - speed * dt
    elseif joystick:isGamepadDown("dpright") then
        position.x = position.x + speed * dt
    end
 
    if joystick:isGamepadDown("dpup") then
        position.y = position.y - speed * dt
    elseif joystick:isGamepadDown("dpdown") then
        position.y = position.y + speed * dt
    end
		
		for i=1, numButtons do
			buttons[i] = joystick:isDown(i)
		end
end
 
function love.draw()
	love.graphics.setColor(colorBG[1], colorBG[2], colorBG[3])
	love.graphics.rectangle("fill", 0,0,800,600)
	
	love.graphics.setColor(colorCircle[1], colorCircle[2], colorCircle[3])
  love.graphics.circle("fill", position.x, position.y, 50)

	love.graphics.setColor(255,255,0)
	for i=1, numButtons do
		if buttons[i] then
			love.graphics.print("button "..i.." pressed", 10, 10 + 15 * i)
		else
			love.graphics.print("button "..i.." not pressed", 10, 10 + 15 * i)
		end
	end

	love.graphics.setColor(255,255,255)
  love.graphics.print("Last gamepad button pressed: "..lastbutton, 10, 10)
	
	if customizing then
		love.graphics.print("WHICH BUTTON IS THE MAGIC BUTTON?", 10, 500)
	else
		love.graphics.print("PRESS SPACE TO CUSTOMIZE GAMEPAD CONTROLS", 10, 500)
	end
end

function love.keypressed(key)
	if key == "space" then
		customizing = true
	-- elseif key == "down" then
		-- focusedElement:downInput -- or something
	end
end

function love.gamepadpressed(j, button)
  lastbutton = button
	
	if customizing then
		magicButton = button
		customizing = false
	else
		if button == magicButton then
			colorCircle = {math.random(255), math.random(255), math.random(255)}
		end
	end
end

function love.joystickremoved(j)
	colorBG = {100,100,100}
end

function love.joystickadded(j)
	colorBG = {0,0,0}

  local joysticks = love.joystick.getJoysticks()
  joystick = joysticks[1]
end

function DOWNPRESSED()
	-- if joystick. --oops, unfinished line...
	
	print("DOWNPRESSED() not implemented")
end