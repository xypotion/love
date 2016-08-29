ListMenu = class()

local xOffset = 10
local yOffset = -5
local optionHeight = 15
local textHeight = 16

function ListMenu:_init(pos)
	self.pos = pos
	
	self.cursor = {
		pos = 3
	}
	
	self.options = {"make another menu","back","back to one"}
end

function ListMenu:draw(dim)
	love.graphics.setColor(111,111,111)
	love.graphics.rectangle("fill", self.pos.x, self.pos.y, 150, 65)

	--print options
	love.graphics.setColor(255,255,255)
	for i = 1, #self.options do
		love.graphics.print(self.options[i], self.pos.x + xOffset, self.pos.y + yOffset + i * optionHeight)
	end
	
	--draw cursor
	love.graphics.circle("fill", self.pos.x, self.pos.y + self.cursor.pos * textHeight, 4)
end