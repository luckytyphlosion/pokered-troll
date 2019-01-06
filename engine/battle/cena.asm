CENA_POKEMON EQU MACHOKE

JohnCenaBattleTurnScript:: ; 3b:4000
    ld hl, wOptions
    res 7, [hl] ; animations forced on
    ld a, [wEnemyMonStatus]
    and a
    jr z, .normalTurn
    callab AIUseFullRestore
    callab DrawHUDsAndHPBars
    ld a, [wCenaBattleTurn]
    cp a, 3
    jr nc, .normalTurn
    jpab ExecutePlayerMove
; script the battle depending on CenaTurn
.normalTurn
    ld a, [wCenaBattleTurn]
    and a, $0F
    add a, a
    ld c, a
    ld b, 0
    ld hl, CenaTurnsJumpTable
    add hl, bc
    ld a, [hli]
    ld h, [hl]
    ld l, a
    call CallHL
    ld a, [wCenaBattleTurn]
    inc a
    ld [wCenaBattleTurn], a
    ret
    
CallHL:
    jp [hl]
    
CenaTurnsJumpTable:
    dw FirstTurnTbolt
    dw SecondTurnPsychic
    dw ThirdTurnRecover
    dw FourthTurnFraud
    dw FifthTurnDamage
    dw SixthTurnQuickClaw
    dw SeventhTurnDed
rept 9
    dw CenaNop
endr
    
FirstTurnTbolt:
    ld a, 1
    ld [wGiveExperience], a
    ld hl,JCTboltText
    call PrintText
    call Delay3
    ld a, $2
    ld [wAnimationType], a
    dec a
    ld [H_WHOSETURN], a
    ld a, THUNDERBOLT
    call CenaAnimation
    xor a
    ld [H_WHOSETURN], a
    ld hl,JCDeflectedText
    call PrintText
    call Delay3
    call NVESound
    ld hl, wDamage
    xor a
    ld [hli], a
    ld a, 10
    ld [hl], a
    callab ApplyDamageToEnemyPokemon
    ld hl,JCDeflectedMoveNVEText
    call PrintText
    jpab ExecutePlayerMove
    
SecondTurnPsychic:
    ld hl,JCPsychicText
    call PrintText
    call Delay3
    ld a, $2
    ld [wAnimationType], a
    dec a
    ld [H_WHOSETURN], a
    ld a, PSYCHIC_M
    call CenaAnimation
    xor a
    ld [H_WHOSETURN], a
    ld hl,JCPowerOfFriendshipText
    call PrintText
    call Delay3
    ld hl, wBattleMonHP
    ld a, [hli]
    ld b, a
    ld c, [hl]
    dec bc
    ld hl, wDamage
    ld a, b
    ld [hli], a
    ld [hl], c
    callab ApplyDamageToPlayerPokemon
    ld hl,JCFriendshipWorkedText
    call PrintText
    jpab ExecutePlayerMove
    
ThirdTurnRecover:
    ld hl,JCRecoverText
    call PrintText
    call Delay3
    xor a
    ld [wAnimationType], a
    inc a
    ld [H_WHOSETURN], a
    ld a, RECOVER
    call CenaAnimation
    ld hl, wEnemyMonHP
    ld a, [hli]
    ld [wHPBarOldHP+1], a
    ld a, [hl]
    ld [wHPBarOldHP], a
    ld hl, wEnemyMonMaxHP
    ld a, [hli]
    ld [wHPBarNewHP+1], a
    ld [wHPBarMaxHP+1], a
    ld [wEnemyMonHP], a
    ld a, [hl]
    ld [wHPBarNewHP], a
    ld [wHPBarMaxHP], a
    ld [wEnemyMonHP+1], a
    ld a, 0
    ld [wHPBarType], a
    coord hl, 2, 2
    predef UpdateHPBar2
    callab DrawHUDsAndHPBars
    xor a
    ld [H_WHOSETURN], a
    callab ExecutePlayerMove
    call ClearEnemyArea
    callab _ScrollTrainerPicAfterBattle
    ld hl,JCCantWinText
    call PrintText
    call Delay3
    ld a, 8
    coord hl, 18, 0
    call SlideTrainerPicOffScreenCena
    call ClearEnemyArea
    ld a, MEWTWO
    call ScrollMonPic
    ld hl, JCInspirationText
    call PrintText
    call Delay3
    callab RetreatMon
	ld c, 50
	call DelayFrames
	callab AnimateRetreatingPlayerMon
    ld de, wBattleMonNick
    ld hl, JCChampHeader
    ld b, wTrainerClass - wBattleMonNick
.copyloop
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .copyloop
    ld a, CENA_POKEMON
    ld [wBattleMonSpecies2], a
    ld [wcf91],a
	ld [wd0b5],a
	call GetMonHeader
    call JCSoundSetup
	jpab SendOutMon
    
FourthTurnFraud:
    ld hl,JCTimeIsUpText
    call PrintText
    call Delay3
	xor a
    ld [wAnimationType], a
	ld [H_WHOSETURN], a
    ld a, SEISMIC_TOSS
    call CenaAnimation
    ld hl,JCFraudExposedText
    call PrintText
    call Delay3
    ld c, 50
    call DelayFrames
    ld a, 100
    ld [wEnemyMonLevel], a
    ld [wCurEnemyLVL], a
    ld a, [wEnemyMonSpecies2]
	ld [wd0b5], a
	call GetMonHeader
    ld de, wEnemyMonMaxHP
    ld b, $0
    call CalcStats
    ld hl, wEnemyMonMaxHP
    ld de, wEnemyMonHP
    ld a, [hli]
    ld [de], a
    inc de
    ld a, [hl]
    ld [de], a
    callab DrawHUDsAndHPBars
    ld hl,JCWeakenedText
    call PrintText
    call Delay3
    ret
    
FifthTurnDamage:
    ld hl,JCTimeIsNowText
    call PrintText
    call Delay3
    ld a, $4
    ld [wAnimationType], a
	xor a
    ld [H_WHOSETURN], a
    ld a, MEGA_PUNCH
    call CenaAnimation
    call SESound
    ld hl, wDamage
    xor a
    ld [hli], a
    ld a, 123
    ld [hl], a
    callab ApplyDamageToEnemyPokemon
    ld hl, JCSEText
    call PrintText
    jp Delay3
    
SixthTurnQuickClaw:
    xor a
    ld [wAnimationType], a
    ld a, 1
    ld [H_WHOSETURN], a
    ld a, XSTATITEM_ANIM
    call CenaAnimation
    ld hl,JCQuickClawText
    call PrintText
    ld c, 50
    call DelayFrames
    ld hl,JCPsychicText
    call PrintText
    ld c, 50
    call DelayFrames
    ld hl,JCReadyText
    call PrintText
    ld c, 20
    call DelayFrames
    ld hl,JCCantSeeMeText
    call PrintText
    call Delay3
    xor a
    ld [wAnimationType], a
    ld [H_WHOSETURN], a
    ld a, FLASH
    call CenaAnimation
    ld c, 10
    call DelayFrames
    ld hl,JCConfusedText
    call PrintText
    ld c, 20
    call DelayFrames
    ld hl,JCHitSelfText
    call PrintText
    call Delay3
    xor a
    ld [wAnimationType], a
    ld [H_WHOSETURN], a
    ld a, 1
    call CenaAnimation
    ld hl, wDamage
    xor a
    ld [hli], a
    ld a, 69
    ld [hl], a
    jpab ApplyDamageToEnemyPokemon
    
SeventhTurnDed:
    ld hl,JCTimeIsNowText
    call PrintText
    call Delay3
    ld a, $5
    ld [wAnimationType], a
    xor a
	ld [H_WHOSETURN], a
    ld a, HYPER_BEAM
    call CenaAnimation
    call SESound
    ld hl, wDamage
    ld a, 420 / 256
    ld [hli], a
    ld a, 420 % 256
    ld [hl], a
    callab ApplyDamageToEnemyPokemon
    ld hl, JCSEText
    call PrintText
    call Delay3
    xor a
    ld [wAnimationType], a
    ld a, 1
    ld [H_WHOSETURN], a
    ld a, EXPLOSION
    call CenaAnimation
    ld hl, JCObliteratedText
    call PrintText
    call Delay3
    xor a
    ld [hCenaSoundEnabled], a
    ret
    
CenaItemTroll:
    call ClearEnemyArea
    callab _ScrollTrainerPicAfterBattle
    ld hl,JCNoItemsText
    call PrintText
    call Delay3
    ld a, 8
    coord hl, 18, 0
    call SlideTrainerPicOffScreenCena
    call ClearEnemyArea
    ld a, MEWTWO
    jp ScrollMonPic
    
    
CenaNop:
    ret
    
CenaAnimation:
    ld [wAnimationID],a
    predef_jump MoveAnimation
    
NVESound:
    ld a, $50
    ld [wFrequencyModifier], a
    ld a, $1
    ld [wTempoModifier], a
    ld a, SFX_NOT_VERY_EFFECTIVE
    call PlaySound 
    jp WaitForSoundToFinish
    
SESound:
    ld a, $e0
    ld [wFrequencyModifier], a
    ld a, $ff
    ld [wTempoModifier], a
    ld a, SFX_SUPER_EFFECTIVE
    call PlaySound 
    jp WaitForSoundToFinish 
    
ClearEnemyArea:
    ld b, 7 ; num rows
    coord hl, 12, 0
    ld a, $7f
.rowLoop
    ld c, 8 ; num cols
.colLoop
    ld [hli], a
    dec c
    jr nz, .colLoop
    ld de, 12
    add hl, de
    dec b
    jr nz, .rowLoop
    ret
    
    
SlideTrainerPicOffScreenCena: ; 3c8df (f:48df)
	ld [hSlideAmount], a
	ld c, a
.slideStepLoop ; each iteration, the trainer pic is slid one tile left/right
	push bc
	push hl
	ld b, 7 ; number of rows
.rowLoop
	push hl
	ld a, [hSlideAmount]
	ld c, a
.columnLoop
	ld a, [hSlideAmount]
	cp 8
	jr z, .slideRight
.slideLeft ; slide player sprite off screen
	ld a, [hld]
	ld [hli], a
	inc hl
	jr .nextColumn
.slideRight ; slide enemy trainer sprite off screen
	ld a, [hli]
	ld [hld], a
	dec hl
.nextColumn
	dec c
	jr nz, .columnLoop
	pop hl
	ld de, 20
	add hl, de
	dec b
	jr nz, .rowLoop
	ld c, 2
	call DelayFrames
	pop hl
	pop bc
	dec c
	jr nz, .slideStepLoop
	ret
    
ScrollMonPic: ; 396d3 (e:56d3)
; Scroll mon pic back in.
	ld [wEnemyMonSpecies2], a
	ld b, SET_PAL_BATTLE
	call RunPaletteCommand
	ld a,[wEnemyMonSpecies2]
	ld [wcf91],a
	ld [wd0b5],a
	call GetMonHeader
	ld de,vFrontPic
	call LoadMonFrontSprite
	coord hl, 19, 0
	ld c, $0
.scrollLoop
	inc c
	ld a, c
    ld [hMonScrollIterNum], a
	cp 9
	ret z
	ld d, $0
	push bc
	push hl
.drawMonPicLoop
	call ScrollMonPicColumn
	inc hl
	ld a, 7
	add d
	ld d, a
	dec c
	jr nz, .drawMonPicLoop
    ld a, [hMonScrollIterNum]
    cp 8
    call z, HideExtraPicColumn
	ld c, 4
	call DelayFrames
	pop hl
	pop bc
	dec hl
	jr .scrollLoop

; write one 7-tile column of the trainer pic to the tilemap
ScrollMonPicColumn: ; 39707 (e:5707)
	push hl
	push de
	push bc
	ld e, 7
.loop
	ld [hl], d
	ld bc, SCREEN_WIDTH
	add hl, bc
	inc d
	dec e
	jr nz, .loop
	pop bc
	pop de
	pop hl
	ret
    
HideExtraPicColumn:
    push hl
    push de
    push bc
    coord hl, 19, 0
    ld d, $7
.hideloop
    ld [hl], $7f
    ld bc, SCREEN_WIDTH
    add hl, bc
    dec d
    jr nz, .hideloop
    pop bc
    pop de
    pop hl
    ret
    
JCTboltText:
    text "Foe MEWTWO"
    line "used THUNDERBOLT!"
    done
    
JCDeflectedText:
    text "The FRANKLIN BADGE"
    line "that ",$52," was"
    cont "standing on"
    cont "deflected the"
    cont "attack back!"
    done
    
JCDeflectedMoveNVEText:
    text "The deflected"
    line "attack was not"
    cont "very effective..."
    prompt
    
JCPsychicText:
    text "Foe MEWTWO"
    line "used PSYCHIC!"
    done
    
JCPowerOfFriendshipText:
    text $52," used PURE"
    line "FRIENDSHIP to"
    cont "try to endure"
    cont "the fierce attack!"
    done
    
JCFriendshipWorkedText:
    text "It worked,"
    line "barely..."
    prompt
    
JCRecoverText:
    text "Foe MEWTWO"
    line "used RECOVER!"
    done
    
JCCantWinText:
    text "PROF. OAK: Give"
    line "it up, ",$52,"!"
    para "You can't win"
    line "against MEWTWO!"
    done
    
JCInspirationText:
    text "Suddenly, ",$52
    line "had a flash of"
    cont "inspiration!"
    para $52," recalled"
    line "the only one"
    cont "who could win"
    cont "this impossible"
    cont "battle for him!"
    prompt
    
JCTimeIsUpText:
    text "CHAMP used"
    line "YOUR TIME IS UP!"
    done

JCTimeIsNowText:
    text "CHAMP used"
    line "MY TIME IS NOW!"
    done
    
JCSEText:
    text "It's super-"
    line "effective!"
    prompt
    
JCFraudExposedText:
    text "Foe MEWTWO's"
    line "fraud was exposed!"
    done
    
JCWeakenedText:
    text "Foe MEWTWO was"
    line "greatly weakened!"
    prompt
    
JCQuickClawText:
    text "Foe MEWTWO's"
    line "QUICK CLAW"
    cont "activated!"
    done

JCReadyText:
    text "CHAMP was ready"
    line "for this kind of"
    cont "shenanigans!"
    done
    
JCCantSeeMeText:
    text "CHAMP used"
    line "U CAN'T C ME!"
    done
    
JCConfusedText:
    text "Foe MEWTWO"
    line "can't see CHAMP!"
    prompt

JCHitSelfText:
    text "Foe MEWTWO"
    line "hit itself in"
    cont "its confusion!"
    done
    
JCObliteratedText:
    text "Foe MEWTWO was"
    line "utterly destroyed!"
    done
    
JCNoItemsText:
	TX_FAR _ItemUseNotTimeText
	db "@"
    
JCChampHeader:
    db "CHAMP@@@@@@"
    db CENA_POKEMON ; species
    dw $e703 ; hp
    db 100 ; level
    db 0 ; status
    db 0 ; type 1
    db 0 ; type 2
    db 0 ; catch rate
rept NUM_MOVES
    db 0 ; move index
endr
    dw $ffff ; dvs
    db 100 ; level
    dw $e703 ; max hp
    dw $e703 ; atk
    dw $e703 ; def
    dw $e703 ; spd
    dw $e703 ; spc
rept NUM_MOVES
    db 0 ; move pp
endr

JCSoundSetup:
	ld a, $ff
	call PlaySound
	
	ld			a,$8f
	ldh			[rNR52],a					
	ld			a,$77
	ldh			[rNR50],a					
	ld			a,$ff
	ldh			[rNR51],a					

	ld			a,$F0
	ldh			[rTMA],a
	ldh			[rTIMA],a					
	ld			a,%0000100
	ldh			[rTAC],a					

	xor			a
	ldh			[rNR31],a
    ld [rNR12],a
    ld [rNR22],a
    ld [rNR42],a
	ld			a,%00100000					
	ldh			[rNR32],a
	ld			a,sound_rate & $FF			
	ldh			[rNR33],a					

	ld			a,sound_start_bank & $FF
	ldh			[hSoundBank],a
	xor			a
	ldh			[hSoundAddr],a
	ld			a,$40
	ldh			[hSoundAddr+1],a
	
    ld a, $1
    ld [hCenaSoundEnabled], a

	ret