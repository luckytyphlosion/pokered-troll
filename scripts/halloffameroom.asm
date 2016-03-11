HallofFameRoomScript: ; 5a49e (16:649e)
	call EnableAutoTextBoxDrawing
	ld hl, HallofFameRoomScriptPointers
	ld a, [wHallOfFameRoomCurScript]
	jp CallFunctionInTable

HallofFameRoomScript_5a4aa: ; 5a4aa (16:64aa)
	xor a
	ld [wJoyIgnore], a
	ld [wHallOfFameRoomCurScript], a
	ret

HallofFameRoomScriptPointers: ; 5a4b2 (16:64b2)
	dw HallofFameRoomScript0
	dw HallofFameRoomScript1
	dw HallofFameRoomScript2
	dw HallofFameRoomScript3
    dw HallofFameRoomScript4
    
HallofFameRoomScript2:
	ld a, $2
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
    ld a, $ff
	ld [wJoyIgnore], a
	ld a, HS_UNKNOWN_DUNGEON_GUY
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, $3
	ld [wHallOfFameRoomCurScript], a
	ret

HallofFameRoomScript4: ; 5a4ba (16:64ba)
	ret

HallofFameRoomScript3: ; 5a4bb (16:64bb)
	call Delay3
	ld a, [wLetterPrintingDelayFlags]
	push af
	xor a
	ld [wJoyIgnore], a
	predef HallOfFamePC
	pop af
	ld [wLetterPrintingDelayFlags], a
	ld hl, wFlags_D733
	res 1, [hl]
	inc hl
	set 0, [hl]
	xor a
	ld hl, wLoreleiCurScript
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld [wLanceCurScript], a
	ld [wHallOfFameRoomCurScript], a
	; Elite 4 events
	ResetEventRange ELITE4_EVENTS_START, ELITE4_CHAMPION_EVENTS_END, 1
	xor a
	ld [wHallOfFameRoomCurScript], a
	ld a, PALLET_TOWN
	ld [wLastBlackoutMap], a
	callba SaveSAVtoSRAM
	ld b, 5
.delayLoop
	ld c, 600 / 5
	call DelayFrames
	dec b
	jr nz, .delayLoop
	call WaitForTextScrollButtonPress
	jp Init

HallofFameRoomScript0: ; 5a50d (16:650d)
	ld a, $ff
	ld [wJoyIgnore], a
	ld hl, wSimulatedJoypadStatesEnd
	ld de, RLEMovement5a528
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, $1
	ld [wHallOfFameRoomCurScript], a
	ret

RLEMovement5a528: ; 5a528 (16:6528)
	db D_UP,$5
	db $ff

HallofFameRoomScript1: ; 5a52b (16:652b)
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	ld a, PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
	ld a, $1
	ld [H_SPRITEINDEX], a
	call SetSpriteMovementBytesToFF
	ld a, SPRITE_FACING_LEFT
	ld [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	call Delay3
	xor a
	ld [wJoyIgnore], a
	inc a ; PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
    ld a, $1
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
    predef HealParty
	ld hl, wd72d
	set 6, [hl]
	set 7, [hl]
	ld hl, OakDefeatedText
	ld de, OakVictoryText
	call SaveEndBattleTextPointers
	ld a, OPP_PROF_OAK
	ld [wCurOpponent], a
	ld a, 4
	ld [wTrainerNo], a
	xor a
	ld [hJoyHeld], a
	ld a, $2
	ld [wHallOfFameRoomCurScript], a
	ret

HallofFameRoomTextPointers: ; 5a56a (16:656a)
	dw HallofFameRoomText1
    dw HallofFameRoomText2

HallofFameRoomText1: ; 5a56c (16:656c)
	TX_FAR _HallofFameRoomText1
	db "@"
    
HallofFameRoomText2: ; 5a56c (16:656c)
	TX_FAR _HallofFameRoomText2
	db "@"

OakDefeatedText: ; 760f9 (1d:60f9)
	TX_FAR _OakDefeatedText
	db "@"

OakVictoryText: ; 760fe (1d:60fe)
	TX_FAR _OakVictoryText
	db "@"