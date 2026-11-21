-- Fist of Retribution: Super Art select, as in 3rd Strike. After a character (and palette) is chosen, a
-- player whose character has a supers.lua picks one of three Super Arts. The pick rides on the selection
-- (start.saPick[playerNo]) and external/mods/forhud.lua hands it to the character as map "sa".

local U = require('external.script.forui')
local S = {}

local function charDef(ref)
	local ok, p = pcall(getCharFileName, ref)
	if ok then return p end
	return nil
end

function S.arts(ref)
	local d = U.charData(charDef(ref), 'supers.lua')
	return d and d.arts or nil
end

-- does this pick need a Super Art chosen?
function S.wanted(side, ref, demo)
	if main.forTrials then return false end   -- Combo Trials: each trial sets its own Super Art
	if demo or main.cpuSide[side] then return false end
	return S.arts(ref) ~= nil
end

-- one frame of the menu (in the palette step's place); returns the next selectState: 1 stay, 3 confirmed, 0 back
function S.menu(side, cmd, player, member)
	local st = start.p[side].t_selTemp[member]
	local arts = S.arts(st.ref)
	if arts == nil then return 3 end
	st.saCur = st.saCur or 1
	start.p[side].inPalMenu = true
	local keys = motif.select_info['p' .. side].palmenu
	local snd = motif.select_info['p' .. side].palmenu
	-- the button that picked the character is still down for a few frames: ignore input until it's released
	st.saWait = (st.saWait or 0) + 1
	if st.saWait == 2 then
		sndPlay(motif.Snd, 200, 1)   -- announcer: "Choose your Super Art"
	end
	if st.saWait < 12 then
		-- hidden seventh colour, as in 3rd Strike: LP+MK+HP held together when the fighter is picked
		if commandGetState(cmd, '/x') and commandGetState(cmd, '/b') and commandGetState(cmd, '/z') then
			st.pal = 7
		end
		S.draw(side, arts, st.saCur, st.ref)
		return 1
	end
	-- confirm with any attack button. Each button is checked on its own: reading a press uses it up.
	local pressed = nil
	for i, btn in ipairs({'x', 'y', 'z', 'a', 'b', 'c'}) do
		if getInput(cmd, btn) then pressed = i break end
	end
	if pressed then
		st.saWait = nil
		st.sa = st.saCur   -- (the colour was set by the button that picked the fighter)
		sndPlay(motif.Snd, snd.done.snd[1], snd.done.snd[2])
		return 3
	elseif getInput(cmd, keys.cancel.key) then
		st.sa, st.saCur, st.saWait = nil, nil, nil
		start.p[side].inPalMenu = false
		sndPlay(motif.Snd, snd.cancel.snd[1], snd.cancel.snd[2])
		return 0
	elseif getInput(cmd, keys.previous.key) then         -- down / left: next art
		st.saCur = st.saCur % #arts + 1
		sndPlay(motif.Snd, snd.value.snd[1], snd.value.snd[2])
	elseif getInput(cmd, keys.next.key) then             -- up / right: previous art
		st.saCur = (st.saCur - 2) % #arts + 1
		sndPlay(motif.Snd, snd.value.snd[1], snd.value.snd[2])
	end
	S.draw(side, arts, st.saCur, st.ref)
	return 1
end

-- the super's preview animation, taken from the character's move list (SUPER ARTS tab, same order as the arts)
local pv = {}
local function preview(ref, i)
	local key = tostring(ref)
	if pv[key] == nil then
		pv[key] = false
		local def = charDef(ref)
		local ml = U.charData(def, 'movelist.lua')
		if ml ~= nil and ml.tabs ~= nil then
			for _, tab in ipairs(ml.tabs) do
				if tab.name == 'SUPER ARTS' then
					local dir = def:gsub('[^/\\]+$', '')
					pv[key] = {sff = sffNew(dir .. ml.sff), moves = tab.moves, anims = {}}
				end
			end
		end
	end
	local p = pv[key]
	if not p or p.moves[i] == nil or p.moves[i].anim == nil then return nil end
	if p.anims[i] == nil then
		local an = animNew(p.sff, p.moves[i].anim)
		animSetLocalcoord(an, U.LW, U.LH)
		animSetLayerno(an, U.LAYER)
		p.anims[i] = an
	end
	return p.anims[i], p.moves[i].scale or 0.5
end

local frame = 0
local slide = {}
function S.draw(side, arts, cur, ref)
	frame = frame + 1
	U.begin('sa' .. side)
	local L = (side == 1)
	local function X(x, w) return L and x or (U.LW - x - (w or 0)) end
	-- darken the screen, keep the portrait readable
	U.box(0, 0, U.LW, U.LH, 4, 6, 18, 150)
	-- banner: slanted gold bar with the title
	local bx, by = 470, 62
	U.slant(X(bx - 30, 800), by, 800, 70, 30, 0, 0, 0, 200)
	U.slant(X(bx - 20, 790), by + 6, 790, 58, 24, 14, 20, 52, 255)
	U.slant(X(bx - 20, 790), by + 6, 790, 4, 2, U.GOLD[1], 170, 40, 255)
	U.slant(X(bx - 20, 790), by + 60, 790, 4, 2, U.GOLD[1], 170, 40, 255)
	U.spr('data/forpz/hudfx.sff', 3, L and 0 or 1, X(bx + 6, 0), by + 35, 0.92)
	-- three slanted cards; the chosen one slides out and crackles
	local cx, cy, cw, ch, gap = 560, 150, 640, 98, 10
	for i, a in ipairs(arts) do
		local on = (i == cur)
		slide[i] = slide[i] or 0
		slide[i] = slide[i] + ((on and 1 or 0) - slide[i]) * 0.3
		local sx = cx - math.floor(46 * slide[i])
		local y = cy + (i - 1) * (ch + gap)
		local x = X(sx, cw)
		if on then
			-- electric edge: two flickering blue outlines
			local f = (math.floor(frame / 2) % 3)
			U.slant(x - 6 - f, y - 6, cw + 12 + 2 * f, ch + 12, 22, 60, 150, 255, 140 + 40 * f)
			U.slant(x - 3, y - 3, cw + 6, ch + 6, 22, 200, 235, 255, 255)
		end
		U.slant(x, y, cw, ch, 22, on and 22 or 12, on and 34 or 16, on and 90 or 40, 250)
		U.slant(x, y, cw, 5, 1, on and U.GOLD[1] or 60, on and U.GOLD[2] or 70, on and U.GOLD[3] or 110, 255)
		-- big Roman numeral
		local rn = U.ROMAN[i] or tostring(i)
		U.btext(rn, X(sx + 70, 0), y + 76, on and 'FoR_Menu' or 'FoR_MenuDim', 1.55, 0, on and 255 or 170)
		-- name, command, gauge
		local tx = sx + 150
		U.btext(string.upper(a.name), X(tx, 0), y + 38, on and 'FoR_Display' or 'FoR_DisplaySmall', on and 0.74 or 1.2, L and 1 or -1, on and 255 or 170)
		U.cmd(a.cmd, L and (x + cw - 30) or (x + 30), y + 52, 28, L)
		local gw = math.floor(250 * a.len / 128)
		local sw = math.floor((gw - (a.stocks - 1) * 6) / a.stocks)
		local fill = on and math.min(1, ((frame % 90) / 45)) or 1
		for k = 1, a.stocks do
			local gx = tx + (k - 1) * (sw + 6)
			U.box(X(gx - 2, sw + 4), y + 52, sw + 4, 20, 0, 0, 0, 255)
			U.box(X(gx, sw), y + 54, sw, 16, 20, 30, 70, 255)
			local fw = math.floor(sw * math.max(0, math.min(1, fill * a.stocks - (k - 1))))
			if fw > 0 then
				U.box(L and X(gx, fw) or X(gx + sw - fw, fw), y + 54, fw, 16, on and 60 or 40, on and 150 or 80, 255, 255)
				U.box(L and X(gx, fw) or X(gx + sw - fw, fw), y + 54, fw, 5, 190, 230, 255, on and 255 or 120)
			end
		end
		U.btext(a.stocks .. (a.stocks == 1 and ' STOCK' or ' STOCKS'), X(tx, 0), y + 92, 'FoR_DisplaySmall', 0.9, L and 1 or -1, on and 255 or 150)
	end
	-- preview of the chosen super, with its description
	local px, py, pw, ph = 560, cy + 3 * (ch + gap) + 6, 640, 180
	local x = X(px, pw)
	local aw = 250
	U.box(x - 3, py - 3, pw + 6, ph + 6, U.GOLD[1], 140, 20, 255)
	U.box(x, py, pw, ph, 10, 14, 36, 255)
	local flash = (frame % 120) < 4
	U.box(x, py, aw, ph, flash and 90 or 18, flash and 110 or 26, flash and 200 or 62, 255)
	for gy = 0, ph - 1, 4 do U.box(x, py + gy, aw, 1, 0, 0, 0, 70) end
	local an, sc = preview(ref, cur)
	if an ~= nil then
		animSetScale(an, sc * 0.8, sc * 0.8)
		animSetWindow(an, x, py, x + aw, py + ph)
		animSetPos(an, x + 70, py + ph - 12)
		animUpdate(an)
		animDraw(an)
	end
	-- the description, re-wrapped to the panel's width
	local words, lines, line = {}, {}, ''
	for _, l in ipairs(arts[cur].desc or {}) do
		for w in l:gmatch('%S+') do table.insert(words, w) end
	end
	for _, w in ipairs(words) do
		if #line + #w + 1 > 40 then
			table.insert(lines, line)
			line = w
		else
			line = (line == '') and w or (line .. ' ' .. w)
		end
	end
	if line ~= '' then table.insert(lines, line) end
	for i, l in ipairs(lines) do
		U.text(l, x + aw + 16, py + 12 + i * 25, 18, 1, 225, 230, 242, 255)
	end
	U.btext('ANY ATTACK BUTTON TO CHOOSE', X(px, 0), py + ph + 30, 'FoR_DisplaySmall', 0.9, L and 1 or -1, 230)
end

-- announcer: "Select your fighter" shortly after each character select screen opens
local selFrames = 0
hook.add("start.f_selectReset", "forsa_announce", function()
	selFrames = 0
end)
hook.add("start.f_selectScreen", "forsa_announce", function()
	selFrames = selFrames + 1
	if selFrames == 25 then
		sndPlay(motif.Snd, 200, 0)
	end
end)

-- carry the pick to the fight (player numbers are only known once the selection is confirmed)
hook.add("start.f_selectMenu.selected", "forsa", function(side, member, sel, p)
	start.saPick = start.saPick or {}
	start.saPick[sel.pn] = p.t_selTemp[member].sa
end)

-- test switch: FOR_SA_PREVIEW=1 shows the Super Art select over the main menu, stepping through the arts
if os.getenv('FOR_SA_PREVIEW') == '1' then
	local n = 0
	hook.add("main.menu.frame", "forsa_preview", function()
		n = n + 1
		local ref = main.f_findCharRef and main.f_findCharRef('milo') or 0
		local arts = S.arts(ref or 0)
		if arts ~= nil then
			S.draw(1, arts, math.floor(n / 150) % #arts + 1, ref or 0)
		end
	end)
end

return S
