function ponginit()		
    paddle_1_width = 20
    paddle_1_height = 70
    paddle_1_x = 0
    paddle_1_y = (screen_height / 2) -  (paddle_1_height / 2)
    paddle_1_speed = 400
    paddle_1_color = {255, 135, 64}

    paddle_2_width = 20
    paddle_2_height = 70
    paddle_2_x = screen_width - paddle_2_width
    paddle_2_y = (screen_height / 2) -  (paddle_1_height / 2)
    paddle_2_speed = 400
    paddle_2_color = {255, 135, 64}

    ball_width = 20
    ball_height = 20
    ball_x = (screen_width / 2) - (ball_width / 2)
    ball_y = (screen_height / 2) - (ball_height / 2)
    ball_color = {255, 214, 64}

    ball_speed_x = -200
    ball_speed_y = 200
end

function pongupdate(dt)
	-- move left paddle
  if love.keyboard.isDown('w') then
      paddle_1_y = paddle_1_y - (paddle_1_speed * dt)
  end
  if love.keyboard.isDown('s') then
      paddle_1_y = paddle_1_y + (paddle_1_speed * dt)
  end
	
	-- move right paddle
	if love.keyboard.isDown('o')
	then
		paddle_2_y = paddle_2_y - (paddle_2_speed * dt)
	end
	if love.keyboard.isDown('l')
	then
		paddle_2_y = paddle_2_y + (paddle_1_speed * dt)
	end
	
	-- bound left paddle to screen
  if paddle_1_y < 0 then
      paddle_1_y = 0
  elseif (paddle_1_y + paddle_1_height) > screen_height then
      paddle_1_y = screen_height - paddle_1_height
  end
	
	--bound right paddle
	if paddle_2_y < 0
	then
		paddle_2_y = 0
	elseif (paddle_2_y + paddle_2_height) > screen_height
	then
		paddle_2_y = screen_height - paddle_2_height
	end			

	-- vertical bouncing
  if ball_y < 0 then
      ball_speed_y = math.abs(ball_speed_y)
  elseif (ball_y + ball_height) > screen_height  then
      ball_speed_y = -math.abs(ball_speed_y)
  end

	-- bounce off left paddle
  if ball_x <= paddle_1_width and
      (ball_y + ball_height) >= paddle_1_y and
      ball_y < (paddle_1_y + paddle_1_height)
  then
      ball_speed_x = math.abs(ball_speed_x)
  end
	
	--bounce off right paddle
	if ball_x + ball_width >= (screen_width - paddle_2_width) and
		(ball_y + ball_height) >= paddle_2_y and
		ball_y < (paddle_2_y + paddle_2_height)
	then
		ball_speed_x = -math.abs(ball_speed_x)
	end

	-- reset ball
  if ball_x + ball_width < 0 or ball_x > screen_width then
      ball_x = (screen_width / 2) - (ball_width / 2)
      ball_y = (screen_height / 2) - (ball_height / 2)
      ball_speed_x = -200
      ball_speed_y = 200
  end

  -- ball moving
  ball_x = ball_x + (ball_speed_x * dt)
  ball_y = ball_y + (ball_speed_y * dt)
end

function pongdraw()
  love.graphics.setColor(paddle_1_color)
  love.graphics.rectangle('fill', paddle_1_x, paddle_1_y, paddle_1_width, paddle_1_height)
	
  love.graphics.setColor(paddle_2_color)
  love.graphics.rectangle('fill', paddle_2_x, paddle_2_y, paddle_2_width, paddle_2_height)

  love.graphics.setColor(ball_color)
  love.graphics.rectangle('fill', ball_x, ball_y, ball_width, ball_height)
end