IndigoPlateauLobbyScript: ; 19c5b (6:5c5b)
	call Serial_TryEstablishingExternallyClockedConnection
	call EnableAutoTextBoxDrawing
	call IndigoPlateauLobby_ResetVictoryRoadAndElite4Events

	ld a, [wIndigoPlateauLobbyCurScript]
	ld hl, IndigoPlateauLobbyScriptPointers
	jp CallFunctionInTable
	
	
IndigoPlateauLobby_ResetVictoryRoadAndElite4Events:
	ld hl, wCurrentMapScriptFlags
	bit 6, [hl]
	res 6, [hl]
	ret z
	ResetEvent EVENT_VICTORY_ROAD_1_BOULDER_ON_SWITCH
	ld hl, wBeatLorelei
	bit 1, [hl]
	res 1, [hl]
	ret z
	; Elite 4 events
	ResetEventRange ELITE4_EVENTS_START, EVENT_LANCES_ROOM_LOCK_DOOR
	ret

IndigoPlateauLobbyScript0:
	ld a, D_DOWN | D_UP | D_LEFT | D_RIGHT | START | SELECT
	ld [wJoyIgnore], a
	ld a, $6
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	ld c, 30
	call DelayFrames
	ld a, HS_INDIGO_PLATEAU_LOBBY_RAGEQUIT_GUY
	ld [wMissableObjectIndex], a
	predef ShowObject
	
	ld a, $6
	ld [H_SPRITEINDEX], a
	call SetSpriteMovementBytesToFF
	ld de, IndigoPlateauLobby_RagequitGuyMovement1
	call MoveSprite
	
	ld a, $1
	ld [wIndigoPlateauLobbyCurScript], a
	ret
	
IndigoPlateauLobbyScript1:
	ld a, [wd730]
	bit 0, a
	ret nz
	ld a, D_DOWN | D_UP | D_LEFT | D_RIGHT | START | SELECT
	ld [wJoyIgnore], a
	
	ld a, $6
	ld [H_SPRITEINDEX], a
	ld a, SPRITE_FACING_UP
	ld [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	ld c, 14
	call DelayFrames
	ld a, $7
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	
	ld a, $6
	ld [H_SPRITEINDEX], a
	call SetSpriteMovementBytesToFF
	ld de, IndigoPlateauLobby_RagequitGuyMovement2
	call MoveSprite
	
	ld a, $2
	ld [wIndigoPlateauLobbyCurScript], a
	ret
	
IndigoPlateauLobbyScript2:
	ld a, [wd730]
	bit 0, a
	ret nz
	
	ld a, HS_INDIGO_PLATEAU_LOBBY_RAGEQUIT_GUY
	ld [wMissableObjectIndex], a
	predef HideObject
	
	ld hl, wXItemQuantitiesAtIndigoPlateau
	lb de, 4, X_ATTACK
.loop
	push hl
	ld b, e
	predef GetQuantityOfItemInBag
	pop hl
	ld a, b
	ld [hli], a
	inc e
	dec d
	jr nz, .loop
	ld b, X_ACCURACY
	push hl
	predef GetQuantityOfItemInBag
	pop hl
	ld [hl], b
	
	xor a
	ld [wJoyIgnore], a
	ld a, $3
	ld [wIndigoPlateauLobbyCurScript], a
	ret
	
IndigoPlateauLobbyScript3:
	ld a, [wYCoord]
	cp 2
	ret nz
	ld a, [wXCoord]
	cp 5
	ret nz
	CheckAndSetEvent EVENT_TALKED_TO_E4_RAGEQUIT_GUY
	ret nz
	ld a, $8
	ld [hSpriteIndexOrTextID], a
	jp DisplayTextID
	
IndigoPlateauLobby_RagequitGuyMovement2:
	db NPC_MOVEMENT_RIGHT
	
IndigoPlateauLobby_RagequitGuyMovement1:
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_DOWN
	db $ff

IndigoPlateauLobbyScriptPointers:
	dw IndigoPlateauLobbyScript0
	dw IndigoPlateauLobbyScript1
	dw IndigoPlateauLobbyScript2
	dw IndigoPlateauLobbyScript3
	
IndigoPlateauLobbyTextPointers: ; 19c7f (6:5c7f)
	dw IndigoPlateauLobbyText1
	dw IndigoPlateauLobbyText2
	dw IndigoPlateauLobbyText3
	dw IndigoPlateauLobbyText4
	dw IndigoPlateauLobbyText5
	dw IndigoPlateauLobbyText6
	dw IndigoPlateauLobbyText7
	dw IndigoPlateauLobbyText8
	
IndigoPlateauLobbyText1: ; 19c89 (6:5c89)
	db $ff

IndigoPlateauLobbyText2: ; 19c8a (6:5c8a)
	TX_FAR _IndigoPlateauLobbyText1
	db "@"

IndigoPlateauLobbyText3: ; 19c8f (6:5c8f)
	TX_ASM
	CheckEvent EVENT_TALKED_TO_E4_RAGEQUIT_GUY
	ld hl, IndigoPlateauLobbyText3_1
	ret z
	
	ld a, [wRagequitGuySisterFlags]
	add a
	ld e, a
	ld d, $0
	ld hl, IndigoPlateauLobbyRagequitGuySisterTextPointers2
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call PrintText
	jp TextScriptEnd
	
IndigoPlateauLobbyText3_1:
	TX_FAR _IndigoPlateauLobbyText3
	db "@"
	
IndigoPlateauLobbyRagequitGuySisterTextPointers2:
	dw RagequitGuySisterText5
	dw RagequitGuySisterText6
	dw RagequitGuySisterText7
	dw RagequitGuySisterText8

RagequitGuySisterText5:
	TX_FAR _RagequitGuySisterText5
	db "@"
	
RagequitGuySisterText6:
	TX_FAR _RagequitGuySisterText6
	db "@"
	
RagequitGuySisterText7:
	TX_FAR _RagequitGuySisterText7
	db "@"

RagequitGuySisterText8:
	TX_FAR _RagequitGuySisterText8
	db "@"

IndigoPlateauLobbyText5: ; 19c94 (6:5c94)
	db $f6

IndigoPlateauLobbyText6:
	TX_FAR _IndigoPlateauLobbyText6
	db "@"

IndigoPlateauLobbyText7:
	TX_FAR _IndigoPlateauLobbyText7
	db "@"
	
IndigoPlateauLobbyText8:
	TX_ASM
	ld hl, wXItemQuantitiesAtIndigoPlateau
	lb de, 4, X_ATTACK
	xor a
	ld [wRagequitGuySisterFlags], a
.checkCurrentBagQuantitiesLoop
	push hl
	ld b, e
	predef GetQuantityOfItemInBag
	pop hl
	call SetFlagsBasedOnXItemQuantity
	inc e
	dec d
	jr nz, .checkCurrentBagQuantitiesLoop
	
	ld b, X_ACCURACY
	push hl
	predef GetQuantityOfItemInBag
	pop hl
	call SetFlagsBasedOnXItemQuantity
	ld a, [wRagequitGuySisterFlags]
	add a
	ld e, a
	ld d, $0
	ld hl, IndigoPlateauLobbyRagequitGuySisterTextPointers1
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call PrintText
	jp TextScriptEnd

IndigoPlateauLobbyRagequitGuySisterTextPointers1:
	dw RagequitGuySisterText1
	dw RagequitGuySisterText2
	dw RagequitGuySisterText3
	dw RagequitGuySisterText4

RagequitGuySisterText1:
	TX_FAR _RagequitGuySisterText1
	db "@"
	
RagequitGuySisterText2:
	TX_FAR _RagequitGuySisterText2
	db "@"

RagequitGuySisterText3:
	TX_FAR _RagequitGuySisterText3
	db "@"

RagequitGuySisterText4:
	TX_FAR _RagequitGuySisterText4
	db "@"

SetFlagsBasedOnXItemQuantity:
	ld a, [hli]
	cp b
	ret z
	jr nc, .soldItem
; bought item
	ld a, [wRagequitGuySisterFlags]
	set 0, a
	ld [wRagequitGuySisterFlags], a
	ret
.soldItem
	ld a, [wRagequitGuySisterFlags]
	set 1, a
	ld [wRagequitGuySisterFlags], a
	ret