GaryObject: ; 0x7612f (size=48)
	db $3 ; border block

	db $4 ; warps
	db $7, $3, $1, LANCES_ROOM
	db $7, $4, $2, LANCES_ROOM
	db $0, $3, $0, HALL_OF_FAME
	db $0, $4, $0, HALL_OF_FAME

	db $0 ; signs

	db $3 ; objects
	object SPRITE_BLUE, $4, $2, STAY, LEFT, $1 ; person
	object SPRITE_OAK, $3, $7, STAY, UP, $2 ; person
	object SPRITE_BIKE_SHOP_GUY, $3, $2, STAY, RIGHT, $3 ; person
	
	; warp-to
	EVENT_DISP CHAMPIONS_ROOM_WIDTH, $7, $3 ; LANCES_ROOM
	EVENT_DISP CHAMPIONS_ROOM_WIDTH, $7, $4 ; LANCES_ROOM
	EVENT_DISP CHAMPIONS_ROOM_WIDTH, $0, $3 ; HALL_OF_FAME
	EVENT_DISP CHAMPIONS_ROOM_WIDTH, $0, $4 ; HALL_OF_FAME
