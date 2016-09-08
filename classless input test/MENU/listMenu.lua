--so if we're going classless, what does a ListMenu look like?
--  x/y/h/w
--  type = "listMenu"
--  cursor & pos
--  images: background image, border image, cursor image
--  options... generating these should probably be entirely contained here, on a per-intent basis. 
--  - i.e. even if two menus work the same way, if their intents (and therefore options) are different, generate them differently
--  - but i guess still draw & update them the same way? will just need a "subtype" field, i guess
--    - or is it better to have something like updateType, drawType, and initType?

--don't forget that options sometimes have hover effects. sample option, for highlighting an item while looking at a character's gear:
-- {
-- 	label = "test", enabled = true,
-- 	action = {func = "itemOptions", args = {inventory[cursor.pos]}},
--  hover = {func = "highlightStat", args {element = self.charReference, option = cursor.pos}},
-- },
--TODO 1. make a regular menu with hover effects, like changing the menu's border color
--TODO 2. make a menu that affects something in another focus element (like another menu)
--TODO 3. then combine those to make a "panel menu" or something that highlights lines in another menu, on hover 
--TODO controller input! 
--TODO menu that scrolls at the top and bottom (test only)

ListMenu = {}

ListMenu.xOffset = 20
ListMenu.yOffset = -2
ListMenu.optionHeight = 13
ListMenu.textHeight = 13
	
function ListMenu.new(params)
	--default stuff
	lm = {
		type = "ListMenu",
		
		x = 10,
		y = 10,
		h = 100,
		w = 100,
		
		textColor = {r = 255, g = 255, b = 255, a = 255},
		bgColor = {r = 127, g = 127, b = 127, a = 127},
		borderColor = {r = 255, g = 255, b = 255, a = 255},
		
		options = {
			{  label = "no params",	action = {func = "gfCancel"}  }
		},
		
		cursor = {pos = 1}
	}
	
	-- addParams(lm, params)
	
	return lm
end

function addMenuOption(menu, params)
end

function ListMenu.draw(menu)
	love.graphics.setColor(111,111,111)
	love.graphics.rectangle("fill", menu.x, menu.y, menu.w, menu.h)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("line", menu.x, menu.y, menu.w, menu.h)

	--print options
	love.graphics.setColor(255,255,255)
	for i = 1, #menu.options do
		love.graphics.print(menu.options[i].label, menu.x + ListMenu.xOffset, menu.y + ListMenu.yOffset + i * ListMenu.optionHeight)
	end
	
	--draw cursor
	love.graphics.circle("fill", menu.x + 10, menu.y + menu.cursor.pos * ListMenu.textHeight + 5, 2)
end

function ListMenu.update(dt)
	
end

------------------------------------------------------------------------------------------------------------------------------------

function ListMenu.keypressed(menu, key)
	if key == "up" then
		menu.cursor.pos = (menu.cursor.pos - 2) % #menu.options + 1
	elseif key == "down" then
		menu.cursor.pos = menu.cursor.pos % #menu.options + 1
	elseif key == "return" then
		menuConfirm(menu)
	end
end

function menuConfirm(menu)
	-- showGlobals()
	-- tablePrint(self.options[self.cursor.pos])
	
	-- print("calling menu action",self.options[self.cursor.pos].action.func)
	local action = menu.options[menu.cursor.pos].action
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