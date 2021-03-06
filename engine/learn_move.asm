LearnMove: ; 6e43 (1:6e43)
	call SaveScreenTilesToBuffer1
	ld a, [wWhichPokemon]
	ld hl, wPartyMonNicks
	call GetPartyMonName
	ld hl, wcd6d
	ld de, wLearnMoveMonName
	ld bc, NAME_LENGTH
	call CopyData

DontAbandonLearning: ; 6e5b (1:6e5b)
	ld hl, wPartyMon1Moves
	ld bc, wPartyMon2Moves - wPartyMon1Moves
	ld a, [wWhichPokemon]
	call AddNTimes
	ld d, h
	ld e, l
	ld b, NUM_MOVES
.findEmptyMoveSlotLoop
	ld a, [hl]
	and a
	jr z, .next
	inc hl
	dec b
	jr nz, .findEmptyMoveSlotLoop
	push de
	call TryingToLearn
	pop de
	jp c, AbandonLearning
	push hl
	push de
	ld [wd11e], a
	call GetMoveName
	ld hl, OneTwoAndText
	call PrintText
	pop de
	pop hl
.next
	ld a, [wMoveNum]
	inc a
	jp z, .unlearnCut
	dec a
	ld [hl], a
	ld bc, wPartyMon1PP - wPartyMon1Moves
	add hl, bc
	push hl
	push de
	dec a
	ld hl, Moves
	ld bc, MoveEnd - Moves
	call AddNTimes
	ld de, wBuffer
	ld a, BANK(Moves)
	call FarCopyData
	ld a, [wBuffer + 5] ; a = move's max PP
	pop de
	pop hl
	ld [hl], a
	ld a, [wIsInBattle]
	and a
	jp z, PrintLearnedMove
	ld a, [wWhichPokemon]
	ld b, a
	ld a, [wPlayerMonNumber]
	cp b
	jp nz, PrintLearnedMove
	ld h, d
	ld l, e
	ld de, wBattleMonMoves
	ld bc, NUM_MOVES
	call CopyData
	ld bc, wPartyMon1PP - wPartyMon1OTID
	add hl, bc
	ld de, wBattleMonPP
	ld bc, NUM_MOVES
	call CopyData
	jp PrintLearnedMove
.unlearnCut
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	ld a, [wWhichPokemon]
	call AddNTimes
	push hl
	ld bc, wPartyMon1PP - wPartyMon1
	add hl, bc
	ld d, h
	ld e, l
	pop hl
	ld bc, wPartyMon1Moves - wPartyMon1
	add hl, bc
	ld c, NUM_MOVES
.findCutLoop
	dec c
	jr z, .cutFourthMove
	ld a, [hli]
	inc de
	cp CUT
	jr nz, .findCutLoop
.shiftMovesLoop
	ld a, [hld]
	ld [hli], a
	inc hl
	ld a, [de]
	dec de
	ld [de], a
	inc de
	inc de
	dec c
	jr nz, .shiftMovesLoop
	dec hl
	dec de
.cutFourthMove
	xor a
	ld [de], a
	ld [hl], a
	
	ld hl, BlastoiseLearnedNothingText
	call PrintText
	ld b, 1
	ret
	
AbandonLearning: ; 6eda (1:6eda)
	ld a, [wMoveNum]
	inc a
	ld hl, AbandonLearningText
	jr nz, .notUnlearningCut
	ld hl, UnabandonLearningText
.notUnlearningCut
	call PrintText
	coord hl, 14, 7
	lb bc, 8, 15
	ld a, TWO_OPTION_MENU
	ld [wTextBoxID], a
	call DisplayTextBoxID ; yes/no menu
	ld a, [wCurrentMenuItem]
	and a
	jp nz, DontAbandonLearning
	ld a, [wMoveNum]
	inc a
	jr nz, .didNotLearn
	ld hl, AreYouSureText
	jr .notUnlearningCut
.didNotLearn
	ld hl, DidNotLearnText
	call PrintText
	ld b, 0
	ret

PrintLearnedMove: ; 6efe (1:6efe)
	ld hl, LearnedMove1Text
	call PrintText
	ld b, 1
	ret

TryingToLearn: ; 6f07 (1:6f07)
	push hl
	ld a, [wMoveNum]
	inc a
	ld hl, BlastoiseTryingToKeepCutText
	jr z, .notNidokingLearningCut
	ld a, [wcf91]
	cp NIDOKING
	ld hl, TryingToLearnText
	jr nz, .notNidokingLearningCut
	ld a, [wMoveNum]
	cp CUT
	jr nz, .notNidokingLearningCut
; troll cut message
	ld hl, NidokingTryingToLearnCutText
.notNidokingLearningCut
	call PrintText
	coord hl, 14, 7
	lb bc, 8, 15
	ld a, TWO_OPTION_MENU
	ld [wTextBoxID], a
	call DisplayTextBoxID ; yes/no menu
	pop hl
	ld a, [wCurrentMenuItem]
	rra
	ret c
	ld a, [wMoveNum]
	inc a
	jr nz, .notUnlearnCut
	ld a, CUT
	and a
	ret
.notUnlearnCut
	ld bc, -NUM_MOVES
	add hl, bc
	push hl
	ld de, wMoves
	ld bc, NUM_MOVES
	call CopyData
	callab FormatMovesString
	pop hl
.loop
	push hl
	ld hl, WhichMoveToForgetText
	call PrintText
	coord hl, 4, 7
	ld b, 4
	ld c, 14
	call TextBoxBorder
	coord hl, 6, 8
	ld de, wMovesString
	ld a, [hFlags_0xFFF6]
	set 2, a
	ld [hFlags_0xFFF6], a
	call PlaceString
	ld a, [hFlags_0xFFF6]
	res 2, a
	ld [hFlags_0xFFF6], a
	ld hl, wTopMenuItemY
	ld a, 8
	ld [hli], a ; wTopMenuItemY
	ld a, 5
	ld [hli], a ; wTopMenuItemX
	xor a
	ld [hli], a ; wCurrentMenuItem
	inc hl
	ld a, [wNumMovesMinusOne]
	ld [hli], a ; wMaxMenuItem
	ld a, A_BUTTON | B_BUTTON
	ld [hli], a ; wMenuWatchedKeys
	ld [hl], 0 ; wLastMenuItem
	ld hl, hFlags_0xFFF6
	set 1, [hl]
	call HandleMenuInput
	ld hl, hFlags_0xFFF6
	res 1, [hl]
	push af
	call LoadScreenTilesFromBuffer1
	pop af
	pop hl
	bit 1, a ; pressed b
	jr nz, .cancel
	push hl
	ld a, [wCurrentMenuItem]
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	push af
	push bc
	call IsMoveHM
	pop bc
	pop de
	ld a, d
	jr c, .hm
	pop hl
	add hl, bc
	and a
	ret
.hm
	ld hl, HMCantDeleteText
	call PrintText
	pop hl
	jr .loop
.cancel
	scf
	ret

BlastoiseTryingToKeepCutText:
	TX_FAR _BlastoiseTryingToKeepCutText
	db "@"

NidokingTryingToLearnCutText:
	TX_FAR _NidokingTryingToLearnCutText
	db "@"

LearnedMove1Text: ; 6fb4 (1:6fb4)
	TX_FAR _LearnedMove1Text
	db $b,6,"@"

WhichMoveToForgetText: ; 6fb4 (1:6fb4)
	TX_FAR _WhichMoveToForgetText
	db "@"

AbandonLearningText: ; 6fb9 (1:6fb9)
	TX_FAR _AbandonLearningText
	db "@"

UnabandonLearningText:
	TX_FAR _UnabandonLearningText
	db "@"
	
AreYouSureText:
	TX_FAR _AreYouSureText
	db "@"

BlastoiseLearnedNothingText:
	TX_FAR _BlastoiseLearnedNothingText
	db "@"
	
DidNotLearnText: ; 6fbe (1:6fbe)
	TX_FAR _DidNotLearnText
	db "@"

TryingToLearnText: ; 6fc3 (1:6fc3)
	TX_FAR _TryingToLearnText
	db "@"

OneTwoAndText: ; 6fc8 (1:6fc8)
	TX_FAR _OneTwoAndText
	db $a
	TX_ASM
	ld a, SFX_SWAP
	call PlaySoundWaitForCurrent
	ld hl, PoofText
	ret

PoofText: ; 6fd7 (1:6fd7)
	TX_FAR _PoofText
	db $a
ForgotAndText: ; 6fdc (1:6fdc)
	TX_FAR _ForgotAndText
	db "@"

HMCantDeleteText: ; 6fe1 (1:6fe1)
	TX_FAR _HMCantDeleteText
	db "@"
