SaffronGymScript: ; 5d00d (17:500d)
	ld hl, wCurrentMapScriptFlags
	bit 6, [hl]
	res 6, [hl]
	call nz, SaffronGymScript_UponMapEntry
	call EnableAutoTextBoxDrawing
	ld hl, SaffronGymTrainerHeader0
	ld de, SaffronGymScriptPointers
	ld a, [wSaffronGymCurScript]
	call ExecuteCurMapScriptInTable
	ld [wSaffronGymCurScript], a
	ret

SaffronGymScript_UponMapEntry:
	ld hl, Gym6CityName
	ld de, Gym6LeaderName
	call LoadGymLeaderAndCityName
; first time entering the map
	ld a, [wWarpedFromWhichMap]
	cp SAFFRON_CITY
	jp z, SaffronGymScript_InitializeSpritePositions
; get current "position" of warp strictly
	ld a, [wWarpedFromWhichWarp]
	ld b, a
	ld a, [wDestinationWarpID]
	dec a
	dec a
	add a
	ld e, a
	ld d, $0
	ld hl, SaffronGymWarpOnlyCoords
	add hl, de
	ld a, [hli]
	ld d, a
	ld e, [hl]
; get position of last warp
	ld a, b
	dec a
	dec a
	add a
	ld c, a
	ld b, $0
	ld hl, SaffronGymWarpOnlyCoords
	add hl, bc	
	ld a, [hli]
	ld b, a
	ld c, [hl]
; new coords = de
; old coords = bc
; calculate offsets
	ld a, b ; subtract old - new
	sub d
	jr nc, .up
	cpl
	inc a
	call SaffronGymWarps_ModBy3
	call SaffronGymWarps_ModifyToUpOrLeft
	jr .checkLeftOrRight
.up
	call SaffronGymWarps_ModBy3
.checkLeftOrRight
	ld b, a
	
	ld a, c
	sub e
	jr nc, .left
	cpl
	inc a
	call SaffronGymWarps_ModBy3
	call SaffronGymWarps_ModifyToUpOrLeft
	jr .shiftSprites
.left
	call SaffronGymWarps_ModBy3
.shiftSprites
	ld c, a
	
; b = y coord offset
; c = x coord offset
	call SaffronGymWarps_ShiftY
	call SaffronGymWarps_ShiftX
	call SaffronGymWarps_UpdateSpritePositions
	call UpdateSprites
	ld c, 2
	jp DelayFrames
	
	
SaffronGymWarps_ShiftY:
	ld a, b
	and a
	ret z
.shiftYLoop
	push bc
	
	ld hl, wSaffronGymSpritePositions
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	ld a, [hl]
	push bc
	push af ; save first row on stack
	
	ld hl, wSaffronGymSpritePositions + 3
	ld de, wSaffronGymSpritePositions
	ld bc, $6
	
	call CopyData ; shift upwards

; move stuff from top row to bottom	
	pop af
	ld hl, wSaffronGymSpritePositions + 8
	ld [hld], a
	pop bc
	ld a, c
	ld [hld], a
	ld [hl], b
	pop bc
	dec b
	jr nz, .shiftYLoop
	ret
	
SaffronGymWarps_ShiftX:
	ld a, c
	and a
	ret z
.outerLoop
	ld hl, wSaffronGymSpritePositions
	ld b, $3
.innerLoop
	ld a, [hli]
	push af ; save first column
	ld a, [hld]
	ld [hli], a
	inc hl ; hl = third column
	ld a, [hld]
	ld [hli], a ; hl = third column after increment
	pop af ; restore first column sprite
	ld [hli], a ; write first to third
	dec b
	jr nz, .innerLoop
	dec c
	jr nz, .outerLoop
	ret
	
SaffronGymWarps_ModBy3:
	ld d, 3
.loop
	sub d
	jr nc, .loop
	add d
	ret
	
SaffronGymWarps_ModifyToUpOrLeft:
	and a
	ret z ; no movement
	dec a
	ld a, $2
	ret z ; one movement in direction X = two in the opposite direction
; reverse above comment
	dec a ; get one
	ret
	
SaffronGymWarps_UpdateSpritePositions:
	ld a, 9
	ld de, wSaffronGymSpritePositions
	ld hl, SaffronGymScript_SpriteCoordinates
.loop
	push af
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	push hl
	ld hl, wSpriteStateData2 + $14
	ld a, [de]
	inc de
	dec a
	swap a
	add l
	ld l, a
	jr nc, .noCarry ; this should never be a problem but coding practices...
	inc h
.noCarry
	ld a, b
	ld [hli], a
	ld [hl], c
	pop hl
	pop af
	dec a
	jr nz, .loop
	ret

SaffronGymScript_SpriteCoordinates:
; hardcode the table instead of shifting around data
spritedatacoords: MACRO
	db \2 + 4, \1 + 4
ENDM

	spritedatacoords $3, $1
	spritedatacoords $a, $1
	spritedatacoords $11, $1
	spritedatacoords $3, $7
	spritedatacoords $9, $8
	spritedatacoords $11, $7
	spritedatacoords $3, $d
	spritedatacoords $a, $f
	spritedatacoords $11, $d
	
SaffronGymScript_InitializeSpritePositions:
	xor a
	ld [wOldWarpedFromWhichWarp], a
	ld hl, SaffronGym_InitialSpritePositions
	ld de, wSaffronGymSpritePositions
	ld bc, SaffronGym_InitialSpritePositionsEnd - SaffronGym_InitialSpritePositions
	jp CopyData

SaffronGym_InitialSpritePositions:
	db 8, 2, 3
	db 4, 1, 5
	db 6, 9, 7
SaffronGym_InitialSpritePositionsEnd:
	
SaffronGymWarpOnlyCoords:
; FORMAT: y, x
	db 0, 0
	db 0, 1
	db 1, 0
	db 1, 1
	db 2, 0
	db 2, 1
	db 3, 0
	db 3, 1
	db 4, 0
	db 4, 1
	db 5, 0
	db 5, 1
	
	db 0, 2
	db 0, 3
	db 1, 2
	db 1, 3
	db 3, 3
	db 4, 3
	
	db 0, 4
	db 0, 5
	db 1, 4
	db 1, 5
	db 2, 4
	db 2, 5
	db 3, 4
	db 3, 5
	db 4, 4
	db 4, 5
	db 5, 4
	db 5, 5
	
; trainer indexes in order:


Gym6CityName: ; 5d033 (17:5033)
	db "SAFFRON CITY@"

Gym6LeaderName: ; 5d040 (17:5040)
	db "SABRINA@"

SaffronGymText_5d048: ; 5d048 (17:5048)
	xor a
	ld [wJoyIgnore], a
	ld [wSaffronGymCurScript], a
	ld [wCurMapScript], a
	ret

SaffronGymScriptPointers: ; 5d053 (17:5053)
	dw CheckFightingMapTrainers
	dw DisplayEnemyTrainerTextAndStartBattle
	dw EndTrainerBattle
	dw SaffronGymScript3

SaffronGymScript3: ; 5d05b (17:505b)
	ld a, [wIsInBattle]
	cp $ff
	jp z, SaffronGymText_5d048
	ld a, $f0
	ld [wJoyIgnore], a

SaffronGymText_5d068: ; 5d068 (17:5068)
	ld a, $a
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	SetEvent EVENT_BEAT_SABRINA
	lb bc, TM_46, 1
	call GiveItem
	jr nc, .BagFull
	ld a, $b
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	SetEvent EVENT_GOT_TM46
	jr .asm_5d091
.BagFull
	ld a, $c
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
.asm_5d091
	ld hl, wObtainedBadges
	set 5, [hl]
	ld hl, wBeatGymFlags
	set 5, [hl]

	; deactivate gym trainers
	SetEventRange EVENT_BEAT_SAFFRON_GYM_TRAINER_0, EVENT_BEAT_SAFFRON_GYM_TRAINER_6

	jp SaffronGymText_5d048

SaffronGymTextPointers: ; 5d0ab (17:50ab)
	dw SaffronGymText1
	dw SaffronGymText2
	dw SaffronGymText3
	dw SaffronGymText4
	dw SaffronGymText5
	dw SaffronGymText6
	dw SaffronGymText7
	dw SaffronGymText8
	dw SaffronGymText9
	dw SaffronGymText10
	dw SaffronGymText11
	dw SaffronGymText12

SaffronGymTrainerHeaders: ; 5d0c3 (17:50c3)
SaffronGymTrainerHeader0: ; 5d0c3 (17:50c3)
	dbEventFlagBit EVENT_BEAT_SAFFRON_GYM_TRAINER_0
	db ($3 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_SAFFRON_GYM_TRAINER_0
	dw SaffronGymBattleText1 ; TextBeforeBattle
	dw SaffronGymAfterBattleText1 ; TextAfterBattle
	dw SaffronGymEndBattleText1 ; TextEndBattle
	dw SaffronGymEndBattleText1 ; TextEndBattle

SaffronGymTrainerHeader1: ; 5d0cf (17:50cf)
	dbEventFlagBit EVENT_BEAT_SAFFRON_GYM_TRAINER_1
	db ($3 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_SAFFRON_GYM_TRAINER_1
	dw SaffronGymBattleText2 ; TextBeforeBattle
	dw SaffronGymAfterBattleText2 ; TextAfterBattle
	dw SaffronGymEndBattleText2 ; TextEndBattle
	dw SaffronGymEndBattleText2 ; TextEndBattle

SaffronGymTrainerHeader2: ; 5d0db (17:50db)
	dbEventFlagBit EVENT_BEAT_SAFFRON_GYM_TRAINER_2
	db ($3 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_SAFFRON_GYM_TRAINER_2
	dw SaffronGymBattleText3 ; TextBeforeBattle
	dw SaffronGymAfterBattleText3 ; TextAfterBattle
	dw SaffronGymEndBattleText3 ; TextEndBattle
	dw SaffronGymEndBattleText3 ; TextEndBattle

SaffronGymTrainerHeader3: ; 5d0e7 (17:50e7)
	dbEventFlagBit EVENT_BEAT_SAFFRON_GYM_TRAINER_3
	db ($3 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_SAFFRON_GYM_TRAINER_3
	dw SaffronGymBattleText4 ; TextBeforeBattle
	dw SaffronGymAfterBattleText4 ; TextAfterBattle
	dw SaffronGymEndBattleText4 ; TextEndBattle
	dw SaffronGymEndBattleText4 ; TextEndBattle

SaffronGymTrainerHeader4: ; 5d0f3 (17:50f3)
	dbEventFlagBit EVENT_BEAT_SAFFRON_GYM_TRAINER_4
	db ($3 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_SAFFRON_GYM_TRAINER_4
	dw SaffronGymBattleText5 ; TextBeforeBattle
	dw SaffronGymAfterBattleText5 ; TextAfterBattle
	dw SaffronGymEndBattleText5 ; TextEndBattle
	dw SaffronGymEndBattleText5 ; TextEndBattle

SaffronGymTrainerHeader5: ; 5d0ff (17:50ff)
	dbEventFlagBit EVENT_BEAT_SAFFRON_GYM_TRAINER_5
	db ($3 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_SAFFRON_GYM_TRAINER_5
	dw SaffronGymBattleText6 ; TextBeforeBattle
	dw SaffronGymAfterBattleText6 ; TextAfterBattle
	dw SaffronGymEndBattleText6 ; TextEndBattle
	dw SaffronGymEndBattleText6 ; TextEndBattle

SaffronGymTrainerHeader6: ; 5d10b (17:510b)
	dbEventFlagBit EVENT_BEAT_SAFFRON_GYM_TRAINER_6, 1
	db ($3 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_SAFFRON_GYM_TRAINER_6, 1
	dw SaffronGymBattleText7 ; TextBeforeBattle
	dw SaffronGymAfterBattleText7 ; TextAfterBattle
	dw SaffronGymEndBattleText7 ; TextEndBattle
	dw SaffronGymEndBattleText7 ; TextEndBattle

	db $ff

SaffronGymText1: ; 5d118 (17:5118)
	TX_ASM
	CheckEvent EVENT_BEAT_SABRINA
	jr z, .asm_5d134
	CheckEventReuseA EVENT_GOT_TM46
	jr nz, .asm_5d12c
.giveBadgeAndTM
	call z, SaffronGymText_5d068
	call DisableWaitingAfterTextDisplay
	jp .asm_5d15f
.asm_5d12c
	ld hl, SaffronGymText_5d16e
	call PrintText
	jp .asm_5d15f
.asm_5d134
	ld a, [wSpriteStateData2 + $14]
	ld b, a
	ld a, [wSpriteStateData2 + $15]
	ld c, a
	ld hl, SaffronGymCornerAndCentreCoords
	call CheckCoords
	jr nc, .regularText
	ld a, [wCoordIndex]
	dec a
	jr nz, .notSabrinaImpressedText
	ld hl, SaffronGymText_SabrinaImpressed
	call PrintText
	call WaitForSoundToFinish
	xor a
	jr .giveBadgeAndTM
.notSabrinaImpressedText
	CheckAndSetEvent EVENT_TALKED_TO_SABRINA_IN_CORNER
	jr nz, .subsequentMeets
	ld hl, SaffronGymText_SabrinaCornerphobic
	call PrintText
	ld hl, SaffronGymText_PuzzleExplanation
	call PrintText
	jp TextScriptEnd
.subsequentMeets
	ld hl, SaffronGymText_ListenAgain
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	ld hl, SaffronGymText_PuzzleExplanation
	jr z, .gotText
	ld hl, SaffronGymText_AfterMeetingSabrinaInCornerRoom
.gotText
	call PrintText
	jp TextScriptEnd
.regularText
	ld hl, SaffronGymText_5d162
	call PrintText
	ld hl, wd72d
	set 6, [hl]
	set 7, [hl]
	ld hl, SaffronGymText_5d167
	ld de, SaffronGymText_5d167
	call SaveEndBattleTextPointers
	ld a, [H_SPRITEINDEX]
	ld [wSpriteIndex], a
	call EngageMapTrainer
	call InitBattleEnemyParameters
	ld a, $6
	ld [wGymLeaderNo], a
	ld a, $3
	ld [wSaffronGymCurScript], a
.asm_5d15f
	jp TextScriptEnd
	
SaffronGymText_SabrinaImpressed:
	TX_FAR _SaffronGymText_SabrinaImpressed
	db "@"
	
SaffronGymText_SabrinaCornerphobic:
	TX_FAR _SaffronGymText_SabrinaCornerphobic
	db "@"

SaffronGymText_ListenAgain:
	TX_FAR _SaffronGymText_ListenAgain
	db "@"
	
SaffronGymText_PuzzleExplanation:
	TX_FAR _SaffronGymText_PuzzleExplanation
	db "@"

SaffronGymText_AfterMeetingSabrinaInCornerRoom:
	TX_FAR _SaffronGymText_AfterMeetingSabrinaInCornerRoom
	db "@"

SaffronGymCornerAndCentreCoords:
; middle
	spritedatacoords $9, $8
; four corners
	spritedatacoords $3, $1
	spritedatacoords $11, $1
	spritedatacoords $3, $d
	spritedatacoords $11, $d
	db $ff

SaffronGymText_5d162: ; 5d162 (17:5162)
	TX_FAR _SaffronGymText_5d162
	db "@"

SaffronGymText_5d167: ; 5d167 (17:5167)
	TX_FAR _SaffronGymText_5d167
	db $11 ; play same sound as red giving oak parcel
	db $6 ; wait for keypress
	db "@"

SaffronGymText_5d16e: ; 5d16e (17:516e)
	TX_FAR _SaffronGymText_5d16e
	db "@"

SaffronGymText10: ; 5d173 (17:5173)
	TX_FAR _SaffronGymText_5d173
	db "@"

SaffronGymText11: ; 5d178 (17:5178)
	TX_FAR ReceivedTM46Text
	db $b
	TX_FAR _TM46ExplanationText
	db "@"

SaffronGymText12: ; 5d182 (17:5182)
	TX_FAR _TM46NoRoomText
	db "@"

SaffronGymText2: ; 5d187 (17:5187)
	TX_ASM
	ld hl, SaffronGymTrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

SaffronGymText3: ; 5d191 (17:5191)
	TX_ASM
	ld hl, SaffronGymTrainerHeader1
	call TalkToTrainer
	jp TextScriptEnd

SaffronGymText4: ; 5d19b (17:519b)
	TX_ASM
	ld hl, SaffronGymTrainerHeader2
	call TalkToTrainer
	jp TextScriptEnd

SaffronGymText5: ; 5d1a5 (17:51a5)
	TX_ASM
	ld hl, SaffronGymTrainerHeader3
	call TalkToTrainer
	jp TextScriptEnd

SaffronGymText6: ; 5d1af (17:51af)
	TX_ASM
	ld hl, SaffronGymTrainerHeader4
	call TalkToTrainer
	jp TextScriptEnd

SaffronGymText7: ; 5d1b9 (17:51b9)
	TX_ASM
	ld hl, SaffronGymTrainerHeader5
	call TalkToTrainer
	jp TextScriptEnd

SaffronGymText8: ; 5d1c3 (17:51c3)
	TX_ASM
	ld hl, SaffronGymTrainerHeader6
	call TalkToTrainer
	jp TextScriptEnd

SaffronGymText9: ; 5d1cd (17:51cd)
	TX_ASM
	CheckEvent EVENT_BEAT_SABRINA
	jr nz, .asm_5d1dd
	ld hl, SaffronGymText_5d1e6
	call PrintText
	jr .asm_5d1e3
.asm_5d1dd
	ld hl, SaffronGymText_5d1eb
	call PrintText
.asm_5d1e3
	jp TextScriptEnd

SaffronGymText_5d1e6: ; 5d1e6 (17:51e6)
	TX_FAR _SaffronGymText_5d1e6
	db "@"

SaffronGymText_5d1eb: ; 5d1eb (17:51eb)
	TX_FAR _SaffronGymText_5d1eb
	db "@"

SaffronGymBattleText1: ; 5d1f0 (17:51f0)
	TX_FAR _SaffronGymBattleText1
	db "@"

SaffronGymEndBattleText1: ; 5d1f5 (17:51f5)
	TX_FAR _SaffronGymEndBattleText1
	db "@"

SaffronGymAfterBattleText1: ; 5d1fa (17:51fa)
	TX_FAR _SaffronGymAfterBattleText1
	db "@"

SaffronGymBattleText2: ; 5d1ff (17:51ff)
	TX_FAR _SaffronGymBattleText2
	db "@"

SaffronGymEndBattleText2: ; 5d204 (17:5204)
	TX_FAR _SaffronGymEndBattleText2
	db "@"

SaffronGymAfterBattleText2: ; 5d209 (17:5209)
	TX_FAR _SaffronGymAfterBattleText2
	db "@"

SaffronGymBattleText3: ; 5d20e (17:520e)
	TX_FAR _SaffronGymBattleText3
	db "@"

SaffronGymEndBattleText3: ; 5d213 (17:5213)
	TX_FAR _SaffronGymEndBattleText3
	db "@"

SaffronGymAfterBattleText3: ; 5d218 (17:5218)
	TX_FAR _SaffronGymAfterBattleText3
	db "@"

SaffronGymBattleText4: ; 5d21d (17:521d)
	TX_FAR _SaffronGymBattleText4
	db "@"

SaffronGymEndBattleText4: ; 5d222 (17:5222)
	TX_FAR _SaffronGymEndBattleText4
	db "@"

SaffronGymAfterBattleText4: ; 5d227 (17:5227)
	TX_FAR _SaffronGymAfterBattleText4
	db "@"

SaffronGymBattleText5: ; 5d22c (17:522c)
	TX_FAR _SaffronGymBattleText5
	db "@"

SaffronGymEndBattleText5: ; 5d231 (17:5231)
	TX_FAR _SaffronGymEndBattleText5
	db "@"

SaffronGymAfterBattleText5: ; 5d236 (17:5236)
	TX_FAR _SaffronGymAfterBattleText5
	db "@"

SaffronGymBattleText6: ; 5d23b (17:523b)
	TX_FAR _SaffronGymBattleText6
	db "@"

SaffronGymEndBattleText6: ; 5d240 (17:5240)
	TX_FAR _SaffronGymEndBattleText6
	db "@"

SaffronGymAfterBattleText6: ; 5d245 (17:5245)
	TX_FAR _SaffronGymAfterBattleText6
	db "@"

SaffronGymBattleText7: ; 5d24a (17:524a)
	TX_FAR _SaffronGymBattleText7
	db "@"

SaffronGymEndBattleText7: ; 5d24f (17:524f)
	TX_FAR _SaffronGymEndBattleText7
	db "@"

SaffronGymAfterBattleText7: ; 5d254 (17:5254)
	TX_FAR _SaffronGymAfterBattleText7
	db "@"
