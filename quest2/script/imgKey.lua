function loadImages()
	makeQuads()
	
	-- meh.
end

--
images = {
	mapChipsets = { --TODO rename
		love.graphics.newImage("img/chipset2.png"),
		love.graphics.newImage("img/chipset2castles??.png"),
	},
	stillActors = {love.graphics.newImage("img/sprites1.png")},
	animatedActors = {love.graphics.newImage("img/sprites1.png")}, --not that we have any of these yet, but it's a little reminder...
	characters = {
		hero = love.graphics.newImage("img/directional-man1.2.png"),
		elf = love.graphics.newImage("img/directional-elf-1.png"),
	},
	swirl = {love.graphics.newImage("img/swirl9.png")}, --eh.
}

-- TODO a little hacky/devvy for now, but this is the gist of it. 1 = collide, 0 = clear
	-- should mirror quadSets.map? 
collisionMaps = {}
collisionMaps[1] = {0,0,1,0,0,1,1} --normal chipset
collisionMaps[2] = {0,1,1,0,0,1,1} --"castle"/derp chipset

--
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

--TODO maybe move. dunno where to though, lol
function tickAnimationKeys(dt)
	for id,ak in pairs(anikeys) do
		if ak.interval then --if it's nil, then it's still!
			ak.time = ak.time + dt
			if ak.time > ak.interval then
				ak.time = 0
				ak.frame = (ak.frame) % ak.count + 1
			end
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
		shock = {quadAt(0.5,0,qs)} --TODO glad it works but it's so wrong :P
	}
	--TODO also emotion/casting/hit/down/whatever quads used by all characters in cutscenes? anikeys may change in those cases, is the problem
	
	qs = {1,1,4,4}
	quadSets.stillActors = {
		{quadAt(0,0,qs)}, --1:map
		{quadAt(1,0,qs)}, --2:rock
		{quadAt(2,0,qs)}, --3:hole
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
	quadSets.swirl = {
		{
			quadAt(0,0,qs),
			quadAt(1,0,qs),
			quadAt(2,0,qs),
			quadAt(3,0,qs),
			quadAt(4,0,qs),
			quadAt(5,0,qs),
			quadAt(6,0,qs),
			quadAt(7,0,qs),
		}
	}
	quadSets.stillActors[5] = swirlQuads --what. TODO
	
	--repeat for other quad collections
end

-- makes a quad with provided args. just saves space above ~
function quadAt(x, y, qs)
	return love.graphics.newQuad(x*tileSize, y*tileSize, qs[1]*tileSize, qs[2]*tileSize, qs[3]*tileSize, qs[4]*tileSize)
end