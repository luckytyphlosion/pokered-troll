; timer interrupt is apparently not invoked anyway
Timer:: ; 2306 (0:2306)
	push af
	push hl
	call _Timer
	pop hl
	pop af
	reti

_Timer:
    ld a, [hCenaSoundEnabled]
    and a
    ret z
   
 
    ld a,[H_LOADEDROMBANK]
    ld [hBackupBank],a
    ld          hl,hSoundBank
    ld          a,[hli]
    ld [H_LOADEDROMBANK],a
    ld [MBC1RomBank],a
    ld          a,[hli]
    ld          h,[hl]
    ld          l,a
 
    xor         a
    ldh         [rNR30],a
 
    ld          a,[hli]
    ldh         [$FF30],a
    ld          a,[hli]
    ldh         [$FF31],a
    ld          a,[hli]
    ldh         [$FF32],a
    ld          a,[hli]
    ldh         [$FF33],a
    ld          a,[hli]
    ldh         [$FF34],a
    ld          a,[hli]
    ldh         [$FF35],a
    ld          a,[hli]
    ldh         [$FF36],a
    ld          a,[hli]
    ldh         [$FF37],a
    ld          a,[hli]
    ldh         [$FF38],a
    ld          a,[hli]
    ldh         [$FF39],a
    ld          a,[hli]
    ldh         [$FF3A],a
    ld          a,[hli]
    ldh         [$FF3B],a
    ld          a,[hli]
    ldh         [$FF3C],a
    ld          a,[hli]
    ldh         [$FF3D],a
    ld          a,[hli]
    ldh         [$FF3E],a
    ld          a,[hli]
    ldh         [$FF3F],a
 
    ld          a,$80
    ldh         [rNR30],a
    ld          a,(sound_rate >> 8) | $80
    ldh         [rNR34],a
 
    bit         7,h
    jr          nz,.incbank             ;hl=$8000, increase bank
    ld          a,l
    ldh         [hSoundAddr+0],a
    ld          a,h
    ldh         [hSoundAddr+1],a
 
    jr          .exit
 
.incbank:
    ld          hl,hSoundBank
    inc         [hl]
	ld a, [hl]
	cp $5e
	jr nz, .noRepeat
	ld a, $40
	ld [hl], a
.noRepeat
    xor         a
    ldh         [hSoundAddr+0],a
    ld          a,$40
    ldh         [hSoundAddr+1],a
 
.exit:
    ld a, [hBackupBank]
    ld [H_LOADEDROMBANK],a
    ld [MBC1RomBank],a
 
    ldh         a,[rSTAT]               ;blank
    bit         1,a
    jr          nz,.exit
    ret
	