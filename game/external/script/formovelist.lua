-- Fist of Retribution: command list with tabs, a looping preview of the highlighted move, its description and
-- its frame data (in the style of current fighting games). Data comes from chars/<name>/movelist.lua, written
-- by forproto/mkmovelist.py. Characters without that file fall back to the engine's plain text list.

local M = {}
local LW, LH = 1280, 720
local LAYER = 2

-- ---------------------------------------------------------------- drawing helpers
local rects = {}
local rectN = 0
local function box(x, y, w, h, r, g, b, a)
	rectN = rectN + 1
	local rc = rects[rectN]
	if rc == nil then
		rc = rectNew()
		rectSetLocalcoord(rc, LW, LH)
		rectSetLayerno(rc, LAYER)
		rects[rectN] = rc
	end
	rectSetColor(rc, r, g, b)
	rectSetAlpha(rc, a or 255, 255 - (a or 255))
	rectSetWindow(rc, x, y, x + w, y + h)
	rectUpdate(rc)
	rectDraw(rc)
end

local fonts = {}
local function font(name, h)
	local k = name .. ':' .. tostring(h)
	if fonts[k] == nil then
		fonts[k] = fontNew(name, h)
	end
	return fonts[k]
end

local texts = {}
local textN = 0
-- align: 1 left, 0 centre, -1 right
local function text(str, x, y, size, align, r, g, b, a, bold)
	textN = textN + 1
	local ts = texts[textN]
	if ts == nil then
		ts = textImgNew()
		texts[textN] = ts
	end
	textImgReset(ts)
	textImgSetFont(ts, font('Open_Sans.def', size))
	textImgSetLocalcoord(ts, LW, LH)
	textImgSetLayerno(ts, LAYER)
	textImgSetAlign(ts, align or 1)
	textImgSetColor(ts, r or 255, g or 255, b or 255, a or 255)
	textImgSetScale(ts, 1, 1)
	textImgSetPos(ts, x, y)
	textImgSetWindow(ts, 0, 0, LW, LH)
	textImgSetText(ts, str)
	textImgDraw(ts)
	if bold then
		textImgSetPos(ts, x + 1, y)
		textImgDraw(ts)
	end
end

-- "^LP_+^LK" -> list of glyph tokens / plain text, using the motif's glyph table (longest token first)
local glyphKeys = nil
local function tokens(cmd)
	if glyphKeys == nil then
		glyphKeys = {}
		for k, _ in pairs(motif.glyphs) do
			table.insert(glyphKeys, k)
		end
		table.sort(glyphKeys, function(a, b) return #a > #b end)
	end
	local out = {}
	local i = 1
	while i <= #cmd do
		local hit = nil
		for _, k in ipairs(glyphKeys) do
			if cmd:sub(i, i + #k - 1) == k then
				hit = k
				break
			end
		end
		if hit then
			table.insert(out, {glyph = hit})
			i = i + #hit
		else
			local j = i
			while j <= #cmd and cmd:sub(j, j) ~= '_' and cmd:sub(j, j) ~= '^' do
				j = j + 1
			end
			if j == i then j = i + 1 end
			table.insert(out, {text = cmd:sub(i, j - 1)})
			i = j
		end
	end
	return out
end

-- draws the input for a move; anchor = right edge when rightAlign
local function drawCmd(toks, x, y, h, rightAlign)
	local w = 0
	local sizes = {}
	for k, t in ipairs(toks) do
		if t.glyph then
			local g = motif.glyphs[t.glyph]
			if g ~= nil and g.Size ~= nil and g.AnimData ~= nil then
				local s = h / g.Size[2]
				sizes[k] = {g.Size[1] * s, s}
				w = w + g.Size[1] * s + 3
			end
		end
	end
	local cx = rightAlign and (x - w) or x
	for k, t in ipairs(toks) do
		if t.glyph and sizes[k] then
			local g = motif.glyphs[t.glyph]
			animSetScale(g.AnimData, sizes[k][2], sizes[k][2])
			animSetPos(g.AnimData, math.floor(cx), y + h)
			animSetLayerno(g.AnimData, LAYER)
			animSetWindow(g.AnimData, 0, 0, LW, LH)
			animDraw(g.AnimData)
			cx = cx + sizes[k][1] + 3
		end
	end
	return w
end

-- ---------------------------------------------------------------- data
local cache = {}
local function load(defPath)
	if defPath == nil or defPath == '' then return nil end
	if cache[defPath] ~= nil then
		return cache[defPath] or nil
	end
	local dir = defPath:gsub('[^/\\]+$', '')
	local f = loadfile(dir .. 'movelist.lua')
	local data = nil
	if f ~= nil then
		local ok, res = pcall(f)
		if ok and type(res) == 'table' then
			data = res
			data.dir = dir
			for _, tab in ipairs(data.tabs) do
				for _, mv in ipairs(tab.moves) do
					mv.toks = tokens(mv.cmd or '')
				end
			end
			data.tab = 1
			data.sel = {}
			data.top = {}
		end
	end
	cache[defPath] = data or false
	return data
end

local function charDef(t)
	if t.tbl ~= nil and t.tbl.ref ~= nil then
		local ok, p = pcall(getCharFileName, t.tbl.ref)
		if ok then return p end
	end
	return nil
end

-- ---------------------------------------------------------------- layout
local LIST_X, LIST_Y, LIST_W, ROW_H, ROWS = 56, 150, 620, 46, 10
local PV_X, PV_Y, PV_W, PV_H = 716, 150, 508, 236
local GOLD = {255, 196, 40}

local KIND_COL = {
	Mid = {120, 190, 255}, Low = {120, 230, 150}, Overhead = {255, 150, 110}, Throw = {255, 120, 200},
	Super = {255, 160, 40}, Counter = {255, 214, 90}, Defence = {170, 200, 255}, Movement = {200, 200, 200},
}

local function num(v)
	if v == nil then return '-' end
	return tostring(v)
end

-- LEFT / RIGHT: next tab; past the first or last tab, the other player's list (two players, or the training dummy)
local function tabStep(data, sec, d)
	sndPlay(motif.Snd, sec.cursor.move.snd[1], sec.cursor.move.snd[2])
	local nt = data.tab + d
	if (nt < 1 or nt > #data.tabs) and menu.t_movelists ~= nil and #menu.t_movelists > 1 then
		menu.movelistChar = (menu.movelistChar - 1 + d) % #menu.t_movelists + 1
		local od = load(charDef(menu.t_movelists[menu.movelistChar]))
		if od ~= nil then
			od.tab = (d > 0) and 1 or #od.tabs
			od.anim = nil
		end
		data.anim = nil
		return
	end
	data.tab = (data.tab - 1 + d) % #data.tabs + 1
	data.anim = nil
end

function M.render(sec, t)
	local data = load(charDef(t))
	if data == nil then
		return false
	end
	rectN, textN = 0, 0
	local tab = data.tabs[data.tab]
	local n = #tab.moves
	local cur = data.sel[data.tab] or 1
	local top = data.top[data.tab] or 1

	-- input
	if esc() or getInput(-1, sec.menu.cancel.key) then
		sndPlay(motif.Snd, sec.cancel.snd[1], sec.cancel.snd[2])
		menu.itemname = ''
		return true
	elseif getInput(-1, sec.menu.subtract.key) then
		-- (each key is read once: a second getInput for the same press in one frame comes back false, which used to
		-- make RIGHT step backwards as well)
		tabStep(data, sec, -1)
		return true
	elseif getInput(-1, sec.menu.add.key) then
		tabStep(data, sec, 1)
		return true
	elseif getInput(-1, sec.menu.previous.key) then
		sndPlay(motif.Snd, sec.cursor.move.snd[1], sec.cursor.move.snd[2])
		cur = cur - 1
		if cur < 1 then cur = n end
		data.anim = nil
	elseif getInput(-1, sec.menu.next.key) then
		sndPlay(motif.Snd, sec.cursor.move.snd[1], sec.cursor.move.snd[2])
		cur = cur + 1
		if cur > n then cur = 1 end
		data.anim = nil
	end
	if cur < top then top = cur end
	if cur > top + ROWS - 1 then top = cur - ROWS + 1 end
	data.sel[data.tab], data.top[data.tab] = cur, top
	local mv = tab.moves[cur]

	-- backdrop
	box(0, 0, LW, LH, 6, 8, 20, 225)
	box(0, 0, LW, 84, 10, 14, 34, 255)
	box(0, 84, LW, 3, GOLD[1], GOLD[2], GOLD[3], 255)
	text('COMMAND LIST', 56, 56, 40, 1, 255, 255, 255, 255, true)
	local who = data.char or t.name or ''
	if menu.t_movelists ~= nil and #menu.t_movelists > 1 and t.pn ~= nil then
		who = t.pn .. 'P  ' .. who
	end
	text(who, LW - 56, 56, 40, -1, GOLD[1], GOLD[2], GOLD[3], 255, true)

	-- tabs
	local tw = (LW - 112) / #data.tabs
	for i, tb in ipairs(data.tabs) do
		local x = 56 + (i - 1) * tw
		if i == data.tab then
			box(x, 98, tw - 6, 38, GOLD[1], GOLD[2], GOLD[3], 255)
			text(tb.name, x + (tw - 6) / 2, 125, 22, 0, 16, 16, 24, 255, true)
		else
			box(x, 98, tw - 6, 38, 30, 36, 64, 255)
			text(tb.name, x + (tw - 6) / 2, 125, 22, 0, 170, 176, 200, 255)
		end
	end

	-- move rows
	for i = 0, ROWS - 1 do
		local k = top + i
		local m = tab.moves[k]
		if m == nil then break end
		local y = LIST_Y + i * ROW_H
		if k == cur then
			box(LIST_X, y, LIST_W, ROW_H - 4, 52, 70, 150, 255)
			box(LIST_X, y, 6, ROW_H - 4, GOLD[1], GOLD[2], GOLD[3], 255)
			text(m.name, LIST_X + 20, y + 30, 25, 1, 255, 255, 255, 255, true)
		else
			box(LIST_X, y, LIST_W, ROW_H - 4, 22, 27, 52, 235)
			text(m.name, LIST_X + 20, y + 30, 25, 1, 205, 210, 228, 255)
		end
		drawCmd(m.toks, LIST_X + LIST_W - 14, y + 7, 28, true)
	end
	-- scroll bar
	if n > ROWS then
		local trackH = ROWS * ROW_H - 4
		box(LIST_X + LIST_W + 6, LIST_Y, 4, trackH, 30, 36, 64, 255)
		box(LIST_X + LIST_W + 6, LIST_Y + trackH * (top - 1) / n, 4, trackH * ROWS / n, GOLD[1], GOLD[2], GOLD[3], 255)
	end

	-- preview window
	box(PV_X - 3, PV_Y - 3, PV_W + 6, PV_H + 6, 70, 84, 150, 255)
	box(PV_X, PV_Y, PV_W, PV_H, 14, 18, 40, 255)
	box(PV_X, PV_Y, PV_W, PV_H * 0.62, 22, 30, 66, 255)
	for gx = 1, 9 do
		box(PV_X + gx * PV_W / 10, PV_Y, 1, PV_H, 40, 52, 104, 255)
	end
	for gy = 1, 4 do
		box(PV_X, PV_Y + gy * PV_H / 5, PV_W, 1, 40, 52, 104, 255)
	end
	local floorY = PV_Y + PV_H - 34
	box(PV_X, floorY, PV_W, 2, 90, 110, 190, 255)
	box(PV_X, floorY + 2, PV_W, PV_H - (floorY - PV_Y) - 2, 10, 13, 30, 255)
	if data.sff == nil or type(data.sff) == 'string' then
		data.sffData = sffNew(data.dir .. data.sff)
		data.sff = true
	end
	if data.anim == nil and mv.anim ~= nil then
		data.anim = animNew(data.sffData, mv.anim)
		animSetLocalcoord(data.anim, LW, LH)
		animSetLayerno(data.anim, LAYER)
		animSetScale(data.anim, mv.scale or 0.5, mv.scale or 0.5)
		animSetWindow(data.anim, PV_X, PV_Y, PV_X + PV_W, PV_Y + PV_H)
	end
	if data.anim ~= nil then
		animSetPos(data.anim, PV_X + PV_W * 0.3, floorY)
		animUpdate(data.anim)
		animDraw(data.anim)
	end

	-- name, kind, input
	local iy = PV_Y + PV_H + 10
	box(PV_X - 3, iy, PV_W + 6, 40, 30, 36, 64, 255)
	text(mv.name, PV_X + 12, iy + 29, 25, 1, 255, 255, 255, 255, true)
	if mv.kind ~= nil then
		local c = KIND_COL[mv.kind] or {200, 200, 200}
		text(string.upper(mv.kind), PV_X + PV_W - 10, iy + 28, 20, -1, c[1], c[2], c[3], 255, true)
	end
	-- description
	local dy = iy + 64
	for i, line in ipairs(mv.desc or {}) do
		text(line, PV_X + 4, dy + (i - 1) * 22, 18, 1, 215, 220, 235, 255)
	end
	if mv.note ~= nil then
		text(mv.note, PV_X + 4, dy + #(mv.desc or {}) * 22, 18, 1, GOLD[1], GOLD[2], GOLD[3], 255)
	end

	-- frame data
	local fy = 544
	local cols = mv.cols or {}
	box(PV_X - 3, fy, PV_W + 6, 26, GOLD[1], GOLD[2], GOLD[3], 255)
	text('FRAME DATA', PV_X + 8, fy + 20, 19, 1, 16, 16, 24, 255, true)
	local labels = {'START-UP', 'ACTIVE', 'RECOVERY', 'DAMAGE'}
	local hasLabel = #cols > 1
	local x0 = PV_X + (hasLabel and 84 or 0)
	local cw = (PV_W - (hasLabel and 84 or 0)) / 4
	for i, lb in ipairs(labels) do
		text(lb, x0 + (i - 0.5) * cw, fy + 46, 16, 0, 150, 160, 196, 255)
	end
	for r, c in ipairs(cols) do
		local y = fy + 50 + (r - 1) * 22
		if r % 2 == 1 then
			box(PV_X - 3, y, PV_W + 6, 22, 22, 27, 52, 235)
		end
		if hasLabel then
			text(c.label or '', PV_X + 8, y + 18, 18, 1, GOLD[1], GOLD[2], GOLD[3], 255, true)
		end
		local dmg = num(c.damage)
		if c.damage ~= nil and (c.hits or 1) > 1 then
			dmg = dmg .. '  (' .. c.hits .. ' hits)'
		end
		local vals = {num(c.startup), num(c.active), num(c.recovery), dmg}
		for i, v in ipairs(vals) do
			text(v, x0 + (i - 0.5) * cw, y + 18, 18, 0, 240, 242, 250, 255)
		end
	end

	-- footer
	box(0, LH - 30, LW, 30, 10, 14, 34, 255)
	text('UP / DOWN  Select move        LEFT / RIGHT  Change tab        BACK  Return', 56, LH - 9, 17, 1, 170, 176, 200, 255)
	text(cur .. ' / ' .. n, LIST_X + LIST_W, LIST_Y + ROWS * ROW_H + 18, 17, -1, 150, 160, 196, 255)
	return true
end

-- ================================================================ pause / training menu
-- Two panes, in the style of current fighting games: the root menu down the left, and on the right either the
-- highlighted entry's sub-menu (settings with their current values) or a short explanation of it.
local HELP = {
	back = {'Return to the fight.'},
	menutraining = {'Set how the training', 'dummy stands, blocks,', 'recovers and fights back.'},
	menuinput = {'Change the keyboard or controller buttons.'},
	commandlist = {'Every move with its input, a preview,', 'a description and frame data.'},
	characterchange = {'Go back to the character select screen.'},
	exit = {'Leave the match and return to the main menu.'},
	reset = {'Restart the round from the starting positions.'},
	reload = {'Start the match again.'},
	dummycontrol = {'Who controls the dummy.', 'Cooperative: it takes hits.', 'AI: the CPU fights back.', 'Manual: a second player.'},
	ailevel = {'CPU strength when Dummy', 'Control is set to AI.', '1 is easiest, 8 hardest: the', 'same levels as arcade mode.'},
	dummymode = {'What the dummy does while', 'idle: stand, crouch, jump', 'or keep jumping.'},
	distance = {'The spacing the dummy', 'tries to keep from you.'},
	guardmode = {'How the dummy blocks.', 'None: never.', 'Auto: after the first hit.', 'All: everything it can.', 'Random: half the time.'},
	fallrecovery = {'After a knockdown the', 'dummy stays down, recovers', 'on the ground, recovers in', 'the air, or picks at random.'},
	buttonjam = {'The dummy keeps pressing', 'this button, so you can', 'practise against a', 'repeated attack.'},
	keyboard = {'Assign keyboard keys.'},
	gamepad = {'Assign controller buttons.'},
	inputdefault = {'Restore the default buttons.'},
}
local GROUP = {dummycontrol = 'DUMMY', dummymode = 'STANCE', guardmode = 'BLOCK', fallrecovery = 'GET-UP', distance = 'SPACING', buttonjam = 'REVERSAL'}

local function label(it)
	local s = it.displayname or it.itemname or ''
	if s == '-' then return '' end
	return s
end

function M.drawMenu(tbl, sec)
	local id = menu.currentMenuId or 'menu'
	local root = menu[id] or tbl
	if root == nil or root.items == nil then
		return false
	end
	rectN, textN = 0, 0
	local training = (id == 'training')
	local inSub = (tbl ~= root)

	box(0, 0, LW, LH, 6, 8, 20, 150)
	-- left pane
	local SX, SY, SW = 56, 70, 340
	box(SX, SY, SW, LH - 140, 10, 14, 34, 240)
	box(SX, SY, SW, 4, GOLD[1], GOLD[2], GOLD[3], 255)
	text(training and 'TRAINING' or 'PAUSED', SX + SW / 2, SY + 62, 38, 0, 255, 255, 255, 255, true)
	box(SX + 40, SY + 82, SW - 80, 2, 70, 84, 150, 255)
	for i, it in ipairs(root.items) do
		local y = SY + 104 + (i - 1) * 50
		local on = (i == root.item)
		if on then
			box(SX + 14, y, SW - 28, 42, inSub and 40 or GOLD[1], inSub and 50 or GOLD[2], inSub and 100 or GOLD[3], 255)
			if inSub then
				box(SX + 14, y, 6, 42, GOLD[1], GOLD[2], GOLD[3], 255)
				text(string.upper(label(it)), SX + SW / 2, y + 30, 23, 0, 255, 255, 255, 255, true)
			else
				text(string.upper(label(it)), SX + SW / 2, y + 30, 23, 0, 16, 16, 24, 255, true)
			end
		else
			text(string.upper(label(it)), SX + SW / 2, y + 30, 23, 0, 190, 196, 216, 255)
		end
	end

	-- right pane
	local RX, RY, RW, RH = 420, 70, 804, LH - 140
	box(RX, RY, RW, RH, 10, 14, 34, 240)
	box(RX, RY, RW, 4, GOLD[1], GOLD[2], GOLD[3], 255)
	local rootIt = root.items[root.item]
	local sub = nil
	if inSub then
		sub = tbl
	elseif rootIt ~= nil and root.submenu ~= nil and root.submenu[rootIt.itemname] ~= nil and root.submenu[rootIt.itemname].items ~= nil then
		sub = root.submenu[rootIt.itemname]
	end
	local helpKey = rootIt and rootIt.itemname or ''
	local LISTW = 470
	if sub ~= nil and sub.items ~= nil then
		text(string.upper(inSub and (tbl.title or '') or label(rootIt)), RX + 24, RY + 44, 26, 1, GOLD[1], GOLD[2], GOLD[3], 255, true)
		local y = RY + 62
		local lastGroup = nil
		for i, it in ipairs(sub.items) do
			local g = GROUP[it.itemname]
			if g ~= nil and g ~= lastGroup then
				box(RX + 16, y, LISTW, 24, 30, 36, 64, 255)
				text(g, RX + 26, y + 19, 17, 1, 150, 160, 196, 255, true)
				y = y + 28
				lastGroup = g
			end
			local on = inSub and (i == tbl.item)
			if on then
				box(RX + 16, y, LISTW, 36, 52, 70, 150, 255)
				box(RX + 16, y, 6, 36, GOLD[1], GOLD[2], GOLD[3], 255)
				helpKey = it.itemname
			end
			local c = on and 255 or (inSub and 205 or 140)
			text(label(it), RX + 36, y + 26, 21, 1, c, c, on and 255 or c + 10, 255, on)
			local v = it.vardisplay
			if v ~= nil and v ~= '' then
				if on then
					text('<', RX + LISTW - 172, y + 26, 21, 0, GOLD[1], GOLD[2], GOLD[3], 255, true)
					text('>', RX + LISTW - 6, y + 26, 21, 0, GOLD[1], GOLD[2], GOLD[3], 255, true)
				end
				text(string.upper(tostring(v)), RX + LISTW - 89, y + 26, 20, 0, on and 255 or c, on and 255 or c, on and 255 or c, 255, on)
			end
			y = y + 40
		end
	else
		text(string.upper(label(rootIt or {})), RX + 24, RY + 44, 26, 1, GOLD[1], GOLD[2], GOLD[3], 255, true)
	end
	-- explanation
	local hx = (sub ~= nil) and (RX + LISTW + 40) or (RX + 24)
	local hy = (sub ~= nil) and (RY + 62) or (RY + 70)
	local hw = RX + RW - hx - 16
	if sub ~= nil then
		box(hx - 12, hy, hw + 12, RH - 78, 22, 27, 52, 235)
		hy = hy + 8
	end
	for i, line in ipairs(HELP[helpKey] or {}) do
		text(line, hx, hy + i * 23, sub ~= nil and 17 or 21, 1, 215, 220, 235, 255)
	end

	-- footer
	box(0, LH - 30, LW, 30, 10, 14, 34, 255)
	text('UP / DOWN  Select        LEFT / RIGHT  Change setting        CONFIRM  Open        BACK  Return', 56, LH - 9, 17, 1, 170, 176, 200, 255)
	return true
end

return M
