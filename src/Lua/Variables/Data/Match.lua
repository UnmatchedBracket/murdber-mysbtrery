local match_time = 190*TICRATE

return {
	time = match_time+10*TICRATE,
	maxtime = match_time,

	murderers = {},
	innocents = {},

	clues_amount = 0,
	clues_in_map = false,
	clues = {},

	speed_cap = 28*FU,

	waiting_for_players = false,

	showdown = false,
	showdown_song = "MMOVRT",
	showdown_ticker = 0,

	overtime = false,
	overtime_ticker = 0,

	storm_point = nil,
	storm_ticker = 0,
	storm_startingdist = 6000*FU,

	gameover = false,
	voting = false,
	mapVote = {},
	results_ticker = 0,
	end_ticker = 0,

	pings_done = 0,
	ping_time = 0,
	ping_approx = FU,
	max_ping_time = 30*TICRATE,
	ping_positions = {},

	corpses = {},
	knownDeadPlayers = {},

	--round ended because all innocents/murderers left the game
	disconnect_end = false,
	killing_end = false,
	sniped_end = false
}