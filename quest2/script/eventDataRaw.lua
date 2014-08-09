math.randomseed(os.time())

-- say: start scrolling text, accepts single string or array of strings
-- warp: starts warp to given destination {wx,wy,mx,my}
-- scorePlus: adds given value to current score

eventDataRaw = {
	{
		spriteId = 1,
		collide = true,
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
			scorePlus, 11,
			say, "Today my favorite number is "..math.random(1,100)..".", 
			scorePlus, 5}
	},
}