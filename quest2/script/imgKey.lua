function loadImages()
	mapTileImage = love.graphics.newImage("img/chipset2.png")
	eventSpritesImage = love.graphics.newImage("img/sprites1.png")
	heroDirectionalImage = love.graphics.newImage("img/directional-man1.2.png")
	-- sprite images, etc
	-- * lazy loading?
	
	makeQuads()
end

function setupAnimationKeys()
	anikeys = {}
	anikeys[2] = {
		frame = 0,
		count = 2,
		interval = .4,
		time = 0
	}
	-- and whichever else
end

function tickAnimationKeys(dt)
	for id,ak in pairs(anikeys) do
		ak.time = ak.time + dt
		if ak.time > ak.interval then
			ak.time = 0
			ak.frame = (ak.frame + 1) % ak.count
		end
	end
	print(math.random())
end

-- called at startup (from loadImages() above) and whenever zoom changes
function makeQuads()
	qs = {} --"quad size", just a shortcut for those last four values (quad length & height, image length & height) newQuad needs below in quadAt

	qs = {1*tileSize,1*tileSize,8*tileSize,8*tileSize}
	spriteQuads = {}
	
	qs = {1*tileSize,1*tileSize,2*tileSize,4*tileSize}
	mapTileQuads = {
		quadAt(0,1,qs), --0: grass
		{quadAt(0,0,qs), quadAt(1,0,qs), anikey = 2}, -- 1: water
		quadAt(0,2,qs), --2: flower
		quadAt(1,1,qs), --3: light dirt
		quadAt(1,2,qs), --4: dark dirt
		quadAt(0,3,qs), --5: stone
		quadAt(1,3,qs), --6: daarkness
	}
	
	print("it's a "..type(mapTileQuads[6]))
	
	--repeat for other quad collections
end

function quadAt(x, y, qs)
	return love.graphics.newQuad(x*tileSize, y*tileSize, qs[1]*tileSize, qs[2]*tileSize, qs[3]*tileSize, qs[4]*tileSize)
end