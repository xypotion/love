math.randomseed(os.time())

-- say: start scrolling text, accepts single string or array of strings
-- warp: starts warp to given destination {wx,wy,mx,my}
-- scorePlus: adds given value to current score

eventDataRaw = {
	{
		spriteId = 1,
		collide = true,
		name = "rock1",
		interactionBehavior = {--[[function (i) score = score + i end, 50, ]]
			say, "Sure is a heavy rock!",
			say, "But it seems fishy."}
	},
	{
		spriteId = 2,
		interactionBehavior = {
			say, "here we go!", 
			warp, {wx=1,wy=1,mx=8,my=8}, 
			say, "wait, what am i doing here?"}
	},
	{
		spriteId = 3,
		collide = true,
		interactionBehavior = {
			scorePlus, 10,
			say, "Hi!",
			scorePlus, 11,
			scorePlus, 12,
			say, {"Today my favorite number is "..math.random(1,100)..".", "I love it so much!"},
			scorePlus, 5}
	},
	{
		spriteId = 1,
		collide = true,
		-- actor = true,
		name = "rock2",
		interactionBehavior = {
			-- say, "Sure is a heavy rock!",
			-- say, "But it seems fishy.",
			vanish, "rock2",
			say, "It disappeared!!"}
	},
	{
		spriteId = 1,
		collide = true,
		name = "rock3",
		interactionBehavior = {
			-- say, "Sure is a heavy rock!",
			-- say, "But it seems fishy.",
			hop, "rock2",
			say, "Rock 2 hopped!!"}
	},
	{
		spriteId = 5,
		collide = true,
		name = "swirl1",
		interactionBehavior = {
			say, "The hell is this?"
		}
	},
	{
		spriteId = 5,
		collide = false,
		-- actor = true,
		name = "swirl2",
		interactionBehavior = {
			say, "a little scene!",
			hop, "hero",
			hop, "hero",
			hop, "hero",
			wait, 0.5,
			say, "...one more hop!",
			hop, "hero",
			scorePlus,100,
			-- hop, "hero",
		}
	},
}