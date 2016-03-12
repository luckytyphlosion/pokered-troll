GaryScript: ; 75f1d (1d:5f1d)
	call EnableAutoTextBoxDrawing
	ld hl, GaryScriptPointers
	ld a, [wGaryCurScript]
	jp CallFunctionInTable

ResetGaryScript: ; 75f29 (1d:5f29)
	xor a
	ld [wJoyIgnore], a
	ld [wGaryCurScript], a
	ret

GaryScriptPointers: ; 75f31 (1d:5f31)
	dw GaryScript0
	dw GaryScript1
	dw GaryScript2
	dw GaryScript3
	dw GaryScript4
	dw GaryScript5
	dw GaryScript6
	dw GaryScript7
	dw GaryScript8

GaryScript0: ; 75f47 (1d:5f47)
	ret

GaryScript1: ; 75f48 (1d:5f48)
	ld a, $ff
	ld [wJoyIgnore], a
	ld hl, wSimulatedJoypadStatesEnd
	ld de, GaryEntrance_RLEMovement
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, $2
	ld [wGaryCurScript], a
	ret

GaryEntrance_RLEMovement: ; 75f63 (1d:5f63)
	db D_UP,4
	db $ff

GaryScript2: ; 75f6a (1d:5f6a)
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	call Delay3
	xor a
	ld [wJoyIgnore], a
	ld hl, wOptions
	res 7, [hl]  ; Turn on battle animations to make the battle feel more epic.
	
	call GaryScript_DoGiantConversation1
	
	ld hl, wd72d
	set 6, [hl]
	set 7, [hl]
	
	ld hl, GaryTextTrickyDefeated
	ld de, GaryTextTrickyDefeated
	call SaveEndBattleTextPointers
	ld a, OPP_SONY3
	ld [wCurOpponent], a

	; select which team to use during the encounter
	ld a, $1
	ld [wTrainerNo], a

	xor a
	ld [hJoyHeld], a
	ld a, $3
	ld [wGaryCurScript], a
	ret

GaryScript_DoGiantConversation2:
	ld hl, GaryScript_SpriteTurnData2
	lb bc, 16, 22
	jr GaryScript_ConversationContinue
	
GaryScript_DoGiantConversation1:
	ld hl, GaryScript_SpriteTurnData1
	lb bc, 1, 14
GaryScript_ConversationContinue:
	ld a, $f0
	ld [wJoyIgnore], a
.loop
	push bc
	push hl
	dec hl
	dec hl
	ld a, [hl]
	cp $3
	ld hl, wd730
	set 6, [hl]
	jr z, .trickyInstantText
	res 6, [hl]
.trickyInstantText
	ld a, b
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	
	pop hl
	ld a, [hli]
	ld [H_SPRITEINDEX], a
	ld a, [hli]
	ld [hSpriteFacingDirection], a
	push hl
	call SetSpriteFacingDirectionAndDelay
	pop hl
	pop bc
	inc b
	ld a, b
	cp c
	jr nz, .loop
	ld a, $ff
	ld [wJoyIgnore], a
	ret
	
	db 0, 0 ; padding
GaryScript_SpriteTurnData1:
	db $1, SPRITE_FACING_DOWN
	db $3, SPRITE_FACING_RIGHT
	db $1, SPRITE_FACING_LEFT
	db $3, SPRITE_FACING_RIGHT
	db $3, SPRITE_FACING_DOWN
	db $1, SPRITE_FACING_LEFT
	db $3, SPRITE_FACING_RIGHT
	db $3, SPRITE_FACING_DOWN
	db $1, SPRITE_FACING_LEFT
	db $1, SPRITE_FACING_DOWN
	db $3, SPRITE_FACING_RIGHT
	db $3, SPRITE_FACING_DOWN
	db $3, SPRITE_FACING_DOWN
	
	db 0, 0
GaryScript_SpriteTurnData2:
	db $2, SPRITE_FACING_UP
	db $2, SPRITE_FACING_LEFT
	db $3, SPRITE_FACING_RIGHT
	db $2, SPRITE_FACING_LEFT
	db $2, SPRITE_FACING_LEFT
	db $2, SPRITE_FACING_LEFT
	
	
GaryScript3: ; 75fbb (1d:5fbb)
	ld a, [wIsInBattle]
	cp $ff
	jp z, ResetGaryScript
	call UpdateSprites
	SetEvent EVENT_BEAT_CHAMPION_RIVAL
	ld a, $f0
	ld [wJoyIgnore], a
	ld a, 14
	ld [hSpriteIndexOrTextID], a
	ld hl, wd730
	set 6, [hl]
	push hl
	call GaryScript_760c8
	pop hl
	res 6, [hl]
	ld a, $3
	ld [H_SPRITEINDEX], a
	call SetSpriteMovementBytesToFF
	ld a, $4
	ld [wGaryCurScript], a
	ret

GaryScript4: ; 75fe4 (1d:5fe4)
	callba Music_Cities1AlternateTempo
	ld a, 15
	ld [hSpriteIndexOrTextID], a
	call GaryScript_760c8
	ld a, $2
	ld [H_SPRITEINDEX], a
	call SetSpriteMovementBytesToFF
	ld de, OakEntranceAfterVictoryMovement
	ld a, $2
	ld [H_SPRITEINDEX], a
	call MoveSprite
	ld a, HS_CHAMPIONS_ROOM_OAK
	ld [wMissableObjectIndex], a
	predef ShowObject
	ld a, $5
	ld [wGaryCurScript], a
	ret

OakEntranceAfterVictoryMovement: ; 76014 (1d:6014)
	db NPC_MOVEMENT_UP
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_UP
	db NPC_MOVEMENT_UP
	db NPC_MOVEMENT_UP
	db $FF

GaryScript5: ; 7601a (1d:601a)
	ld a, [wd730]
	bit 0, a
	ret nz
	
	ld a, PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
	
	xor a ; SPRITE_FACING_DOWN
	ld [hSpriteFacingDirection], a
	inc a
	ld [H_SPRITEINDEX], a
	call SetSpriteFacingDirectionAndDelay
	
	ld a, $2
	ld [H_SPRITEINDEX], a
	ld a, SPRITE_FACING_LEFT ; SPRITE_FACING_DOWN
	ld [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	
	ld a, $3
	ld [H_SPRITEINDEX], a
	ld a, SPRITE_FACING_RIGHT
	ld [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	
	call GaryScript_DoGiantConversation2

	ld de, OakExitGaryRoomMovement
	ld a, $2
	ld [H_SPRITEINDEX], a
	call MoveSprite
	ld a, $6
	ld [wGaryCurScript], a
	ret

OakExitGaryRoomMovement: ; 76080 (1d:6080)
	db NPC_MOVEMENT_UP
	db NPC_MOVEMENT_UP
	db $FF

GaryScript6: ; 76083 (1d:6083)
	ld a, [wd730]
	bit 0, a
	ret nz
	ld a, HS_CHAMPIONS_ROOM_OAK
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, $7
	ld [wGaryCurScript], a
	ret

GaryScript7: ; 76099 (1d:6099)
	ld a, $ff
	ld [wJoyIgnore], a
	ld hl, wSimulatedJoypadStatesEnd
	ld de, WalkToHallOfFame_RLEMovment
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, $8
	ld [wGaryCurScript], a
	ret

WalkToHallOfFame_RLEMovment: ; 760b4 (1d:60b4)
	db D_UP,4
	db $ff

GaryScript8: ; 760b9 (1d:60b9)
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	xor a
	ld [wJoyIgnore], a
	ld [wGaryCurScript], a
	ret

GaryScript_760c8: ; 760c8 (1d:60c8)
	ld a, $f0
	ld [wJoyIgnore], a
	call DisplayTextID
	ld a, $ff
	ld [wJoyIgnore], a
	ret

GaryTextPointers: ; 760d6 (1d:60d6)
	dw GaryTextLostToTricky
	dw GaryChampionIntroText
	dw GaryTextTrickyIntro
	dw GaryTextStopTalkingTooFast
	dw GaryTextBeingFastIsHowIGo
	dw GaryTextTrickyMonologue
	dw GaryTextHey
	dw GaryTextMonologueContinued
	dw GaryTextMonologueContinued2
	dw GaryTextSarcasticReply
	dw GaryTextEncouragementToPlayer
	dw GaryTextHeyRude
	dw GaryTextDoBattleNow
	dw GaryTextTrickyAmazed
	dw GaryTextOakAppears
	dw GaryTextAppplaudPlayer
	dw GaryTextCriticizeRival
	dw GaryText_TrickyCalledOut
	dw GaryTextTrickyWhat
	dw GaryText_JustKidding
	dw GaryText_CongratulatePlayer
	
GaryTextLostToTricky: ; 760e0 (1d:60e0)
	TX_FAR _GaryTextLostToTricky
	db "@"

GaryChampionIntroText: ; 760f4 (1d:60f4)
	TX_FAR _GaryChampionIntroText
	db "@"

GaryTextTrickyIntro:
	TX_FAR _GaryTextTrickyIntro
	db "@"

GaryTextStopTalkingTooFast:
	TX_FAR _GaryTextStopTalkingTooFast
	db "@"

GaryTextBeingFastIsHowIGo:
	TX_FAR _GaryTextBeingFastIsHowIGo
	db "@"

GaryTextTrickyMonologue:
	TX_FAR _GaryTextTrickyMonologue
	db "@"

GaryTextHey:
	TX_FAR _GaryTextHey
	db "@"
	
GaryTextMonologueContinued:
	TX_FAR _GaryTextMonologueContinued
	db "@"
	
GaryTextMonologueContinued2:
	TX_FAR _GaryTextMonologueContinued2
	db "@"

GaryTextSarcasticReply:
	TX_FAR _GaryTextSarcasticReply
	db "@"

GaryTextEncouragementToPlayer:
	TX_FAR _GaryTextEncouragementToPlayer
	db "@"
	
GaryTextHeyRude:
	TX_FAR _GaryTextHeyRude
	db "@"
	
GaryTextDoBattleNow:
	TX_FAR _GaryTextDoBattleNow
	db "@"
	
GaryTextTrickyDefeated:
	TX_FAR _GaryTextTrickyDefeated
	db "@"

GaryTextTrickyAmazed:
	TX_FAR _GaryTextTrickyAmazed
	db "@"
	
GaryTextOakAppears:
	TX_FAR _GaryTextOakAppears
	db "@"
	
GaryTextAppplaudPlayer:
	TX_ASM
	ld a, [wPlayerStarter]
	ld [wd11e], a
	call GetMonName
	ld hl, GaryText_76120
	call PrintText
	jp TextScriptEnd
	
GaryText_76120:
	TX_FAR _GaryTextAppplaudPlayer
	db "@"
	
GaryTextCriticizeRival:
	TX_FAR _GaryTextCriticizeRival
	db "@"
	
GaryText_TrickyCalledOut:
	TX_FAR _GaryText_TrickyCalledOut
	db "@"

GaryTextTrickyWhat:
	TX_FAR _GaryTextTrickyWhat
	db "@"
	
GaryText_JustKidding:
	TX_FAR _GaryText_JustKidding
	db "@"
	
GaryText_CongratulatePlayer:
	TX_FAR _GaryText_CongratulatePlayer
	db "@"
