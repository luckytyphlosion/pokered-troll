VermilionDockScript: ; 1db52 (7:5b52)
	call EnableAutoTextBoxDrawing
	CheckEventHL EVENT_STARTED_WALKING_OUT_OF_DOCK
	jr nz, .asm_1db8d
	CheckEventReuseHL EVENT_GOT_HM01
	ret z
	ld a, [wDestinationWarpID]
	cp $1
	ret nz
	CheckEventReuseHL EVENT_SS_ANNE_LEFT
	jp z, VermilionDock_1db9b
	SetEventReuseHL EVENT_STARTED_WALKING_OUT_OF_DOCK
	call Delay3
	ld hl, wd730
	set 7, [hl]
	ld hl, wSimulatedJoypadStatesEnd
	ld a, D_UP
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, $3
	ld [wSimulatedJoypadStatesIndex], a
	xor a
	ld [wSpriteStateData2 + $06], a
	ld [wOverrideSimulatedJoypadStatesMask], a
	dec a
	ld [wJoyIgnore], a
	ret
.asm_1db8d
	CheckEventAfterBranchReuseHL EVENT_WALKED_OUT_OF_DOCK, EVENT_STARTED_WALKING_OUT_OF_DOCK
	ret nz
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	ld [wJoyIgnore], a
	SetEventReuseHL EVENT_WALKED_OUT_OF_DOCK
	ret

VermilionDock_1db9b: ; 1db9b (7:5b9b)
	SetEventForceReuseHL EVENT_SS_ANNE_LEFT
	ld a, $ff
	ld [wJoyIgnore], a
	ld [wNewSoundID], a
	call PlaySound
	ld c, BANK(Music_Surfing)
	ld a, MUSIC_SURFING
	call PlayMusic
	callba LoadSmokeTileFourTimes
	xor a
	ld [wSpriteStateData1 + 2], a
	ld c, 120
	call DelayFrames
	ld b, $9c
	call CopyScreenTileBufferToVRAM
	coord hl, 0, 10
	ld bc, SCREEN_WIDTH * 6
	ld a, $14 ; water tile
	call FillMemory
	ld a, 1
	ld [H_AUTOBGTRANSFERENABLED], a
	call Delay3
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	ld [wSSAnneSmokeDriftAmount], a
	ld [rOBP1], a
	ld a, 88
	ld [wSSAnneSmokeX], a
	ld hl, wMapViewVRAMPointer
	ld c, [hl]
	inc hl
	ld b, [hl]
	push bc
	push hl
	ld a, SFX_SS_ANNE_HORN
	call PlaySoundWaitForCurrent
	ld a, $ff
	ld [wUpdateSpritesEnabled], a
	ld d, $0
	ld e, $8
.asm_1dbfa
	ld hl, $0002
	add hl, bc
	ld a, l
	ld [wMapViewVRAMPointer], a
	ld a, h
	ld [wMapViewVRAMPointer + 1], a
	push hl
	push de
	call ScheduleEastColumnRedraw
	call VermilionDock_EmitSmokePuff
	pop de
	ld b, $10
.asm_1dc11
	call VermilionDock_AnimSmokePuffDriftRight
	ld c, $8
.asm_1dc16
	push de
	ld a, [wOldSSAnneNoteValue]
	ld e, a
	ld a, [wChannelCommandPointers + 2]
	cp e ; has the main note changed?
	pop de
	jr z, .noteNotChanged
	ld [wOldSSAnneNoteValue], a
	ld a, d
	cpl
	ld d, a
	call VermilionDock_ComplementSmokeX
.noteNotChanged
	call VermilionDock_1dc7c
	dec c
	jr nz, .asm_1dc16
	bit 7, d
	jr z, .increment
	dec d
	dec d
.increment
	inc d
	dec b
	jr nz, .asm_1dc11
	pop bc
	dec e
	jr nz, .asm_1dbfa
	xor a
	ld [rWY], a
	ld [hWY], a
	call VermilionDock_EraseSSAnne
	ld a, $90
	ld [hWY], a
	ld a, $1
	ld [wUpdateSpritesEnabled], a
	pop hl
	pop bc
	ld [hl], b
	dec hl
	ld [hl], c
	call LoadPlayerSpriteGraphics
	ld hl, wNumberOfWarps
	dec [hl]
	ret

VermilionDock_AnimSmokePuffDriftRight: ; 1dc42 (7:5c42)
	push bc
	push de
	ld hl, wOAMBuffer + $11
	ld a, [wSSAnneSmokeDriftAmount]
	swap a
	ld e, a
	ld bc, 4
.loop
	bit 7, d
	jr z, .increment
	dec [hl]
	dec [hl]
.increment
	inc [hl]
	add hl, bc
	dec e
	jr nz, .loop
	pop de
	pop bc
	ret

VermilionDock_ComplementSmokeX:
	push bc
	push de
	ld hl, wOAMBuffer + $11
	ld de, $4
	ld a, [wSSAnneSmokeDriftAmount]
	swap a
	ld c, a
.loop
	ld a, SCREEN_WIDTH_PIXELS + 8
	sub [hl]
	ld [hl], a
	add hl, de
	dec c
	jr nz, .loop
	pop de
	pop bc
	ret
	
	
VermilionDock_EmitSmokePuff: ; 1dc59 (7:5c59)
; new smoke puff above the S.S. Anne's front smokestack
	ld a, [wSSAnneSmokeX]
	sub 16
	ld [wSSAnneSmokeX], a
	ld c, a
	ld b, 100 ; Y
	ld a, [wSSAnneSmokeDriftAmount]
	inc a
	ld [wSSAnneSmokeDriftAmount], a
	ld a, $1
	ld de, VermilionDockOAMBlock
	call WriteOAMBlock
	ret

VermilionDockOAMBlock: ; 1dc74 (7:5c74)
	db $fc, $10
	db $fd, $10
	db $fe, $10
	db $ff, $10

VermilionDock_1dc7c: ; 1dc7c (7:5c7c)
	ld h, d
	ld l, $50
	call .asm_1dc86
	ld h, $0
	ld l, $80
.asm_1dc86
	ld a, [rLY]
	cp l
	jr nz, .asm_1dc86
	ld a, h
	ld [rSCX], a
.asm_1dc8e
	ld a, [rLY]
	cp h
	jr z, .asm_1dc8e
	ret

VermilionDock_EraseSSAnne: ; 1dc94 (7:5c94)
; Fill the area the S.S. Anne occupies in BG map 0 with water tiles.
	ld hl, wVermilionDockTileMapBuffer
	ld bc, (5 * BG_MAP_WIDTH) + SCREEN_WIDTH
	ld a, $14 ; water tile
	call FillMemory
	ld hl, vBGMap0 + 10 * BG_MAP_WIDTH
	ld de, wVermilionDockTileMapBuffer
	ld bc, (6 * BG_MAP_WIDTH) / 16
	call CopyVideoData

; Replace the blocks of the lower half of the ship with water blocks. This
; leaves the upper half alone, but that doesn't matter because replacing any of
; the blocks is unnecessary because the blocks the ship occupies are south of
; the player and won't be redrawn when the player automatically walks north and
; exits the map. This code could be removed without affecting anything.
	overworldMapCoord hl, 5, 2, VERMILION_DOCK_WIDTH
	ld a, $d ; water block
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a

	ld a, SFX_SS_ANNE_HORN
	call PlaySound
	ld c, 120
	call DelayFrames
	ret

VermilionDockTextPointers: ; 1dcbf (7:5cbf)
	dw VermilionDockText1

VermilionDockText1: ; 1dcc1 (7:5cc1)
	TX_FAR _VermilionDockText1
	db "@"
