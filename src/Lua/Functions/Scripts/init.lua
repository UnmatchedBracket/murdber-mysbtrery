local matchVars = MM.require "Variables/Data/Match"
local shallowCopy = MM.require "Libs/shallowCopy"
local randomPlayer = MM.require "Libs/getRandomPlayer"

return function(self)
	MM_N = shallowCopy(matchVars)

	for p in players.iterate do
		self:playerInit(p)
	end

	local count = 0
	for p in players.iterate do
		count = $+1
	end

	MM_N.waiting_for_players = count < 2

	if not (self:isMM() and count >= 2) then return end

	local murdererP = randomPlayer(function(p) return p.mm end)
	local sherriffP = randomPlayer(function(p) return p.mm and p ~= murdererP end)

	murdererP.mm.role = 2 -- murderer
	sherriffP.mm.role = 3 -- sherriff
end