-- Fist of Retribution: small immediate-mode drawing helpers (boxes, text, input glyphs) shared by the
-- Super Art select and the in-fight super gauge. Each caller draws on its own channel; begin(channel)
-- rewinds that channel's pools once per frame so objects are reused instead of created every frame.

local U = {}
U.LW, U.LH = 1280, 720
U.LAYER = 2

local chans = {}
local cur = nil

function U.begin(name)
	local c = chans[name]
	if c == nil then
		c = {rects = {}, texts = {}, rn = 0, tn = 0}
		chans[name] = c
	end
	c.rn, c.tn = 0, 0
	cur = c
end

function U.box(x, y, w, h, r, g, b, a)
	if w <= 0 or h <= 0 then return end
	cur.rn = cur.rn + 1
	local rc = cur.rects[cur.rn]
	if rc == nil then
		rc = rectNew()
		rectSetLocalcoord(rc, U.LW, U.LH)
		rectSetLayerno(rc, U.LAYER)
		cur.rects[cur.rn] = rc
	end
	rectSetColor(rc, r, g, b)
	rectSetAlpha(rc, a or 255, 255 - (a or 255))
	rectSetWindow(rc, x, y, x + w, y + h)
	rectUpdate(rc)
	rectDraw(rc)
end

local fonts = {}
local function font(h)
	if fonts[h] == nil then
		fonts[h] = fontNew('Open_Sans.def', h)
	end
	return fonts[h]
end

-- align: 1 left, 0 centre, -1 right
function U.text(str, x, y, size, align, r, g, b, a, bold)
	cur.tn = cur.tn + 1
	local ts = cur.texts[cur.tn]
	if ts == nil then
		ts = textImgNew()
		cur.texts[cur.tn] = ts
	end
	textImgReset(ts)
	textImgSetFont(ts, font(size))
	textImgSetLocalcoord(ts, U.LW, U.LH)
	textImgSetLayerno(ts, U.LAYER)
	textImgSetAlign(ts, align or 1)
	textImgSetColor(ts, r or 255, g or 255, b or 255, a or 255)
	textImgSetScale(ts, 1, 1)
	textImgSetPos(ts, x, y)
	textImgSetWindow(ts, 0, 0, U.LW, U.LH)
	textImgSetText(ts, str)
	textImgDraw(ts)
	if bold then
		textImgSetPos(ts, x + 1, y)
		textImgDraw(ts)
	end
end

-- text in one of the game's bitmap fonts (data/forpz/fonts/*.def), scaled; align: 1 left, 0 centre, -1 right
local bfonts = {}
function U.btext(str, x, y, def, scale, align, a)
	if bfonts[def] == nil then
		bfonts[def] = fontNew('data/forpz/fonts/' .. def .. '.def', -1)
	end
	cur.tn = cur.tn + 1
	local ts = cur.texts[cur.tn]
	if ts == nil then
		ts = textImgNew()
		cur.texts[cur.tn] = ts
	end
	textImgReset(ts)
	textImgSetFont(ts, bfonts[def])
	textImgSetLocalcoord(ts, U.LW, U.LH)
	textImgSetLayerno(ts, U.LAYER)
	textImgSetAlign(ts, align or 1)
	textImgSetColor(ts, 255, 255, 255, a or 255)
	textImgSetScale(ts, scale or 1, scale or 1)
	textImgSetPos(ts, x, y)
	textImgSetWindow(ts, 0, 0, U.LW, U.LH)
	textImgSetText(ts, str)
	textImgDraw(ts)
end

-- a slanted bar (parallelogram leaning right by `lean` px over its height), drawn as thin strips
function U.slant(x, y, w, h, lean, r, g, b, a, step)
	step = step or 3
	for yy = 0, h - 1, step do
		local off = math.floor(lean * (h - yy) / h)
		U.box(x + off, y + yy, w, math.min(step, h - yy), r, g, b, a)
	end
end

-- input notation ("_QDF_QDF^P") drawn with the motif's glyphs; returns the width used
local glyphKeys = nil
function U.cmd(cmd, x, y, h, rightAlign)
	if motif == nil or motif.glyphs == nil then return 0 end
	if glyphKeys == nil then
		glyphKeys = {}
		for k, _ in pairs(motif.glyphs) do table.insert(glyphKeys, k) end
		table.sort(glyphKeys, function(a, b) return #a > #b end)
	end
	local toks, i = {}, 1
	while i <= #cmd do
		local hit = nil
		for _, k in ipairs(glyphKeys) do
			if cmd:sub(i, i + #k - 1) == k then hit = k break end
		end
		if hit then table.insert(toks, hit) i = i + #hit else i = i + 1 end
	end
	local w, sizes = 0, {}
	for k, t in ipairs(toks) do
		local g = motif.glyphs[t]
		if g ~= nil and g.Size ~= nil and g.AnimData ~= nil then
			local s = h / g.Size[2]
			sizes[k] = {g.Size[1] * s, s}
			w = w + g.Size[1] * s + 3
		end
	end
	local cx = rightAlign and (x - w) or x
	for k, t in ipairs(toks) do
		if sizes[k] then
			local g = motif.glyphs[t]
			animSetScale(g.AnimData, sizes[k][2], sizes[k][2])
			animSetPos(g.AnimData, math.floor(cx), y + h)
			animSetLayerno(g.AnimData, U.LAYER)
			animSetWindow(g.AnimData, 0, 0, U.LW, U.LH)
			animDraw(g.AnimData)
			cx = cx + sizes[k][1] + 3
		end
	end
	return w
end

-- character data files next to the .def (movelist.lua, supers.lua); cached per path
local dataCache = {}
function U.charData(defPath, file)
	if defPath == nil or defPath == '' then return nil end
	local key = defPath .. '|' .. file
	if dataCache[key] ~= nil then return dataCache[key] or nil end
	local dir = defPath:gsub('[^/\\]+$', '')
	local f = loadfile(dir .. file)
	local res = nil
	if f ~= nil then
		local ok, r = pcall(f)
		if ok and type(r) == 'table' then res = r end
	end
	dataCache[key] = res or false
	return res
end

U.GOLD = {255, 160, 40}      -- Knicks orange
U.BLUE = {40, 110, 255}      -- Knicks blue
U.ROMAN = {'I', 'II', 'III'}

return U
