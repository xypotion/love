function loadImages()
	mapTileImage = love.graphics.newImage("img/chipset2.png")
	eventSpritesImage = love.graphics.newImage("img/sprites1.png")
	heroDirectionalImage = love.graphics.newImage("img/directional-man1.2.png")
	swirlImage = love.graphics.newImage("img/swirl8reverse.png")
	-- sprite images, etc
	-- * lazy loading?
	
	makeQuads()
end

--TODO this maybe doesn't even have to be a called function; just make it raw, outside data
-- function setupAnimationKeys()
	anikeys = {}
	anikeys[1] = { --MASTER, used for all maps TODO maybe even make it anikeys.map instead of [1]
		frame = 1,
		count = 2,
		interval = .4,
		time = 0
	}
	anikeys.hero = {
		frame = 1,
		count = 2,
		interval = .32,
		time = 0
	}
	anikeys.swirl = {
		frame = 1,
		count = 8,
		interval = .05,
		time = 0
	}
	-- and whichever else
-- end

function tickAnimationKeys(dt)
	for id,ak in pairs(anikeys) do
		ak.time = ak.time + dt
		if ak.time > ak.interval then
			ak.time = 0
			ak.frame = (ak.frame) % ak.count + 1
		end
	end
end

-- called at startup (from loadImages() above) and whenever zoom changes
function makeQuads()
	qs = {} --"quad size", shortcut for the last 4 of 6 arguments to newQuad in quadAt

	--TODO consider making anikeys specific to spritequad collections like this, not their members? 
	  -- probably shouldn't be mixing sprite types too much in final game assets...
	-- also TODO put image references in the quad collections, as well? i think that's right, haha
	qs = {1,1,4,4}
	spriteQuads = {
		quadAt(1,0,qs), --1:rock
		quadAt(2,0,qs), --2:hole
		{quadAt(0,3,qs), quadAt(1,3,qs), anikeyId = 1}, --3:elf TODO change anikey. i'm arbitrarily deciding that [1] is ONLY for map tiles.
		quadAt(0,0,qs), --4:map
	}
	
	qs = {1,1,2,4}
	mapTileQuads = {
		quadAt(0,1,qs), --1: grass
		quadAt(0,2,qs), --2: flower
		{quadAt(0,0,qs), quadAt(1,0,qs)}, --3: water
		quadAt(1,1,qs), --4: light dirt
		quadAt(1,2,qs), --5: dark dirt
		quadAt(0,3,qs), --6: stone
		quadAt(1,3,qs), --7: daarkness
	}
	
	qs = {1,1,8,1}
	heroQuads = {
		anikey = anikeys.hero,
		s = {quadAt(0,0,qs),quadAt(1,0,qs)},
		n = {quadAt(2,0,qs),quadAt(3,0,qs)},
		w = {quadAt(4,0,qs),quadAt(5,0,qs)},
		e = {quadAt(6,0,qs),quadAt(7,0,qs)},
	}
	
	qs = {1,1,8,1}
	swirlQuads = {
		quadAt(0,0,qs),
		quadAt(1,0,qs),
		quadAt(2,0,qs),
		quadAt(3,0,qs),
		quadAt(4,0,qs),
		quadAt(5,0,qs),
		quadAt(6,0,qs),
		quadAt(7,0,qs),
		-- anikey = anikeys.swirl,
		anikeyId = "swirl",
	}
	spriteQuads[5] = swirlQuads --what. TODO
	
	--repeat for other quad collections
end

-- makes a quad with provided args. just saves space above ~
function quadAt(x, y, qs)
	return love.graphics.newQuad(x*tileSize, y*tileSize, qs[1]*tileSize, qs[2]*tileSize, qs[3]*tileSize, qs[4]*tileSize)
end