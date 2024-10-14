local function manage_position(p, item)
	if not item.stick then return end

	if item.animation then
		local t = FixedDiv(item.anim, item.max_anim)

		item.pos = {
			x = ease.incubic(t, item.default_pos.x, item.anim_pos.x),
			y = ease.incubic(t, item.default_pos.y, item.anim_pos.y),
			z = ease.incubic(t, item.default_pos.z, item.anim_pos.z),
		}
	else
		item.pos = {
			x = item.default_pos.x,
			y = item.default_pos.y,
			z = item.default_pos.z
		}
	end

	local ox = FixedMul(p.mo.radius*3/2, item.pos.y)
	local oy = FixedMul(p.mo.radius*3/2, -item.pos.x)

	local xx = FixedMul(ox, cos(p.mo.angle))
	local xy = FixedMul(ox, sin(p.mo.angle))
	local yx = FixedMul(oy, sin(p.mo.angle))
	local yy = FixedMul(oy, cos(p.mo.angle))

	local x = xx-yx
	local y = yy+xy

	item.mobj.angle = p.mo.angle
	P_MoveOrigin(item.mobj,
		p.mo.x+x,
		p.mo.y+y,
		p.mo.z+FixedMul(p.mo.height/2, p.mo.scale)+item.pos.z
	)
end

addHook("PostThinkFrame", do
	if not MM:isMM() then return end

	for p in players.iterate do
		if not (p and p.mm and #p.mm.inventory.items) then continue end

		local inv = p.mm.inventory

		for i,item in ipairs(inv.items) do
			if not (item.mobj and item.mobj.valid) then
				item.mobj = MM:MakeWeaponMobj(p, item)
			end

			if i ~= inv.cur_sel then
				item.mobj.flags = $|MF2_DONTDRAW
				continue
			end
			item.mobj.flags = $ & ~MF2_DONTDRAW
	
			manage_position(p, item)
		end
	end
end)

MM:addPlayerScript(function(p)
	local inv = p.mm.inventory
	local sel = 0

	if p.cmd.buttons & BT_WEAPONNEXT
	and not (p.lastbuttons & BT_WEAPONNEXT) then
		sel = $+1
	end

	if p.cmd.buttons & BT_WEAPONPREV
	and not (p.lastbuttons & BT_WEAPONPREV) then
		sel = $-1
	end

	if abs(sel) then
		local item = inv.items[inv.cur_sel]
		local def = MM.Items[item and item.id or ""]

		inv.cur_sel = $+sel

		while inv.cur_sel < 1 do
			inv.cur_sel = $+p.mm.inventory.count
		end
		while inv.cur_sel > p.mm.inventory.count do
			inv.cur_sel = $-p.mm.inventory.count
		end

		local newitem = inv.items[inv.cur_sel]
		local newdef = MM.Items[newitem and newitem.id or ""]

		if item
		and def
		and def.unequip then
			def.unequip(item, p)
		end

		if newitem
		and newdef
		and newdef.equip then
			newdef.equip(newitem, p)
		end

		if newitem
		and newitem.equipsfx then
			S_StartSound(p.mo, newitem.equipsfx)
		end

		if newitem then
			newitem.anim = 0
			newitem.hit = 0
			newitem.cooldown = max(newitem.cooldown, 12)
		end
	end

	local item = inv.items[inv.cur_sel]

	if not item then return end
	local def = MM.Items[item.id]

	// timers

	item.hit = max(0, $-1)
	item.anim = max(0, $-1)
	item.cooldown = max(0, $-1)
	if item.timeleft >= 0 then
		item.timeleft = max(0, $-1)
	end

	// drop le weapon

	if p.cmd.buttons & BT_CUSTOM2
	and not (p.lastbuttons & BT_CUSTOM2) then
		MM:DropItem(p)
		return
	end

	if item.timeleft == 0 then
		MM:DropItem(p, true)
		return
	end

	// attacking/use

	if p.cmd.buttons & BT_ATTACK
	and not (p.lastbuttons & BT_ATTACK)
	and not (item.cooldown) then
		item.hit = item.max_hit
		item.anim = item.max_anim
		item.cooldown = item.max_cooldown

		if item.shootable then
			local bullet = P_SpawnMobjFromMobj(p.mo, 0,0,p.mo.height/2, item.shootmobj)

			bullet.angle = p.mo.angle
			bullet.aiming = p.aiming
			bullet.color = p.mo.color
			bullet.target = p.mo

			P_InstaThrust(bullet, bullet.angle, 32*cos(p.aiming))
			bullet.momz = 32*sin(p.aiming)

			table.insert(item.bullets, bullet)
		end
		if def.attack then
			def.attack(item, p)
		end
		if item.attacksfx then
			S_StartSound(p.mo, item.attacksfx)
		end
	end

	// hit detection

	if item.damage
	and item.hit then
		for p2 in players.iterate do
			if not (p2 ~= p
			and p2
			and p2.mo
			and p2.mo.health
			and p2.mm
			and not p2.mm.spectator) then continue end

			local dist = R_PointToDist2(p.mo.x, p.mo.y, p2.mo.x, p2.mo.y)
			local maxdist = (p.mo.radius+p2.mo.radius)*3/2

			if dist > maxdist
			or abs(p.mo.z-p2.mo.z) > max(p.mo.height, p2.mo.height)*3/2
			or not P_CheckSight(p.mo, p2.mo) then
				continue
			end

			P_DamageMobj(p2.mo, item.mobj, p.mo, 999, DMG_INSTAKILL)
			item.hit = 0
			item.anim = item.max_anim/3
			if item.hitsfx then
				S_StartSound(p.mo, item.hitsfx)
			end
			return
		end
	end
end)