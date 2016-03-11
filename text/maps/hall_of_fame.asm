_HallofFameRoomText1::
	text "OAK: Er-hem!"
	line "Congratulations"
	cont $52, "!"

	para "This floor is the"
	line "#MON HALL OF"
	cont "FAME!"

	para "#MON LEAGUE"
	line "champions are"
	cont "honored for their"
	cont "exploits here!"

	para "Their #MON are"
	line "also recorded in"
	cont "the HALL OF FAME!"
    
    para "However..."
    
    para "I am sorry to say"
    line "that this is the"
    cont "end for you."
    
    para "Anyone who is"
    line "powerful enough"
    cont "to beat someone"
    cont "like TRICKY is"
    cont "too dangerous to"
    cont "be allowed to"
    cont "enter the"
    cont "HALL OF FAME."
    
    para "Now you will face"
    line "true power."
    done

_HallofFameRoomText2::
    text "OAK: Well then..."
    
    para "It seems I must"
    line "admit defeat."
    
    para "Your #MON are"
    line "too much for even"
    cont "MEWTWO itself..."
    
    para $52, "! You have"
	line "endeavored hard"
	cont "to become the new"
	cont "LEAGUE champion!"

	para "Congratulations,"
	line $52, ", you and"
	cont "your #MON are"
	cont "HALL OF FAMERs!"
	done
    
_OakVictoryText::
    text "This must"
    line "be a joke, right?"
    
    para "How could I"
    line "possibly win"
    cont "against CHAMP?"
    prompt
    
_OakDefeatedText::
    text "No way."
    line "That's impossible!"
    prompt