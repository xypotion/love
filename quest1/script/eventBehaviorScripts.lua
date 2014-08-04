--[[
maybe make a bunch of script/data files and keep them in a separate window!

event scripts
map behavior scripts
map data
sprite data + quads

enemy data
battle behavior scripts
- AI scripts
- ability scripts

item data

lol, you need to make: map loader (w/graphics), then event loader (w/graphics), THEN behavior scripts
]]

function doScript(id) --super generic, but why not?
	startScene()
	--find and do the right behavior
	endScene()
end