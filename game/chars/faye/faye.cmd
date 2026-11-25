; Faye Donovan - command file
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
name = "SA_QCF2_P"
command = ~D, DF, F, D, DF, F, x
time = 30

[Command]
name = "SA_QCB2_P"
command = ~D, DB, B, D, DB, B, x
time = 30

[Command]
name = "SA_QCF2_P"
command = ~D, DF, F, D, DF, F, y
time = 30

[Command]
name = "SA_QCB2_P"
command = ~D, DB, B, D, DB, B, y
time = 30

[Command]
name = "SA_QCF2_P"
command = ~D, DF, F, D, DF, F, z
time = 30

[Command]
name = "SA_QCB2_P"
command = ~D, DB, B, D, DB, B, z
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
name = "HCB_x"
command = ~F, DF, D, DB, B, x
time = 24

[Command]
name = "HCB_y"
command = ~F, DF, D, DB, B, y
time = 24

[Command]
name = "HCB_z"
command = ~F, DF, D, DB, B, z
time = 24

[Command]
name = "HCB_PP"
command = ~F, DF, D, DB, B, x+y
time = 24

[Command]
name = "HCB_PP"
command = ~F, DF, D, DB, B, x+z
time = 24

[Command]
name = "HCB_PP"
command = ~F, DF, D, DB, B, y+z
time = 24

[Command]
name = "HCB_yz"
command = ~F, DF, D, DB, B, y+z
time = 24

[Command]
name = "DP_KK"
command = ~F, D, DF, a+b

[Command]
name = "DP_KK"
command = ~F, D, DF, F, a+b

[Command]
name = "QCF_KK"
command = ~D, DF, F, a+b

[Command]
name = "DP_KK"
command = ~F, D, DF, a+c

[Command]
name = "DP_KK"
command = ~F, D, DF, F, a+c

[Command]
name = "QCF_KK"
command = ~D, DF, F, a+c

[Command]
name = "DP_KK"
command = ~F, D, DF, b+c

[Command]
name = "DP_KK"
command = ~F, D, DF, F, b+c

[Command]
name = "QCF_KK"
command = ~D, DF, F, b+c

[Command]
name = "DP_a"
command = ~F, D, DF, a

[Command]
name = "DP_a"
command = ~F, D, DF, F, a

[Command]
name = "QCF_a"
command = ~D, DF, F, a

[Command]
name = "DP_b"
command = ~F, D, DF, b

[Command]
name = "DP_b"
command = ~F, D, DF, F, b

[Command]
name = "QCF_b"
command = ~D, DF, F, b

[Command]
name = "DP_c"
command = ~F, D, DF, c

[Command]
name = "DP_c"
command = ~F, D, DF, F, c

[Command]
name = "QCF_c"
command = ~D, DF, F, c

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

[State -1, SA I Phantom Massacre]
type = ChangeState
value = 3100
triggerall = command = "SA_QCF2_P"
triggerall = Map(sa) <= 1 && power >= 1000
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = movecontact && (stateno = [1000, 1003] || stateno = [1100, 1103])

[State -1, SA II Desert Rose Requiem]
type = ChangeState
value = 3200
triggerall = command = "SA_QCB2_P"
triggerall = Map(sa) = 2 && power >= 1000
triggerall = statetype != A
trigger1 = ctrl

[State -1, SA III The Perfect Assassination]
type = ChangeState
value = 3300
triggerall = command = "SA_QCF2_K"
triggerall = Map(sa) = 3 && power >= 1000
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440
trigger3 = movecontact && (stateno = [1000, 1003] || stateno = [1100, 1103])

[State -1, Shade Low]
type = ChangeState
value = 1220
triggerall = command = "a"
trigger1 = (stateno = [1200, 1203]) && Time >= 6

[State -1, Shade High]
type = ChangeState
value = 1221
triggerall = command = "b"
trigger1 = (stateno = [1200, 1203]) && Time >= 6

[State -1, Shade Feint]
type = ChangeState
value = 1222
triggerall = command = "c"
trigger1 = (stateno = [1200, 1203]) && Time >= 6

[State -1, Death's Approach EX]
type = ChangeState
value = 1103
triggerall = command = "DP_KK"
triggerall = power >= ceil(40000.0 / ifelse(Map(sa) = 2, 128, ifelse(Map(sa) = 3, 80, 112)))
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Death's Approach HK]
type = ChangeState
value = 1102
triggerall = command = "DP_c"
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Death's Approach MK]
type = ChangeState
value = 1101
triggerall = command = "DP_b"
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Death's Approach LK]
type = ChangeState
value = 1100
triggerall = command = "DP_a"
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Vanishing Point EX]
type = ChangeState
value = 1603
triggerall = command = "HCF_PP"
triggerall = power >= ceil(40000.0 / ifelse(Map(sa) = 2, 128, ifelse(Map(sa) = 3, 80, 112)))
triggerall = statetype != A
trigger1 = ctrl

[State -1, Vanishing Point HP]
type = ChangeState
value = 1602
triggerall = command = "HCF_z"
triggerall = statetype != A
trigger1 = ctrl

[State -1, Vanishing Point MP]
type = ChangeState
value = 1601
triggerall = command = "HCF_y"
triggerall = statetype != A
trigger1 = ctrl

[State -1, Vanishing Point LP]
type = ChangeState
value = 1600
triggerall = command = "HCF_x"
triggerall = statetype != A
trigger1 = ctrl

[State -1, Pistol EX low]
type = ChangeState
value = 1713
triggerall = command = "HCB_yz"
triggerall = power >= ceil(40000.0 / ifelse(Map(sa) = 2, 128, ifelse(Map(sa) = 3, 80, 112)))
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Pistol EX]
type = ChangeState
value = 1703
triggerall = command = "HCB_PP"
triggerall = power >= ceil(40000.0 / ifelse(Map(sa) = 2, 128, ifelse(Map(sa) = 3, 80, 112)))
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Pistol HP]
type = ChangeState
value = 1700
triggerall = command = "HCB_z"
triggerall = var(14) <= 0
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Pistol MP]
type = ChangeState
value = 1710
triggerall = command = "HCB_y"
triggerall = var(14) <= 0
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Pistol LP]
type = ChangeState
value = 1700
triggerall = command = "HCB_x"
triggerall = var(14) <= 0
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Pistol air EX]
type = ChangeState
value = 1723
triggerall = command = "HCB_PP"
triggerall = power >= ceil(40000.0 / ifelse(Map(sa) = 2, 128, ifelse(Map(sa) = 3, 80, 112)))
triggerall = statetype = A
trigger1 = ctrl

[State -1, Pistol air]
type = ChangeState
value = 1720
triggerall = command = "HCB_x" || command = "HCB_y" || command = "HCB_z"
triggerall = var(14) <= 0
triggerall = statetype = A
trigger1 = ctrl

[State -1, Pistol to Ghost Step a]
type = ChangeState
value = 1200
triggerall = command = "a"
trigger1 = (stateno = 1700 || stateno = 1710) && AnimElemTime(8) > 0
trigger2 = (stateno = 1703 || stateno = 1713) && var(15) >= 2 && AnimElemTime(8) > 0

[State -1, Pistol to Ghost Step b]
type = ChangeState
value = 1201
triggerall = command = "b"
trigger1 = (stateno = 1700 || stateno = 1710) && AnimElemTime(8) > 0
trigger2 = (stateno = 1703 || stateno = 1713) && var(15) >= 2 && AnimElemTime(8) > 0

[State -1, Pistol to Ghost Step c]
type = ChangeState
value = 1202
triggerall = command = "c"
trigger1 = (stateno = 1700 || stateno = 1710) && AnimElemTime(8) > 0
trigger2 = (stateno = 1703 || stateno = 1713) && var(15) >= 2 && AnimElemTime(8) > 0

[State -1, Phantom Veil EX]
type = ChangeState
value = 1403
triggerall = command = "QCB_PP"
triggerall = power >= ceil(40000.0 / ifelse(Map(sa) = 2, 128, ifelse(Map(sa) = 3, 80, 112)))
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Phantom Veil HP]
type = ChangeState
value = 1402
triggerall = command = "QCB_z"
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Phantom Veil MP]
type = ChangeState
value = 1401
triggerall = command = "QCB_y"
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Phantom Veil LP]
type = ChangeState
value = 1400
triggerall = command = "QCB_x"
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Mirage Double EX]
type = ChangeState
value = 1503
triggerall = command = "QCB_KK"
triggerall = power >= ceil(40000.0 / ifelse(Map(sa) = 2, 128, ifelse(Map(sa) = 3, 80, 112)))
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Mirage Double HK]
type = ChangeState
value = 1502
triggerall = command = "QCB_c"
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Mirage Double MK]
type = ChangeState
value = 1501
triggerall = command = "QCB_b"
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Mirage Double LK]
type = ChangeState
value = 1500
triggerall = command = "QCB_a"
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Ghost Step EX]
type = ChangeState
value = 1203
triggerall = command = "QCF_KK"
triggerall = power >= ceil(40000.0 / ifelse(Map(sa) = 2, 128, ifelse(Map(sa) = 3, 80, 112)))
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Ghost Step HK]
type = ChangeState
value = 1202
triggerall = command = "QCF_c"
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Ghost Step MK]
type = ChangeState
value = 1201
triggerall = command = "QCF_b"
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Ghost Step LK]
type = ChangeState
value = 1200
triggerall = command = "QCF_a"
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Silent Execution EX]
type = ChangeState
value = 1003
triggerall = command = "QCF_PP"
triggerall = power >= ceil(40000.0 / ifelse(Map(sa) = 2, 128, ifelse(Map(sa) = 3, 80, 112)))
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Silent Execution HP]
type = ChangeState
value = 1002
triggerall = command = "QCF_z"
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Silent Execution MP]
type = ChangeState
value = 1001
triggerall = command = "QCF_y"
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

[State -1, Silent Execution LP]
type = ChangeState
value = 1000
triggerall = command = "QCF_x"
triggerall = statetype != A
trigger1 = ctrl
trigger2 = movecontact
trigger2 = stateno = 200 || stateno = 210 || stateno = 230 || stateno = 400 || stateno = 410 || stateno = 430 || stateno = 440

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
var(21) = 9

[State -1, Parry window (ground, 11f)]
type = VarSet
triggerall = var(20) = 0 && var(24) && statetype != A
trigger1 = command = "tapF" && ctrl
trigger2 = command = "tapD" && ctrl
var(21) = 12

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

[State -1, 2HK]
type = ChangeState
value = 450
triggerall = command = "c"
triggerall = command = "holddown"
trigger1 = statetype != A && ctrl

[State -1, 2MK]
type = ChangeState
value = 440
triggerall = command = "b"
triggerall = command = "holddown"
trigger1 = statetype != A && ctrl

[State -1, 2LK]
type = ChangeState
value = 430
triggerall = command = "a"
triggerall = command = "holddown"
trigger1 = statetype != A && ctrl

[State -1, 2HP]
type = ChangeState
value = 420
triggerall = command = "z"
triggerall = command = "holddown"
trigger1 = statetype != A && ctrl

[State -1, 2MP]
type = ChangeState
value = 410
triggerall = command = "y"
triggerall = command = "holddown"
trigger1 = statetype != A && ctrl

[State -1, 2LP]
type = ChangeState
value = 400
triggerall = command = "x"
triggerall = command = "holddown"
trigger1 = statetype != A && ctrl
trigger2 = stateno = 400 && movecontact && command = "holddown"

[State -1, 4HK Retreating Crescent]
type = ChangeState
value = 330
triggerall = command = "c"
triggerall = command = "holdback" && command != "holddown"
trigger1 = statetype != A && ctrl

[State -1, 6MK Rising Heel]
type = ChangeState
value = 320
triggerall = command = "b"
triggerall = command = "holdfwd" && command != "holddown"
trigger1 = statetype != A && ctrl

[State -1, 6HP False Opening]
type = ChangeState
value = 310
triggerall = command = "z"
triggerall = command = "holdfwd" && command != "holddown"
trigger1 = statetype != A && ctrl

[State -1, 6MP Assassin's Elbow]
type = ChangeState
value = 300
triggerall = command = "y"
triggerall = command = "holdfwd" && command != "holddown"
trigger1 = statetype != A && ctrl

[State -1, 5HK]
type = ChangeState
value = 250
triggerall = command = "c"
triggerall = command != "holddown"
trigger1 = statetype != A && ctrl

[State -1, 5MK]
type = ChangeState
value = 240
triggerall = command = "b"
triggerall = command != "holddown"
trigger1 = statetype != A && ctrl

[State -1, 5LK]
type = ChangeState
value = 230
triggerall = command = "a"
triggerall = command != "holddown"
trigger1 = statetype != A && ctrl

[State -1, 5HP]
type = ChangeState
value = 220
triggerall = command = "z"
triggerall = command != "holddown"
trigger1 = statetype != A && ctrl

[State -1, 5MP]
type = ChangeState
value = 210
triggerall = command = "y"
triggerall = command != "holddown"
trigger1 = statetype != A && ctrl

[State -1, 5LP]
type = ChangeState
value = 200
triggerall = command = "x"
triggerall = command != "holddown"
trigger1 = statetype != A && ctrl
trigger2 = stateno = 200 && movecontact

