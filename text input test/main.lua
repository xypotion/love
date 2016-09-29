function love.load()
	text = "type here! \n"
	blinker = 0
end

function love.update(dt)
	blinker = (blinker + dt) % 1
end

function love.draw()
	if blinker > 0.5 then
		love.graphics.print(text.."|", 10, 10)
	else
		love.graphics.print(text, 10, 10)
	end
end

function love.textinput(t)
	text = text..t
end

function love.keypressed(key)
	if key == "backspace" then
		text = string.sub(text, 1,  -2)
	elseif key == "return" then
		text = text.."\n"
	end
end