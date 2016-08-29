require "MISC/helpers"
require "MENU/listMenu"

function love.load()
	-- love.window.setMode(800, 600, {highdpi = true})
	-- print(love.window.getPixelScale())
	
	focusStack = {}
	table.insert(focusStack, ListMenu({x=100, y=100}))
	table.insert(focusStack, ListMenu({x=300, y=100}))
	
	print(pcall(love.draw))
	print(pcall("love.draw"))
	print(pcall(lobeliaaa))
	-- _G["love"]["update"](1)
end

function love.update(dt)
end

function love.draw()
	local dim = false
	
	for key, element in ipairs(focusStack) do
		element:draw(dim)
		dim = true
	end
	
	-- for k,v in pairs(zarr) do --apparently really doesn't go in order. don't trust it for z-ordering! https://www.lua.org/pil/7.3.html
	-- for k,v in ipairs(zarr) do --also out for z-ordering since it stops once it hits a nil. do this another way if you want to
		-- draw(v)
	-- end
end

------------------------------------------------------------------

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end