Tile = class()

COLORS = {
	-- {239,127,63,255},
-- 	{239,63,127,255},
-- 	{127,239,63,255},
-- 	{127,63,239,255},
-- 	{63,239,127,255},
-- 	{63,127,239,255},
	{63,63,63,255},
	{239,239,239,255},
	{239,63,63,255},
	{63,239,63,255},
	{63,63,239,255},
	{239,239,63,255},
	{63,239,239,255},
	{239,63,239,255},
}

function Tile:_init(x,y)
	self.color = COLORS[math.random(1,#COLORS)]
	self.x = x
	self.y = y
	print "ima tile"
end

function Tile:draw()
	love.graphics.setColor(unpack(self.color))
	
	love.graphics.rectangle("fill", 50*self.x, 50*self.y, 40, 40)
end