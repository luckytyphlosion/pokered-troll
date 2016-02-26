TreeMonBaseStats:
db DEX_RHYDON
db 70 ; base hp
db 70 ; base attack
db 70 ; base defense
db 70 ; base speed
db 70 ; base special
db GRASS ; species type 1
db GRASS ; species type 2
db 3  ; catch rate
db 1  ; base exp yield
INCBIN "pic/bmon/montree.pic",0,1 ; 66, sprite dimensions
dw MonTreePicFront
dw MagikarpPicBack
; attacks known at lvl 0
db MEGA_DRAIN
db CUT
db LEECH_LIFE
db SLEEP_POWDER
db 5 ; growth rate
; learnset
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
db 0 ; padding

MonTreePicFront:
	INCBIN "pic/bmon/montree.pic"