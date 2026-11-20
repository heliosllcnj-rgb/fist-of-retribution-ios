-- Fist of Retribution: one-on-one only, as in 3rd Strike. Wherever a mode offers team types (Simul, Tag, Turns),
-- only Single is left, so the Team Mode screen is skipped. A side with no team menu is left alone.
-- Runs after each mode has set its team options (hook "main.t_itemname").
hook.add("main.t_itemname", "forsingle", function(t, item)
	if main == nil or main.teamMenu == nil or os.getenv("FOR_TEAMS") == "1" then return end
	for side = 1, 2 do
		local tm = main.teamMenu[side]
		if tm ~= nil then
			local any = false
			for _, k in ipairs({'single', 'simul', 'tag', 'turns', 'ratio'}) do
				if tm[k] then any = true end
				if k ~= 'single' then tm[k] = false end
			end
			if any then tm.single = true end
		end
	end
end)
