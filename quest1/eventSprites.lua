function initEventSprites()
	sprites = love.graphics.newImage("sprites1.png")
	spriteQuads = {
		map = love.graphics.newQuad(0*tileSize,0*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
		rock = love.graphics.newQuad(1*tileSize,0*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
		hole = love.graphics.newQuad(2*tileSize,0*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
		ladder = love.graphics.newQuad(3*tileSize,0*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
		gold = love.graphics.newQuad(0*tileSize,1*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
		elf = { --trying this way for now
			love.graphics.newQuad(0*tileSize,3*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
			love.graphics.newQuad(1*tileSize,3*tileSize,1*tileSize,1*tileSize,4*tileSize,4*tileSize),
		}
	}
end