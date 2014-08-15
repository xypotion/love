function loadImages()
	-- mapTileImage = love.graphics.newImage("img/chipset2.png")
	-- eventSpritesImage = love.graphics.newImage("img/sprites1.png")
	-- heroDirectionalImage = love.graphics.newImage("img/directional-man1.2.png")
	-- swirlImage = love.graphics.newImage("img/swirl9.png")
	-- sprite images, etc
	-- * lazy loading?
	
	makeQuads()
end
	
images = {
	mapChipsets = {love.graphics.newImage("img/chipset2.png")},
	stillActors = {love.graphics.newImage("img/sprites1.png")},
	animatedActors = {love.graphics.newImage("img/sprites1.png")}, --TODO heh
	characters = {
		hero = love.graphics.newImage("img/directional-man1.2.png"),
		elf = love.graphics.newImage("img/directional-elf-1.png"),
		},
}

-- quadSets = {}
-- quadSets.stillActors = {
-- 	--quads
-- }

anikeys = {}
anikeys.map = {
	frame = 1,
	count = 2,
	interval = .4,
	time = 0
}
anikeys.stillActors = {
	frame = 1,
	count = 1,
	interval = 5, --TODO somehow prevent from ticking?
	time = 0
}
anikeys.characters = {
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

function tickAnimationKeys(dt)
	for id,ak in pairs(anikeys) do
		ak.time = ak.time + dt
		if ak.time > ak.interval then
			ak.time = 0
			ak.frame = (ak.frame) % ak.count + 1
		end
	end
end

-- called at startup (from loadImages() above) and (TODO) whenever zoom changes
function makeQuads()
	qs = {} --"quad size", shortcut for the last 4 of 6 arguments to newQuad in quadAt

	--TODO consider making anikeys specific to spritequad collections like this, not their members? 
	  -- probably shouldn't be mixing sprite types too much in final game assets...
	-- also TODO put image references in the quad collections, as well? i think that's right, haha
	quadSets = {}

	qs = {1,1,8,1}
	quadSets.characters = {
		-- anikey = anikeys.characters,
		s = {quadAt(0,0,qs),quadAt(1,0,qs)},
		n = {quadAt(2,0,qs),quadAt(3,0,qs)},
		w = {quadAt(4,0,qs),quadAt(5,0,qs)},
		e = {quadAt(6,0,qs),quadAt(7,0,qs)},
		shock = {quadAt(0.5,0,qs)} --TODO
	}
	--TODO also emotion/casting/hit/down/whatever quads used by all characters in cutscenes? anikeys will be change in those cases, is the problem
	
	qs = {1,1,4,4}
	quadSets.stillActors = {
		quadAt(0,0,qs), --1:map
		{quadAt(1,0,qs)}, --2:rock
		quadAt(2,0,qs), --3:hole
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
	quadSets.stillActors[5] = swirlQuads --what. TODO
	
	--repeat for other quad collections
end

-- makes a quad with provided args. just saves space above ~
function quadAt(x, y, qs)
	return love.graphics.newQuad(x*tileSize, y*tileSize, qs[1]*tileSize, qs[2]*tileSize, qs[3]*tileSize, qs[4]*tileSize)
end

--queried by ID by actors when loaded. provides: image pointer, anikey, quadset
-- function makeSpriteConstructs()
-- 	spriteConstructs = {
-- 		-- {image = images.mapChipsets[1], anikey = anikeys.map, quads = mapTileQuads}, --NOT FOR MAP CHIPSETS
-- 		{image = images.stillActors[1], quadSet = quadSets.stillActor[1]}
-- 	}
-- end