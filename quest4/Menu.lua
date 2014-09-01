Menu = class()

function Menu:_init(pos, width, height)
	if pos then
		self.pos = {x=pos.x,y=pos.y}
	else
		self.pos = {x=100,y=100}
	end
	self.width = width or 100
	self.height = height or 100
	
	self.cursor = {
		pos = {x=1,y=1},
		screenPosDelta = {x=10*zoom,y=10*zoom}		
	}
	
	self:updateCursorScreenPos()
	
	self.options = {}
	
	ping(self.width)
end

function Menu:draw()
	love.graphics.setColor(31,31,31,223)
	love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.width, self.height)
	
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("GENERIC MENU; DO NOT INSTANTIATE",10,10)
end

function Menu:drawCursor()
	love.graphics.setColor(255,255,0,255)
	love.graphics.print("GENERIC CURSOR", self.cursor.screenPos.x + 4, 100 + m.cursor.screenPos.y + 4)--, 8*zoom, 8*zoom, 0, zoom/12, zoom/12) --hack TODO
end

function Menu:confirmOK()
	return true
end

function Menu:keyPressed(key)	
	self:remove()
end

function Menu:updateCursorScreenPos()
	-- m = menuStack[#menuStack]
	self.cursor.screenPos = self.cursor.screenPos or {} --in case it's unset
	
	self.cursor.screenPos.x = self.pos.x + self.cursor.pos.x * self.cursor.screenPosDelta.x * zoom
	self.cursor.screenPos.y = self.pos.y + self.cursor.pos.y * self.cursor.screenPosDelta.y * zoom
end

--TODO sorta hacky right now. might move to a different class and/or split 1D vs 2D menus. meh.

function Menu:confirm()
	if self:confirmOK() then
		print("confirm")
		self:remove()
	end
	
	return self:choice()
end

function Menu:choice()
	return "GENERIC CHOICE"
end

function Menu:cancel()
	print("cancel")
	self:remove()
end

---------------------------------------------------------------------------------------------------------------------
--static functions

function Menu:top()
	return menuStack[#menuStack]
end

function Menu:add()
	menuStack[#menuStack + 1] = self
end

function Menu:remove()
	menuStack[#menuStack] = nil
end