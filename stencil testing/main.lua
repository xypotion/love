-- local function myStencilFunction()
--    love.graphics.rectangle("fill", 225, 200, 350, 300)
-- end
--
-- function love.draw()
--     -- draw a rectangle as a stencil. Each pixel touched by the rectangle will have its stencil value set to 1. The rest will be 0.
--     love.graphics.stencil(myStencilFunction, "replace", 1)
--
--    -- Only allow rendering on pixels which have a stencil value greater than 0.
--     love.graphics.setStencilTest("greater", 0)
--
--     love.graphics.setColor(255, 0, 0, 120)
--     love.graphics.circle("fill", 300, 300, 150, 50)
--
--     love.graphics.setColor(0, 255, 0, 120)
--     love.graphics.circle("fill", 500, 300, 150, 50)
--
--     love.graphics.setColor(0, 0, 255, 120)
--     love.graphics.circle("fill", 400, 400, 150, 50)
--
--     love.graphics.setStencilTest()
-- end





-- -- a black/white mask image: black pixels will mask, white pixels will pass.
-- local mask = love.graphics.newImage("mymask1.png")
--
-- local mask_shader = love.graphics.newShader[[
--    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
--       if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
--          // a discarded pixel wont be applied as the stencil.
--          discard;
--       }
--       return vec4(1.0);
--    }
-- ]]
--
-- local function myStencilFunction()
--    love.graphics.setShader(mask_shader)
--    love.graphics.draw(mask, 0, 0)
--    love.graphics.setShader()
-- end
--
-- function love.draw()
--     love.graphics.stencil(myStencilFunction, "replace", 1)
--     love.graphics.setStencilTest("greater", 0)
--     love.graphics.rectangle("fill", 0, 0, 256, 256)
--     love.graphics.setStencilTest()
-- end


 
function love.load()
	foo = 0
	painting1 = love.graphics.newImage("painting1.jpg")
	painting2 = love.graphics.newImage("painting2.jpg")
	
	circles = {}
	
	math.randomseed(os.time())
	
	clicked = false
end

local function myStencilFunction()
   -- Draw four overlapping circles as a stencil.
	 -- love.graphics.setColor(31, 31, 191) --doesn't do anything?
		 
   -- love.graphics.circle("fill", 200, 250, foo)
   -- love.graphics.circle("line", 300, 250, 100)
   -- love.graphics.circle("fill", 250, 200, 100)
   -- love.graphics.circle("fill", 250, 300, 100)
	 
	 for k, c in pairs(circles) do
		 love.graphics.circle("fill", c[1], c[2], c[3])
	 end
end
 
function love.update(dt)
	foo = foo + dt * 64
	
	if clicked then
		makeCircle(love.mouse.getPosition())
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end
 
function love.draw()
	-- love.graphics.setColor(255, 31, 31)
	-- love.graphics.rectangle("fill", 0, 0, 500, 500)
	love.graphics.setStencilTest()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(painting1)
	
	love.graphics.print("click!")

	-- Each pixel touched by each circle will have its stencil value incremented by 1.
	-- The stencil values for pixels where the circles overlap will be at least 2.
	love.graphics.stencil(myStencilFunction, "incrementwrap")

	-- Only allow drawing in areas which have stencil values that are less than 2.
	love.graphics.setStencilTest("greater", 0)

	-- Draw a big rectangle.
	-- love.graphics.setColor(255, 31, 31)
	-- love.graphics.rectangle("fill", 0, 0, 500, 500)
	love.graphics.setColor(255, 63, 63)
	love.graphics.draw(painting1)
	
	-- love.graphics.setStencilTest()
	love.graphics.setStencilTest("greater", 2)
	-- love.graphics.rectangle("fill", 0, 0, 800, 600)
	love.graphics.draw(painting2)


	-- love.graphics.rectangle("fill",0,0,600,600)
end

function love.mousepressed(x, y)
	-- table.insert(circles, {x, y, math.random(50) + 50})
	-- for i = 1, 20 do
	-- end
	
	clicked = true
end

function makeCircle(x, y)
	table.insert(circles, {x + math.random(200) - 100, y + math.random(200) - 100, math.random(50) + 5})
end