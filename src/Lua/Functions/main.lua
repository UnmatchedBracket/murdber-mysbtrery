local function doAndInsert(file)
	MM[file] = dofile("Functions/Scripts/"..file)
end

doAndInsert("isMM")
doAndInsert("init")
doAndInsert("playerInit")
doAndInsert("canGameEnd")
doAndInsert("endGame")
doAndInsert("pingMurderers")
doAndInsert("playerWithGun")
doAndInsert("startVote")
doAndInsert("startEndCamera")
doAndInsert("handleStorm")
doAndInsert("startShowdown")
doAndInsert("startOvertime")
doAndInsert("discordMessage")
doAndInsert("getpermlevel")
