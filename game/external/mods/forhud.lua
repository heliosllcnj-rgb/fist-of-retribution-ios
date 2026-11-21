-- Fist of Retribution: 3rd Strike style super gauge, drawn every frame of a fight.
--
-- * Hands each player the Super Art picked at select (start.saPick[playerNo]) through the character map "sa".
-- * Draws, at the bottom of the screen, a gauge whose length follows the art's bar length (as in 3rd Strike:
--   SA II's long bar is drawn longer than SA III's short one), the stock count in a box at the outer edge,
--   the art's numeral, and MAX when every stock is full (steady, no flashing). The engine's own power bar is moved off
--   screen in fight.def.

local U = require('external.script.forui')

local BAR_MAX = 340           -- on-screen width of the longest bar (128 units)
local Y = 660                 -- top of the gauge
local H = 18                  -- bar height

local INSTALL = 420           -- SA III Perfect Harmony lasts 420 frames (map "harmony" counts down)

local function drawGauge(side, sa, stocks, maxStocks, frac, len, frame, left, right, install)
	local w = math.floor(BAR_MAX * len / 128)
	local boxW = 52
	local x0, dir
	if side == 1 then x0, dir = left + 40, 1 else x0, dir = right - 40, -1 end
	-- stock box at the outer edge
	local bx = (dir == 1) and x0 or (x0 - boxW)
	local full = stocks >= maxStocks
	U.box(bx - 2, Y - 14, boxW + 4, H + 30, 255, 255, 255, 230)
	U.box(bx, Y - 12, boxW, H + 26, 12, 18, 48, 255)
	local nc = U.GOLD           -- (no flashing: a full gauge is shown by its steady gold bar and MAX)
	U.text(tostring(stocks), bx + boxW / 2, Y + H + 8, 38, 0, nc[1], nc[2], nc[3], 255, true)
	-- the bar, growing inward from the stock box
	local gx = (dir == 1) and (bx + boxW + 6) or (bx - 6 - w)
	U.box(gx - 2, Y - 2, w + 4, H + 4, 255, 255, 255, 230)
	U.box(gx, Y, w, H, 10, 14, 34, 255)
	-- 40-unit EX marks along the bar
	for u = 40, len - 1, 40 do
		local mx = (dir == 1) and (gx + w * u / len) or (gx + w - w * u / len)
		U.box(math.floor(mx), Y, 1, H, 70, 80, 120, 255)
	end
	local fw = full and w or math.floor(w * frac)
	if install > 0 then
		-- Perfect Harmony active: the bar turns pale blue and drains as the install runs out (3rd Strike style)
		local iw = math.floor(w * install / INSTALL)
		local ix = (dir == 1) and gx or (gx + w - iw)
		U.box(ix, Y, iw, H, 140, 212, 255, 255)
		U.box(ix, Y, iw, math.floor(H / 3), 235, 250, 255, 255)
		fw = 0
	end
	if fw > 0 then
		local fx = (dir == 1) and gx or (gx + w - fw)
		if full then
			U.box(fx, Y, fw, H, 255, 160, 30, 255)
			U.box(fx, Y, fw, math.floor(H / 3), 255, 214, 110, 255)
		else
			U.box(fx, Y, fw, H, U.BLUE[1], U.BLUE[2], U.BLUE[3], 255)
			U.box(fx, Y, fw, math.floor(H / 3), 120, 180, 255, 255)
		end
	end
	-- the art's numeral and MAX above the bar
	local lx = (dir == 1) and gx or (gx + w)
	U.text('SA ' .. (U.ROMAN[sa] or 'I'), lx, Y - 8, 18, dir, 255, 255, 255, 255, true)
	if full then
		local mx = (dir == 1) and (gx + w) or gx
		U.text('MAX', mx, Y - 8, 18, -dir, U.GOLD[1], U.GOLD[2], U.GOLD[3], 255, true)
	end
end

local frame = 0
hook.add("loop", "forhud", function()
	frame = frame + 1
	U.begin('hud')
	for pn = 1, 2 do
		if player(pn) then
			-- hand over the Super Art picked at select
			local pick = start ~= nil and start.saPick ~= nil and start.saPick[pn] or nil
			if pick ~= nil and map('sa') ~= pick then
				mapSet('sa', pick)
			end
			local sa = math.floor(map('sa'))
			local pmax = powerMax()
			if sa >= 1 and sa <= 3 and pmax > 0 then
				local len = ({112, 128, 80})[sa]
				local maxStocks = math.floor(pmax / 1000 + 0.5)
				local pw = power()
				local stocks = math.floor(pw / 1000)
				local frac = (pw - stocks * 1000) / 1000
				-- the visible fight area: 4:3 stages are pillarboxed inside the 16:9 window
				local aspect = gameHeight() > 0 and gameWidth() / gameHeight() or 16 / 9
				local visW = math.min(U.LW, U.LH * aspect)
				local left = (U.LW - visW) / 2
				local inst = map('harmony') or 0
				drawGauge(teamSide(), sa, stocks, maxStocks, frac, len, frame, left, U.LW - left, inst)
			end
		end
	end
end)
