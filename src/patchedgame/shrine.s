	.include "uscii.i"


player_xpos		= $0010
player_ypos		= $0011
tile_xpos		= $0012
tile_ypos		= $0013
map_x			= $0014
map_y			= $0015
new_x			= $0016
new_y			= $0017
britannia_x		= $0018
britannia_y		= $0019
current_location	= $001a
game_mode		= $001b
dungeon_level		= $001c
balloon_flying		= $001d
player_transport	= $001e
party_size		= $001f
dng_direction		= $0020
light_duration		= $0021
moon_phase_trammel	= $0022
moon_phase_felucca	= $0023
horse_mode		= $0024
player_has_spoken_to_lb = $0025
last_humility_check	= $0027
altar_room_principle	= $0028
last_meditated		= $0029
last_found_reagent	= $002a
ship_hull		= $002b
move_counter		= $002c
key_buf 		= $0030
key_buf_len		= $0038
charptr 		= $003d
magic_aura		= $0046
aura_duration		= $0047
tile_under_player	= $0048
tile_north		= $0049
tile_south		= $004a
tile_east		= $004b
tile_west		= $004c
music_volume		= $004d
console_xpos		= $004e
console_ypos		= $004f
diskid			= $0050
numdrives		= $0051
currdisk_drive1 	= $0052
currdisk_drive2 	= $0053
currplayer		= $0054
hexnum			= $0056
bcdnum			= $0057
zptmp1			= $005a
damage			= $005c
reqdisk 		= $005e
currdrive		= $005f
lt_y			= $0060
lt_x			= $0061
lt_rwflag		= $0062
lt_addr_hi		= $0063
monster_type		= $0066
game_mode_temp		= $0068
moongate_tile		= $006d
moongate_xpos		= $006e
moongate_ypos		= $006f
tilerow 		= $0072
movement_mode		= $0074
direction		= $0075
delta_x 		= $0078
delta_y 		= $0079
temp_x			= $007a
temp_y			= $007b
ptr2			= $007c
ptr1			= $007e
j_waitkey		= $0800
j_player_teleport	= $0803
j_move_east		= $0806
j_move_west		= $0809
j_move_south		= $080c
j_move_north		= $080f
j_drawinterface 	= $0812
j_drawview		= $0815
j_update_britannia	= $0818
j_primm_xy		= $081e
j_primm 		= $0821
j_console_out		= $0824
j_clearbitmap		= $0827
j_mulax 		= $082a
j_get_stats_ptr 	= $082d
j_printname		= $0830
j_printbcd		= $0833
j_drawcursor		= $0836
j_drawcursor_xy 	= $0839
j_drawvert		= $083c
j_drawhoriz		= $083f
j_request_disk		= $0842
j_update_status 	= $0845
j_blocked_tile		= $0848
j_update_view		= $084b
j_rand			= $084e
j_loadsector		= $0851
j_playsfx		= $0854
j_update_view_combat	= $0857
j_getnumber		= $085a
j_getplayernum		= $085d
j_update_wind		= $0860
j_animate_view		= $0863
j_printdigit		= $0866
j_clearstatwindow	= $0869
j_animate_creatures	= $086c
j_centername		= $086f
j_print_direction	= $0872
j_clearview		= $0875
j_invertview		= $0878
j_centerstring		= $087b
j_printstring		= $087e
j_gettile_bounds	= $0881
j_gettile_britannia	= $0884
j_gettile_opposite	= $0887
j_gettile_currmap	= $088a
j_gettile_tempmap	= $088d
j_get_player_tile	= $0890
j_gettile_towne 	= $0893
j_gettile_dungeon	= $0896
div32			= $1572
div16			= $1573
mul32			= $1578
mul16			= $1579
j_fileio		= $a100
j_readblock		= $a103
j_loadtitle		= $a106
j_togglesnd		= $a109
j_kernalin		= $a10c
j_setirqv		= $a10f
j_clearkbd		= $a112
j_irqhandler		= $a115
party_stats		= $aa00
virtues_and_stats	= $ab00
torches 		= $ab08
gems			= $ab09
keys			= $ab0a
sextant 		= $ab0b
stones			= $ab0c
runes			= $ab0d
items			= $ab0e
threepartkey		= $ab0f
food_hi 		= $ab10
food_lo 		= $ab11
food_frac		= $ab12
gold			= $ab13
horn			= $ab15
wheel			= $ab16
skull			= $ab17
armour			= $ab18
weapons 		= $ab20
reagents		= $ab38
mixtures		= $ab40
map_status		= $ac00
object_xpos		= $ac20
object_ypos		= $ac40
object_tile		= $ac60
currmap 		= $ae00
tempmap 		= $ae80
music_ctl		= $af20
music_nop		= $af23
bmplineaddr_lo		= $e000
bmplineaddr_hi		= $e0c0
chrlineaddr_lo		= $e180
chrlineaddr_hi		= $e198
tile_color		= $e1b0
music_init		= $ec00


	.segment "OVERLAY"

shrine:
	lda current_location
	sec
	sbc #$19
	sta shrine_num
	tay
	lda runes
	and rune_mask,y
	bne @haverune
	jsr j_primm
	.byte $8d
	.byte "THOU DOST NOT", $8d
	.byte "BEAR THE RUNE", $8d
	.byte "OF ENTRY! A", $8d
	.byte "STRANGE FORCE", $8d
	.byte "KEEPS YOU OUT!", $8d
	.byte 0

	jmp exit_shrine

@haverune:
	lda #$cc
	ldx #$1c
	jsr j_fileio
	ldx #$7f
@copymap:
	lda tempmap,x
	sta currmap,x
	dex
	bpl @copymap
	lda #$ff
	sta game_mode
	jsr j_update_view
	lda #$03
	jsr music_ctl
	jsr j_primm
	.byte $8d
	.byte "YOU ENTER THE", $8d
	.byte "ANCIENT SHRINE", $8d
	.byte "AND SIT BEFORE", $8d
	.byte "THE ALTAR...", $8d
	.byte $8d
	.byte "UPON WHAT VIRTUE", $8d
	.byte "DOST THOU", $8d
	.byte "MEDITATE?", $8d
	.byte 0

	lda #$00
	sta num_cycles
	jsr get_string
@askcycles:
	jsr j_primm
	.byte $8d
	.byte "FOR HOW MANY", $8d
	.byte "CYCLES (0-3):", 0

	jsr get_number			; Buggy original:
	bne :+                          ;	cmp #$04
	jmp no_focus                    ;	bcs @askcycles
:	cmp #$04                        ;	sta num_cycles
	bcs @askcycles                  ;	sta cycle_ctr
	sta num_cycles                  ;	bne :+
	sta cycle_ctr                   ;	jmp no_focus
	lda #$00
	sta unused
	jsr compare_string
	cmp shrine_num
	beq @virtue_shrine_match
	jmp no_focus

@virtue_shrine_match:
	lda move_counter+2
	cmp last_meditated
	bne @begin
	jmp still_weary

@begin:
	sta last_meditated
	jsr j_primm
	.byte $8d
	.byte "BEGIN MEDITATION", $8d
	.byte 0

@slowdots:
	lda #$10
	sta $70
@print:
	jsr delay
	lda #$ae
	jsr j_console_out
	dec $70
	bne @print
	bit $c010
	lda #$00
	sta key_buf_len
	jsr j_primm
	.byte $8d
	.byte "MANTRA", 0

	jsr get_string
	jsr compare_string
	sec
	sbc #$08
	cmp shrine_num
	beq @correctmantra
	jmp @wrongmantra

@correctmantra:
	dec cycle_ctr
	bne @slowdots
	jmp @checkresult

@wrongmantra:
	jsr j_primm
	.byte $8d
	.byte "THOU ART NOT", $8d
	.byte "ABLE TO FOCUS", $8d
	.byte "THY THOUGHTS", $8d
	.byte "WITH THAT", $8d
	.byte "MANTRA!", $8d
	.byte 0

	ldy #$06
	lda #$03
	jsr decrease_virtue
	jmp exit_shrine

@checkresult:
	lda num_cycles
	cmp #$03
	bne @vision
	ldy shrine_num
	lda virtues_and_stats,y
	cmp #$99
	bne @vision
	jmp partial_avatar

@vision:
	jsr j_primm
	.byte $8d
	.byte "THY THOUGHTS", $8d
	.byte "ARE PURE,", $8d
	.byte "THOU ART GRANTED", $8d
	.byte "A VISION!", $8d
	.byte 0

	ldy #$06
	lda num_cycles
	asl a
	adc num_cycles
	jsr increase_virtue
	jsr j_waitkey
	lda #$8d
	jsr j_console_out
	ldy shrine_num
	lda shrine_msg_idx,y
	clc
	ldy num_cycles
	adc shrine_msg_per_cycle,y
	clc
	adc #$01
	jsr print_hint
	jsr j_waitkey
exit_shrine:
	lda #$8d
	jsr j_console_out
	lda #$00
	sta current_location
	lda #$01
	sta game_mode
	jsr j_update_view
	rts

	ldx #$0a
:	jsr shortdelay
	dex
	bne :-
	rts

delay:
	ldx #$05
:	jsr shortdelay
	dex
	bne :-
	rts

shortdelay:
	ldy #$ff
:	lda #$ff
:	sec
	sbc #$01
	bne :-
	dey
	bne :--
	jsr j_clearkbd
	rts

no_focus:
	jsr j_primm
	.byte $8d
	.byte "THOU ART UNABLE", $8d
	.byte "TO FOCUS THY", $8d
	.byte "THOUGHTS ON", $8d
	.byte "THIS SUBJECT!", $8d
	.byte 0

	jsr j_waitkey
	jmp exit_shrine

still_weary:
	jsr j_primm
	.byte $8d
	.byte "THY MIND IS", $8d
	.byte "STILL WEARY", $8d
	.byte "FROM THY LAST", $8d
	.byte "MEDITATION!", $8d
	.byte 0

	jsr j_waitkey
	jmp exit_shrine

increase_virtue:
	sta $59
	sed
	clc
	lda virtues_and_stats,y
	beq @nooverflow
	adc $59
	bcc @nooverflow
	lda #$99
@nooverflow:
	sta virtues_and_stats,y
	cld
	rts

decrease_virtue:
	sta zptmp1
	sty $59
	lda virtues_and_stats,y
	beq @lost_an_eighth
@subtract:
	sed
	sec
	sbc zptmp1
	beq :+
	bcs @positive
:	lda #1
@positive:
	sta virtues_and_stats,y
	cld
	rts

@lost_an_eighth:
	jsr j_primm
	.byte $8d
	.byte "THOU HAST LOST", $8d
	.byte "AN EIGHTH!", $8d
	.byte 0

	ldy $59
	lda #$99
	jmp @subtract

partial_avatar:
	jsr j_primm
	.byte $8d
	.byte "THOU HAST", $8d
	.byte "ACHIEVED PARTIAL", $8d
	.byte "AVATARHOOD IN", $8d
	.byte "THE VIRTUE OF", $8d
	.byte 0

	lda #$97
	clc
	adc shrine_num
	jsr j_printstring
	jsr j_invertview
	ldx #$ff
	lda #$09
	jsr j_playsfx
	jsr j_invertview
	lda #$8d
	jsr j_console_out
	ldy shrine_num
	lda #$00
	sta virtues_and_stats,y
	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "THOU ART GRANTED", $8d
	.byte "A VISION!", $8d
	.byte 0

	lda #$00
	sta game_mode
	lda shrine_num
	jsr draw_rune
	jsr j_waitkey
	jmp exit_shrine

get_number:
	jsr j_waitkey
	beq get_number
	sec
	sbc #$b0
	cmp #$0a
	bcc @ok
	lda #$00
@ok:
	pha
	jsr j_printdigit
	lda #$8d
	jsr j_console_out
	pla
	rts

shrine_num:
	.byte 0
num_cycles:
	.byte 0
cycle_ctr:
	.byte 0
unused:
	.byte 0
shrine_msg_idx:
	.byte 0, 3, 6, 9, $0c, $0f, $12, $15
shrine_msg_per_cycle:
;	.byte $18, 0, 0, 0, 1, 1, 1, 2, 2, 2	; Buggy original.
	.byte $18, 0, 1, 2, 1, 1, 1, 2, 2, 2	; Fixed version.
rune_mask:
	.byte $80, $40, $20, $10, 8, 4, 2, 1

get_string:
	lda #$bf
	jsr j_console_out
	lda #$00
	sta $6a
@waitkey:
	jsr j_waitkey
	beq @timeout
@checkkey:
	cmp #$8d
	beq @done
	cmp #$94
	beq @del
	cmp #$a0
	bcc @waitkey
	ldx $6a
	sta $af00,x
	jsr j_console_out
	inc $6a
	lda $6a
	cmp #$0f
	bcc @waitkey
	bcs @done
@del:
	lda $6a
	beq @waitkey
	dec $6a
	dec console_xpos
	lda #$a0
	jsr j_console_out
	dec console_xpos
	jmp @waitkey

@timeout:
	lda num_cycles
	beq @checkkey
@done:
	ldx $6a
	lda #$a0
@clearend:
	sta $af00,x
	inx
	cpx #$06
	bcc @clearend
	lda #$8d
	jsr j_console_out
	rts

compare_string:
	lda #$0f
	sta $6a
@nextstring:
	lda $6a
	asl a
	asl a
	tay
	ldx #$00
@compare:
	lda virtues_and_mantras,y
	cmp $af00,x
	bne @differ
	iny
	inx
	cpx #$04
	bcc @compare
	lda $6a
	rts

@differ:
	dec $6a
	bpl @nextstring
	lda $6a
	rts

virtues_and_mantras:
	.byte "HONE"
	.byte "COMP"
	.byte "VALO"
	.byte "JUST"
	.byte "SACR"
	.byte "HONO"
	.byte "SPIR"
	.byte "HUMI"
	.byte "AHM "
	.byte "MU  "
	.byte "RA  "
	.byte "BEH "
	.byte "CAH "
	.byte "SUMM"
	.byte "OM  "
	.byte "LUM "

print_hint:
	tay
	lda #$fa
	sta ptr1
	lda #$8c
	sta ptr1+1
	ldx #$00
@checknext:
	lda (ptr1,x)
	beq @possiblestring
@wrongstring:
	jsr @incptr
	jmp @checknext

@possiblestring:
	dey
	beq @gotstring
	jmp @wrongstring

@gotstring:
	jsr @incptr
	ldx #$00
	lda (ptr1,x)
	beq @done
	jsr j_console_out
	jmp @gotstring

@done:
	rts

@incptr:
	inc ptr1
	bne :+
	inc ptr1+1
:	rts

hint_honesty_0:
	.byte 0, "TAKE NOT THE", $8d
	.byte "GOLD OF OTHERS", $8d
	.byte "FOUND IN TOWNS", $8d
	.byte "AND CASTLES FOR", $8d
	.byte "YOURS IT IS NOT!", $8d
hint_honesty_1:
	.byte 0, "CHEAT NOT THE", $8d
	.byte "MERCHANTS AND", $8d
	.byte "PEDDLERS FOR", $8d
	.byte "'TIS AN EVIL", $8d
	.byte "THING TO DO!", $8d
hint_honesty_2:
	.byte 0, "SECOND, READ THE", $8d
	.byte "BOOK OF TRUTH AT", $8d
	.byte "THE ENTRANCE TO", $8d
	.byte "THE GREAT", $8d
	.byte "STYGIAN ABYSS!", $8d
hint_compassion_0:
	.byte 0, "KILL NOT THE", $8d
	.byte "NON-EVIL BEASTS", $8d
	.byte "OF THE LAND, AND", $8d
	.byte "DO NOT ATTACK", $8d
	.byte "THE FAIR PEOPLE!", $8d
hint_compassion_1:
	.byte 0, "GIVE OF THY", $8d
	.byte "PURSE TO THOSE", $8d
	.byte "WHO BEG AND THY", $8d
	.byte "DEED SHALL NOT", $8d
	.byte "BE FORGOTTEN!", $8d
hint_compassion_2:
	.byte 0, "THIRD, LIGHT THE", $8d
	.byte "CANDLE OF LOVE", $8d
	.byte "AT THE ENTRANCE", $8d
	.byte "TO THE GREAT", $8d
	.byte "STYGIAN ABYSS!", $8d
hint_valor_0:
	.byte 0, "VICTORIES SCORED", $8d
	.byte "OVER EVIL", $8d
	.byte "CREATURES HELP", $8d
	.byte "TO BUILD A", $8d
	.byte "VALOROUS SOUL!", $8d
hint_valor_1:
	.byte 0, "TO FLEE FROM", $8d
	.byte "BATTLE WITH LESS", $8d
	.byte "THAN GRIEVOUS", $8d
	.byte "WOUNDS OFTEN", $8d
	.byte "SHOWS A COWARD!", $8d
hint_valor_2:
	.byte 0, "FIRST, RING THE", $8d
	.byte "BELL OF COURAGE", $8d
	.byte "AT THE ENTRANCE", $8d
	.byte "TO THE GREAT", $8d
	.byte "STYGIAN ABYSS!", $8d
hint_justice_0:
	.byte 0, "TO TAKE THE GOLD", $8d
	.byte "OF OTHERS IS", $8d
	.byte "INJUSTICE NOT", $8d
	.byte "SOON FORGOTTEN,", $8d
	.byte "TAKE ONLY THY", $8d
	.byte "DUE!", $8d
hint_justice_1:
	.byte 0, "ATTACK NOT A", $8d
	.byte "PEACEFUL CITIZEN", $8d
	.byte "FOR THAT ACTION", $8d
	.byte "DESERVES STRICT", $8d
	.byte "PUNISHMENT!", $8d
hint_justice_2:
	.byte 0, "KILL NOT A", $8d
	.byte "NON-EVIL BEAST", $8d
	.byte "FOR THEY DESERVE", $8d
	.byte "NOT DEATH EVEN", $8d
	.byte "IF IN HUNGER", $8d
	.byte "THEY ATTACK", $8d
	.byte "THEE!", $8d
hint_sacrifice_0:
	.byte 0, "TO GIVE THY LAST", $8d
	.byte "GOLD PIECE UNTO", $8d
	.byte "THE NEEDY SHOWS", $8d
	.byte "GOOD MEASURE OF", $8d
	.byte "SELF-SACRIFICE!", $8d
hint_sacrifice_1:
	.byte 0, "FOR THEE TO FLEE", $8d
	.byte "AND LEAVE THY", $8d
	.byte "COMPANIONS IS A", $8d
	.byte "SELF-SEEKING", $8d
	.byte "ACTION TO BE", $8d
	.byte "AVOIDED!", $8d
hint_sacrifice_2:
	.byte 0, "TO GIVE OF THY", $8d
	.byte "LIFE'S BLOOD SO", $8d
	.byte "THAT OTHERS MAY", $8d
	.byte "LIVE IS A VIRTUE", $8d
	.byte "OF GREAT PRAISE!", $8d
hint_honor_0:
	.byte 0, "TAKE NOT THE", $8d
	.byte "GOLD OF OTHERS", $8d
	.byte "FOR THIS SHALL", $8d
	.byte "BRING DISHONOR", $8d
	.byte "UPON THEE!", $8d
hint_honor_1:
	.byte 0, "TO STRIKE FIRST", $8d
	.byte "A NON-EVIL BEING", $8d
	.byte "IS BY NO MEANS", $8d
	.byte "AN HONORABLE", $8d
	.byte "DEED!", $8d
hint_honor_2:
	.byte 0, "SEEK YE TO SOLVE", $8d
	.byte "THE MANY QUESTS", $8d
	.byte "BEFORE THEE, AND", $8d
	.byte "HONOR SHALL BE", $8d
	.byte "A REWARD!", $8d
hint_spirituality_0:
	.byte 0, "SEEK YE TO KNOW", $8d
	.byte "THYSELF, VISIT", $8d
	.byte "THE SEER OFTEN", $8d
	.byte "FOR HE CAN", $8d
	.byte "SEE INTO THY", $8d
	.byte "INNER BEING!", $8d
hint_spirituality_1:
	.byte 0, "MEDITATION", $8d
	.byte "LEADS TO", $8d
	.byte "ENLIGHTENMENT.", $8d
	.byte "SEEK YE ALL", $8d
	.byte "WISDOM AND", $8d
	.byte "KNOWLEDGE!", $8d
hint_spirituality_2:
	.byte 0, "IF THOU DOST", $8d
	.byte "SEEK THE WHITE", $8d
	.byte "STONE, SEARCH YE", $8d
	.byte "NOT UNDER THE", $8d
	.byte "GROUND, BUT IN", $8d
	.byte "THE SKY NEAR", $8d
	.byte "SERPENTS SPINE!", $8d
hint_humility_0:
	.byte 0, "CLAIM NOT TO BE", $8d
	.byte "THAT WHICH THOU", $8d
	.byte "ART NOT, HUMBLE", $8d
	.byte "ACTIONS SPEAK", $8d
	.byte "WELL OF THEE!", $8d
hint_humility_1:
	.byte 0, "STRIVE NOT TO", $8d
	.byte "WIELD THE GREAT", $8d
	.byte "FORCE OF EVIL", $8d
	.byte "FOR ITS POWER", $8d
	.byte "WILL OVERCOME", $8d
	.byte "THEE!", $8d
hint_humility_2:
	.byte 0, "IF THOU DOST", $8d
	.byte "SEEK THE BLACK", $8d
	.byte "STONE, SEARCH YE", $8d
	.byte "AT THE TIME AND", $8d
	.byte "PLACE OF THE", $8d
	.byte "GATE ON THE", $8d
	.byte "DARKEST OF ALL", $8d
	.byte "NIGHTS!", $8d
hint_end:
	.byte 0

draw_rune:
	pha
	jsr swap_buf
	jsr j_clearview
	jsr clear_view_colors
	pla
	tax
	lda infinity,x
	asl a
	tax
	lda rune_addr,x
	sta key_buf
	lda rune_addr+1,x
	sta key_buf+1
	ldx #$50
	lda bmplineaddr_lo,x
	clc
	adc #$48
	sta key_buf+2
	lda bmplineaddr_hi,x
	adc #$00
	sta key_buf+3
	lda #$04
	sta row_ctr
@nextline:
	ldy #$00
:	lda (key_buf),y
	sta (key_buf+2),y
	iny
	cpy #$18
	bne :-
	lda key_buf
	clc
	adc #$18
	sta key_buf
	lda key_buf+1
	adc #$00
	sta key_buf+1
	lda key_buf+2
	clc
	adc #$40
	sta key_buf+2
	lda key_buf+3
	adc #$01
	sta key_buf+3
	dec row_ctr
	bne @nextline
	jsr swap_buf
	rts

clear_view_colors:
	lda #$29
	sta key_buf
	lda #$04
	sta key_buf+1
	ldx #$16
@nextline:
	ldy #$00
@nextchar:
	lda #$10
	sta (key_buf),y
	iny
	cpy #$16
	bne @nextchar
	lda key_buf
	clc
	adc #$28
	sta key_buf
	bcc :+
	inc key_buf+1
:	dex
	bne @nextline
	rts

swap_buf:
	ldx #$07
:	lda key_buf,x
	tay
	lda key_buf_tmp,x
	sta key_buf,x
	tya
	sta key_buf_tmp,x
	dex
	bpl :-
	rts

key_buf_tmp:
	.res 8, 0
row_ctr:
	.byte 0
infinity:
	.byte 0, 1, 2, 0, 1, 0, 3, 4

rune_addr:
	.addr rune_i
	.addr rune_n
	.addr rune_f
	.addr rune_t
	.addr rune_y

rune_i:
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9510	........
	.byte	$0E,$3E,$3C,$1C,$1C,$1C,$1C,$1C ; 9518	N><\\\\\
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9520	........
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9528	........
	.byte	$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C ; 9530	\\\\\\\\
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9538	........
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9540	........
	.byte	$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C ; 9548	\\\\\\\\
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9550	........
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9558	........
	.byte	$1C,$1E,$3E,$38,$00,$00,$00,$00 ; 9560	\^>8....
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9568	........
rune_n:
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9570	........
	.byte	$0E,$3E,$3C,$1C,$1C,$1C,$1C,$1C ; 9578	N><\\\\\
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9580	........
	.byte	$00,$00,$00,$03,$07,$0E,$0C,$0C ; 9588	...CGNLL
	.byte	$1C,$1C,$1C,$DC,$FC,$7C,$3C,$1E ; 9590	\\\\||<^
	.byte	$00,$00,$00,$00,$70,$38,$18,$18 ; 9598	....p8XX
	.byte	$0E,$07,$00,$00,$00,$00,$00,$00 ; 95A0	NG......
	.byte	$1F,$1F,$1D,$1C,$1C,$1C,$1C,$1C ; 95A8	__]\\\\\
	.byte	$38,$F0,$E0,$00,$00,$00,$00,$00 ; 95B0	8p`.....
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 95B8	........
	.byte	$1C,$1E,$3E,$38,$00,$00,$00,$00 ; 95C0	\^>8....
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 95C8	........
rune_f:
	.byte	$03,$0F,$0F,$07,$07,$07,$07,$07 ; 95D0	COOGGGGG
	.byte	$9E,$9E,$0C,$0C,$0C,$1C,$F8,$F0 ; 95D8	^^LLL\xp
	.byte	$78,$78,$30,$30,$30,$30,$30,$60 ; 95E0	xx00000`
	.byte	$07,$07,$07,$07,$07,$07,$07,$07 ; 95E8	GGGGGGGG
	.byte	$00,$00,$03,$FF,$FC,$00,$00,$00 ; 95F0	..C.|...
	.byte	$60,$E0,$C0,$80,$00,$00,$00,$00 ; 95F8	``@.....
	.byte	$07,$07,$07,$07,$07,$07,$07,$07 ; 9600	GGGGGGGG
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9608	........
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9610	........
	.byte	$07,$07,$0F,$0E,$00,$00,$00,$00 ; 9618	GGON....
	.byte	$00,$80,$80,$00,$00,$00,$00,$00 ; 9620	........
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9628	........
rune_t:
	.byte	$00,$00,$01,$07,$1F,$1C,$00,$00 ; 9630	..AG_\..
	.byte	$1C,$7F,$FF,$DD,$1C,$1C,$1C,$1C ; 9638	\..]\\\\
	.byte	$00,$00,$C0,$F0,$7C,$1C,$00,$00 ; 9640	..@p|\..
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9648	........
	.byte	$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C ; 9650	\\\\\\\\
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9658	........
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9660	........
	.byte	$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C ; 9668	\\\\\\\\
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9670	........
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9678	........
	.byte	$1C,$1E,$3E,$38,$00,$00,$00,$00 ; 9680	\^>8....
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9688	........
rune_y:
	.byte	$E0,$FC,$7F,$77,$70,$70,$70,$70 ; 9690	`|.wpppp
	.byte	$00,$00,$80,$F0,$FE,$1F,$03,$00 ; 9698	...p~_C.
	.byte	$00,$00,$00,$00,$00,$C0,$F8,$7F ; 96A0	.....@x.
	.byte	$70,$70,$70,$70,$70,$70,$7F,$7F ; 96A8	pppppp..
	.byte	$00,$00,$00,$00,$00,$00,$FF,$FF ; 96B0	........
	.byte	$0F,$0E,$0E,$0E,$0E,$0E,$FE,$FE ; 96B8	ONNNNN~~
	.byte	$70,$70,$70,$70,$70,$70,$70,$70 ; 96C0	pppppppp
	.byte	$30,$30,$30,$30,$30,$30,$30,$30 ; 96C8	00000000
	.byte	$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E ; 96D0	NNNNNNNN
	.byte	$70,$78,$F8,$E0,$00,$00,$00,$00 ; 96D8	pxx`....
	.byte	$30,$38,$78,$70,$00,$00,$00,$00 ; 96E0	08xp....
	.byte	$0E,$0F,$1F,$1C,$00,$00,$00,$00 ; 96E8	NO_\....
