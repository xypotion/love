function love.load()
	-- array of rectangles
	boxes = {}--{12,34,56,78}}
	love.window.setMode(500, 500)
	
	seed = os.time()
	
	math.randomseed(seed)
	love.window.setTitle("seed = "..seed)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
	
	if key == "backspace" then
		boxes[#boxes] = nil
	end
	
	if key == "a" then
		boxes[#boxes + 1] = {math.random(-100,500),math.random(-100,500),math.random(10,100),math.random(10,100)}
	end
	
	if key == "s" then
		for i=1,16 do boxes[#boxes + 1] = {math.random(-100,500),math.random(-100,500),math.random(10,100),math.random(10,100)} end
	end
	
end

-- function love.update(dt)
-- end

function love.draw()
	love.graphics.setColor(255 - #boxes * 3 % 256, #boxes * 2 % 256, #boxes % 256)
	for i=1, #boxes do
		love.graphics.rectangle("fill", boxes[i][1], boxes[i][2], boxes[i][3], boxes[i][4])
	end
	
	love.graphics.setColor(255,255,255)
	if #boxes > 0 then
		love.graphics.print(#boxes)
	else
		love.graphics.print("controls:\nA - add 1 box\nS - add 16 boxes\nBackspace - delete newest box")
	end
end