Mansion4Script: ; 523b9 (14:63b9)
	call Mansion4Script_523cf
	CheckEvent EVENT_STEPPED_ON_RATICATE_TILE
	jr nz, .notRaticateTile
	ld a, [wYCoord]
	cp 26
	jr nz, .notRaticateTile
	ld a, [wXCoord]
	cp 18
	jr nz, .notRaticateTile
; raticate tile
; shoutouts to yellow
	ld a, RATICATE
	ld [wCurOpponent], a
	ld a, 46
	ld [wCurEnemyLVL], a
	ld a, $1
	ld [wInescapeableBattle], a
	SetEvent EVENT_STEPPED_ON_RATICATE_TILE
	ld hl, wd732
	set 7, [hl]
.notRaticateTile
	call EnableAutoTextBoxDrawing
	ld hl, Mansion4TrainerHeader0
	ld de, Mansion4ScriptPointers
	ld a, [wMansion4CurScript]
	call ExecuteCurMapScriptInTable
	ld [wMansion4CurScript], a
	ret

Mansion4Script_523cf: ; 523cf (14:63cf)
	ld hl, wCurrentMapScriptFlags
	bit 5, [hl]
	res 5, [hl]
	ret z
	CheckEvent EVENT_MANSION_SWITCH_ON
	jr nz, .asm_523ff
	ld a, $e
	ld bc, $80d
	call Mansion2Script_5202f
	ld a, $e
	ld bc, $b06
	call Mansion2Script_5202f
	ld a, $5f
	ld bc, $304
	call Mansion2Script_5202f
	ld a, $54
	ld bc, $808
	call Mansion2Script_5202f
	ret
.asm_523ff
	ld a, $2d
	ld bc, $80d
	call Mansion2Script_5202f
	ld a, $5f
	ld bc, $b06
	call Mansion2Script_5202f
	ld a, $e
	ld bc, $304
	call Mansion2Script_5202f
	ld a, $e
	ld bc, $808
	call Mansion2Script_5202f
	ret

Mansion4Script_Switches: ; 52420 (14:6420)
	ld a, [wSpriteStateData1 + 9]
	cp SPRITE_FACING_UP
	ret nz
	xor a
	ld [hJoyHeld], a
	ld a, $9
	ld [hSpriteIndexOrTextID], a
	jp DisplayTextID

Mansion4ScriptPointers: ; 52430 (14:6430)
	dw CheckFightingMapTrainers
	dw DisplayEnemyTrainerTextAndStartBattle
	dw EndTrainerBattle

Mansion4TextPointers: ; 52436 (14:6436)
	dw Mansion4Text1
	dw Mansion4Text2
	dw PickUpItemText
	dw PickUpItemText
	dw PickUpItemText
	dw PickUpItemText
	dw Mansion4Text7
	dw PickUpItemText
	dw Mansion3Text6

Mansion4TrainerHeaders: ; 52448 (14:6448)
Mansion4TrainerHeader0: ; 52448 (14:6448)
	dbEventFlagBit EVENT_BEAT_MANSION_4_TRAINER_0
	db ($0 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_MANSION_4_TRAINER_0
	dw Mansion4BattleText1 ; TextBeforeBattle
	dw Mansion4AfterBattleText1 ; TextAfterBattle
	dw Mansion4EndBattleText1 ; TextEndBattle
	dw Mansion4EndBattleText1 ; TextEndBattle

Mansion4TrainerHeader2: ; 52454 (14:6454)
	dbEventFlagBit EVENT_BEAT_MANSION_4_TRAINER_2
	db ($3 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_MANSION_4_TRAINER_2
	dw Mansion4BattleText2 ; TextBeforeBattle
	dw Mansion4AfterBattleText2 ; TextAfterBattle
	dw Mansion4EndBattleText2 ; TextEndBattle
	dw Mansion4EndBattleText2 ; TextEndBattle

	db $ff

Mansion4Text1: ; 52461 (14:6461)
	TX_ASM
	ld hl, Mansion4TrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

Mansion4Text2: ; 5246b (14:646b)
	TX_ASM
	ld hl, Mansion4TrainerHeader2
	call TalkToTrainer
	jp TextScriptEnd

Mansion4BattleText1: ; 52475 (14:6475)
	TX_FAR _Mansion4BattleText1
	db "@"

Mansion4EndBattleText1: ; 5247a (14:647a)
	TX_FAR _Mansion4EndBattleText1
	db "@"

Mansion4AfterBattleText1: ; 5247f (14:647f)
	TX_FAR _Mansion4AfterBattleText1
	db "@"

Mansion4BattleText2: ; 52484 (14:6484)
	TX_FAR _Mansion4BattleText2
	db "@"

Mansion4EndBattleText2: ; 52489 (14:6489)
	TX_FAR _Mansion4EndBattleText2
	db "@"

Mansion4AfterBattleText2: ; 5248e (14:648e)
	TX_FAR _Mansion4AfterBattleText2
	db "@"

Mansion4Text7: ; 52493 (14:6493)
	TX_FAR _Mansion4Text7
	db "@"
