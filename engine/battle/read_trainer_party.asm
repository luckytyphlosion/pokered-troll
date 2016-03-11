ReadTrainer: ; 39c53 (e:5c53)

; don't change any moves in a link battle
	ld a,[wLinkState]
	and a
	ret nz

; set [wEnemyPartyCount] to 0, [wEnemyPartyMons] to FF
; XXX first is total enemy pokemon?
; XXX second is species of first pokemon?
	ld hl,wEnemyPartyCount
	xor a
	ld [hli],a
	dec a
	ld [hl],a

; get the pointer to trainer data for this class
	ld a,[wCurOpponent]
	sub $C9 ; convert value from pokemon to trainer
	add a,a
	ld hl,TrainerDataPointers
	ld c,a
	ld b,0
	add hl,bc ; hl points to trainer class
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ld a,[wTrainerNo]
	ld b,a
; At this point b contains the trainer number,
; and hl points to the trainer class.
; Our next task is to iterate through the trainers,
; decrementing b each time, until we get to the right one.
.outer
	dec b
	jr z,.IterateTrainer
.inner
	ld a,[hli]
	and a
	jr nz,.inner
	jr .outer

; if the first byte of trainer data is FF,
; - each pokemon has a specific level
;      (as opposed to the whole team being of the same level)
; - if [wLoneAttackNo] != 0, one pokemon on the team has a special move
; else the first byte is the level of every pokemon on the team
.IterateTrainer
	ld a,[hli]
	cp $FF ; is the trainer special?
	jr z,.SpecialTrainer ; if so, check for special moves
	cp $FE
	jr z, .championTrainer
	ld [wCurEnemyLVL],a
.LoopTrainerData
	ld a,[hli]
	and a ; have we reached the end of the trainer data?
	jp z,.finishUp
	ld [wcf91],a ; write species somewhere (XXX why?)
	ld a,ENEMY_PARTY_DATA
	ld [wMonDataLocation],a
	push hl
	call AddPartyMon
	pop hl
	jr .LoopTrainerData
.SpecialTrainer
; if this code is being run:
; - each pokemon has a specific level
;      (as opposed to the whole team being of the same level)
; - if [wLoneAttackNo] != 0, one pokemon on the team has a special move
	ld a,[hli]
	and a ; have we reached the end of the trainer data?
	jp z,.addLoneMove
	ld [wCurEnemyLVL],a
	ld a,[hli]
	ld [wcf91],a
	ld a,ENEMY_PARTY_DATA
	ld [wMonDataLocation],a
	push hl
	call AddPartyMon
	pop hl
	jr .SpecialTrainer
.championTrainer
	push hl
	ld hl, wPartySpecies
	ld c, $0
.findBlastoiseLoop
	ld a, [hli]
	cp BLASTOISE
	jr z, .foundBlastoise
	inc c
	cp $ff
	jr nz, .findBlastoiseLoop
; if the player doesn't have blastoise in the party
; troll with team with 6 level 100 mewtwos
; Kappa
.blastoiseNotHighEnoughLevel
	ld hl, TrollGreen3Data
	ld a, SONY4
	ld [wCurOpponent], a
	pop hl
	jr .SpecialTrainer
.foundBlastoise
	ld a, c
	ld bc, wPartyMon2 - wPartyMon1
	ld hl, wPartyMon1
	call AddNTimes
	ld b, h
	ld c, l
	
	ld hl, wPartyMon1HPExp - wPartyMon1
	add hl, bc
	ld a, l
	ld [wSavedPartyMonStatExpPtr], a
	ld a, h
	ld [wSavedPartyMonStatExpPtr + 1], a
	
	ld hl, wPartyMon1DVs - wPartyMon1
	add hl, bc
	ld a, [hli]
	ld [wSavedMonDVs], a
	ld a, [hl]
	ld [wSavedMonDVs + 1], a
	
	ld hl, wPartyMon1Level - wPartyMon1
	add hl, bc
	ld b, [hl]
	ld a, b
	cp 45
	jr c, .blastoiseNotHighEnoughLevel
	pop hl
	ld de, $0
.championTrainerLoop
	ld a, [hli]
	and a ; have we reached the end of the trainer data?
	jp z,.finishUp
	ld c, a ; c = enemy level
	ld a, b ; b = player level
	cp 55 ; are we level 54 or lower?
	ld a, c
	jr c, .usePresetLevel ; if so, just use the default levels
	cp 100
	jr z, .usePresetLevel ; don't buff gengar
	sub 55
	add b ; calc enemy level - 55 + player level and use that as the new level
.usePresetLevel
	ld [wCurEnemyLVL],a
	ld a,[hli]
	ld [wcf91],a
	ld a,ENEMY_PARTY_DATA
	ld [wMonDataLocation],a
	push bc
	push hl
	push de
	call AddPartyMon
	pop de
	ld a, e ; get current mon value
	ld hl, wEnemyMon1Moves
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes
	ld b, e ; save current mon value
	ld c, NUM_MOVES
	ld d, h
	ld e, l ; de = enemy moves
	pop hl
.writeChampionMovesLoop
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .writeChampionMovesLoop
	ld e, b ; restore current mon value
	pop bc
	
	push hl
	push bc
	push de
	ld a, e
	ld hl, wEnemyMon1
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes
	push hl
	ld bc, wEnemyMon1HPExp - wEnemyMon1
	add hl, bc
	ld d, h
	ld e, l
	ld a, [wSavedPartyMonStatExpPtr]
	ld l, a
	ld a, [wSavedPartyMonStatExpPtr + 1]
	ld h, a
	ld bc, NUM_STATS * 2
	call CopyData
	pop hl
	
	push hl
	ld bc, wEnemyMon1Stats - wEnemyMon1
	add hl, bc
	ld d, h
	ld e, l
	pop hl
	ld bc, wEnemyMon1HPExp - 1 - wEnemyMon1
	add hl, bc
	ld b, $1
	call CalcStats
	pop de
	pop bc
	pop hl
	inc e
	jr .championTrainerLoop
	
.addLoneMove
; does the trainer have a single monster with a different move
	ld a,[wLoneAttackNo] ; Brock is 01, Misty is 02, Erika is 04, etc
	and a
	jr z,.AddTeamMove
	dec a
	add a,a
	ld c,a
	ld b,0
	ld hl,LoneMoves
	add hl,bc
	ld a,[hli]
	ld d,[hl]
	ld hl,wEnemyMon1Moves + 2
	ld bc,wEnemyMon2 - wEnemyMon1
	call AddNTimes
	ld [hl],d
	jr .finishUp
.AddTeamMove
; check if our trainer's team has special moves

; get trainer class number
	ld a,[wCurOpponent]
	sub 200
	ld b,a
	ld hl,TeamMoves

; iterate through entries in TeamMoves, checking each for our trainer class
.IterateTeamMoves
	ld a,[hli]
	cp b
	jr z,.GiveTeamMoves ; is there a match?
	inc hl ; if not, go to the next entry
	inc a
	jr nz,.IterateTeamMoves

; no matches found. is this trainer champion rival?
	ld a,b
	cp SONY3
	jr z,.ChampionRival
	jr .finishUp ; nope
.GiveTeamMoves
	ld a,[hl]
	ld [wEnemyMon5Moves + 2],a
	jr .finishUp
.ChampionRival ; give moves to his team

; pidgeot
	ld a,SKY_ATTACK
	ld [wEnemyMon1Moves + 2],a

; starter
	ld a,[wRivalStarter]
	cp STARTER3
	ld b,MEGA_DRAIN
	jr z,.GiveStarterMove
	cp STARTER1
	ld b,FIRE_BLAST
	jr z,.GiveStarterMove
	ld b,BLIZZARD ; must be squirtle
.GiveStarterMove
	ld a,b
	ld [wEnemyMon6Moves + 2],a
.finishUp
; clear wAmountMoneyWon addresses
	xor a
	ld de,wAmountMoneyWon
	ld [de],a
	inc de
	ld [de],a
	inc de
	ld [de],a
	ld a,[wCurEnemyLVL]
	ld b,a
.LastLoop
; update wAmountMoneyWon addresses (money to win) based on enemy's level
	ld hl,wTrainerBaseMoney + 1
	ld c,2 ; wAmountMoneyWon is a 3-byte number
	push bc
	predef AddBCDPredef
	pop bc
	inc de
	inc de
	dec b
	jr nz,.LastLoop ; repeat wCurEnemyLVL times
	ret
