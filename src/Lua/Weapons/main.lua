mobjinfo[freeslot "MT_MM_WEAPON"] = {
	radius = 16*FU,
	height = 16*FU,
	spawnstate = S_THOK,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT,
	flags2 = MF2_DONTDRAW
}

MM.weapons = {}

local function getWeapon(file)
	local data = dofile("Weapons/"..file.."/def.lua")

	MM.weapons[file] = data
end

-- globalized version for modding
function MM:makeWeapon(name, data)
	self.weapons[name] = data
end

function MM:giveWeapon(p, name)
	if not (p.mo and p.mm) then return end
	if not (self.weapons[name]) then return end

	p.mm.weapon = P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_MM_WEAPON)
	p.mm.weapon.__type = name
	p.mm.weapon.target = p.mo
	p.mm.weapon.fired = false
	p.mm.weapon.state = self.weapons[name].state
	p.mm.weapon.ox = 0
	p.mm.weapon.oy = 0
	p.mm.weapon.oz = 0

	self.weapons[name].spawn(p, p.mm.weapon)
end

function MM:getWpnData(p)
	if not (p.mo and p.mm and p.mm.weapon and p.mm.weapon.valid) then return end

	return self.weapons[p.mm.weapon.__type]
end

local weapons = {}
addHook("NetVars", function(n) weapons = n($) end)

addHook("MobjSpawn", function(wpn)
	table.insert(weapons, wpn)
end, MT_MM_WEAPON)

addHook("TouchSpecial", function(special, toucher)
	if not (special
	and special.target
	and special.target.player
	and special.target.player.mm) then return true end

	if not (toucher
	and toucher.player
	and toucher.player.mm) then return true end

	if special.target.player.mm.role == toucher.player.mm.role then
		return true
	end

	if special.target == toucher then return true end

	local data = MM:getWpnData(special.target.player)
	if data.can_damage(special.target.player, special, toucher.player) then
		P_DamageMobj(toucher, special, special, 999, DMG_INSTAKILL)
	end
	return true
end, MT_MM_WEAPON)

addHook("MobjThinker", function(wpn)
	if not (wpn and wpn.valid) then return end
	if not (wpn.target
	and wpn.target.valid
	and wpn.target.player
	and wpn.target.player.mm
	and wpn.target.player.mm.weapon == wpn) then
		P_RemoveMobj(wpn)
		return
	end

	local data = MM:getWpnData(wpn.target.player)

	data.think(wpn.target.player, wpn)
	if wpn.target.player.cmd.buttons & BT_ATTACK
	and not wpn.fired then
		data.attack(wpn.target.player, wpn)
		wpn.fired = true
	end
	if not (wpn.target.player.cmd.buttons & BT_ATTACK) then
		wpn.fired = false
	end
	
end, MT_MM_WEAPON)

addHook("PostThinkFrame", do
	for _,wpn in pairs(weapons) do
		if not (wpn and wpn.valid) then
			table.remove(weapons, _)
			continue
		end

		wpn.momx = wpn.target.momx
		wpn.momy = wpn.target.momy
		wpn.momz = wpn.target.momz
		wpn.angle = wpn.target.angle
		P_MoveOrigin(wpn,
			wpn.target.x+wpn.ox,
			wpn.target.y+wpn.oy,
			wpn.target.z+(wpn.target.height/2)+wpn.oz)
	end
end)

getWeapon("Knife")
getWeapon("Gun")

dofile "Weapons/dropped"