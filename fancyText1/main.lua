require 'helpers'

function love.load()
	local font = love.graphics.newFont(20)
	
	t1 = love.graphics.newText(font, "hello world")
	
	tWrapped = love.graphics.newText(font)
	tWrapped:setf("if this lets me wrap text automatically within pixel bounds i'm going to be very excited.", 200, "left")
	
	tColored = love.graphics.newText(font)
	tColored:setf({{255, 255, 255}, "and obviously the best text color is ", {192, 32, 255}, "purple.\n", {255, 255, 63}, "...OK, Löve 0.10.0 is really cool."}, 500, "left" )
end

function love.draw()
	love.graphics.draw(t1, 10, 10)

	love.graphics.rectangle("line", 10, 50, 200, 200)
	love.graphics.draw(tWrapped, 10, 50)
	
	love.graphics.draw(tColored, 10, 300)
end

function love.update(dt)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end