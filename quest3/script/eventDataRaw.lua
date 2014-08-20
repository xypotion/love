math.randomseed(os.time())

-- say: start scrolling text, accepts single string or array of strings
-- warp: starts warp to given destination {wx,wy,mx,my}
-- scorePlus_: adds given value to current score

--EXAMPLE
--[[
	name = "foo" --how scripts will reference this actor in most cases. if omitted, most scripts will be unable to see or use this actor
	sc = {category="stillActors", image=1, quad=1} --"sprite construct"; when LOADED, category => anikey, category+image => image, category+quad => quad
		-- note: actors will still have their own image, anikey, and quad pointers; this is so they CAN BE ALTERED for cutscenes, etc withought messing with sc
			--TODO determine if above statement is necessary/true. emotes/complex actors cover... all of that? i think? (if you handle anikeys smartly)
		-- can also just omit if event is invisible! e.g. town exit points
	complex = false-- if false, may animate and "perform" e.g. hopping, but doesn't turn or emote
		-- or true: animates, but has a facing (south by default), and can emote (!!), interrupting normal animation temporarily
	collide = true -- if true, hero cannot pass through; if false, s/he can. also determines how interaction is triggered
	interactionBehavior = {say, "hello world"} -- commands in manual interaction script, listed in pairs
	interactionBehavior = interactionBehaviorsRaw[1] -- can also have shortcuts like so (TODO)
	idleBehavior = {} -- still need TODO this :)
	--that's it!
]]


eventDataRaw = {
	--1:
	{
		name = "rock1",
		-- spriteId = 1,
		sc = {category="stillActors", image=1, quadId=2},
		collide = true,
		interactionBehavior = {
			say, "Sure is a heavy rock!",
			say, "But it seems fishy."}
	},
	{
		sc = {category="stillActors", image=1, quadId=3},
		interactionBehavior = {
			say, "here we go!", 
			warp, {wx=1,wy=1,mx=8,my=8}, 
			say, "wait, what am i doing here?"}
	},
	{
		sc = {category="characters", image="elf", quadId=1},
		name = "elf",
		complex = true, --TODO MAYBE slip into sc.quadId instead of making separate? more concise, les redundant/confusing...
		collide = true,
		interactionBehavior = {
			shock_, "elf",
			shock_, "hero",
			scorePlus_, 10,
			wait, 0.5,
			noEmote_, "elf",
			noEmote_, "hero",
			say, "Hello!",
			scorePlus_, 11,
			scorePlus_, 12,
			say, {"Today my favorite number is "..math.random(1,100)..".", "I love it so much!"},
			scorePlus_, 5}
	},
	{
		name = "rock2",
		sc = {category="stillActors", image=1, quadId=2},
		collide = true,
		interactionBehavior = {
			vanish_, "rock2",
			say, "It disappeared!!"
		}
	},
	--5:
	{
		name = "rock3",
		sc = {category="stillActors", image=1, quadId=2},
		collide = true,
		interactionBehavior = {
			hop, "rock2",
			say, "Rock 2 hopped!!"
		}
	},
	--6:
	{
		name = "swirl1",
		sc = {category="swirl", image=1, quadId=1},
		collide = true,
		interactionBehavior = {
			say, "The hell is this?"
		}
	},
	{
		name = "swirl2",
		sc = {category="swirl", image=1, quadId=1},
		collide = false,
		interactionBehavior = {
			say, "a little scene!",
			hop_, "swirl1",
			hop, "hero",
			hop_, "swirl1",
			hop, "hero",
			hop_, "swirl1",
			hop, "hero",
			wait, 0.5,
			hop_, "swirl2",
			say, "...one more hop!",
			hop_, "swirl1",
			hop, "hero",
			scorePlus_,100,
		}
	},
	{
		name = "marble1",
		sc = {category="marble", image=1, quadId=1},
		collide = false,
	},
	{
		name = "marble2",
		sc = {category="marble", image=2, quadId=1},
		collide = false,
	},
	--10:
	{
		name = "marble3",
		sc = {category="marble", image=3, quadId=1},
		collide = false,
	},
	{
		name = "marble4",
		sc = {category="marble", image=5, quadId=1},
		collide = false,
	},
	{
		name = "marble5",
		sc = {category="marble", image=6, quadId=1},
		collide = false,
	},
	{
		name = "marble6",
		sc = {category="marble", image=7, quadId=1},
		collide = false,
	},
	{
		name = "marble6.1",
		sc = {category="marble", image=8, quadId=1},
		collide = false,
	},
}
