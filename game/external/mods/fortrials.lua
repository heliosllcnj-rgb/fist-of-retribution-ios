-- Fist of Retribution: Combo Trials.
--
-- A training match where the left side works through a list of combos (external/script/fortrials_data.lua,
-- written by forproto/mktrials.py). Each trial is a list of steps; a step is done when the fighter lands a hit
-- from the right move while the combo counter is still running. Dropping the combo starts the trial again.
-- Finishing a trial moves on to the next one.
--
-- Controls: the two extra buttons: W goes to the next trial (after the last comes the first), D starts or stops the
-- demonstration, where the game plays the combo itself with real lever and button presses.
--
-- The characters do the resetting and take the demonstration's inputs through maps (see trial_bridge in
-- forproto/cnsgen.py). Started from the main menu (COMBO TRIALS) or, for recording, with FOR_TRIALS=1
-- (FOR_TRIALS_DEMO=1 plays every trial by itself).

local U = require('external.script.forui')
local okData, DATA = pcall(require, os.getenv('FOR_TRIALS_DATA') or 'external.script.fortrials_data')
if not okData then DATA = {} end

local ENV = os.getenv('FOR_TRIALS') == '1'
local ENV_DEMO = os.getenv('FOR_TRIALS_DEMO') == '1'

local T = {
	idx = 1, progress = 0, hitStarted = false, lastCombo = 0, lastState = -1, lastTime = 0,
	banner = 0, failed = 0, settle = 0, done = {}, allDone = false, char = nil,
	demo = ENV_DEMO, act = 1, actFrame = 0, actWait = -1, entries = 0, actEntries = -1, contactSeen = false,
}

hook.add("main.t_itemname", "fortrials", function(t, item)
	main.forTrials = false
end)

local function active()
	return ENV or (main ~= nil and main.forTrials == true)
end

local function inList(v, l)
	for _, x in ipairs(l) do
		if x == v then return true end
	end
	return false
end

local function reset(tr)
	for pn = 1, 2 do
		if player(pn) then
			mapSet('trx', pn == 1 and -(tr.dist / 2) or (tr.dist / 2))
			mapSet('trs', 1)
			mapSet('tin', 0)
			if pn == 1 then
				mapSet('sa', tr.sa)
				if start ~= nil and start.saPick ~= nil then start.saPick[1] = tr.sa end
			end
		end
	end
	T.progress, T.hitStarted, T.lastCombo = 0, false, 0
	T.settle = 50
	T.act, T.actFrame, T.actWait, T.actEntries, T.contactSeen = 1, 0, -1, -1, false
end

local function goto_(i, n)
	if i < 1 then i = n end
	if i > n then i = 1 end
	T.idx = i
	T.banner, T.failed = 0, 0
	T.needReset = true
end

-- the demonstration: real inputs, one action at a time
local function demoStep(tr)
	local a = tr.demo[T.act]
	if a == nil then return 0 end
	if T.actWait < 0 then
		-- waiting for this action's moment
		if T.act > 1 and T.entries <= T.actEntries then return 0 end
		local ok = false
		if a.when == 'free' then
			ok = ctrl() and stateType() ~= 'A' and moveType() ~= 'H'
		elseif a.when == 'contact' then
			ok = moveContact() > 0 and (a.st == nil or inList(stateNo(), a.st))
		elseif a.when == 'air' then
			ok = stateType() == 'A' and stateNo() == 50
		elseif a.when == 'fall' then
			ok = stateType() == 'A' and velY() > 0 and posY() > -(a.h or 50)
		end
		if not ok then return 0 end
		T.actWait = a.wait or 0
		T.actFrame = 0
		T.actEntries = T.entries
	end
	if T.actWait > 0 then
		T.actWait = T.actWait - 1
		return 0
	end
	T.actFrame = T.actFrame + 1
	local k = a.keys[T.actFrame] or 0
	if T.actFrame >= #a.keys then
		T.act = T.act + 1
		T.actWait = -1
	end
	return k
end

local function draw(ch, tr, n, left)
	local x, y, w = left + 30, 104, 440
	local RH = 62
	local rows = #tr.steps
	local h = 70 + rows * RH + (tr.note ~= '' and 34 or 0)
	U.box(x - 2, y - 2, w + 4, h + 4, 255, 255, 255, 60)
	U.box(x, y, w, h, 8, 12, 30, 220)
	U.box(x, y, w, 4, U.GOLD[1], U.GOLD[2], U.GOLD[3], 255)
	U.text('COMBO TRIAL ' .. T.idx .. ' / ' .. n, x + 14, y + 28, 19, 1, U.GOLD[1], U.GOLD[2], U.GOLD[3], 255, true)
	if T.done[T.idx] then
		U.text('CLEARED', x + w - 14, y + 28, 17, -1, 120, 230, 140, 255, true)
	end
	U.text(string.upper(tr.name), x + 14, y + 56, 23, 1, 255, 255, 255, 255, true)
	for i, s in ipairs(tr.steps) do
		local ry = y + 68 + (i - 1) * RH
		local doneStep = i <= T.progress
		local cur = (i == T.progress + 1) and T.banner == 0
		if doneStep then
			U.box(x + 8, ry, w - 16, RH - 4, U.GOLD[1], U.GOLD[2], U.GOLD[3], 240)
		elseif cur then
			U.box(x + 8, ry, w - 16, RH - 4, 40, 60, 140, 255)
			U.box(x + 8, ry, 5, RH - 4, U.GOLD[1], U.GOLD[2], U.GOLD[3], 255)
		else
			U.box(x + 8, ry, w - 16, RH - 4, 20, 26, 54, 240)
		end
		local c = doneStep and 16 or (cur and 255 or 175)
		U.text(tostring(i), x + 32, ry + 38, 26, 0, c, c, doneStep and 24 or c, 255, true)
		U.text(s.text, x + 58, ry + 23, 20, 1, c, c, doneStep and 24 or c, 255, doneStep or cur)
		U.cmd(s.cmd, x + 58, ry + 28, 27)
	end
	if tr.note ~= '' then
		U.text(tr.note, x + 14, y + h - 12, 15, 1, 200, 208, 232, 255)
	end
	U.text(T.demo and 'DEMONSTRATION        D: stop' or 'W: next trial        D: watch the demonstration', x + 2, y + h + 24, 16, 1, 225, 230, 245, 255, true)
	if T.banner > 0 then
		local flash = (math.floor(T.banner / 4) % 2 == 0)
		local msg = T.allDone and 'ALL TRIALS COMPLETE!' or 'TRIAL COMPLETE!'
		local bx = x + w + 24
		local bw = U.LW - left - bx
		U.box(bx, 150, bw, 76, 6, 8, 20, 200)
		U.box(bx, 150, bw, 3, U.GOLD[1], U.GOLD[2], U.GOLD[3], 255)
		U.box(bx, 223, bw, 3, U.GOLD[1], U.GOLD[2], U.GOLD[3], 255)
		U.text(msg, bx + bw / 2, 204, 44, 0, 255, flash and 255 or 200, flash and 255 or 90, 255, true)
	elseif T.failed > 0 then
		U.text('COMBO DROPPED', x + w / 2, y + h + 58, 24, 0, 255, 110, 110, 255, true)
	end
end

hook.add("loop", "fortrials", function()
	if not active() then return end
	if not player(1) then return end
	local ch = DATA[name()]
	if ch == nil or #ch.trials == 0 then return end
	if T.char ~= name() then
		T.char = name()
		T.idx, T.done, T.allDone, T.banner = tonumber(os.getenv('FOR_TRIALS_START') or '1'), {}, false, 0
		T.needReset = true
	end
	local n = #ch.trials
	local tr = ch.trials[T.idx]

	-- both fighters know a trial is running; the dummy stands still
	for pn = 1, 2 do
		if player(pn) then
			mapSet('trial', 1)
			if pn == 2 and ENV then setAILevel(0) end
		end
	end
	player(1)
	if roundState() ~= 2 then
		U.begin('trials')
		return
	end

	-- change trial
	if not ENV_DEMO then
		if getInput(1, 'w') then
			goto_(T.idx + 1, n)
		elseif getInput(1, 'd') then
			T.demo = not T.demo
			T.needReset = true
		end
		tr = ch.trials[T.idx]
	end
	if T.needReset then
		T.needReset = false
		reset(tr)
		player(1)
	end

	-- state entries (a move starting, or starting again)
	local st, tm = stateNo(), time()
	if st ~= T.lastState or tm < T.lastTime then
		T.entries = T.entries + 1
		T.entered = true
	end
	T.lastState, T.lastTime = st, tm

	local combo = comboCount()
	if T.settle > 0 then
		T.settle = T.settle - 1
		if T.settle == 48 then
			setPower(tr.power)
		end
		mapSet('tin', 0)
	elseif T.banner > 0 then
		-- let the combo play out before counting down to the next trial
		if not (T.banner == T.bannerMax and (combo > 0 or moveType() == 'A' or not ctrl()) and T.bannerHold < 420) then
			T.banner = T.banner - 1
		else
			T.bannerHold = T.bannerHold + 1
		end
		mapSet('tin', 0)
		if T.banner == 0 then
			if T.allDone and ENV_DEMO then
				print('TRIALS ALLDONE ' .. ch.title) io.stdout:flush()
			end
			if T.allDone then T.done, T.allDone = {}, false end
			if not (T.demo and not ENV_DEMO) then goto_(T.idx + 1, n) else T.demo = false T.needReset = true end
		end
	else
		-- progress
		local s = tr.steps[T.progress + 1]
		if s ~= nil and inList(st, s.st) then
			if s.nohit then
				T.progress = T.progress + 1
			elseif combo > T.lastCombo and (T.progress == 0 or T.hitStarted or combo >= 1) then
				if not T.hitStarted or combo > 1 or T.progress == 0 then
					T.progress = T.progress + 1
					T.hitStarted = true
				end
			end
		end
		-- the combo counter fell back to zero: dropped
		if T.hitStarted and combo == 0 and T.progress < #tr.steps then
			T.failed = 70
			if ENV_DEMO then print('TRIALS DROPPED ' .. ch.title .. ' ' .. T.idx .. ' at step ' .. (T.progress + 1) .. ' act=' .. T.act .. ' st=' .. st) io.stdout:flush() end
			T.progress, T.hitStarted = 0, false
			if T.demo then T.needReset = true end
			if os.getenv('FOR_TRIALS_SKIP') then goto_(T.idx + 1, n) end
		end
		if T.progress >= #tr.steps then
			T.done[T.idx] = true
			local all = true
			for i = 1, n do if not T.done[i] then all = false end end
			T.allDone = all
			T.banner = all and 170 or 70
			T.bannerMax, T.bannerHold = T.banner, 0
			sndPlay(motif.Snd, 200, all and 4 or 3)   -- announcer: "Trial complete" / "All trials complete"
			if ENV_DEMO then print('TRIALS COMPLETE ' .. ch.title .. ' ' .. T.idx .. ' combo=' .. combo) io.stdout:flush() end
		end
		if T.demo then
			mapSet('tin', demoStep(tr))
			-- the demonstration is getting nowhere (a whiff, say): start the trial again
			if T.progress < #tr.steps and ctrl() and combo == 0 and moveType() == 'I' and stateType() ~= 'A' then
				T.stall = (T.stall or 0) + 1
				if T.stall > 100 then
					T.stall = 0
					if ENV_DEMO then print('TRIALS STALLED ' .. ch.title .. ' ' .. T.idx .. ' progress=' .. T.progress .. ' act=' .. T.act) io.stdout:flush() end
					T.needReset = true
					if os.getenv('FOR_TRIALS_SKIP') then goto_(T.idx + 1, n) end
				end
			else
				T.stall = 0
			end
		end
	end
	if T.failed > 0 then T.failed = T.failed - 1 end
	T.lastCombo = combo

	local aspect = gameHeight() > 0 and gameWidth() / gameHeight() or 16 / 9
	local visW = math.min(U.LW, U.LH * aspect)
	U.begin('trials')
	draw(ch, tr, n, (U.LW - visW) / 2)
end)

return T
