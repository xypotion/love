math.randomseed(os.time())

eventDataRaw = {
	{
		spriteId = 1,
		collide = true,
		interactionBehavior = {--[[function (i) score = score + i end, 50, ]]"Sure is a heavy rock!", "But it seems fishy."}
	},
	{
		spriteId = 2,
		interactionBehavior = {"here we go!", startWarpTo, {wx=1,wy=1,mx=8,my=8}, "wait, what am i doing here?"}
	},
	{
		spriteId = 3,
		collide = true,
		interactionBehavior = {--[[function () score = score + 50 end]]"Today my favorite number is "..math.random(1,100).."."}
	},
}