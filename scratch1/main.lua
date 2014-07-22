-- require "pongshit"
-- require "doodles"
require "gridlocking"

function love.load()
  screen_width = 500
  screen_height = 300
  background_color = {31, 127, 63}
	-- ponginit()
	
	frame_length = .4
	time = 0
	spritestate = 1
	
	char_height = 32
	char_width = 32
	
	char_x = (screen_width - char_width)/2
	char_y = (screen_height - char_height)/2
	char_speed = 150
	
	char_image = love.graphics.newImage("man7d.png")
	quad1 = love.graphics.newQuad(0,0,32,32,64,32)
	quad2 = love.graphics.newQuad(32,0,32,32,64,32)
	-- char_image = love.graphics.newImage("man7c.png")
	-- quad1 = love.graphics.newQuad(0,0,64,64,128,64)
	-- quad2 = love.graphics.newQuad(64,0,64,64,128,64)
	
	state = 'play'

  love.window.setTitle('...')
  love.window.setMode(screen_width, screen_height)
	
	gridLoad()
end

function love.update(dt) -- dt is the time since love.update was last called and can be used for making the speed of things consistent. (cool!)
  if state ~= 'play' then
    return
  end
	
	move_character(dt)
	
	anim_step(dt)
	
	gridUpdate(dt)
end

function love.draw()
  love.graphics.setBackgroundColor(background_color)
	-- pongdraw()
	
  if state == 'pause' then
    love.graphics.setColor(0, 0, 0, 100)
    love.graphics.rectangle('fill', 0, 0, screen_width, screen_height)
  end

  love.graphics.setColor(255, 255, 255, 255)
	
	if spritestate == 1 then current_quad = quad1 else current_quad = quad2 end
	-- love.graphics.draw(char_image, current_quad, round(char_x), round(char_y))
	love.graphics.draw(char_image, current_quad, player.act_x, player.act_y)
	love.graphics.draw(char_image, current_quad, 100, 100, 0, .5, .5)
	love.graphics.draw(char_image, current_quad, 250, 50, 0, 2, 2)
	love.graphics.draw(char_image, current_quad, 350, 50, 0, 3, 3)

  love.graphics.setFont(love.graphics.newFont(8))
  love.graphics.setColor(0, 255, 0, 255)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

function love.keypressed(key)
  if key == 'q' or key == 'escape' then
    love.event.quit()
  end

  if key == 'p' then
    if state == 'play' then
      state = 'pause'
    else
      state = 'play'
    end
  end

-- function love.keypressed(key)
    if key == "up" then
        player.grid_y = player.grid_y - 32
    elseif key == "down" then
        player.grid_y = player.grid_y + 32
    elseif key == "left" then
        player.grid_x = player.grid_x - 32
    elseif key == "right" then
        player.grid_x = player.grid_x + 32
    end
end

function love.focus(f)
	if not f then
    state = 'pause'
  end
end

function move_character(dt)
	-- if love.keyboard.isDown('w') then
	-- 	char_y = char_y - char_speed * dt
	-- end
	-- if love.keyboard.isDown('a') then
	-- 	char_x = char_x - char_speed * dt
	-- end
	-- if love.keyboard.isDown('s') then
	-- 	char_y = char_y + char_speed * dt
	-- end
	-- if love.keyboard.isDown('d') then
	-- 	char_x = char_x + char_speed * dt
	-- end
	
	gridMove(dt)
end

function anim_step(dt)
	time = time + dt
	if(time > frame_length) then
		spritestate = (spritestate + 1) % 2
		time = 0
	end
end


function round(num)
	if math.modf(num) > .5 then
		return math.ceil(num)
	else
		return math.floor(num)
	end
end