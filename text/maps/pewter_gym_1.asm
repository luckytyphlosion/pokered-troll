_PewterGymText_5c49e::
	text "I'm BROCK!"
	line "I'm PEWTER's GYM"
	cont "LEADER!"

	para "I believe in rock"
	line "hard defense and"
	cont "determination!"

	para "That's why my"
	line "#MON are all"
	cont "the rock-type!"
	prompt

_PewterGymText_BrockTextContinued::
	text "Do you still want"
	line "to challenge me?"
	cont "Fine then! Show"
	cont "me your best!"
	done

_PewterGymText_BrockPity1::
	text "Hmm..."
	
	para "Your #MON seem"
	line "to be somewhat"
	cont "weak."
	
	para "Maybe this will"
	line "help you out."
	prompt

_PewterGymText_BrockPity2::
	text $52, " got"
	line "@"
	TX_RAM wcf4b
	text "!@@"
	
_PewterGymText_BrockPity3::
	db $0
	para "Use this on a"
	line "#MON to"
	cont "increase its"
	cont "level!"
	
	para "Anyway..."
	para "@@"
