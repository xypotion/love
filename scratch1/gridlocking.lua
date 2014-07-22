function gridLoad()
	player = {
    grid_x = 256,
    grid_y = 256,
    act_x = 200,
    act_y = 200,
		speed = 10
	}
end

function gridUpdate(dt)
  player.act_y = player.act_y - ((player.act_y - player.grid_y) * player.speed * dt)
  -- player.act_x = player.act_x - ((player.act_x - player.grid_x) * player.speed * dt)
	-- i hate it. X(
	
	-- repeat
  	-- player.act_y = player.act_y + player.speed * dt-- - ((player.act_y - player.grid_y) * player.speed * dt)
  player.act_x = player.act_x - ((player.act_x - player.grid_x) * player.speed * dt)
end

function gridMove(dt)
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
end

-- function gridDraw()
-- 	love.grap