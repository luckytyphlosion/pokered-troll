PrintNewBikeText: ; 1e94b (7:694b)
	call EnableAutoTextBoxDrawing
	tx_pre_jump NewBicycleText

NewBicycleText: ; 1e953 (7:6953)
	TX_FAR _NewBicycleText
	db "@"

DisplayOakLabLeftPoster: ; 1e958 (7:6958)
	call EnableAutoTextBoxDrawing
	tx_pre_jump PushStartText

PushStartText: ; 1e960 (7:6960)
	TX_FAR _PushStartText
	db "@"

DisplayOakLabRightPoster: ; 1e965 (7:6965)
	call EnableAutoTextBoxDrawing
	ld hl, wPokedexOwned
	ld b, wPokedexOwnedEnd - wPokedexOwned
	call CountSetBits
	ld a, [wNumSetBits]
	cp 2
	tx_pre_id SaveOptionText
	jr c, .ownLessThanTwo
	; own two or more mon
	tx_pre_id StrengthsAndWeaknessesText
.ownLessThanTwo
	jp PrintPredefTextID

SaveOptionText: ; 1e97e (7:697e)
	TX_FAR _SaveOptionText
	db "@"

StrengthsAndWeaknessesText: ; 1e983 (7:6983)
	TX_FAR _StrengthsAndWeaknessesText
	db "@"

SafariZoneCheck: ; 1e988 (7:6988)
	CheckEventHL EVENT_IN_SAFARI_ZONE ; if we are not in the Safari Zone,
	jr z, SafariZoneGameStillGoing ; don't bother printing game over text
	ld a, [wNumSafariBalls]
	and a
	jr z, SafariZoneGameOver
	jr SafariZoneGameStillGoing

SafariZoneCheckSteps: ; 1e997 (7:6997)
	ld a, [wSafariSteps]
	ld b, a
	ld a, [wSafariSteps + 1]
	ld c, a
	or b
	jr z, SafariZoneGameOver
	dec bc
	ld a, b
	ld [wSafariSteps], a
	ld a, c
	ld [wSafariSteps + 1], a
SafariZoneGameStillGoing: ; 1e9ab (7:69ab)
	xor a
	ld [wSafariZoneGameOver], a
	ret

SafariZoneGameOver: ; 1e9b0 (7:69b0)
	call EnableAutoTextBoxDrawing
	xor a
	ld [wAudioFadeOutControl], a
	dec a
	call PlaySound
	ld c, BANK(SFX_Safari_Zone_PA)
	ld a, SFX_SAFARI_ZONE_PA
	call PlayMusic
.asm_1e9c2
	ld a, [wChannelSoundIDs + CH4]
	cp $b9
	jr nz, .asm_1e9c2
	ld a, TEXT_SAFARI_GAME_OVER
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	xor a
	ld [wPlayerMovingDirection], a
	ld a, SAFARI_ZONE_ENTRANCE
	ld [hWarpDestinationMap], a
	ld a, $3
	ld [wDestinationWarpID], a
	ld a, $5
	ld [wSafariZoneEntranceCurScript], a
	SetEvent EVENT_SAFARI_GAME_OVER
	ld a, 1
	ld [wSafariZoneGameOver], a
	ret

PrintSafariGameOverText: ; 1e9ed (7:69ed)
	xor a
	ld [wJoyIgnore], a
	ld hl, SafariGameOverText
	jp PrintText

SafariGameOverText: ; 1e9f7 (7:69f7)
	TX_ASM
	ld a, [wNumSafariBalls]
	and a
	jr z, .asm_1ea04
	ld hl, TimesUpText
	call PrintText
.asm_1ea04
	ld hl, GameOverText
	call PrintText
	jp TextScriptEnd

TimesUpText: ; 1ea0d (7:6a0d)
	TX_FAR _TimesUpText
	db "@"

GameOverText: ; 1ea12 (7:6a12)
	TX_FAR _GameOverText
	db "@"

PrintCinnabarQuiz: ; 1ea17 (7:6a17)
	ld a, [wSpriteStateData1 + 9]
	cp SPRITE_FACING_UP
	ret nz
	call EnableAutoTextBoxDrawing
	tx_pre_jump CinnabarGymQuiz

CinnabarGymQuiz: ; 1ea25 (7:6a25)
	TX_ASM
	call SaveScreenTilesToBuffer2
	xor a
	ld [wOpponentAfterWrongAnswer], a
	ld a, [wHiddenObjectFunctionArgument]
	and $f
	ld [hGymGateIndex], a
	dec a ; first question?
	ld hl, CinnabarGymQuizIntroText
	jr nz, .doNotPrintIntroText
	ld hl, CinnabarGymQuizFirstQuestionIntroText
.doNotPrintIntroText
	call PrintText
	ld a, [hGymGateIndex]
	dec a
	add a
	ld d, 0
	ld e, a
	ld hl, CinnabarQuizQuestions
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call PrintText
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	call CinnabarGymQuiz_1ea92
	jp TextScriptEnd

CinnabarGymQuizIntroText: ; 1ea5b (7:6a5b)
	TX_FAR _CinnabarGymQuizIntroText
	db "@"

CinnabarGymQuizFirstQuestionIntroText:
	TX_FAR _CinnabarGymQuizFirstQuestionIntroText
	db "@"
	
CinnabarQuizQuestions: ; 1ea60 (7:6a60)
	dw CinnabarQuizQuestionsText1
	dw CinnabarQuizQuestionsText2
	dw CinnabarQuizQuestionsText3
	dw CinnabarQuizQuestionsText4
	dw CinnabarQuizQuestionsText5
	dw CinnabarQuizQuestionsText6

CinnabarQuizQuestionsText1: ; 1ea6c (7:6a6c)
	TX_FAR _CinnabarQuizQuestionsText1
	db "@"

CinnabarQuizQuestionsText2: ; 1ea71 (7:6a71)
	TX_FAR _CinnabarQuizQuestionsText2
	db "@"

CinnabarQuizQuestionsText3: ; 1ea76 (7:6a76)
	TX_FAR _CinnabarQuizQuestionsText3
	db "@"

CinnabarQuizQuestionsText4: ; 1ea80 (7:6a80)
	TX_FAR _CinnabarQuizQuestionsText4
	db "@"

CinnabarQuizQuestionsText5: ; 1ea7b (7:6a7b)
	TX_ASM
	ld hl, CinnabarQuizQuestion5Items
.searchForGoodItem
	ld a, [hli]
	cp $ff
	jr nz, .notNinetyNineValue
	ld a, MASTER_BALL
	ld [wd11e], a
	call GetItemName
	call CopyStringToCF4B
	ld a, $99
	ld [hDivideBCDQuotient + 2], a
	jr .ninetyNineValue
.notNinetyNineValue
	ld [wcf91], a
	
	push hl
	ld a, [wListMenuID]
	push af
	ld a, SPECIALLISTMENU
	ld [wListMenuID], a
	ld a, ItemPrices & $ff
	ld [wItemPrices], a
	ld a, ItemPrices / $100
	ld [wItemPrices + 1], a
	call GetItemPrice
	pop af
	ld [wListMenuID], a
	
	ld hl, wPlayerMoney
	ld a, [hli]
	ld [hMoney], a
	ld a, [hli]
	ld [hMoney + 1], a
	ld a, [hl]
	ld [hMoney + 2], a
	
	ld hl, hItemPrice
	ld a, [hli]
	ld [hDivideBCDDivisor], a
	ld a, [hli]
	ld [hDivideBCDDivisor + 1], a
	ld a, [hl]
	ld [hDivideBCDDivisor + 2], a
	
	predef DivideBCDPredef3
	
	pop hl
	
	ld a, [hDivideBCDQuotient]
	and a
	jr nz, .searchForGoodItem
	ld a, [hDivideBCDQuotient + 1]
	and a
	jr nz, .searchForGoodItem
	ld a, [hDivideBCDQuotient + 2]
	cp $99 + $1
	jr nc, .searchForGoodItem
	
	push hl
	ld hl, MoreThan10CharacterNumbers
	ld de, $1
	call IsInArray
	pop hl
	jr c, .searchForGoodItem
	
	ld a, [wcf91]
	ld [wd11e], a
	call GetItemName
	call CopyStringToCF4B
.ninetyNineValue
	ld a, [hDivideBCDQuotient + 2]
	cp $20
	jr c, .uniqueNumber
; if repetitive number
	swap a
	and $f
	dec a
	ld hl, CinnabarQuizRepetitiveNumberStrings
	call CinnabarQuiz_SearchForString
	
	ld hl, wcd6d
	call CopyString
	dec hl
	push hl
; now look for the lower digit
	ld a, [hDivideBCDQuotient + 2]
	and $f
	jr z, .doNotPutZero
	ld hl, CinnabarQuizUniqueNumberStrings
	call CinnabarQuiz_SearchForString
	pop hl
	
	call CopyString ; copy the rest of the number
	jr .done
.doNotPutZero
	pop hl
	jr .done
.uniqueNumber
	cp $10
	jr c, .doNotAdjustBCD
	and $f
	add 10
.doNotAdjustBCD
	ld hl, CinnabarQuizUniqueNumberStrings
	call CinnabarQuiz_SearchForString
	
	ld hl, wcd6d
	call CopyString
.done
	xor a
	ld [wNumMovesMinusOne], a
	ld hl, CinnabarQuizQuestionsText5_ActualQuestion
	call PrintText
	jp TextScriptEnd

CinnabarQuiz_SearchForString:
	ld c, a
	ld b, "@"
	jr .handleLoop
.searchForTerminatorLoop
	ld a, [hli]
	cp b
	jr nz, .searchForTerminatorLoop
.handleLoop
	dec c
	jr nz, .searchForTerminatorLoop
	ld d, h
	ld e, l
	ret

CinnabarQuizQuestionsText5_ActualQuestion:
	TX_FAR _CinnabarQuizQuestionsText5_ActualQuestion
	db "@"
	
CinnabarQuizQuestion5Items:
	db POKE_BALL
	db BURN_HEAL
	db POTION
	db LEMONADE
	db SUPER_REPEL
	db X_DEFEND
	db FULL_HEAL
	db DIRE_HIT
	db SUPER_POTION
	db POKE_DOLL
	db ULTRA_BALL
	db REVIVE
	db WATER_STONE
	db MAX_POTION
	db FULL_RESTORE
	db PROTEIN
	db $ff
	
MoreThan10CharacterNumbers:
	db $23
	db $27
	db $28
	db $33
	db $37
	db $38
	db $73
	db $74
	db $75
	db $77
	db $78
	db $79
	db $83
	db $87
	db $88
	db $93
	db $97
	db $98
	db $ff
	
CinnabarQuizUniqueNumberStrings:
	db "ONE@"
	db "TWO@"
	db "THREE@"
	db "FOUR@"
	db "FIVE@"
	db "SIX@"
	db "SEVEN@"
	db "EIGHT@"
	db "NINE@"
	db "TEN@"
	db "ELEVEN@"
	db "TWELVE@"
	db "THIRTEEN@"
	db "FOURTEEN@"
	db "FIFTEEN@"
	db "SIXTEEN@"
	db "SEVENTEEN@"
	db "EIGHTEEN@"
	db "NINETEEN@"

CinnabarQuizRepetitiveNumberStrings:
	db "TWENTY@"
	db "THIRTY@"
	db "FORTY@"
	db "FIFTY@"
	db "SIXTY@"
	db "SEVENTY@"
	db "EIGHTY@"
	db "NINETY@"

CinnabarQuizQuestionsText6: ; 1ea85 (7:6a85)
	TX_FAR _CinnabarQuizQuestionsText6
	db "@"

AnswerThisQuestionText:
	TX_FAR _AnswerThisQuestionText
	db "@"
	
CinnabarGymGateFlagAction: ; 1ea8a (7:6a8a)
	EventFlagAddress hl, EVENT_CINNABAR_GYM_GATE0_UNLOCKED
	predef_jump FlagActionPredef

CinnabarGymQuiz_1ea92: ; 1ea92 (7:6a92)
	ld hl, AnswerThisQuestionText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	ret nz ; didn't choose to answer the question
	ld a, NAME_ANSWER_SCREEN
	ld [wNamingScreenType], a
	callab DisplayCinnabarAnswerScreen
	call CinnabarGymQuiz_AdjustLowercase
	call CinnabarGymQuiz_CheckForCorrectAnswer
	jr nc, .wrongAnswer
	ld hl, wCurrentMapScriptFlags
	set 5, [hl]
	ld a, [hGymGateIndex]
	ld [$ffe0], a
	ld hl, CinnabarGymQuizCorrectText
	call PrintText
	ld a, [$ffe0]
	AdjustEventBit EVENT_CINNABAR_GYM_GATE0_UNLOCKED, 0
	ld c, a
	ld b, FLAG_SET
	call CinnabarGymGateFlagAction
	jp UpdateCinnabarGymGateTileBlocks_
.wrongAnswer
	call WaitForSoundToFinish
	ld a, SFX_DENIED
	call PlaySound
	call WaitForSoundToFinish
	ld hl, CinnabarGymQuizIncorrectText
	jp PrintText

CinnabarGymQuiz_AdjustLowercase:
	ld hl, wBuffer
.loop
	ld a, [hli]
	cp "@"
	ret z
	cp "a"
	jr c, .loop
	cp "é"
	jr nc, .loop
; subtract to get uppercase
	sub $20
	dec hl
	ld [hli], a
	jr .loop
	
CinnabarGymQuiz_CheckForCorrectAnswer:
	ld a, [hGymGateIndex]
	dec a
	add a
	ld c, a
	ld b, $0
	ld hl, CinnabarGymQuizAnswersPointerTable
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, wBuffer
.loop
	push de
	push hl
	call .stringTerminatorCmp
	pop hl
	pop de
	ret c ; found
	ld a, [hl]
	and a
	ret z ; not found
	ld c, a
	ld b, $0
	add hl, bc ; get offset
	jr .loop

.stringTerminatorCmp
	inc hl
.stringTerminatorLoop
	ld a, [de]
	cp [hl]
	jr nz, .stringsDifferent
	inc hl
	inc de
	cp "@"
	jr nz, .stringTerminatorLoop
	scf
	ret
.stringsDifferent
	and a
	ret
	
CinnabarGymQuizAnswersPointerTable:
	dw CinnabarGymQuizAnswer_Defense
	dw CinnabarGymQuizAnswer_Thirteen
	dw CinnabarGymQuizAnswer_Shopkeeper
	dw CinnabarGymQuizAnswer_BugGhost
	dw wNumMovesMinusOne ; CinnabarGymQuizAnswer_Money
	dw CinnabarGymQuizAnswer_ThreeTimesNine
	
stringoffset: MACRO
	db (.offsetCalc\2End - .offsetCalc\2) + 1
.offsetCalc\2
	db \1
.offsetCalc\2End
ENDM
	
CinnabarGymQuizAnswer_Defense:
	db $0,"DEFENSE@"
	
CinnabarGymQuizAnswer_Thirteen:
	db $0,"THIRTEEN@"
	
CinnabarGymQuizAnswer_Shopkeeper:
	db $0,"SHO",$e1,"EEPERS@" ; $e1 = pk

CinnabarGymQuizAnswer_BugGhost:
	stringoffset "BUG/GHOST@", 1
	stringoffset "BUG GHOST@", 2
	stringoffset "BUGGHOST@",  3
	stringoffset "GHOST/BUG@", 4
	stringoffset "GHOST BUG@", 5
	db $0, "GHOSTBUG@"

CinnabarGymQuizAnswer_ThreeTimesNine:
	stringoffset "THREE×NINE@", 1
	stringoffset "NINE×THREE@", 2
	db $0, "THREECUBED@"

CinnabarGymQuizCorrectText: ; 1eae3 (7:6ae3)
	db $0b
	TX_FAR _CinnabarGymQuizCorrectText
	db $06
	TX_ASM

	ld a, [$ffe0]
	AdjustEventBit EVENT_CINNABAR_GYM_GATE0_UNLOCKED, 0
	ld c, a
	ld b, FLAG_TEST
	call CinnabarGymGateFlagAction
	ld a, c
	and a
	jp nz, TextScriptEnd
	call WaitForSoundToFinish
	ld a, SFX_GO_INSIDE
	call PlaySound
	call WaitForSoundToFinish
	jp TextScriptEnd

CinnabarGymQuizIncorrectText: ; 1eb05 (7:6b05)
	TX_FAR _CinnabarGymQuizIncorrectText
	db "@"

UpdateCinnabarGymGateTileBlocks_: ; 1eb0a (7:6b0a)
; Update the overworld map with open floor blocks or locked gate blocks
; depending on event flags.
	ld a, 6
	ld [hGymGateIndex], a
.loop
	ld a, [hGymGateIndex]
	dec a
	add a
	add a
	ld d, 0
	ld e, a
	ld hl, CinnabarGymGateCoords
	add hl, de
	ld a, [hli]
	ld b, [hl]
	ld c, a
	inc hl
	ld a, [hl]
	ld [wGymGateTileBlock], a
	push bc
	ld a, [hGymGateIndex]
	ld [$ffe0], a
	AdjustEventBit EVENT_CINNABAR_GYM_GATE0_UNLOCKED, 0
	ld c, a
	ld b, FLAG_TEST
	call CinnabarGymGateFlagAction
	ld a, c
	and a
	jr nz, .unlocked
	ld a, [wGymGateTileBlock]
	jr .next
.unlocked
	ld a, $e
.next
	pop bc
	ld [wNewTileBlockID], a
	predef ReplaceTileBlock
	ld hl, hGymGateIndex
	dec [hl]
	jr nz, .loop
	ret

CinnabarGymGateCoords: ; 1eb48 (7:6b48)
	; format: x-coord, y-coord, direction, padding
	; direction: $54 = horizontal gate, $5f = vertical gate
	db $09,$03,$54,$00
	db $06,$03,$54,$00
	db $06,$06,$54,$00
	db $03,$08,$5f,$00
	db $02,$06,$54,$00
	db $02,$03,$54,$00

PrintMagazinesText: ; 1eb60 (7:6b60)
	call EnableAutoTextBoxDrawing
	tx_pre MagazinesText
	ret

MagazinesText: ; 1eb69 (7:6b69)
	TX_FAR _MagazinesText
	db "@"

BillsHousePC: ; 1eb6e (7:6b6e)
	call EnableAutoTextBoxDrawing
	ld a, [wSpriteStateData1 + 9]
	cp SPRITE_FACING_UP
	ret nz
	CheckEvent EVENT_LEFT_BILLS_HOUSE_AFTER_HELPING
	jr nz, .asm_1ebd2
	CheckEventReuseA EVENT_USED_CELL_SEPARATOR_ON_BILL
	jr nz, .asm_1eb86
	CheckEventReuseA EVENT_BILL_SAID_USE_CELL_SEPARATOR
	jr nz, .asm_1eb8b
.asm_1eb86
	tx_pre_jump BillsHouseMonitorText
.asm_1eb8b
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	tx_pre BillsHouseInitiatedText
	ld c, 32
	call DelayFrames
	ld a, SFX_TINK
	call PlaySound
	call WaitForSoundToFinish
	ld c, 80
	call DelayFrames
	ld a, SFX_SHRINK
	call PlaySound
	call WaitForSoundToFinish
	ld c, 48
	call DelayFrames
	ld a, SFX_TINK
	call PlaySound
	call WaitForSoundToFinish
	ld c, 32
	call DelayFrames
	ld a, SFX_GET_ITEM_1
	call PlaySound
	call WaitForSoundToFinish
	call PlayDefaultMusic
	SetEvent EVENT_USED_CELL_SEPARATOR_ON_BILL
	ret
.asm_1ebd2
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	tx_pre BillsHousePokemonList
	ret

BillsHouseMonitorText: ; 1ebdd (7:6bdd)
	TX_FAR _BillsHouseMonitorText
	db "@"

BillsHouseInitiatedText: ; 1ebe2 (7:6be2)
	TX_FAR _BillsHouseInitiatedText
	db $06
	TX_ASM
	ld a, $ff
	ld [wNewSoundID], a
	call PlaySound
	ld c, 16
	call DelayFrames
	ld a, SFX_SWITCH
	call PlaySound
	call WaitForSoundToFinish
	ld c, 60
	call DelayFrames
	jp TextScriptEnd

BillsHousePokemonList: ; 1ec05 (7:6c05)
	TX_ASM
	call SaveScreenTilesToBuffer1
	ld hl, BillsHousePokemonListText1
	call PrintText
	xor a
	ld [wMenuItemOffset], a ; not used
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	ld a, A_BUTTON | B_BUTTON
	ld [wMenuWatchedKeys], a
	ld a, 4
	ld [wMaxMenuItem], a
	ld a, 2
	ld [wTopMenuItemY], a
	ld a, 1
	ld [wTopMenuItemX], a
.billsPokemonLoop
	ld hl, wd730
	set 6, [hl]
	coord hl, 0, 0
	ld b, 10
	ld c, 9
	call TextBoxBorder
	coord hl, 2, 2
	ld de, BillsMonListText
	call PlaceString
	ld hl, BillsHousePokemonListText2
	call PrintText
	call SaveScreenTilesToBuffer2
	call HandleMenuInput
	bit 1, a ; pressed b
	jr nz, .cancel
	ld a, [wCurrentMenuItem]
	add EEVEE
	cp EEVEE
	jr z, .displayPokedex
	cp FLAREON
	jr z, .displayPokedex
	cp JOLTEON
	jr z, .displayPokedex
	cp VAPOREON
	jr z, .displayPokedex
	jr .cancel
.displayPokedex
	call DisplayPokedex
	call LoadScreenTilesFromBuffer2
	jr .billsPokemonLoop
.cancel
	ld hl, wd730
	res 6, [hl]
	call LoadScreenTilesFromBuffer2
	jp TextScriptEnd

BillsHousePokemonListText1: ; 1ec7f (7:6c7f)
	TX_FAR _BillsHousePokemonListText1
	db "@"

BillsMonListText: ; 1ec84 (7:6c84)
	db   "EEVEE"
	next "FLAREON"
	next "JOLTEON"
	next "VAPOREON"
	next "CANCEL@"

BillsHousePokemonListText2: ; 1ecaa (7:6caa)
	TX_FAR _BillsHousePokemonListText2
	db "@"

DisplayOakLabEmailText: ; 1ecaf (7:6caf)
	ld a, [wSpriteStateData1 + 9]
	cp SPRITE_FACING_UP
	ret nz
	call EnableAutoTextBoxDrawing
	tx_pre_jump OakLabEmailText

OakLabEmailText: ; 1ecbd (7:6cbd)
	TX_FAR _OakLabEmailText
	db "@"
