; Michael "Milo" Foster - command file
; Buttons: x = LP, y = MP, z = HP, a = LK, b = MK, c = HK

[Remap]
x = x
y = y
z = z
a = a
b = b
c = c
s = s

[Defaults]
command.time = 15
command.buffer.time = 1

[Command]
name = "QCF_PP"
command = ~D, DF, F, x+y

[Command]
name = "QCF_PP"
command = ~D, DF, F, x+z

[Command]
name = "QCF_PP"
command = ~D, DF, F, y+z

[Command]
name = "QCF_x"
command = ~D, DF, F, x

[Command]
name = "QCF_y"
command = ~D, DF, F, y

[Command]
name = "QCF_z"
command = ~D, DF, F, z

[Command]
name = "HCF_PP"
command = ~B, DB, D, DF, F, x+y
time = 24

[Command]
name = "HCF_PP"
command = ~B, DB, D, DF, F, x+z
time = 24

[Command]
name = "HCF_PP"
command = ~B, DB, D, DF, F, y+z
time = 24

[Command]
name = "HCF_x"
command = ~B, DB, D, DF, F, x
time = 24

[Command]
name = "HCF_y"
command = ~B, DB, D, DF, F, y
time = 24

[Command]
name = "HCF_z"
command = ~B, DB, D, DF, F, z
time = 24

[Command]
name = "RETRIBUTION"
command = ~D, DB, B, DB, D, DF, F, x+y
time = 40

[Command]
name = "RETRIBUTION"
command = ~D, DB, B, DB, D, DF, F, x+z
time = 40

[Command]
name = "RETRIBUTION"
command = ~D, DB, B, DB, D, DF, F, y+z
time = 40

[Command]
name = "SA_QCF2_P"
command = ~D, DF, F, D, DF, F, x
time = 30

[Command]
name = "SA_QCF2_P"
command = ~D, DF, F, D, DF, F, y
time = 30

[Command]
name = "SA_QCF2_P"
command = ~D, DF, F, D, DF, F, z
time = 30

[Command]
name = "SA_QCF2_K"
command = ~D, DF, F, D, DF, F, a
time = 30

[Command]
name = "SA_QCF2_K"
command = ~D, DF, F, D, DF, F, b
time = 30

[Command]
name = "SA_QCF2_K"
command = ~D, DF, F, D, DF, F, c
time = 30

[Command]
name = "SA_QCB2_P"
command = ~D, DB, B, D, DB, B, x
time = 30

[Command]
name = "SA_QCB2_P"
command = ~D, DB, B, D, DB, B, y
time = 30

[Command]
name = "SA_QCB2_P"
command = ~D, DB, B, D, DB, B, z
time = 30

[Command]
name = "QCF_KK"
command = ~D, DF, F, a+b

[Command]
name = "QCF_KK"
command = ~D, DF, F, a+c

[Command]
name = "QCF_KK"
command = ~D, DF, F, b+c

[Command]
name = "QCF_a"
command = ~D, DF, F, a

[Command]
name = "QCF_b"
command = ~D, DF, F, b

[Command]
name = "QCF_c"
command = ~D, DF, F, c

[Command]
name = "QCB_PP"
command = ~D, DB, B, x+y

[Command]
name = "QCB_PP"
command = ~D, DB, B, x+z

[Command]
name = "QCB_PP"
command = ~D, DB, B, y+z

[Command]
name = "QCB_x"
command = ~D, DB, B, x

[Command]
name = "QCB_y"
command = ~D, DB, B, y

[Command]
name = "QCB_z"
command = ~D, DB, B, z

[Command]
name = "QCB_KK"
command = ~D, DB, B, a+b

[Command]
name = "QCB_KK"
command = ~D, DB, B, a+c

[Command]
name = "QCB_KK"
command = ~D, DB, B, b+c

[Command]
name = "QCB_a"
command = ~D, DB, B, a

[Command]
name = "QCB_b"
command = ~D, DB, B, b

[Command]
name = "QCB_c"
command = ~D, DB, B, c

[Command]
name = "DP_PP"
command = ~F, D, DF, x+y

[Command]
name = "DP_PP"
command = ~F, D, DF, F, x+y

[Command]
name = "DP_PP"
command = ~F, D, DF, x+z

[Command]
name = "DP_PP"
command = ~F, D, DF, F, x+z

[Command]
name = "DP_PP"
command = ~F, D, DF, y+z

[Command]
name = "DP_PP"
command = ~F, D, DF, F, y+z

[Command]
name = "DP_x"
command = ~F, D, DF, x

[Command]
name = "DP_x"
command = ~F, D, DF, F, x

[Command]
name = "DP_y"
command = ~F, D, DF, y

[Command]
name = "DP_y"
command = ~F, D, DF, F, y

[Command]
name = "DP_z"
command = ~F, D, DF, z

[Command]
name = "DP_z"
command = ~F, D, DF, F, z

[Command]
name = "throw"
command = x+a
time = 1

[Command]
name = "overhead"
command = y+b
time = 1

[Command]
name = "taunt"
command = z+c
time = 1

[Command]
name = "FF"
command = F, F
time = 10

[Command]
name = "superjump"
command = $D, $U
time = 12

[Command]
name = "BB"
command = B, B
time = 10

[Command]
name = "recovery"
command = x+a
time = 1

[Command]
name = "recovery"
command = y+b
time = 1

[Command]
name = "tapF"
command = F
time = 1

[Command]
name = "tapD"
command = D
time = 1

[Command]
name = "x"
command = x
time = 1

[Command]
name = "y"
command = y
time = 1

[Command]
name = "z"
command = z
time = 1

[Command]
name = "a"
command = a
time = 1

[Command]
name = "b"
command = b
time = 1

[Command]
name = "c"
command = c
time = 1

[Command]
name = "s"
command = s
time = 1

[Command]
name = "holdfwd"
command = /$F
time = 1

[Command]
name = "holdback"
command = /$B
time = 1

[Command]
name = "holdup"
command = /$U
time = 1

[Command]
name = "holddown"
command = /$D
time = 1

;===========================================================================
[Statedef -1]

[State -1, Fist of Retribution (desperation super)]
type = ChangeState
value = 3300
triggerall = command = "RETRIBUTION"
triggerall = PowerMax > 0 && Power >= PowerMax
triggerall = Life * 10 < LifeMax * 3
triggerall = statetype != A
triggerall = AILevel = 0
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = movecontact
trigger3 = stateno = [1000, 1003] || stateno = [1100, 1103] || stateno = [1200, 1203] || stateno = [1300, 1303] || stateno = [1400, 1403]

[State -1, Fist of Retribution (CPU)]
type = ChangeState
value = 3300
triggerall = AILevel > 0 && RoundState = 2
triggerall = PowerMax > 0 && Power >= PowerMax
triggerall = Life * 10 < LifeMax * 3
triggerall = statetype != A && ctrl
triggerall = P2StateType != L && P2MoveType != H
trigger1 = P2BodyDist X < 150 && Random < 6 + AILevel * 3

[State -1, SA I Thunder God's Judgment]
type = ChangeState
value = 3000
triggerall = command = "SA_QCF2_P"
triggerall = Map(sa) <= 1 && power >= 1000
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves supers alone until its patterns use them
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = movecontact
trigger3 = stateno = [1000, 1003] || stateno = [1100, 1103] || stateno = [1200, 1203] || stateno = [1300, 1303] || stateno = [1400, 1403]

[State -1, SA II Lightning Requiem]
type = ChangeState
value = 3100
triggerall = command = "SA_QCF2_K"
triggerall = Map(sa) = 2 && power >= 1000
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves supers alone until its patterns use them
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = movecontact
trigger3 = stateno = [1000, 1003] || stateno = [1100, 1103] || stateno = [1200, 1203] || stateno = [1300, 1303] || stateno = [1400, 1403]

[State -1, SA III Perfect Harmony]
type = ChangeState
value = 3200
triggerall = command = "SA_QCB2_P"
triggerall = Map(sa) = 3 && power >= 1000 && Map(harmony) <= 0
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves supers alone until its patterns use them
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = movecontact
trigger3 = stateno = [1000, 1003] || stateno = [1100, 1103] || stateno = [1200, 1203] || stateno = [1300, 1303] || stateno = [1400, 1403]

[State -1, Harmony Counter EX]
type = ChangeState
value = 1503
triggerall = command = "HCF_PP"
triggerall = power >= ceil(40000.0 / ifelse(Map(sa) = 2, 128, ifelse(Map(sa) = 3, 80, 112)))
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 15))

[State -1, Harmony Counter HP]
type = ChangeState
value = 1502
triggerall = command = "HCF_z"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 15))

[State -1, Harmony Counter MP]
type = ChangeState
value = 1501
triggerall = command = "HCF_y"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 15))

[State -1, Harmony Counter LP]
type = ChangeState
value = 1500
triggerall = command = "HCF_x"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 15))

[State -1, Skybreaker Kick EX]
type = ChangeState
value = 1403
triggerall = command = "QCF_KK"
triggerall = power >= ceil(40000.0 / ifelse(Map(sa) = 2, 128, ifelse(Map(sa) = 3, 80, 112)))
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 14))

[State -1, Skybreaker Kick HK]
type = ChangeState
value = 1402
triggerall = command = "QCF_c"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 14))

[State -1, Skybreaker Kick MK]
type = ChangeState
value = 1401
triggerall = command = "QCF_b"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 14))

[State -1, Skybreaker Kick LK]
type = ChangeState
value = 1400
triggerall = command = "QCF_a"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 14))

[State -1, Static Breaker EX]
type = ChangeState
value = 1303
triggerall = command = "QCB_PP"
triggerall = power >= ceil(40000.0 / ifelse(Map(sa) = 2, 128, ifelse(Map(sa) = 3, 80, 112)))
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 13))

[State -1, Static Breaker HP]
type = ChangeState
value = 1302
triggerall = command = "QCB_z"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 13))

[State -1, Static Breaker MP]
type = ChangeState
value = 1301
triggerall = command = "QCB_y"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 13))

[State -1, Static Breaker LP]
type = ChangeState
value = 1300
triggerall = command = "QCB_x"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 13))

[State -1, Air Flashstep EX]
type = ChangeState
value = 1253
triggerall = command = "QCB_KK"
triggerall = power >= ceil(40000.0 / ifelse(Map(sa) = 2, 128, ifelse(Map(sa) = 3, 80, 112)))
triggerall = statetype = A && Pos Y < -18
triggerall = AILevel = 0
trigger1 = ctrl
trigger2 = movecontact && (stateno = [600, 659])
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 12))

[State -1, Air Flashstep HK]
type = ChangeState
value = 1252
triggerall = command = "QCB_c"
triggerall = statetype = A && Pos Y < -18
triggerall = AILevel = 0
trigger1 = ctrl
trigger2 = movecontact && (stateno = [600, 659])
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 12))

[State -1, Air Flashstep MK]
type = ChangeState
value = 1251
triggerall = command = "QCB_b"
triggerall = statetype = A && Pos Y < -18
triggerall = AILevel = 0
trigger1 = ctrl
trigger2 = movecontact && (stateno = [600, 659])
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 12))

[State -1, Air Flashstep LK]
type = ChangeState
value = 1250
triggerall = command = "QCB_a"
triggerall = statetype = A && Pos Y < -18
triggerall = AILevel = 0
trigger1 = ctrl
trigger2 = movecontact && (stateno = [600, 659])
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 12))

[State -1, Air Flashstep (CPU)]
type = ChangeState
value = 1252
triggerall = AILevel > 0 && statetype = A && ctrl && Pos Y < -40 && Vel Y > -2
triggerall = P2BodyDist X > 15 && P2BodyDist X < 100 && P2StateType != A && P2StateType != L
trigger1 = Random < AILevel * 4
trigger2 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 12))

[State -1, Flashstep EX]
type = ChangeState
value = 1203
triggerall = command = "QCB_KK"
triggerall = power >= ceil(40000.0 / ifelse(Map(sa) = 2, 128, ifelse(Map(sa) = 3, 80, 112)))
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 12))

[State -1, Flashstep HK]
type = ChangeState
value = 1202
triggerall = command = "QCB_c"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 12))

[State -1, Flashstep MK]
type = ChangeState
value = 1201
triggerall = command = "QCB_b"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 12))

[State -1, Flashstep LK]
type = ChangeState
value = 1200
triggerall = command = "QCB_a"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 12))

[State -1, Volt Ascension EX]
type = ChangeState
value = 1103
triggerall = command = "DP_PP"
triggerall = power >= ceil(40000.0 / ifelse(Map(sa) = 2, 128, ifelse(Map(sa) = 3, 80, 112)))
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 11))

[State -1, Volt Ascension HP]
type = ChangeState
value = 1102
triggerall = command = "DP_z"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 11))

[State -1, Volt Ascension MP]
type = ChangeState
value = 1101
triggerall = command = "DP_y"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 11))

[State -1, Volt Ascension LP]
type = ChangeState
value = 1100
triggerall = command = "DP_x"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its patterns use it
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 11))

[State -1, Thunderline EX]
type = ChangeState
value = 1003
triggerall = command = "QCF_PP"
triggerall = power >= ceil(40000.0 / ifelse(Map(sa) = 2, 128, ifelse(Map(sa) = 3, 80, 112)))
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its real animation is made
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 10))

[State -1, Thunderline HP]
type = ChangeState
value = 1002
triggerall = command = "QCF_z"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its real animation is made
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 10))

[State -1, Thunderline MP]
type = ChangeState
value = 1001
triggerall = command = "QCF_y"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its real animation is made
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 10))

[State -1, Thunderline LP]
type = ChangeState
value = 1000
triggerall = command = "QCF_x"
triggerall = statetype != A
triggerall = AILevel = 0   ; the CPU leaves this special alone until its real animation is made
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = Map(harmony) > 0 && statetype != A && movetype = A && ((stateno >= 200 && stateno < 500) || (movecontact && stateno >= 1000 && stateno < 1600 && floor(stateno / 100) != 10))

[State -1, Back throw]
type = ChangeState
value = 805
triggerall = command = "throw" && command = "holdback"
triggerall = statetype = S && ctrl
trigger1 = p2bodydist X < 12 && p2statetype != A && p2movetype != H
trigger1 = p2statetype != L

[State -1, Throw]
type = ChangeState
value = 800
triggerall = command = "throw"
triggerall = statetype = S && ctrl
trigger1 = p2bodydist X < 12 && p2statetype != A && p2movetype != H
trigger1 = p2statetype != L

[State -1, Universal overhead]
type = ChangeState
value = 260
triggerall = command = "overhead"
trigger1 = statetype != A && ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 260

[State -1, Taunt]
type = ChangeState
value = 195
triggerall = command = "taunt"
trigger1 = statetype = S && ctrl

[State -1, Dash]
type = ChangeState
value = 100
trigger1 = command = "FF"
trigger1 = statetype = S && ctrl

[State -1, Back dash]
type = ChangeState
value = 105
trigger1 = command = "BB"
trigger1 = statetype = S && ctrl

; ---- Parry inputs (3rd Strike rules; windows run in Statedef -2 of the .cns) ----
[State -1, Air parry input]
type = VarSet
triggerall = var(20) = 0 && var(24) && command = "tapF"
trigger1 = statetype = A && ctrl
var(22) = 3

[State -1, High parry input]
type = VarSet
triggerall = var(20) = 0 && var(24) && command = "tapF"
trigger1 = statetype != A && ctrl
trigger2 = statetype != A && stateno = [150, 153]
var(22) = 1

[State -1, Low parry input]
type = VarSet
triggerall = var(20) = 0 && var(24) && command = "tapD"
trigger1 = statetype != A && ctrl
trigger2 = statetype != A && stateno = [150, 153]
var(22) = 2

[State -1, Parry window (air, 8f)]
type = VarSet
triggerall = var(20) = 0 && var(24)
trigger1 = command = "tapF" && ctrl && statetype = A
var(21) = ifelse(Map(harmony) > 0, 13, 9)

[State -1, Parry window (ground, 11f)]
type = VarSet
triggerall = var(20) = 0 && var(24) && statetype != A
trigger1 = command = "tapF" && ctrl
trigger2 = command = "tapD" && ctrl
var(21) = ifelse(Map(harmony) > 0, 16, 12)

[State -1, Parry window (guard stun, 3f)]
type = VarSet
triggerall = var(20) = 0 && var(24) && statetype != A && stateno = [150, 153]
trigger1 = command = "tapF" || command = "tapD"
var(21) = 4

[State -1, Parry tap bookkeeping]
type = VarSet
triggerall = var(20) = 0 && var(21) > 0 && var(23) > 0
trigger1 = 1
var(23) = 0

[State -1, Parry released reset]
type = VarSet
triggerall = var(20) = 0 && var(21) > 0
trigger1 = 1
var(25) = 0

[State -1, Parry lockout]
type = VarSet
triggerall = var(20) = 0 && var(21) > 0
trigger1 = 1
var(20) = ifelse(statetype = A, 18, 21)

[State -1, Lever neutral memo]
type = VarSet
trigger1 = 1
var(24) = command != "holdfwd" && command != "holdback" && command != "holdup" && command != "holddown"

[State -1, jHK]
type = ChangeState
value = 650
triggerall = command = "c"
trigger1 = statetype = A && ctrl

[State -1, jMK]
type = ChangeState
value = 640
triggerall = command = "b"
trigger1 = statetype = A && ctrl

[State -1, jLK]
type = ChangeState
value = 630
triggerall = command = "a"
trigger1 = statetype = A && ctrl

[State -1, jHP]
type = ChangeState
value = 620
triggerall = command = "z"
trigger1 = statetype = A && ctrl

[State -1, jMP]
type = ChangeState
value = 610
triggerall = command = "y"
trigger1 = statetype = A && ctrl

[State -1, jLP]
type = ChangeState
value = 600
triggerall = command = "x"
trigger1 = statetype = A && ctrl

[State -1, 3HK Low Thunder Sweep]
type = ChangeState
value = 340
triggerall = command = "c"
triggerall = command = "holddown" && command = "holdfwd"
trigger1 = statetype != A && ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 340

[State -1, 2HK]
type = ChangeState
value = 450
triggerall = command = "c"
triggerall = command = "holddown"
trigger1 = statetype != A && ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 450

[State -1, 2MK]
type = ChangeState
value = 440
triggerall = command = "b"
triggerall = command = "holddown"
trigger1 = statetype != A && ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 440

[State -1, 2LK]
type = ChangeState
value = 430
triggerall = command = "a"
triggerall = command = "holddown"
trigger1 = statetype != A && ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 430

[State -1, 2HP]
type = ChangeState
value = 420
triggerall = command = "z"
triggerall = command = "holddown"
trigger1 = statetype != A && ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 420

[State -1, 2MP]
type = ChangeState
value = 410
triggerall = command = "y"
triggerall = command = "holddown"
trigger1 = statetype != A && ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 410

[State -1, 2LP]
type = ChangeState
value = 400
triggerall = command = "x"
triggerall = command = "holddown"
trigger1 = statetype != A && ctrl
trigger2 = stateno = 400 && movecontact && command = "holddown"
trigger3 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 400

[State -1, 4HK Turning Heel]
type = ChangeState
value = 330
triggerall = command = "c"
triggerall = command = "holdback" && command != "holddown"
trigger1 = statetype != A && ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 330

[State -1, 6MK Marty's Step Kick]
type = ChangeState
value = 320
triggerall = command = "b"
triggerall = command = "holdfwd" && command != "holddown"
trigger1 = statetype != A && ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 320

[State -1, 6HP Breaker Straight]
type = ChangeState
value = 310
triggerall = command = "z"
triggerall = command = "holdfwd" && command != "holddown"
trigger1 = statetype != A && ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 310

[State -1, 6MP Legacy Elbow]
type = ChangeState
value = 300
triggerall = command = "y"
triggerall = command = "holdfwd" && command != "holddown"
trigger1 = statetype != A && ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 300

[State -1, Master's Combination]
type = ChangeState
value = 220
triggerall = command = "z"
triggerall = command != "holddown" && command != "holdfwd" && command != "holdback"
trigger1 = stateno = 210 && movecontact
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 220

[State -1, Three-Point Lesson 2]
type = ChangeState
value = 240
triggerall = command = "b"
triggerall = command != "holddown" && command != "holdfwd" && command != "holdback"
trigger1 = stateno = 230 && movecontact
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 240

[State -1, Three-Point Lesson 3]
type = ChangeState
value = 250
triggerall = command = "c"
triggerall = command != "holddown" && command != "holdfwd" && command != "holdback"
trigger1 = stateno = 240 && movecontact
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 250

[State -1, 5HK]
type = ChangeState
value = 250
triggerall = command = "c"
triggerall = command != "holddown"
trigger1 = statetype != A && ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 250

[State -1, 5MK]
type = ChangeState
value = 240
triggerall = command = "b"
triggerall = command != "holddown"
trigger1 = statetype != A && ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 240

[State -1, 5LK]
type = ChangeState
value = 230
triggerall = command = "a"
triggerall = command != "holddown"
trigger1 = statetype != A && ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 230

[State -1, 5HP]
type = ChangeState
value = 220
triggerall = command = "z"
triggerall = command != "holddown"
trigger1 = statetype != A && ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 220

[State -1, 5MP]
type = ChangeState
value = 210
triggerall = command = "y"
triggerall = command != "holddown"
trigger1 = statetype != A && ctrl
trigger2 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 210

[State -1, 5LP]
type = ChangeState
value = 200
triggerall = command = "x"
triggerall = command != "holddown"
trigger1 = statetype != A && ctrl
trigger2 = stateno = 200 && movecontact
trigger3 = Map(harmony) > 0 && statetype != A && movecontact && stateno >= 200 && stateno < 500 && stateno != 200

