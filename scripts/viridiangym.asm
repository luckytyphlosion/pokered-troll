ViridianGymScript: ; 748a3 (1d:48a3)
	ld hl, Gym8CityName
	ld de, Gym8LeaderName
	call LoadGymLeaderAndCityName
	call EnableAutoTextBoxDrawing
	ld hl, ViridianGymTrainerHeaders
	ld de, ViridianGymScriptPointers
	ld a, [wViridianGymCurScript]
	call ExecuteCurMapScriptInTable
	ld [wViridianGymCurScript], a
	ret

Gym8CityName: ; 748bf (1d:48bf)
	db "VIRIDIAN CITY@"
Gym8LeaderName: ; 748cd (1d:48cd)
	db "GIOVANNI@"

ViridianGymScript_748d6: ; 748d6 (1d:48d6)
	xor a
	ld [wJoyIgnore], a
	ld [wViridianGymCurScript], a
	ld [wCurMapScript], a
	ret

ViridianGymScriptPointers: ; 748e1 (1d:48e1)
	dw ViridianGymScript0
	dw DisplayEnemyTrainerTextAndStartBattle
	dw EndTrainerBattle
	dw ViridianGymScript3
	dw ViridianGymScript4
	dw ViridianGymScript5
	dw ViridianGymScript6

ViridianGymScript0: ; 748eb (1d:48eb)
	ld hl, wCurrentMapScriptFlags
	bit 6, [hl]
	res 6, [hl]
	jr z, .notRhyhornCooltrainerRematch
	CheckEvent EVENT_RHYHORN_COOLTRAINER_REMATCHED
	jr z, .notRhyhornCooltrainerRematch
	CheckEvent EVENT_BEAT_RHYHORN_COOLTRAINER_AGAIN
	jr nz, .notRhyhornCooltrainerRematch
	SetEvent EVENT_DO_RHYHORN_COOLTRAINER_ALT_TEXT
	call UpdateSprites
	jr .doRhyhornCooltrainerRematch
.notRhyhornCooltrainerRematch
	ld a, [wYCoord]
	ld b, a
	ld a, [wXCoord]
	ld c, a
	ld hl, ViridianGymArrowTilePlayerMovement
	call DecodeArrowMovementRLE
	cp $ff
	jp nz, .simulateJoypadStates
	ld a, [wYCoord]
	cp 5
	jr nz, .checkFightingMapTrainers
	ld a, [wXCoord]
	cp 11
	jr nz, .checkFightingMapTrainers
	CheckEvent EVENT_BEAT_VIRIDIAN_GYM_TRAINER_5
	jr z, .checkFightingMapTrainers
	CheckEvent EVENT_BEAT_VIRIDIAN_GYM_TRAINER_4
	jr z, .checkFightingMapTrainers
	CheckEvent EVENT_BEAT_RHYHORN_COOLTRAINER_AGAIN
	jr z, .rhyhornCooltrainerRematch
.checkFightingMapTrainers
	jp CheckFightingMapTrainers
; make cooltrainer snipe the trainer, effectively trapping them and forcing a wipe
.rhyhornCooltrainerRematch 
	ld a, SPRITE_FACING_LEFT
	ld [wSpriteStateData1 + $69], a ; lol69
	ld a, LEFT
	ld [wMapSpriteData + 5 * 2], a
	SetEvent EVENT_RHYHORN_COOLTRAINER_REMATCHED
	call UpdateSprites
	callab SaveSAVtoSRAM ; no savescumming
.doRhyhornCooltrainerRematch
	ld a, $6
	ld [wSpriteIndex], a
	ld hl, wFlags_D733
	set 3, [hl]
	call EngageMapTrainer
	ld a, [wSpriteIndex]
	ld [wEmotionBubbleSpriteIndex], a
	xor a ; EXCLAMATION_BUBBLE
	ld [wWhichEmotionBubble], a
	predef EmotionBubble
	ld a, D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	xor a
	ld [hJoyHeld], a
	ld a, SPRITE_FACING_LEFT
	ld [wTrainerFacingDirection], a
	call TrainerWalkUpToPlayer_Bank0
	ld hl, ViridianGymEndBattleText5
	ld de, ViridianGymAfterBattleText5
	call SaveEndBattleTextPointers
	ld a, $5
	ld [wCurMapScript], a
	ret
	
.simulateJoypadStates
	call StartSimulatingJoypadStates
	ld hl, wd736
	set 7, [hl]
	ld a, SFX_ARROW_TILES
	call PlaySound
	ld a, $ff
	ld [wJoyIgnore], a
	ld a, $4
	ld [wCurMapScript], a
	ret

ViridianGymScript5:
	ld a, [wd730]
	bit 0, a
	ret nz
	xor a
	ld [wJoyIgnore], a
	ld a, 15
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
ViridianGymScript_StartRhyhornGymBattle:
	call StartTrainerBattle
	ld a, $6
	ld [wCurMapScript], a
	ld [wSpriteIndex], a
	ld [hSpriteIndexOrTextID], a
	ret
	
ViridianGymScript6:
	ld a, [wIsInBattle]
	cp $ff
	jr nz, .wonBattle
	SetEvent EVENT_BEAT_RHYHORN_COOLTRAINER_AGAIN
	ResetEvent EVENT_RHYHORN_COOLTRAINER_REMATCHED
	jp ViridianGymScript_748d6
.wonBattle
	ld a, $f0
	ld [wJoyIgnore], a
	ld hl, ViridianGymEndBattleText5
	ld de, ViridianGymAfterBattleText5
	call SaveEndBattleTextPointers
	ld a, 16
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	ld a, $6
	ld [wSpriteIndex], a
	call EngageMapTrainer
	jr ViridianGymScript_StartRhyhornGymBattle
	
;format:
;db y,x
;dw pointer to movement
ViridianGymArrowTilePlayerMovement: ; 74916 (1d:4916)
	db $b,$13
	dw ViridianGymArrowMovement1
	db $1,$13
	dw ViridianGymArrowMovement2
	db $2,$12
	dw ViridianGymArrowMovement3
	db $2,$b
	dw ViridianGymArrowMovement4
	db $a,$10
	dw ViridianGymArrowMovement5
	db $6,$4
	dw ViridianGymArrowMovement6
	db $d,$5
	dw ViridianGymArrowMovement7
	db $e,$4
	dw ViridianGymArrowMovement8
	db $f,$0
	dw ViridianGymArrowMovement9
	db $f,$1
	dw ViridianGymArrowMovement10
	db $10,$d
	dw ViridianGymArrowMovement11
	db $11,$d
	dw ViridianGymArrowMovement12
	db $FF

;format: direction, count
ViridianGymArrowMovement1: ; 74947 (1d:4947)
	db D_UP,$09,$FF

ViridianGymArrowMovement2: ; 7494a (1d:494a)
	db D_LEFT,$08,$FF

ViridianGymArrowMovement3: ; 7494d (1d:494d)
	db D_DOWN,$09,$FF

ViridianGymArrowMovement4: ; 74950 (1d:4950)
	db D_RIGHT,$06,$FF

ViridianGymArrowMovement5: ; 74953 (1d:4953)
	db D_DOWN,$02,$FF

ViridianGymArrowMovement6: ; 74956 (1d:4956)
	db D_DOWN,$07,$FF

ViridianGymArrowMovement7: ; 74959 (1d:4959)
	db D_RIGHT,$08,$FF

ViridianGymArrowMovement8: ; 7495c (1d:495c)
	db D_RIGHT,$09,$FF

ViridianGymArrowMovement9: ; 7495f (1d:495f)
	db D_UP,$08,$FF

ViridianGymArrowMovement10: ; 74962 (1d:4962)
	db D_UP,$06,$FF

ViridianGymArrowMovement11: ; 74965 (1d:4965)
	db D_LEFT,$06,$FF

ViridianGymArrowMovement12: ; 74968 (1d:4968)
	db D_LEFT,$0C,$FF

ViridianGymScript4: ; 7496b (1d:496b)
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	jr nz, .asm_74980
	xor a
	ld [wJoyIgnore], a
	ld hl, wd736
	res 7, [hl]
	ld a, $0
	ld [wCurMapScript], a
	ret
.asm_74980
	jpba LoadSpinnerArrowTiles

ViridianGymScript3: ; 74988 (1d:4988)
	ld a, [wIsInBattle]
	cp $ff
	jp z, ViridianGymScript_748d6
	ld a, $f0
	ld [wJoyIgnore], a
ViridianGymScript3_74995: ; 74995 (1d:4995)
	ld a, $c
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	SetEvent EVENT_BEAT_VIRIDIAN_GYM_GIOVANNI
	lb bc, TM_27, 1
	call GiveItem
	jr nc, .BagFull
	ld a, $d
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	SetEvent EVENT_GOT_TM27
	jr .asm_749be
.BagFull
	ld a, $e
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
.asm_749be
	ld hl, wObtainedBadges
	set 7, [hl]
	ld hl, wBeatGymFlags
	set 7, [hl]

	; deactivate gym trainers
	SetEventRange EVENT_BEAT_VIRIDIAN_GYM_TRAINER_0, EVENT_BEAT_VIRIDIAN_GYM_TRAINER_7

	ld a, HS_ROUTE_22_RIVAL_2
	ld [wMissableObjectIndex], a
	predef ShowObject
	SetEvents EVENT_2ND_ROUTE22_RIVAL_BATTLE, EVENT_ROUTE22_RIVAL_WANTS_BATTLE
	jp ViridianGymScript_748d6

ViridianGymTextPointers: ; 749ec (1d:49ec)
	dw ViridianGymText1
	dw ViridianGymText2
	dw ViridianGymText3
	dw ViridianGymText4
	dw ViridianGymText5
	dw ViridianGymText6
	dw ViridianGymText7
	dw ViridianGymText8
	dw ViridianGymText9
	dw ViridianGymText10
	dw PickUpItemText
	dw ViridianGymText12
	dw ViridianGymText13
	dw ViridianGymText14
	dw ViridianGymBattleText_RhyhornCooltrainerRematch
	dw ViridianGymBattleText_RhyhornCooltrainerLost

ViridianGymTrainerHeaders: ; 74a08 (1d:4a08)
ViridianGymTrainerHeader0: ; 74a08 (1d:4a08)
	dbEventFlagBit EVENT_BEAT_VIRIDIAN_GYM_TRAINER_0
	db ($4 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_VIRIDIAN_GYM_TRAINER_0
	dw ViridianGymBattleText1 ; TextBeforeBattle
	dw ViridianGymAfterBattleText1 ; TextAfterBattle
	dw ViridianGymEndBattleText1 ; TextEndBattle
	dw ViridianGymEndBattleText1 ; TextEndBattle

ViridianGymTrainerHeader1: ; 74a14 (1d:4a14)
	dbEventFlagBit EVENT_BEAT_VIRIDIAN_GYM_TRAINER_1
	db ($4 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_VIRIDIAN_GYM_TRAINER_1
	dw ViridianGymBattleText2 ; TextBeforeBattle
	dw ViridianGymAfterBattleText2 ; TextAfterBattle
	dw ViridianGymEndBattleText2 ; TextEndBattle
	dw ViridianGymEndBattleText2 ; TextEndBattle

ViridianGymTrainerHeader2: ; 74a20 (1d:4a20)
	dbEventFlagBit EVENT_BEAT_VIRIDIAN_GYM_TRAINER_2
	db ($4 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_VIRIDIAN_GYM_TRAINER_2
	dw ViridianGymBattleText3 ; TextBeforeBattle
	dw ViridianGymAfterBattleText3 ; TextAfterBattle
	dw ViridianGymEndBattleText3 ; TextEndBattle
	dw ViridianGymEndBattleText3 ; TextEndBattle

ViridianGymTrainerHeader3: ; 74a2c (1d:4a2c)
	dbEventFlagBit EVENT_BEAT_VIRIDIAN_GYM_TRAINER_3
	db ($2 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_VIRIDIAN_GYM_TRAINER_3
	dw ViridianGymBattleText4 ; TextBeforeBattle
	dw ViridianGymAfterBattleText4 ; TextAfterBattle
	dw ViridianGymEndBattleText4 ; TextEndBattle
	dw ViridianGymEndBattleText4 ; TextEndBattle

ViridianGymTrainerHeader4: ; 74a38 (1d:4a38)
	dbEventFlagBit EVENT_BEAT_VIRIDIAN_GYM_TRAINER_4
	db ($4 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_VIRIDIAN_GYM_TRAINER_4
	dw ViridianGymBattleText5 ; TextBeforeBattle
	dw ViridianGymAfterBattleText5 ; TextAfterBattle
	dw ViridianGymEndBattleText5 ; TextEndBattle
	dw ViridianGymEndBattleText5 ; TextEndBattle

ViridianGymTrainerHeader5: ; 74a44 (1d:4a44)
	dbEventFlagBit EVENT_BEAT_VIRIDIAN_GYM_TRAINER_5
	db ($4 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_VIRIDIAN_GYM_TRAINER_5
	dw ViridianGymBattleText6 ; TextBeforeBattle
	dw ViridianGymAfterBattleText6 ; TextAfterBattle
	dw ViridianGymEndBattleText6 ; TextEndBattle
	dw ViridianGymEndBattleText6 ; TextEndBattle

ViridianGymTrainerHeader6: ; 74a50 (1d:4a50)
	dbEventFlagBit EVENT_BEAT_VIRIDIAN_GYM_TRAINER_6, 1
	db ($3 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_VIRIDIAN_GYM_TRAINER_6, 1
	dw ViridianGymBattleText7 ; TextBeforeBattle
	dw ViridianGymAfterBattleText7 ; TextAfterBattle
	dw ViridianGymEndBattleText7 ; TextEndBattle
	dw ViridianGymEndBattleText7 ; TextEndBattle

ViridianGymTrainerHeader7: ; 74a5c (1d:4a5c)
	dbEventFlagBit EVENT_BEAT_VIRIDIAN_GYM_TRAINER_7, 1
	db ($4 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_VIRIDIAN_GYM_TRAINER_7, 1
	dw ViridianGymBattleText8 ; TextBeforeBattle
	dw ViridianGymAfterBattleText8 ; TextAfterBattle
	dw ViridianGymEndBattleText8 ; TextEndBattle
	dw ViridianGymEndBattleText8 ; TextEndBattle

	db $ff

ViridianGymText1: ; 74a69 (1d:4a69)
	TX_ASM
	CheckEvent EVENT_BEAT_VIRIDIAN_GYM_GIOVANNI
	jr z, .asm_6de66
	CheckEventReuseA EVENT_GOT_TM27
	jr nz, .asm_9fc95
	call z, ViridianGymScript3_74995
	call DisableWaitingAfterTextDisplay
	jr .asm_6dff7
.asm_9fc95
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, ViridianGymText_74ad9
	call PrintText
	call GBFadeOutToBlack
	ld a, HS_VIRIDIAN_GYM_GIOVANNI
	ld [wMissableObjectIndex], a
	predef HideObject
	call UpdateSprites
	call Delay3
	call GBFadeInFromBlack
	jr .asm_6dff7
.asm_6de66
	ld hl, ViridianGymText_74ace
	call PrintText
	ld hl, wd72d
	set 6, [hl]
	set 7, [hl]
	ld hl, ViridianGymText_74ad3
	ld de, ViridianGymText_74ad3
	call SaveEndBattleTextPointers
	ld a, [H_SPRITEINDEX]
	ld [wSpriteIndex], a
	call EngageMapTrainer
	call InitBattleEnemyParameters
	ld a, $8
	ld [wGymLeaderNo], a
	ld a, $3
	ld [wViridianGymCurScript], a
.asm_6dff7
	jp TextScriptEnd

ViridianGymText_74ace: ; 74ace (1d:4ace)
	TX_FAR _ViridianGymText_74ace
	db "@"

ViridianGymText_74ad3: ; 74ad3 (1d:4ad3)
	TX_FAR _ViridianGymText_74ad3
	db $0b, "@"

ViridianGymText_74ad9: ; 74ad9 (1d:4ad9)
	TX_FAR _ViridianGymText_74ad9
	db $0d, "@"

ViridianGymText12: ; 74adf (1d:4adf)
	TX_FAR _ViridianGymText12
	db "@"

ViridianGymText13: ; 74ae4 (1d:4ae4)
	TX_FAR _ReceivedTM27Text
	db $0b

TM27ExplanationText: ; 74ae9 (1d:4ae9)
	TX_FAR _TM27ExplanationText
	db "@"

ViridianGymText14: ; 74aee (1d:4aee)
	TX_FAR _TM27NoRoomText
	db "@"

ViridianGymText2: ; 74af3 (1d:4af3)
	TX_ASM
	ld hl, ViridianGymTrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

ViridianGymBattleText1: ; 74afd (1d:4afd)
	TX_FAR _ViridianGymBattleText1
	db "@"

ViridianGymEndBattleText1: ; 74b02 (1d:4b02)
	TX_FAR _ViridianGymEndBattleText1
	db "@"

ViridianGymAfterBattleText1: ; 74b07 (1d:4b07)
	TX_FAR _ViridianGymAfterBattleText1
	db "@"

ViridianGymText3: ; 74b0c (1d:4b0c)
	TX_ASM
	ld hl, ViridianGymTrainerHeader1
	call TalkToTrainer
	jp TextScriptEnd

ViridianGymBattleText2: ; 74b16 (1d:4b16)
	TX_FAR _ViridianGymBattleText2
	db "@"

ViridianGymEndBattleText2: ; 74b1b (1d:4b1b)
	TX_FAR _ViridianGymEndBattleText2
	db "@"

ViridianGymAfterBattleText2: ; 74b20 (1d:4b20)
	TX_FAR _ViridianGymAfterBattleText2
	db "@"

ViridianGymText4: ; 74b25 (1d:4b25)
	TX_ASM
	ld hl, ViridianGymTrainerHeader2
	call TalkToTrainer
	jp TextScriptEnd

ViridianGymBattleText3: ; 74b2f (1d:4b2f)
	TX_FAR _ViridianGymBattleText3
	db "@"

ViridianGymEndBattleText3: ; 74b34 (1d:4b34)
	TX_FAR _ViridianGymEndBattleText3
	db "@"

ViridianGymAfterBattleText3: ; 74b39 (1d:4b39)
	TX_FAR _ViridianGymAfterBattleText3
	db "@"

ViridianGymText5: ; 74b3e (1d:4b3e)
	TX_ASM
	ld hl, ViridianGymTrainerHeader3
	call TalkToTrainer
	jp TextScriptEnd

ViridianGymBattleText4: ; 74b48 (1d:4b48)
	TX_FAR _ViridianGymBattleText4
	db "@"

ViridianGymBattleText_RhyhornCooltrainerRematch:
	TX_ASM
	CheckEvent EVENT_DO_RHYHORN_COOLTRAINER_ALT_TEXT
	ld hl, ViridianGymBattleText_RematchRegularText
	jr z, .gotText
	ld hl, ViridianGymBattleText_RematchAltText
.gotText
	call PrintText
	jp TextScriptEnd
	
ViridianGymBattleText_RematchRegularText:
	TX_FAR _ViridianGymBattleText_RematchRegularText
	db "@"

ViridianGymBattleText_RematchAltText:
	TX_FAR _ViridianGymBattleText_RematchAltText
	db "@"

ViridianGymBattleText_RhyhornCooltrainerLost:
	TX_FAR _ViridianGymBattleText_RhyhornCooltrainerLost
	db "@"

ViridianGymEndBattleText4: ; 74b4d (1d:4b4d)
	TX_FAR _ViridianGymEndBattleText4
	db "@"

ViridianGymAfterBattleText4: ; 74b52 (1d:4b52)
	TX_FAR _ViridianGymAfterBattleText4
	db "@"

ViridianGymText6: ; 74b57 (1d:4b57)
	TX_ASM
	ld hl, ViridianGymTrainerHeader4
	call TalkToTrainer
	jp TextScriptEnd

ViridianGymBattleText5: ; 74b61 (1d:4b61)
	TX_FAR _ViridianGymBattleText5
	db "@"

ViridianGymEndBattleText5: ; 74b66 (1d:4b66)
	TX_FAR _ViridianGymEndBattleText5
	db "@"

ViridianGymAfterBattleText5: ; 74b6b (1d:4b6b)
	TX_FAR _ViridianGymAfterBattleText5
	db "@"

ViridianGymText7: ; 74b70 (1d:4b70)
	TX_ASM
	ld hl, ViridianGymTrainerHeader5
	call TalkToTrainer
	jp TextScriptEnd

ViridianGymBattleText6: ; 74b7a (1d:4b7a)
	TX_FAR _ViridianGymBattleText6
	db "@"

ViridianGymEndBattleText6: ; 74b7f (1d:4b7f)
	TX_FAR _ViridianGymEndBattleText6
	db "@"

ViridianGymAfterBattleText6: ; 74b84 (1d:4b84)
	TX_FAR _ViridianGymAfterBattleText6
	db "@"

ViridianGymText8: ; 74b89 (1d:4b89)
	TX_ASM
	ld hl, ViridianGymTrainerHeader6
	call TalkToTrainer
	jp TextScriptEnd

ViridianGymBattleText7: ; 74b93 (1d:4b93)
	TX_FAR _ViridianGymBattleText7
	db "@"

ViridianGymEndBattleText7: ; 74b98 (1d:4b98)
	TX_FAR _ViridianGymEndBattleText7
	db "@"

ViridianGymAfterBattleText7: ; 74b9d (1d:4b9d)
	TX_FAR _ViridianGymAfterBattleText7
	db "@"

ViridianGymText9: ; 74ba2 (1d:4ba2)
	TX_ASM
	ld hl, ViridianGymTrainerHeader7
	call TalkToTrainer
	jp TextScriptEnd

ViridianGymBattleText8: ; 74bac (1d:4bac)
	TX_FAR _ViridianGymBattleText8
	db "@"

ViridianGymEndBattleText8: ; 74bb1 (1d:4bb1)
	TX_FAR _ViridianGymEndBattleText8
	db "@"

ViridianGymAfterBattleText8: ; 74bb6 (1d:4bb6)
	TX_FAR _ViridianGymAfterBattleText8
	db "@"

ViridianGymText10: ; 74bbb (1d:4bbb)
	TX_ASM
	CheckEvent EVENT_BEAT_VIRIDIAN_GYM_GIOVANNI
	jr nz, .asm_1abd1
	ld hl, ViridianGymText_74bd4
	call PrintText
	jr .asm_6064d
.asm_1abd1
	ld hl, ViridianGymText_74bd9
	call PrintText
.asm_6064d
	jp TextScriptEnd

ViridianGymText_74bd4: ; 74bd4 (1d:4bd4)
	TX_FAR _ViridianGymText_74bd4
	db "@"

ViridianGymText_74bd9: ; 74bd9 (1d:4bd9)
	TX_FAR _ViridianGymText_74bd9
	db "@"
