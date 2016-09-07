ListMenu = class()

local xOffset = 20
local yOffset = -5
local optionHeight = 23
local textHeight = 23

function ListMenu:_init(pos)
	self.pos = pos
	self.w, self.h = 100, 100
	-- self.yMargin = 10
	-- self.xMargin = 10
	
	self.cursor = {
		pos = 1
	}
	
	self.options = {
		-- "back to one"
	}
end

function ListMenu:draw(dim)
	love.graphics.setColor(111,111,111)
	love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.w, self.h)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("line", self.pos.x, self.pos.y, self.w, self.h)

	--print options
	love.graphics.setColor(255,255,255)
	for i = 1, #self.options do
		love.graphics.print(self.options[i].label, self.pos.x + xOffset, self.pos.y + yOffset + i * optionHeight)
	end
	
	--draw cursor
	love.graphics.circle("fill", self.pos.x + 10, self.pos.y + self.cursor.pos * textHeight + 5, 4)
end

------------------------------------------------------------------------------------------------------------------------------------

function ListMenu:keypressed(key)
	if key == "up" then
		self.cursor.pos = (self.cursor.pos - 2) % #self.options + 1
	elseif key == "down" then
		self.cursor.pos = self.cursor.pos % #self.options + 1
	elseif key == "return" then
		self:menuConfirm()
	end
end

function ListMenu:menuConfirm()
	-- showGlobals()
	-- tablePrint(self.options[self.cursor.pos])
	
	-- print("calling menu action",self.options[self.cursor.pos].action.func)
	local action = self.options[self.cursor.pos].action
	-- local func = self.options[self.cursor.pos].action.func
	-- call(self.options[self.cursor.pos].action.func)
	-- local success, err = pcall(self.options[self.cursor.pos].action.func())
	-- local success, err = pcall(function (func))
	-- print(success, err)
	
	if action.args then 
		local success, err = pcall(_G[action.func], unpack(action.args))
		print(success, err)
	else
		local success, err = pcall(_G[action.func])
		print(success, err)
	end	
end

function ListMenu:addMenu()
end