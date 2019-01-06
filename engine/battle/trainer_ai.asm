; creates a set of moves that may be used and returns its address in hl
; unused slots are filled with 0, all used slots may be chosen with equal probability
AIEnemyTrainerChooseMoves: ; 39719 (e:5719)
	ld a, $a
	ld hl, wBuffer ; init temporary move selection array. Only the moves with the lowest numbers are chosen in the end
	ld [hli], a   ; move 1
	ld [hli], a   ; move 2
	ld [hli], a   ; move 3
	ld [hl], a    ; move 4
	ld a, [wEnemyDisabledMove] ; forbid disabled move (if any)
	swap a
	and $f
	jr z, .noMoveDisabled
	ld hl, wBuffer
	dec a
	ld c, a
	ld b, $0
	add hl, bc    ; advance pointer to forbidden move
	ld [hl], $50  ; forbid (highly discourage) disabled move
.noMoveDisabled
	ld hl, TrainerClassMoveChoiceModifications
	ld a, [wTrainerClass]
	ld b, a
.loopTrainerClasses
	dec b
	jr z, .readTrainerClassData
.loopTrainerClassData
	ld a, [hli]
	and a
	jr nz, .loopTrainerClassData
	jr .loopTrainerClasses
.readTrainerClassData
	ld a, [hl]
	and a
	jp z, .useOriginalMoveSet
	push hl
.nextMoveChoiceModification
	pop hl
	ld a, [hli]
	and a
	jr z, .loopFindMinimumEntries
	push hl
	ld hl, AIMoveChoiceModificationFunctionPointers
	dec a
	add a
	ld c, a
	ld b, 0
	add hl, bc    ; skip to pointer
	ld a, [hli]   ; read pointer into hl
	ld h, [hl]
	ld l, a
	ld de, .nextMoveChoiceModification  ; set return address
	push de
	jp hl       ; execute modification function
.loopFindMinimumEntries ; all entries will be decremented sequentially until one of them is zero
	ld a, [wChampionUsedXItem]
	and a
	ret nz ; do not decide which move to use if champion used an x item
	ld hl, wBuffer  ; temp move selection array
	ld de, wEnemyMonMoves  ; enemy moves
	ld c, NUM_MOVES
.loopDecrementEntries
	ld a, [de]
	inc de
	and a
	jr z, .loopFindMinimumEntries
	dec [hl]
	jr z, .minimumEntriesFound
	inc hl
	dec c
	jr z, .loopFindMinimumEntries
	jr .loopDecrementEntries
.minimumEntriesFound
	ld a, c
.loopUndoPartialIteration ; undo last (partial) loop iteration
	inc [hl]
	dec hl
	inc a
	cp NUM_MOVES + 1
	jr nz, .loopUndoPartialIteration
	ld hl, wBuffer  ; temp move selection array
	ld de, wEnemyMonMoves  ; enemy moves
	ld c, NUM_MOVES
.filterMinimalEntries ; all minimal entries now have value 1. All other slots will be disabled (move set to 0)
	ld a, [de]
	and a
	jr nz, .moveExisting
	ld [hl], a
.moveExisting
	ld a, [hl]
	dec a
	jr z, .slotWithMinimalValue
	xor a
	ld [hli], a     ; disable move slot
	jr .next
.slotWithMinimalValue
	ld a, [de]
	ld [hli], a     ; enable move slot
.next
	inc de
	dec c
	jr nz, .filterMinimalEntries
	ld hl, wBuffer    ; use created temporary array as move set
	ret
.useOriginalMoveSet
	ld hl, wEnemyMonMoves    ; use original move set
	ret

AIMoveChoiceModificationFunctionPointers: ; 397a3 (e:57a3)
	dw AIMoveChoiceModification1
	dw AIMoveChoiceModification2
	dw AIMoveChoiceModification3
	dw AIMoveChoiceModification4

; discourages moves that cause no damage but only a status ailment if player's mon already has one
AIMoveChoiceModification1: ; 397ab (e:57ab)
	ld a, [wBattleMonStatus]
	and a
	ret z ; return if no status ailment on player's mon
	ld hl, wBuffer - 1 ; temp move selection array (-1 byte offest)
	ld de, wEnemyMonMoves ; enemy moves
	ld b, NUM_MOVES + 1
.nextMove
	dec b
	ret z ; processed all 4 moves
	inc hl
	ld a, [de]
	and a
	ret z ; no more moves in move set
	inc de
	call ReadMove
	ld a, [wEnemyMovePower]
	and a
	jr nz, .nextMove
	ld a, [wEnemyMoveEffect]
	push hl
	push de
	push bc
	ld hl, StatusAilmentMoveEffects
	ld de, $0001
	call IsInArray
	pop bc
	pop de
	pop hl
	jr nc, .nextMove
	ld a, [hl]
	add $5 ; heavily discourage move
	ld [hl], a
	jr .nextMove

StatusAilmentMoveEffects: ; 57e2
	db $01 ; unused sleep effect
	db SLEEP_EFFECT
	db POISON_EFFECT
	db PARALYZE_EFFECT
	db $FF

; slightly encourage moves with specific effects.
; in particular, stat-modifying moves and other move effects
; that fall in-bewteen
AIMoveChoiceModification2: ; 397e7 (e:57e7)
	ld a, [wAILayer2Encouragement]
	cp $1
	ret nz
	ld hl, wBuffer - 1 ; temp move selection array (-1 byte offset)
	ld de, wEnemyMonMoves ; enemy moves
	ld b, NUM_MOVES + 1
.nextMove
	dec b
	ret z ; processed all 4 moves
	inc hl
	ld a, [de]
	and a
	ret z ; no more moves in move set
	inc de
	call ReadMove
	ld a, [wEnemyMoveEffect]
	cp ATTACK_UP1_EFFECT
	jr c, .nextMove
	cp BIDE_EFFECT
	jr c, .preferMove
	cp ATTACK_UP2_EFFECT
	jr c, .nextMove
	cp POISON_EFFECT
	jr c, .preferMove
	jr .nextMove
.preferMove
	dec [hl] ; sligthly encourage this move
	jr .nextMove

; encourages moves that are effective against the player's mon (even if non-damaging).
; discourage damaging moves that are ineffective or not very effective against the player's mon,
; unless there's no damaging move that deals at least neutral damage
AIMoveChoiceModification3: ; 39817 (e:5817)
	ld hl, wBuffer - 1 ; temp move selection array (-1 byte offset)
	ld de, wEnemyMonMoves ; enemy moves
	ld b, NUM_MOVES + 1
.nextMove
	dec b
	ret z ; processed all 4 moves
	inc hl
	ld a, [de]
	and a
	ret z ; no more moves in move set
	inc de
	call ReadMove
	push hl
	push bc
	push de
	callab AIGetTypeEffectiveness
	pop de
	pop bc
	pop hl
	ld a, [wTypeEffectiveness]
	cp $10
	jr z, .nextMove
	jr c, .notEffectiveMove
	dec [hl] ; sligthly encourage this move
	jr .nextMove
.notEffectiveMove ; discourages non-effective moves if better moves are available
	push hl
	push de
	push bc
	ld a, [wEnemyMoveType]
	ld d, a
	ld hl, wEnemyMonMoves  ; enemy moves
	ld b, NUM_MOVES + 1
	ld c, $0
.loopMoves
	dec b
	jr z, .done
	ld a, [hli]
	and a
	jr z, .done
	call ReadMove
	ld a, [wEnemyMoveEffect]
	cp SUPER_FANG_EFFECT
	jr z, .betterMoveFound ; Super Fang is considered to be a better move
	cp SPECIAL_DAMAGE_EFFECT
	jr z, .betterMoveFound ; any special damage moves are considered to be better moves
	cp FLY_EFFECT
	jr z, .betterMoveFound ; Fly is considered to be a better move
	ld a, [wEnemyMoveType]
	cp d
	jr z, .loopMoves
	ld a, [wEnemyMovePower]
	and a
	jr nz, .betterMoveFound ; damaging moves of a different type are considered to be better moves
	jr .loopMoves
.betterMoveFound
	ld c, a
.done
	ld a, c
	pop bc
	pop de
	pop hl
	and a
	jr z, .nextMove
	inc [hl] ; sligthly discourage this move
	jr .nextMove

AIMoveChoiceModification4: ; 39883 (e:5883)
	ld a, [wEnemyMonPartyPos]
	cp $5 ; position of gengar
	jr nz, .notGengar
	ld a, [wEnemyMonStatus]
	and a
	jp z, .doNotUseHealingItem
	jp AIUseFullHeal
.notGengar
	cp $2 ; position of clefable
	jr nz, .doNotUseHaze
	ld a, [wChampionAIClefableFirstTurn]
	and a
	ld a, $1
	ld [wChampionAIClefableFirstTurn], a
	jr z, .switchToGolbat
	call ChampAI_CheckForSpecialOrAttackBoost
	jr nc, .doNotUseHaze
.switchToGolbat
	ld a, $1
	ld [wChampionSwappedOutToGolbat], a
	scf
	jp .afterSuccessfulItemUse
.doNotUseHaze
	ld a, [wEnemyMonStatus]
	and 1 << FRZ
	jr nz, .useFullRestore
	
	ld a, [wEnemyMonPartyPos]
	cp $3
	jr nz, .notNidoqueen
	ld a, [wEnemyBattleStatus2]
	bit UsingXAccuracy, a
	jr z, .allowHealingItem
	call ComparePlayerAndEnemySpeed
	jp c, .doNotUseHealingItem
	jr .allowHealingItem
.notNidoqueen
	ld a, [wActionResultOrTookBattleTurn]
	and a
	jp z, .doNotUseHealingItem
	
.allowHealingItem
	ld a, [wEnemyMonStatus]
	and a
	jr nz, .useFullRestore
	
	ld a, [wEnemyMonMaxHP]
	ld b, a
	ld a, [wEnemyMonMaxHP + 1]
	ld c, a
	
	ld hl, wEnemyMonHP
	ld a, [hli]
	ld l, [hl]
	ld h, a
	push hl
	add hl, hl
; 2 * cur - max
	ld a, l
	sub c
	ld a, h
	sbc b
	pop de
	jr c, .useFullRestore
	ld a, [wActionResultOrTookBattleTurn]
	and a
	jp z, .doNotUseHealingItem
	call ScaleBCAndDEBy4IfEither16Bit
; bc = max hp
; de = cur hp
	xor a
	ld [H_MULTIPLICAND], a
	ld a, d
	ld [H_MULTIPLICAND+1], a
	ld a, e
	ld [H_MULTIPLICAND+2], a
	ld a, 255
	ld [H_MULTIPLIER], a
	call Multiply
	ld a, c
	ld [H_DIVISOR], a
	ld b, $4
	call Divide
	ld a, [H_DIVIDEND+3]
	ld b, a
	call Random
	cp b
	jr c, .tryUsingXItem
.useFullRestore
	call AIUseFullRestore
	jp .afterSuccessfulItemUse
.tryUsingXItem
	ld a, [wEnemyMonPartyPos]
	add a
	ld e, a
	ld d, $0
	ld hl, ChampAI_EnemyUseXItemWeightingPointers
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wChampionAICurScript]
	ld e, a
	ld d, $0
	add hl, de
	ld a, [hl]
	and a
	jr z, .doNotUseHealingItem
	ld b, a
	ld c, $4
.getNonMaxedOutStatLoop
	ld a, b
	and %11
	ld hl, wEnemyMonStatMods
	ld e, a
	ld d, $0
	add hl, de
	ld a, [hl]
	cp 13
	jr c, .canUseXItem
	srl b
	srl b
	dec c
	jr nz, .getNonMaxedOutStatLoop
	jr .doNotUseHealingItem
.canUseXItem
	ld c, e
	call ChampionTryUseStatUp
	jr c, .afterSuccessfulItemUse
.doNotUseHealingItem
	ld a, [wEnemyMonPartyPos]
	add a
	ld e, a
	ld d, $0
	ld hl, ChampionBattleIndividualMonAIs
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wChampionAICurScript]
	add a
	ld e, a
	ld d, $0
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call JumpToAddress
.afterSuccessfulItemUse
	ld a, $0
	rla
	ld [wChampionUsedXItem], a
	ret

ChampAI_CheckForSpecialOrAttackBoost:
	ld b, $7 + $1
	ld a, [wPlayerMonAttackMod]
	cp b
	jr nc, .boostedAttackOrSpecial
	ld a, [wPlayerMonSpecialMod]
	cp b
	jr nc, .boostedAttackOrSpecial
	and a
	ret
.boostedAttackOrSpecial
	scf
	ret
	
ChampionBattleIndividualMonAIs:
	dw ChampAI_Charizard
	dw ChampAI_Raticate
	dw ChampAI_Clefable
	dw ChampAI_Nidoqueen
	dw ChampAI_Blastoise
	dw ChampAI_Gengar
	
ChampAI_Charizard:
	dw ChampAI_Charizard_SlashSpam
	dw ChampAI_Charizard_FissureSpam
	
ChampAI_Raticate:
	dw ChampAI_Raticate_FirstTurn
	dw ChampAI_Raticate_BodySlam
	dw ChampAI_Raticate_Thunderbolt

ChampAI_Clefable:
	dw ChampAI_Clefable_FirstTurn
	dw ChampAI_Clefable_BodySlam
	dw ChampAI_Clefable_Thunderbolt
	
ChampAI_Nidoqueen:
	dw ChampAI_Nidoqueen_UseXSpeed
	dw ChampAI_Nidoqueen_Thunderbolt
	dw ChampAI_Nidoqueen_Earthquake
	
ChampAI_Blastoise:
	dw ChampAI_Blastoise_UseXAccuracy
	dw ChampAI_Blastoise_UseXSpeed
	dw ChampAI_Blastoise_MegaKick
	
ChampAI_Gengar:
	dw ChampAI_Gengar_UseRandomMoves
	
ChampAI_EnemyUseXItemWeightingPointers:
	dw ChampAI_XItem_Charizard
	dw ChampAI_XItem_Raticate
	dw ChampAI_XItem_Clefable
	dw ChampAI_XItem_Nidoqueen
	dw ChampAI_XItem_Blastoise
	dw ChampAI_XItem_Gengar
	
ChampAI_XItem_Charizard:
	weighstats 0, 0, 0, 0
	weighstats SPD, SPC, DFN, ATK
	
ChampAI_XItem_Raticate:
	weighstats 0, 0, 0, 0
	weighstats ATK, SPD, SPC, DFN
	weighstats SPC, SPD, ATK, DFN

ChampAI_XItem_Clefable:
	weighstats 0, 0, 0, 0
	weighstats ATK, SPC, SPD, DFN
	weighstats SPC, SPD, ATK, DFN
ChampAI_XItem_Gengar:
	weighstats 0, 0, 0, 0
	
ChampAI_XItem_Nidoqueen:
	weighstats SPD, SPC, ATK, DFN
	weighstats SPC, SPD, ATK, DFN
	weighstats ATK, SPC, SPD, DFN
	
ChampAI_XItem_Blastoise:
	weighstats ATK, SPC, SPD, DFN
	weighstats ATK, SPC, SPD, DFN
	weighstats SPC, ATK, SPD, DFN
	
ChampAI_Charizard_SlashSpam:
	ld hl, wPlayerMonStatMods
	lb bc, 7 + 1, $6 ; 6 mods in total
.checkStatModsLoop
	ld a, [hli]
	cp b
	jr nc, .statWasBoosted
	dec c
	jr nz, .checkStatModsLoop
; forbid everything but slash
	jp ChampAI_ChooseMove3
	
.statWasBoosted
	call AIUseXAccuracy
	
	ld a, $1
	ld [wChampionAICurScript], a
	scf
	ret

ChampAI_Charizard_FissureSpam:
	call ComparePlayerAndEnemySpeed
	jp c, ChampAI_ChooseMove4
; use x speed or slash
	call ComparePlayerAndEnemySpeed_EnemyHasSpeedBoost
	jp c, AIUseXSpeed
	call ChampionTryUseXSpeed
	ret c
	jp ChampAI_ChooseMove3
	
ChampAI_Clefable_FirstTurn:
ChampAI_Raticate_FirstTurn:
	dmgcmpstats ATK, 1, SPC, 1
	call CompareDamageBetweenBodySlamAndThunderbolt
	jr c, .useBodySlam
; x spc tbolt
	call AIUseXSpecial
	ld a, $2
	jr .writeChampionAICurScript
.useBodySlam
	call AIUseXAttack
	ld a, $1
.writeChampionAICurScript
	ld [wChampionAICurScript], a
	scf
	ret

ChampAI_Clefable_BodySlam:
	call Random
	cp 25
	jr nc, ChampAI_Raticate_BodySlam
	jp ChampAI_ChooseMove4
	
ChampAI_Raticate_BodySlam:
	call CompareDamageBetweenBodySlamAndThunderbolt_NoStatModifying
	jp c, ChampAI_ChooseMove1
; switch to thunderbolt, with a chance of using an x special
	ld a, $2
	ld [wChampionAICurScript], a
	ld c, SPC
	call ChampionTryUseStatUp
	ret c
	jp ChampAI_ChooseMove2

ChampAI_Clefable_Thunderbolt:
	call Random
	cp 25
	jr nc, ChampAI_Raticate_Thunderbolt
	jp ChampAI_ChooseMove4
	
ChampAI_Raticate_Thunderbolt:
	call CompareDamageBetweenBodySlamAndThunderbolt_NoStatModifying
	jp nc, ChampAI_ChooseMove2
; switch to body slam, with a chance of using an x attack
	ld a, $1
	ld [wChampionAICurScript], a
	ld c, ATK
	call ChampionTryUseStatUp
	ret c
	jp ChampAI_ChooseMove1
	
ChampAI_Nidoqueen_UseXSpeed:
	call ComparePlayerAndEnemySpeed
	jr c, .checkForXAccuracy
	call ComparePlayerAndEnemySpeed_EnemyHasSpeedBoost
	jr nc, .doNotTryUsingXSpeed
	ld c, SPD
	call ChampionTryUseStatUp
	ret c
.doNotTryUsingXSpeed
	dmgcmpstats ATK, 1, SPC, 1
	lb de, EARTHQUAKE, THUNDERBOLT
	call CompareDamageBetweenTwoMoves
	jr c, .useEarthquake
	ld a, [wEnemyMonSpecialMod]
	cp 8
	jr c, .useXSpecial
	ld a, $1
	ld [wChampionAICurScript], a
	ld c, SPC
	call ChampionTryUseStatUp
	ret c
	jp ChampAI_ChooseMove2
.useXSpecial
	call AIUseXSpecial
	ld a, $1
	jr .setChampionCurScript
.useEarthquake
	ld a, [wEnemyMonAttackMod]
	cp 8
	jr c, .useXAttack
	ld a, $2
	ld [wChampionAICurScript], a
	ld c, ATK
	call ChampionTryUseStatUp
	ret c
	jp ChampAI_ChooseMove4
.useXAttack
	call AIUseXAttack
	ld a, $2
.setChampionCurScript
	ld [wChampionAICurScript], a
	scf
	ret
	
.checkForXAccuracy
	ld hl, wEnemyBattleStatus2
	bit UsingXAccuracy, [hl]
	jp nz, ChampAI_ChooseMove1
	call AIUseXAccuracy
	scf
	ret
	
ChampAI_Nidoqueen_Thunderbolt:
	dmgcmpstats ATK, 0, SPC, 0
	lb de, EARTHQUAKE, THUNDERBOLT
	call CompareDamageBetweenTwoMoves
	jp nc, ChampAI_ChooseMove2
; try to horn drill again
	ld c, SPD
	call ChampionTryUseStatUp
	jr c, .goBackToXSpeed
	ld a, $2
	ld [wChampionAICurScript], a
	ld c, ATK
	call ChampionTryUseStatUp
	ret c
	jp ChampAI_ChooseMove4
.goBackToXSpeed
	xor a
	ld [wChampionAICurScript], a
	scf
	ret
	
ChampAI_Nidoqueen_Earthquake:
	dmgcmpstats ATK, 0, SPC, 0
	lb de, EARTHQUAKE, THUNDERBOLT
	call CompareDamageBetweenTwoMoves
	jp c, ChampAI_ChooseMove4
; try to use horn drill again
	ld c, SPD
	call ChampionTryUseStatUp
	jr c, .goBackToXSpeed
	ld a, $1
	ld [wChampionAICurScript], a
	ld c, SPC
	call ChampionTryUseStatUp
	ret c
	jp ChampAI_ChooseMove2
.goBackToXSpeed
	xor a
	ld [wChampionAICurScript], a
	scf
	ret
	
ChampAI_Blastoise_UseXAccuracy:
	call AIUseXAccuracy
	ld a, $1
	ld [wChampionAICurScript], a
	scf
	ret

ChampAI_Blastoise_UseXSpeed:
	call ComparePlayerAndEnemySpeed
	jp c, ChampAI_ChooseMove4
	call ComparePlayerAndEnemySpeed_EnemyHasSpeedBoost
	jr nc, .doNotUseXSpeed
	ld c, SPD
	call ChampionTryUseStatUp
	ret c
.doNotUseXSpeed
	
	ld a, $2
	ld [wChampionAICurScript], a
	
	ld a, [wEnemyMonAttackMod]
	cp 8
	jp c, AIUseXAttack
	ld c, ATK
	call ChampionTryUseStatUp
	ret c
	jp ChampAI_ChooseMove3
	
ChampAI_Blastoise_MegaKick:
	ld a, MEGA_KICK
	call ReadMove
	callab TestDamage
	ld hl, wBattleMonMaxHP
	ld a, [hli]
	ld b, a
	ld c, [hl]
	
	ld hl, wDamage
	ld a, [hli]
	ld l, [hl]
	ld h, a
; bc = player max hp
; hl = potential damage

; multiply potential damage by 3
	ld d, h
	ld e, l
	add hl, hl
	add hl, de
	
; is potential damage * 3 > max hp?
; hl - bc
	ld a, l
	sub c
	ld a, h
	sbc b
	jr nc, .useMegaKick
; try to attempt to use an x item
	call ChampionTryUseXSpeed
	jr c, .goBackToXSpeed
	call Random
	cp 25 ; ~10% of using ice beam instead of mega kick
	jp c, ChampAI_ChooseMove2
.useMegaKick
	jp ChampAI_ChooseMove3
.goBackToXSpeed
	ld a, $1
	ld [wChampionAICurScript], a
	scf
	ret
	
ChampAI_Gengar_UseRandomMoves:
	and a
	ret
	
CompareDamageBetweenBodySlamAndThunderbolt_NoStatModifying:
	dmgcmpstats ATK, 0, SPC, 0
	
CompareDamageBetweenBodySlamAndThunderbolt:
	lb de, BODY_SLAM, THUNDERBOLT
	
; fallthrough
CompareDamageBetweenTwoMoves:
; compares the damage the selected two moves would do
; input:
; b:
; - which stat to boost for first attack
; - low nybble = number of boosts from current stat mod, high nybble = which stat
; c: 
; - which stat to boost for second attack
; - low nybble = number of boosts from current stat mod, high nybble = which stat
; d: move 1
; e: move 2
; output:
; carry if move1 > move2, no carry if move2 < move1
	push bc
	push de
	ld c, d
	call TestDamage
	ld a, [wDamage]
	ld [wSavedDamage], a
	ld a, [wDamage+1]
	ld [wSavedDamage+1], a
	pop de
	pop bc
	ld b, c
	ld c, e
	call TestDamage
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage+1]
	ld c, a
	ld a, [wSavedDamage]
	ld d, a
	ld a, [wSavedDamage+1]
	ld e, a
; bc = move1 damage
; de = move2 damage
	ld a, e
	sub c
	ld a, d
	sbc b
	ret

TestDamage:
	push bc
	ld a, b
	swap a
	and $f
	ld e, a
	ld d, $0
	ld hl, wEnemyMonStatMods
	add hl, de
	
	ld a, b
	and $f
	add [hl]
	cp 13
	jr c, .doNotSetMaxStatModValue
	ld a, 13
.doNotSetMaxStatModValue
	ld [hl], a
	push hl ; address of modified stat mod
	
	ld a, c
	call ReadMove
	ld a, b
	swap a
	and $f
	ld c, a ; index for CalculateModifiedStat
	
	push bc
	ld hl, wEnemyMonAttack
	ld de, wGrassRate
	ld bc, NUM_STATS * 2
	call CopyData
	pop bc
	
	call CalculateModifiedStatWithBadgeBoosts
	callab _TestDamage
	
	ld hl, wGrassRate
	ld de, wEnemyMonAttack
	ld bc, NUM_STATS * 2
	call CopyData
	
	pop hl ; restore address of modified stat mod
	pop bc ; restore number of boosts
	ld a, b
	and $f
	ld b, a
	ld a, [hl]
	sub b
	ld [hl], a
	ret


ChampAI_ChooseMove1:
	xor a
	jr ChampAI_ChooseMoveInA
	
ChampAI_ChooseMove2:
	ld a, $1
	jr ChampAI_ChooseMoveInA
	
ChampAI_ChooseMove3:
	ld a, $2
	jr ChampAI_ChooseMoveInA
	
ChampAI_ChooseMove4:
	ld a, $3

ChampAI_ChooseMoveInA:
; choose the move with index in a
	ld hl, wBuffer
	ld c, a
	xor a
.loop
	cp c
	jr z, .skip
	ld [hl], $50
.skip
	inc hl
	inc a
	cp NUM_MOVES
	jr nz, .loop
	and a ; reset carry
	ret

ComparePlayerAndEnemySpeed_EnemyHasSpeedBoost:
; check if using an x speed would result in the enemy
; outspeeding the player
	ld a, [wEnemyMonSpeedMod]
	cp 13
	ret nc ; if we can't boost anymore, do not bother recalculating
	inc a
	ld [wEnemyMonSpeedMod], a
	
	ld a, [wEnemyMonSpeed]
	ld b, a
	ld a, [wEnemyMonSpeed+1]
	ld c, a
	push bc ; store the speed to prevent it from being overwritten
	
	ld c, SPC
	call CalculateModifiedStatWithBadgeBoosts
	call ComparePlayerAndEnemySpeed
	pop bc
	ld a, b
	ld [wEnemyMonSpeed], a
	ld a, c
	ld [wEnemyMonSpeed+1], a
	
	push af ; save flags
	ld hl, wEnemyMonSpeedMod
	dec [hl]
	pop af
	ret
	
CalculateModifiedStatWithBadgeBoosts:
	ld a, $1
	ld [wCalculateWhoseStats], a
	jpab _CalculateModifiedStatWithBadgeBoosts

ComparePlayerAndEnemySpeed:
; compare PSpeed and ESpeed
; output:
; carry if enemy is faster
; no carry if enemy is slower
; zero flag if speedtie
	push bc
	push de
	ld a, [wBattleMonSpeed]
	ld b, a
	ld a, [wBattleMonSpeed+1]
	ld c, a
	ld a, [wEnemyMonSpeed]
	ld d, a
	ld a, [wEnemyMonSpeed+1]
	ld e, a
; bc = player speed
; de = enemy speed
	ld a, c
	sub e
	ld a, b
	sbc d
	pop de
	pop bc
	ret

ChampionTryUseXSpeed:
	ld a, SPD
	ld [wSavedChampionStatItem], a
	jr _ChampionTryUseXSpeed

ChampionTryUseStatUp:
; input:
; c = current stat (0 = attack, 1 = def...)
	ld a, c
	ld [wSavedChampionStatItem], a
	
	ld hl, wEnemyMonStatMods
	ld b, $0
	add hl, bc
	ld a, [hl]
	
	dec a
	ld e, a
	ld d, $0
	ld hl, StatModifierProbabilityTable
	add hl, de
	ld b, [hl]
	call Random
	cp b ; is rand < probability value?
	ret nc ; if not, do not stat up
; also factor in current HP
_ChampionTryUseXSpeed:
	ld a, [wSavedChampionStatItem]
	ld c, a
	ld b, $0
	ld hl, wEnemyMonStatMods
	add hl, bc
	ld a, [hl]
	cp 13
	ret nc
	
	ld hl, wEnemyMonHP
	ld a, [hli]
	ld d, a
	ld e, [hl]
	
	ld hl, wEnemyMonMaxHP
	ld a, [hli]
	ld b, a
	ld c, [hl]

; cur - max
	ld a, d
	cp b
	jr nz, .calculate
	ld a, e
	cp c
	jr z, .success
.calculate
	call ScaleBCAndDEBy4IfEither16Bit
	xor a
	ld [H_MULTIPLICAND], a
	ld a, d
	ld [H_MULTIPLICAND+1], a
	ld a, e
	ld [H_MULTIPLICAND+2], a
	
	ld a, 255
	ld [H_MULTIPLIER], a
	call Multiply
	
	ld a, c
	ld [H_DIVISOR], a
	ld b, $4
	call Divide
	ld a, [H_QUOTIENT+3]
	ld b, a
; do the following probability check twice:
; check if a random number is less than the quotient
; if either checks succeed, use an x item
	call Random
	cp b
	jr c, .success
	call Random
	cp b
	ret nc
.success
	ld a, [wSavedChampionStatItem]
	ld c, a
	ld a, ATTACK_UP1_EFFECT
	add c
	ld b, a
	ld a, c
	add X_ATTACK
	jp AIIncreaseStat
	
StatModifierProbabilityTable:
	db 223
	db 218
	db 212
	db 204
	db 191
	db 170
	db 127
	db 85
	db 63
	db 51
	db 42
	db 36
	db 31
	
ScaleBCAndDEBy4IfEither16Bit:
	ld a, b
	and a
	jr nz, .scaleStats
	ld a, d
	and a
	ret z
.scaleStats
	srl b
	rr c
	srl b
	rr c
	ld a, b
	or c
	jr nz, .nonZeroValue
	inc c
.nonZeroValue
	srl d
	rr e
	srl d
	rr e
	ld a, d
	or e
	ret nz
	inc e
	ret

ReadMove: ; 39884 (e:5884)
	push hl
	push de
	push bc
	dec a
	ld hl,Moves
	ld bc,MoveEnd - Moves
	call AddNTimes
	ld de,wEnemyMoveNum
	call CopyData
	pop bc
	pop de
	pop hl
	ret

; move choice modification methods that are applied for each trainer class
; 0 is sentinel value
TrainerClassMoveChoiceModifications: ; 3989b (e:589b)
	db 0      ; YOUNGSTER
	db 1,0    ; BUG CATCHER
	db 1,0    ; LASS
	db 1,3,0  ; SAILOR
	db 1,0    ; JR_TRAINER_M
	db 1,0    ; JR_TRAINER_F
	db 1,2,3,0; POKEMANIAC
	db 1,2,0  ; SUPER_NERD
	db 1,0    ; HIKER
	db 1,0    ; BIKER
	db 1,3,0  ; BURGLAR
	db 1,0    ; ENGINEER
	db 1,2,0  ; JUGGLER_X
	db 1,3,0  ; FISHER
	db 1,3,0  ; SWIMMER
	db 0      ; CUE_BALL
	db 1,0    ; GAMBLER
	db 1,3,0  ; BEAUTY
	db 1,2,0  ; PSYCHIC_TR
	db 1,3,0  ; ROCKER
	db 1,0    ; JUGGLER
	db 1,0    ; TAMER
	db 1,0    ; BIRD_KEEPER
	db 1,0    ; BLACKBELT
	db 1,0    ; SONY1
	db 1,3,0  ; PROF_OAK
	db 1,2,0  ; CHIEF
	db 1,2,0  ; SCIENTIST
	db 1,3,0  ; GIOVANNI
	db 1,0    ; ROCKET
	db 1,3,0  ; COOLTRAINER_M
	db 1,3,0  ; COOLTRAINER_F
	db 1,0    ; BRUNO
	db 1,0    ; BROCK
	db 1,3,0  ; MISTY
	db 1,3,0  ; LT_SURGE
	db 1,3,0  ; ERIKA
	db 1,3,0  ; KOGA
	db 1,3,0  ; BLAINE
	db 1,3,0  ; SABRINA
	db 1,2,0  ; GENTLEMAN
	db 1,3,0  ; SONY2
	db 4,0    ; SONY3
	db 1,2,3,0; LORELEI
	db 1,0    ; CHANNELER
	db 1,0    ; AGATHA
	db 1,3,0  ; LANCE
	db 1,3,0  ; SONY4

INCLUDE "engine/battle/trainer_pic_money_pointers.asm"

INCLUDE "text/trainer_names.asm"

INCLUDE "engine/battle/bank_e_misc.asm"

INCLUDE "engine/battle/read_trainer_party.asm"

INCLUDE "data/trainer_moves.asm"

INCLUDE "data/trainer_parties.asm"

TrainerAI: ; 3a52e (e:652e)
	and a
	ld a,[wIsInBattle]
	dec a
	ret z ; if not a trainer, we're done here
	ld a,[wLinkState]
	cp LINK_STATE_BATTLING
	ret z
	ld a,[wTrainerClass] ; what trainer class is this?
	dec a
	ld c,a
	ld b,0
	ld hl,TrainerAIPointers
	add hl,bc
	add hl,bc
	add hl,bc
	ld a,[wAICount]
	and a
	ret z ; if no AI uses left, we're done here
	inc hl
	inc a
	jr nz,.getpointer
	dec hl
	ld a,[hli]
	ld [wAICount],a
.getpointer
	ld a,[hli]
	ld h,[hl]
	ld l,a
	call Random
	jp hl

TrainerAIPointers: ; 3a55c (e:655c)
; one entry per trainer class
; first byte, number of times (per Pokémon) it can occur
; next two bytes, pointer to AI subroutine for trainer class
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,JugglerAI ; juggler_x
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,JugglerAI ; juggler
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 2,BlackbeltAI ; blackbelt
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 1,GenericAI ; chief
	dbw 3,GenericAI
	dbw 1,GiovanniAI ; giovanni
	dbw 3,GenericAI
	dbw 2,CooltrainerMAI ; cooltrainerm
	dbw 1,CooltrainerFAI ; cooltrainerf
	dbw 2,BrunoAI ; bruno
	dbw 5,BrockAI ; brock
	dbw 1,MistyAI ; misty
	dbw 1,LtSurgeAI ; surge
	dbw 1,ErikaAI ; erika
	dbw 2,KogaAI ; koga
	dbw 2,BlaineAI ; blaine
	dbw 1,SabrinaAI ; sabrina
	dbw 3,GenericAI
	dbw 1,Sony2AI ; sony2
	dbw 1,GenericAI ; sony3
	dbw 2,LoreleiAI ; lorelei
	dbw 3,GenericAI
	dbw 2,AgathaAI ; agatha
	dbw 1,LanceAI ; lance
	dbw 1,GenericAI

JugglerAI: ; 3a5e9 (e:65e9)
	cp $40
	ret nc
	jp AISwitchIfEnoughMons

BlackbeltAI: ; 3a5ef (e:65ef)
	cp $20
	ret nc
	jp AIUseXAttack

GiovanniAI: ; 3a5f5 (e:65f5)
	cp $40
	ret nc
	jp AIUseGuardSpec

CooltrainerMAI: ; 3a5fb (e:65fb)
	cp $40
	ret nc
	jp AIUseXAttack

CooltrainerFAI: ; 3a601 (e:6601)
	cp $40
	ld a,$A
	call AICheckIfHPBelowFraction
	jp c,AIUseHyperPotion
	ld a,5
	call AICheckIfHPBelowFraction
	ret nc
	jp AISwitchIfEnoughMons

BrockAI: ; 3a614 (e:6614)
; if his active monster has a status condition, use a full heal
	ld a,[wEnemyMonStatus]
	and a
	ret z
	jp AIUseFullHeal

MistyAI: ; 3a61c (e:661c)
	cp $40
	ret nc
	jp AIUseXDefend

LtSurgeAI: ; 3a622 (e:6622)
	cp $40
	ret nc
	jp AIUseXSpeed

ErikaAI: ; 3a628 (e:6628)
	cp $80
	ret nc
	ld a,$A
	call AICheckIfHPBelowFraction
	ret nc
	jp AIUseSuperPotion

KogaAI: ; 3a634 (e:6634)
	cp $40
	ret nc
	jp AIUseXAttack

BlaineAI: ; 3a63a (e:663a)
	cp $40
	ret nc
	jp AIUseSuperPotion

SabrinaAI: ; 3a640 (e:6640)
	cp $40
	ret nc
	ld a,$A
	call AICheckIfHPBelowFraction
	ret nc
	jp AIUseHyperPotion

Sony2AI: ; 3a64c (e:664c)
	cp $20
	ret nc
	ld a,5
	call AICheckIfHPBelowFraction
	ret nc
	jp AIUsePotion

Sony3AI: ; 3a658 (e:6658)
	cp $20
	ret nc
	ld a,5
	call AICheckIfHPBelowFraction
	ret nc
	jp AIUseFullRestore

LoreleiAI: ; 3a664 (e:6664)
	cp $80
	ret nc
	ld a,5
	call AICheckIfHPBelowFraction
	ret nc
	jp AIUseSuperPotion

BrunoAI: ; 3a670 (e:6670)
	cp $40
	ret nc
	jp AIUseXDefend

AgathaAI: ; 3a676 (e:6676)
	cp $14
	jp c,AISwitchIfEnoughMons
	cp $80
	ret nc
	ld a,4
	call AICheckIfHPBelowFraction
	ret nc
	jp AIUseSuperPotion

LanceAI: ; 3a687 (e:6687)
	cp $80
	ret nc
	ld a,5
	call AICheckIfHPBelowFraction
	ret nc
	jp AIUseHyperPotion

GenericAI: ; 3a693 (e:6693)
	and a ; clear carry
	ret

; end of individual trainer AI routines

DecrementAICount: ; 3a695 (e:6695)
	ld hl,wAICount
	dec [hl]
	scf
	ret

AIPlayRestoringSFX: ; 3a69b (e:669b)
	ld a,SFX_HEAL_AILMENT
	jp PlaySoundWaitForCurrent

AIUseFullRestore: ; 3a6a0 (e:66a0)
	call AICureStatus
	ld a,FULL_RESTORE
	ld [wAIItem],a
	ld de,wHPBarOldHP
	ld hl,wEnemyMonHP + 1
	ld a,[hld]
	ld [de],a
	inc de
	ld a,[hl]
	ld [de],a
	inc de
	ld hl,wEnemyMonMaxHP + 1
	ld a,[hld]
	ld [de],a
	inc de
	ld [wHPBarMaxHP],a
	ld [wEnemyMonHP + 1],a
	ld a,[hl]
	ld [de],a
	ld [wHPBarMaxHP+1],a
	ld [wEnemyMonHP],a
	jr AIPrintItemUseAndUpdateHPBar

AIUsePotion: ; 3a6ca (e:66ca)
; enemy trainer heals his monster with a potion
	ld a,POTION
	ld b,20
	jr AIRecoverHP

AIUseSuperPotion: ; 3a6d0 (e:66d0)
; enemy trainer heals his monster with a super potion
	ld a,SUPER_POTION
	ld b,50
	jr AIRecoverHP

AIUseHyperPotion: ; 3a6d6 (e:66d6)
; enemy trainer heals his monster with a hyper potion
	ld a,HYPER_POTION
	ld b,200
	; fallthrough

AIRecoverHP: ; 3a6da (e:66da)
; heal b HP and print "trainer used $(a) on pokemon!"
	ld [wAIItem],a
	ld hl,wEnemyMonHP + 1
	ld a,[hl]
	ld [wHPBarOldHP],a
	add b
	ld [hld],a
	ld [wHPBarNewHP],a
	ld a,[hl]
	ld [wHPBarOldHP+1],a
	ld [wHPBarNewHP+1],a
	jr nc,.next
	inc a
	ld [hl],a
	ld [wHPBarNewHP+1],a
.next
	inc hl
	ld a,[hld]
	ld b,a
	ld de,wEnemyMonMaxHP + 1
	ld a,[de]
	dec de
	ld [wHPBarMaxHP],a
	sub b
	ld a,[hli]
	ld b,a
	ld a,[de]
	ld [wHPBarMaxHP+1],a
	sbc b
	jr nc,AIPrintItemUseAndUpdateHPBar
	inc de
	ld a,[de]
	dec de
	ld [hld],a
	ld [wHPBarNewHP],a
	ld a,[de]
	ld [hl],a
	ld [wHPBarNewHP+1],a
	; fallthrough

AIPrintItemUseAndUpdateHPBar: ; 3a718 (e:6718)
	call AIPrintItemUse_
	coord hl, 2, 2
	xor a
	ld [wHPBarType],a
	predef UpdateHPBar2
	jp DecrementAICount

AISwitchIfEnoughMons: ; 3a72a (e:672a)
; enemy trainer switches if there are 3 or more unfainted mons in party
	ld a,[wEnemyPartyCount]
	ld c,a
	ld hl,wEnemyMon1HP

	ld d,0 ; keep count of unfainted monsters

	; count how many monsters haven't fainted yet
.loop
	ld a,[hli]
	ld b,a
	ld a,[hld]
	or b
	jr z,.Fainted ; has monster fainted?
	inc d
.Fainted
	push bc
	ld bc, wEnemyMon2 - wEnemyMon1
	add hl,bc
	pop bc
	dec c
	jr nz,.loop

	ld a,d ; how many available monsters are there?
	cp 2 ; don't bother if only 1 or 2
	jp nc,SwitchEnemyMon
	and a
	ret

SwitchEnemyMon: ; 3a74b (e:674b)

; prepare to withdraw the active monster: copy hp, number, and status to roster

	ld a,[wEnemyMonPartyPos]
	ld hl,wEnemyMon1HP
	ld bc,wEnemyMon2 - wEnemyMon1
	call AddNTimes
	ld d,h
	ld e,l
	ld hl,wEnemyMonHP
	ld bc,4
	call CopyData

	ld hl, AIBattleWithdrawText
	call PrintText

	; This wFirstMonsNotOutYet variable is abused to prevent the player from
	; switching in a new mon in response to this switch.
	ld a,1
	ld [wFirstMonsNotOutYet],a
	callab EnemySendOut
	xor a
	ld [wFirstMonsNotOutYet],a

	ld a,[wLinkState]
	cp LINK_STATE_BATTLING
	ret z
	scf
	ret

AIBattleWithdrawText: ; 3a781 (e:6781)
	TX_FAR _AIBattleWithdrawText
	db "@"

AIUseFullHeal: ; 3a786 (e:6786)
	call AIPlayRestoringSFX
	call AICureStatus
	ld a,FULL_HEAL
	jp AIPrintItemUse

AICureStatus: ; 3a791 (e:6791)
; cures the status of enemy's active pokemon
	ld a,[wEnemyMonPartyPos]
	ld hl,wEnemyMon1Status
	ld bc,wEnemyMon2 - wEnemyMon1
	call AddNTimes
	xor a
	ld [hl],a ; clear status in enemy team roster
	ld [wEnemyMonStatus],a ; clear status of active enemy
	ld hl,wEnemyBattleStatus3
	res 0,[hl]
	ret

AIUseXAccuracy: ; 0x3a7a8 unused
	call AIPlayRestoringSFX
	ld hl,wEnemyBattleStatus2
	set 0,[hl]
	ld a,X_ACCURACY
	jp AIPrintItemUse

AIUseGuardSpec: ; 3a7b5 (e:67b5)
	call AIPlayRestoringSFX
	ld hl,wEnemyBattleStatus2
	set 1,[hl]
	ld a,GUARD_SPEC
	jp AIPrintItemUse

AIUseDireHit: ; 0x3a7c2 unused
	call AIPlayRestoringSFX
	ld hl,wEnemyBattleStatus2
	set 2,[hl]
	ld a,DIRE_HIT
	jp AIPrintItemUse

AICheckIfHPBelowFraction: ; 3a7cf (e:67cf)
; return carry if enemy trainer's current HP is below 1 / a of the maximum
	ld [H_DIVISOR],a
	ld hl,wEnemyMonMaxHP
	ld a,[hli]
	ld [H_DIVIDEND],a
	ld a,[hl]
	ld [H_DIVIDEND + 1],a
	ld b,2
	call Divide
	ld a,[H_QUOTIENT + 3]
	ld c,a
	ld a,[H_QUOTIENT + 2]
	ld b,a
	ld hl,wEnemyMonHP + 1
	ld a,[hld]
	ld e,a
	ld a,[hl]
	ld d,a
	ld a,d
	sub b
	ret nz
	ld a,e
	sub c
	ret

AIUseXAttack: ; 3a7f2 (e:67f2)
	ld b,$A
	ld a,X_ATTACK
	jr AIIncreaseStat

AIUseXDefend: ; 3a7f8 (e:67f8)
	ld b,$B
	ld a,X_DEFEND
	jr AIIncreaseStat

AIUseXSpeed: ; 3a7fe (e:67fe)
	ld b,$C
	ld a,X_SPEED
	jr AIIncreaseStat

AIUseXSpecial: ; 3a804 (e:6804)
	ld b,$D
	ld a,X_SPECIAL
	; fallthrough

AIIncreaseStat: ; 3a808 (e:6808)
	ld [wAIItem],a
	ld a, [H_WHOSETURN]
	push af
	ld a, $1
	ld [H_WHOSETURN], a
	push bc
	call AIPrintItemUse_
	pop bc
	ld hl,wEnemyMoveEffect
	ld a,[hld]
	push af
	ld a,[hl]
	push af
	push hl
	ld a,ANIM_AF
	ld [hli],a
	ld [hl],b
	callab StatModifierUpEffect
	pop hl
	pop af
	ld [hli],a
	pop af
	ld [hl],a
	pop af
	ld [H_WHOSETURN], a
	jp DecrementAICount

AIPrintItemUse: ; 3a82c (e:682c)
	ld [wAIItem],a
	call AIPrintItemUse_
	jp DecrementAICount

AIPrintItemUse_: ; 3a835 (e:6835)
; print "x used [wAIItem] on z!"
	ld a,[wAIItem]
	ld [wd11e],a
	call GetItemName
	ld hl, AIBattleUseItemText
	jp PrintText

AIBattleUseItemText: ; 3a844 (e:6844)
	TX_FAR _AIBattleUseItemText
	db "@"
