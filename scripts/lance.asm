LanceScript: ; 5a2ae (16:62ae)
	call LanceCheckForChampResets
	call LanceShowOrHideEntranceBlocks
	call EnableAutoTextBoxDrawing
	ld hl, LanceTrainerHeaders
	ld de, LanceScriptPointers
	ld a, [wLanceCurScript]
	call ExecuteCurMapScriptInTable
	ld [wLanceCurScript], a
	ret


	
LanceCheckForChampResets:
	ld hl, wCurrentMapScriptFlags
	bit 5, [hl]
	ret z
	
	ld a, SRAM_ENABLE
	ld [MBC1SRamEnable], a
	ld a, $1
	ld [MBC1SRamBankingMode], a
	ld [MBC1SRamBank], a
	ld a, [sNumChampionAttempts]
	ld b, a
	xor a
	ld [MBC1SRamEnable], a
	ld [MBC1SRamBankingMode], a
	ld [MBC1SRamBank], a
	
	ld a, b
	cp $3
    ld hl, LanceTextPointers + $4 ; starts at LanceShop
	jr nc, .setTP ; enable lance shop if 3+ tries
	ld hl, LanceTextPointers
.setTP
	ld a, l
	ld [wMapTextPtr], a
	ld a, h
	ld [wMapTextPtr+1], a
	ret c ; if not 3+ tries, we're now done
	
	SetEvent EVENT_UNLOCKED_LANCE_SHOP
	
    ld a, b
	cp $4
	ret nc ; only show the nag once
    
    ld a, $1
	ld [H_SPRITEINDEX], a
    ld a, [wYCoord]
    cp 1
	ld a, SPRITE_FACING_UP
    jr c, .setDirection ; player Y = 0, face up
    jr nz, .showText ; player Y >= 2, stay facing down
    ld a, SPRITE_FACING_LEFT
.setDirection
	ld [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
.showText
	ld a, $2
	ld [hSpriteIndexOrTextID], a
	jp DisplayTextID
	
	
	
LanceShowOrHideEntranceBlocks: ; 5a2c4 (16:62c4)
	ld hl, wCurrentMapScriptFlags
	bit 5, [hl]
	res 5, [hl]
	ret z
	CheckEvent EVENT_LANCES_ROOM_LOCK_DOOR
	jr nz, .closeEntrance
	; open entrance
	ld a, $31
	ld b, $32
	jp LanceSetEntranceBlocks
.closeEntrance
	ld a, $72
	ld b, $73

LanceSetEntranceBlocks: ; 5a2de (16:62de)
; Replaces the tile blocks so the player can't leave.
	push bc
	ld [wNewTileBlockID], a
	lb bc, 6, 2
	call LanceSetEntranceBlock
	pop bc
	ld a, b
	ld [wNewTileBlockID], a
	lb bc, 6, 3

LanceSetEntranceBlock: ; 5a2f0 (16:62f0)
	predef_jump ReplaceTileBlock

ResetLanceScript: ; 5a2f5 (16:62f5)
	xor a
	ld [wLanceCurScript], a
	ret

LanceScriptPointers: ; 5a2fa (16:62fa)
	dw LanceScript0
	dw DisplayEnemyTrainerTextAndStartBattle
	dw LanceScript2
	dw LanceScript3
	dw LanceScript4

LanceScript4: ; 5a304 (16:6304)
	ret

LanceScript0: ; 5a305 (16:6305)
	CheckEvent EVENT_BEAT_LANCE
	ret nz
	ld hl, LanceTriggerMovementCoords
	call ArePlayerCoordsInArray
	jp nc, CheckFightingMapTrainers
	xor a
	ld [hJoyHeld], a
	ld a, [wCoordIndex]
	cp $3  ; Is player standing next to Lance's sprite?
	jr nc, .notStandingNextToLance
	ld a, $1
	ld [hSpriteIndexOrTextID], a
	jp DisplayTextID
.notStandingNextToLance
	cp $5  ; Is player standing on the entrance staircase?
	jr z, WalkToLance
	CheckAndSetEvent EVENT_LANCES_ROOM_LOCK_DOOR
	ret nz
	ld hl, wCurrentMapScriptFlags
	set 5, [hl]
	ld a, SFX_GO_INSIDE
	call PlaySound
	jp LanceShowOrHideEntranceBlocks

LanceTriggerMovementCoords: ; 5a33e (16:633e)
	db $01,$05
	db $02,$06
	db $0B,$05
	db $0B,$06
	db $10,$18
	db $FF

LanceScript2: ; 5a349 (16:6349)
	call EndTrainerBattle
	ld a, [wIsInBattle]
	cp $ff
	jp z, ResetLanceScript
	ld a, $1
	ld [hSpriteIndexOrTextID], a
	jp DisplayTextID

WalkToLance: ; 5a35b (16:635b)
; Moves the player down the hallway to Lance's room.
	ld a, $ff
	ld [wJoyIgnore], a
	ld hl, wSimulatedJoypadStatesEnd
	ld de, WalkToLance_RLEList
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, $3
	ld [wLanceCurScript], a
	ld [wCurMapScript], a
	ret

WalkToLance_RLEList: ; 5a379 (16:6379)
	db D_UP, $0C
	db D_LEFT, $0C
	db D_DOWN, $07
	db D_LEFT, $06
	db $FF

LanceScript3: ; 5a382 (16:6382)
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	call Delay3
	xor a
	ld [wJoyIgnore], a
	ld [wLanceCurScript], a
	ld [wCurMapScript], a
	ret

LanceTextPointers: ; 5a395 (16:6395)
; Default Set
	dw LanceText1
	dw LanceText2
; Lance Shop Set (used in map script)
	dw LanceShopText
    dw LanceText2

LanceTrainerHeaders: ; 5a397 (16:6397)
LanceTrainerHeader0: ; 5a397 (16:6397)
	dbEventFlagBit EVENT_BEAT_LANCES_ROOM_TRAINER_0
	db ($0 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_LANCES_ROOM_TRAINER_0
	dw LanceBeforeBattleText ; TextBeforeBattle
	dw LanceAfterBattleText ; TextAfterBattle
	dw LanceEndBattleText ; TextEndBattle
	dw LanceEndBattleText ; TextEndBattle

	db $ff

LanceText1: ; 5a3a4 (16:63a4)
	TX_ASM
	ld hl, LanceTrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

LanceText2:
	TX_FAR _LanceText2
	db "@"

LanceBeforeBattleText: ; 5a3ae (16:63ae)
	TX_FAR _LanceBeforeBattleText
	db "@"

LanceEndBattleText: ; 5a3b3 (16:63b3)
	TX_FAR _LanceEndBattleText
	db "@"

LanceAfterBattleText: ; 5a3b8 (16:63b8)
	TX_FAR _LanceAfterBattleText
	TX_ASM
	SetEvent EVENT_BEAT_LANCE
	jp TextScriptEnd
