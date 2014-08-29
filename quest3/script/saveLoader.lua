-- loads all progress-related data

-- TODO actually save & load files here! just kinda hard-coded playtesting data for now

function loadSaveData()
	worldPos = {x=2,y=1}
	heroGridPos = {x=8,y=8}
	facing = "s" -- for south
	
	--great for defaults; can use "or" when loading if they are set?
	playerSettings = {
		textSpeed = 60,
		anyKeyAdvancesText = true,
	}

	windowState = 1
	
	-- derp derp
	-- storyProgress = 0
	score = 0
	
	rockTriggered = false
	
	--TODO load/create world here?
end