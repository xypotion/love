Menu2D = class(Menu)

function Menu2D:_init(...)
	self.super:_init(...)
	
	-- tablePrint(self.cursor)
	
	self.options = {{1,2},{3,4}} --TODO why?
end

function Menu2D:keyPressed(key)
	-- print(key.." pressed on generic menu.")
	if key == "w" or key == "up" then
		self:up()
	elseif key == "s" or key == "down" then
		self:down()
	elseif key == "a" or key == "left" then
		self:left()
	elseif key == "d" or key == "right" then
		self:right()
	elseif key == " " or key == "return" then
		self:confirm()
	elseif key == "x" then
		self:cancel()
	end
	
	self:updateCursorScreenPos()
end

function Menu2D:up()
	self.cursor.pos.y = (self.cursor.pos.y - 2) % #(self.options) + 1
end

function Menu2D:down()
	self.cursor.pos.y = (self.cursor.pos.y) % #(self.options) + 1
end

function Menu2D:right()
	self.cursor.pos.x = (self.cursor.pos.x) % #(self.options[1]) + 1
end

function Menu2D:left()
	self.cursor.pos.x = (self.cursor.pos.x - 2) % #(self.options[1]) + 1
end

function Menu2D:choice()
	return self.options[self.cursor.pos.y][self.cursor.pos.x]
end