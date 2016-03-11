; timer interrupt is apparently not invoked anyway
Timer:: ; 2306 (0:2306)
	push af
	push bc
	push hl
	callab _Timer
	pop hl
	pop bc
	pop af
	reti
