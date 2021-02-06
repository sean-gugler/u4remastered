	.include "uscii.i"


party_size		= $1f
player_has_spoken_to_lb	= $25
console_xpos		= $4e
currplayer		= $54
talk_zptmp		= $6a
ptr1			= $7e

j_waitkey		= $0800
j_primm_xy		= $081e
j_primm			= $0821
j_console_out		= $0824
j_get_stats_ptr		= $082d
j_printname		= $0830
j_update_status		= $0845
j_rand			= $084e
j_playsfx		= $0854
j_printdigit		= $0866
j_invertview		= $0878

j_fileio		= $a100
inbuf			= $af00
music_ctl		= $af20


	.segment "OVERLAY"

j_continue:
	jmp continue

talk_lord_british:
	pla
	sta $0c
	pla
	sta $0d
	lda player_has_spoken_to_lb
	bne @check_alive
	inc player_has_spoken_to_lb
	jmp lb_intro

@check_alive:
	lda #$01
	sta currplayer
	jsr j_get_stats_ptr
	ldy #$45     ;Should be #$12 - no idea where #$45 came from.
	lda (ptr1),y
	cmp #$c4
	bne @alive
	lda #$c7
	sta (ptr1),y
	jsr j_printname
	jsr j_primm
;	.byte $8d    ;cosmetic FIX
	.byte "THOU SHALT", $8d
	.byte "LIVE AGAIN!", $8d
	.byte 0

	ldx #$14
	lda #$0a
	jsr j_playsfx
	jsr j_invertview
	lda #$09
	ldx #$c0
	jsr j_playsfx
	jsr j_invertview
	jsr restore_party_hp
	jsr j_update_status
@alive:
	jsr j_primm
	.byte "LORD BRITISH", $8d
	.byte "SAYS: WELCOME", $8d
	.byte 0

	lda #$01
	sta currplayer
	jsr j_printname
	lda party_size
	cmp #$02
	bcc @alone
	beq @one_companion
	bcs @three_or_more
@alone:
	jsr j_primm
	.byte $8d
	.byte "MY FRIEND!", $8d
	.byte 0

	jmp check_xp

@one_companion:
	jsr j_primm
	.byte $8d
	.byte "AND THEE ALSO", $8d
	.byte 0

	inc currplayer
	jsr j_printname
	jsr j_primm
	.byte "!", $8d
	.byte 0

	jmp check_xp

@three_or_more:
	jsr j_primm
	.byte $8d
	.byte "AND THY WORTHY", $8d
	.byte "ADVENTURERS!", $8d
	.byte 0

check_xp:
	lda party_size
	sta currplayer
@next:
	jsr j_get_stats_ptr
	ldy #$1c
	lda (ptr1),y
	jsr decode_bcd_value
	ldx #$01
@sqrt:
	cmp #$00
	beq @check_level
	lsr a
	inx
	jmp @sqrt

@check_level:
	txa
	ldy #$1a
	cmp (ptr1),y
	beq @already_at_level
	sta (ptr1),y
	sta talk_zptmp
	ldy #$18
	sta (ptr1),y
	lda #$00
	iny
	sta (ptr1),y
	jsr j_get_stats_ptr
	ldy #$12
	lda #$c7
	sta (ptr1),y
	ldy #$15
@inc_stat:
	jsr j_rand
	and #$07
	sed
	sec
	adc (ptr1),y
	cld
	cmp #$51
	bcc @less_than_51
	lda #$50
@less_than_51:
	sta (ptr1),y
	dey
	cpy #$13
	bcs @inc_stat
	jsr print_newline
	jsr j_printname
	jsr j_primm
	.byte $8d
	.byte "THOU ART NOW", $8d
	.byte "LEVEL ", 0

	lda talk_zptmp
	jsr j_printdigit
	jsr print_newline
	jsr j_invertview
	lda #$09
	ldx #$c0
	jsr j_playsfx
	jsr j_invertview
	jsr j_update_status
@already_at_level:
	dec currplayer
	beq @what
	jmp @next

@what:
	jsr j_primm
	.byte $8d
	.byte "WHAT WOULD THOU", $8d
	.byte "ASK OF ME?", $8d
	.byte 0

	jmp main_prompt

continue:
	pla
	pla
next_question:
	lda #$01
	jsr music_ctl
	jsr j_primm
	.byte $8d
	.byte "WHAT ELSE?", $8d
	.byte 0

main_prompt:
	jsr get_input
	jsr check_keyword
	bpl jump_to_keyword
	jsr print_he_says
	jsr j_primm
	.byte "I CANNOT HELP", $8d
	.byte "THEE WITH THAT.", $8d
	.byte 0

	jmp next_question

jump_to_keyword:
	asl a
	tay
	lda keyword_jumptable,y
	sta ptr1
	lda keyword_jumptable+1,y
	sta ptr1+1
	jmp (ptr1)

keyword_jumptable:
	.addr answer_bye
	.addr answer_bye
	.addr answer_name
	.addr answer_look
	.addr answer_job
	.addr answer_heal
	.addr answer_trut
	.addr answer_love
	.addr answer_cour
	.addr answer_hone
	.addr answer_comp
	.addr answer_valo
	.addr answer_just
	.addr answer_sacr
	.addr answer_hono
	.addr answer_spir
	.addr answer_humi
	.addr answer_prid
	.addr answer_avat
	.addr answer_ques
	.addr answer_brit
	.addr answer_ankh
	.addr answer_help
	.addr answer_abys
	.addr answer_mond
	.addr answer_mina
	.addr answer_exod
	.addr answer_virt

print_lb_says:
	jsr j_primm
	.byte $8d
	.byte "LORD BRITISH", $8d
	.byte "SAYS: ", $8d
	.byte 0

	rts

print_he_says:
	jsr j_primm
	.byte $8d
	.byte "HE SAYS:", $8d
	.byte 0

	rts

print_he_asks:
	jsr j_primm
	.byte $8d
	.byte "HE ASKS:", $8d
	.byte 0

print_newline:
	lda #$8d
	jsr j_console_out
	rts

ask_y_or_n:
	jsr get_input
	lda inbuf
	cmp #$d9
	beq @yes
	cmp #$ce
	beq @no
	jsr j_primm
	.byte $8d
	.byte "YES OR NO:", $8d
	.byte 0

	rts

	jmp ask_y_or_n

@yes:
	lda #$00
	rts

@no:
	lda #$01
	rts

answer_bye:
	jsr print_lb_says
	jsr j_primm
	.byte "FARE THEE", $8d
	.byte "WELL MY FRIEND", 0

	lda party_size
	cmp #$01
	bne @plural
	jsr j_primm
	.byte "!", $8d
	.byte 0

	jmp exit_conversation

@plural:
	jsr j_primm
	.byte "S!", $8d
	.byte 0

	jmp exit_conversation

answer_name:
	jsr print_he_says
	jsr j_primm
	.byte "MY NAME IS", $8d
	.byte "LORD BRITISH,", $8d
	.byte "SOVEREIGN OF", $8d
	.byte "ALL BRITANNIA!", $8d
	.byte 0

	jmp next_question

answer_look:
	jsr j_primm
	.byte "THOU SEEST THE", $8d
	.byte "KING WITH THE", $8d
	.byte "ROYAL SCEPTRE.", $8d
	.byte 0

	jmp next_question

answer_job:
	jsr print_he_says
	jsr j_primm
	.byte "I RULE ALL", $8d
	.byte "BRITANNIA, AND", $8d
	.byte "SHALL DO MY BEST", $8d
	.byte "TO HELP THEE!", $8d
	.byte 0

	jmp next_question

answer_heal:
	jsr print_he_says
	jsr j_primm
	.byte "I AM WELL,", $8d
	.byte "THANK YE.", $8d
	.byte 0

	jsr print_he_asks
	jsr j_primm
	.byte "ART THOU WELL?", $8d
	.byte 0

	jsr ask_y_or_n
	bne @notwell
	jsr print_he_says
	jsr j_primm
	.byte "THAT IS GOOD.", $8d
	.byte 0

	jmp next_question

@notwell:
	jsr print_he_says
	jsr j_primm
	.byte "LET ME HEAL", $8d
	.byte "THY WOUNDS!", $8d
	.byte 0

	ldx #$14
	lda #$0a
	jsr j_playsfx
	jsr j_invertview
	lda #$09
	ldx #$c0
	jsr j_playsfx
	jsr j_invertview
	jsr restore_party_hp
	jsr j_update_status
	jmp next_question

answer_trut:
	jsr print_he_says
	jsr j_primm
	.byte "MANY TRUTHS CAN", $8d
	.byte "BE LEARNED AT", $8d
	.byte "THE LYCAEUM. IT", $8d
	.byte "LIES ON THE", $8d
	.byte "NORTHWESTERN", $8d
	.byte "SHORE OF VERITY", $8d
	.byte "ISLE!", $8d
	.byte 0

	jmp next_question

answer_love:
	jsr print_he_says
	jsr j_primm
	.byte "LOOK FOR THE", $8d
	.byte "MEANING OF LOVE", $8d
	.byte "AT EMPATH ABBEY.", $8d
	.byte "THE ABBEY SITS", $8d
	.byte "ON THE WESTERN", $8d
	.byte "EDGE OF THE DEEP", $8d
	.byte "FOREST!", $8d
	.byte 0

	jmp next_question

answer_cour:
	jsr print_he_says
	jsr j_primm
	.byte "SERPENT CASTLE", $8d
	.byte "ON THE ISLE OF", $8d
	.byte "DEEDS IS WHERE", $8d
	.byte "COURAGE SHOULD", $8d
	.byte "BE SOUGHT!", $8d
	.byte 0

	jmp next_question

answer_hone:
	jsr print_he_says
	jsr j_primm
	.byte "THE FAIR TOWNE", $8d
	.byte "OF MOONGLOW, ON", $8d
	.byte "VERITY ISLE, IS", $8d
	.byte "WHERE THE VIRTUE", $8d
	.byte "OF HONESTY", $8d
	.byte "THRIVES!", $8d
	.byte 0

	jmp next_question

answer_comp:
	jsr print_he_says
	jsr j_primm
	.byte "THE BARDS IN THE", $8d
	.byte "TOWNE OF BRITAIN", $8d
	.byte "ARE WELL VERSED", $8d
	.byte "IN THE VIRTUE OF", $8d
	.byte "COMPASSION!", $8d
	.byte 0

	jmp next_question

answer_valo:
	jsr print_he_says
	jsr j_primm
	.byte "MANY VALIANT", $8d
	.byte "FIGHTERS COME", $8d
	.byte "FROM JHELOM,", $8d
	.byte "IN THE VALARIAN", $8d
	.byte "ISLES!", $8d
	.byte 0

	jmp next_question

answer_just:
	jsr print_he_says
	jsr j_primm
	.byte "IN THE CITY OF", $8d
	.byte "YEW, IN THE DEEP", $8d
	.byte "FOREST, JUSTICE", $8d
	.byte "IS SERVED!", $8d
	.byte 0

	jmp next_question

answer_sacr:
	jsr print_he_says
	jsr j_primm
	.byte "MINOC, TOWNE OF", $8d
	.byte "SELF-SACRIFICE,", $8d
	.byte "LIES ON THE", $8d
	.byte "EASTERN SHORES", $8d
	.byte "OF LOST HOPE", $8d
	.byte "BAY!", $8d
	.byte 0

	jmp next_question

answer_hono:
	jsr print_he_says
	jsr j_primm
	.byte "THE PALADINS WHO", $8d
	.byte "STRIVE FOR HONOR", $8d
	.byte "ARE OFT SEEN IN", $8d
	.byte "TRINSIC, NORTH", $8d
	.byte "OF THE CAPE OF", $8d
	.byte "HEROES!", $8d
	.byte 0

	jmp next_question

answer_spir:
	jsr print_he_says
	jsr j_primm
	.byte "IN SKARA BRAE", $8d
	.byte "THE SPIRITUAL", $8d
	.byte "PATH IS TAUGHT,", $8d
	.byte "FIND IT ON AN", $8d
	.byte "ISLE NEAR", $8d
	.byte "SPIRITWOOD!", $8d
	.byte 0

	jmp next_question

answer_humi:
	jsr print_he_says
	jsr j_primm
	.byte "HUMILITY IS THE", $8d
	.byte "FOUNDATION OF", $8d
	.byte "VIRTUE! THE", $8d
	.byte "RUINS OF PROUD", $8d
	.byte "MAGINCIA ARE A", $8d
	.byte "TESTIMONY UNTO", $8d
	.byte "THE VIRTUE OF", $8d
	.byte "HUMILITY!", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "FIND THE RUINS", $8d
	.byte "OF MAGINCIA FAR", $8d
	.byte "OFF THE SHORES", $8d
	.byte "OF BRITANNIA,", $8d
	.byte "ON A SMALL ISLE", $8d
	.byte "IN THE VAST", $8d
	.byte "OCEAN!", $8d
	.byte 0

	jmp next_question

answer_prid:
	jsr print_he_says
	jsr j_primm
	.byte "OF THE EIGHT", $8d
	.byte "COMBINATIONS OF", $8d
	.byte "TRUTH, LOVE AND", $8d
	.byte "COURAGE, THAT", $8d
	.byte "WHICH CONTAINS", $8d
	.byte "NEITHER TRUTH,", $8d
	.byte "LOVE NOR COURAGE", $8d
	.byte "IS PRIDE.", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "PRIDE BEING NOT", $8d
	.byte "A VIRTUE MUST BE", $8d
	.byte "SHUNNED IN FAVOR", $8d
	.byte "OF HUMILITY, THE", $8d
	.byte "VIRTUE WHICH IS", $8d
	.byte "THE ANTITHESIS", $8d
	.byte "OF PRIDE!", $8d
	.byte 0

	jmp next_question

answer_avat:
	jsr print_lb_says
	jsr j_primm
	.byte "TO BE AN AVATAR", $8d
	.byte "IS TO BE THE", $8d
	.byte "EMBODIMENT OF", $8d
	.byte "THE EIGHT", $8d
	.byte "VIRTUES.", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "IT IS TO LIVE A", $8d
	.byte "LIFE CONSTANTLY", $8d
	.byte "AND FOREVER IN", $8d
	.byte "THE QUEST TO", $8d
	.byte "BETTER THYSELF", $8d
	.byte "AND THE WORLD IN", $8d
	.byte "WHICH WE LIVE.", $8d
	.byte 0

	jmp next_question

answer_ques:
	jsr print_lb_says
	jsr j_primm
	.byte "THE QUEST OF", $8d
	.byte "THE AVATAR IS", $8d
	.byte "IS TO KNOW AND", $8d
	.byte "BECOME THE", $8d
	.byte "EMBODIMENT OF", $8d
	.byte "THE EIGHT", $8d
	.byte "VIRTUES OF", $8d
	.byte "GOODNESS!", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "IT IS KNOWN THAT", $8d
	.byte "ALL WHO TAKE ON", $8d
	.byte "THIS QUEST MUST", $8d
	.byte "PROVE THEMSELVES", $8d
	.byte "BY CONQUERING", $8d
	.byte "THE ABYSS AND", $8d
	.byte "VIEWING THE", $8d
	.byte "CODEX OF", $8d
	.byte "ULTIMATE WISDOM!", $8d
	.byte 0

	jmp next_question

answer_brit:
	jsr print_he_says
	jsr j_primm
	.byte "EVEN THOUGH THE", $8d
	.byte "GREAT EVIL LORDS", $8d
	.byte "HAVE BEEN ROUTED", $8d
	.byte "EVIL YET REMAINS", $8d
	.byte "IN BRITANNIA.", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "IF BUT ONE SOUL", $8d
	.byte "COULD COMPLETE", $8d
	.byte "THE QUEST OF THE", $8d
	.byte "AVATAR, OUR", $8d
	.byte "PEOPLE WOULD", $8d
	.byte "HAVE A NEW HOPE,", $8d
	.byte "A NEW GOAL FOR", $8d
	.byte "LIFE.", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "THERE WOULD BE A", $8d
	.byte "SHINING EXAMPLE", $8d
	.byte "THAT THERE IS", $8d
	.byte "MORE TO LIFE", $8d
	.byte "THAN THE ENDLESS", $8d
	.byte "STRUGGLE FOR", $8d
	.byte "POSSESSIONS", $8d
	.byte "AND GOLD!", $8d
	.byte 0

	jmp next_question

answer_ankh:
	jsr print_he_says
	jsr j_primm
	.byte "THE ANKH IS THE", $8d
	.byte "SYMBOL OF ONE", $8d
	.byte "WHO STRIVES FOR", $8d
	.byte "VIRTUE, KEEP IT", $8d
	.byte "WITH THEE AT", $8d
	.byte "ALL TIMES FOR BY", $8d
	.byte "THIS MARK THOU", $8d
	.byte "SHALT BE KNOWN!", $8d
	.byte 0

	jmp next_question

answer_help:
	;lda #$00
	;jsr music_ctl
	lda #$d2
	ldx #$88
	jsr j_fileio
answer_abys:
	jsr print_he_says
	jsr j_primm
	.byte "THE GREAT", $8d
	.byte "STYGIAN ABYSS", $8d
	.byte "IS THE DARKEST", $8d
	.byte "POCKET OF EVIL", $8d
	.byte "REMAINING IN", $8d
	.byte "BRITANNIA!", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "IT IS SAID THAT", $8d
	.byte "IN THE DEEPEST", $8d
	.byte "RECESSES OF THE", $8d
	.byte "ABYSS IS THE", $8d
	.byte "CHAMBER OF THE", $8d
	.byte "CODEX!", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "IT IS ALSO SAID", $8d
	.byte "THAT ONLY ONE OF", $8d
	.byte "HIGHEST VIRTUE", $8d
	.byte "MAY ENTER THIS", $8d
	.byte "CHAMBER, ONE", $8d
	.byte "SUCH AS AN", $8d
	.byte "AVATAR!!!", $8d
	.byte 0

	jmp next_question

answer_mond:
	jsr print_he_says
	jsr j_primm
	.byte "MONDAIN IS DEAD!", $8d
	.byte 0

	jmp next_question

answer_mina:
	jsr print_he_says
	jsr j_primm
	.byte "MINAX IS DEAD!", $8d
	.byte 0

	jmp next_question

answer_exod:
	jsr print_he_says
	jsr j_primm
	.byte "EXODUS IS DEAD!", $8d
	.byte 0

	jmp next_question

answer_virt:
	jsr print_he_says
	jsr j_primm
	.byte "THE EIGHT", $8d
	.byte "VIRTUES OF THE", $8d
	.byte "AVATAR ARE:", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte "HONESTY,", $8d
	.byte "COMPASSION,", $8d
	.byte "VALOR,", $8d
	.byte "JUSTICE,", $8d
	.byte "SACRIFICE,", $8d
	.byte "HONOR,", $8d
	.byte "SPIRITUALITY,", $8d
	.byte "AND HUMILITY!", $8d
	.byte 0

	jmp next_question

lb_intro:
	jsr j_primm
	.byte "LORD BRITISH", $8d
	.byte "RISES AND SAYS", $8d
	.byte "AT LONG LAST!", $8d
	.byte 0

	lda #$01
	sta currplayer
	jsr j_printname
	jsr j_primm
	.byte $8d
	.byte "THOU HAST COME!", $8d
	.byte "WE HAVE WAITED", $8d
	.byte "SUCH A LONG,", $8d
	.byte "LONG TIME...", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "LORD BRITISH", $8d
	.byte "SITS AND SAYS:", $8d
	.byte "A NEW AGE IS", $8d
	.byte "UPON BRITANNIA.", $8d
	.byte "THE GREAT EVIL", $8d
	.byte "LORDS ARE GONE", $8d
	.byte "BUT OUR PEOPLE", $8d
	.byte "LACK DIRECTION", $8d
	.byte "AND PURPOSE IN", $8d
	.byte "THEIR LIVES...", 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte $8d
	.byte "A CHAMPION OF", $8d
	.byte "VIRTUE IS CALLED", $8d
	.byte "FOR. THOU MAY BE", $8d
	.byte "THIS CHAMPION,", $8d
	.byte "BUT ONLY TIME", $8d
	.byte "SHALL TELL. I", $8d
	.byte "WILL AID THEE", $8d
	.byte "ANY WAY THAT I", $8d
	.byte "CAN!", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "HOW MAY I", $8d
	.byte "HELP THEE?", $8d
	.byte 0

	jmp main_prompt

keywords:
	.byte "    "
	.byte "BYE "
	.byte "NAME"
	.byte "LOOK"
	.byte "JOB "
	.byte "HEAL"
	.byte "TRUT"
	.byte "LOVE"
	.byte "COUR"
	.byte "HONE"
	.byte "COMP"
	.byte "VALO"
	.byte "JUST"
	.byte "SACR"
	.byte "HONO"
	.byte "SPIR"
	.byte "HUMI"
	.byte "PRID"
	.byte "AVAT"
	.byte "QUES"
	.byte "BRIT"
	.byte "ANKH"
	.byte "HELP"
	.byte "ABYS"
	.byte "MOND"
	.byte "MINA"
	.byte "EXOD"
	.byte "VIRT"
	.byte 0, 0, 0, 0

check_keyword:
	lda #$00
	sta talk_zptmp
@check:
	lda talk_zptmp
	asl a
	asl a
	tay
	ldx #$00
@compare:
	lda keywords,y
	beq @nomatch
	cmp inbuf,x
	bne @next
	iny
	inx
	cpx #$04
	bcc @compare
	lda talk_zptmp
	rts

@next:
	inc talk_zptmp
	jmp @check

@nomatch:
	lda #$ff
	rts

get_input:
	lda #$bf
	jsr j_console_out
	lda #$00
	sta talk_zptmp
@getkey:
	jsr j_waitkey
	cmp #$8d
	beq @enter
	cmp #$94
	beq @backspace
	cmp #$a0
	bcc @getkey
	ldx talk_zptmp
	sta inbuf,x
	jsr j_console_out
	inc talk_zptmp
	lda talk_zptmp
	cmp #$0f
	bcc @getkey
	bcs @enter
@backspace:
	lda talk_zptmp
	beq @getkey
	dec talk_zptmp
	dec console_xpos
	lda #$a0
	jsr j_console_out
	dec console_xpos
	jmp @getkey

@enter:
	ldx talk_zptmp
	lda #$a0
@padspace:
	sta inbuf,x
	inx
	cpx #$06
	bcc @padspace
	lda #$8d
	jsr j_console_out
	rts

restore_party_hp:
	lda party_size
	sta currplayer
@next:
	jsr j_get_stats_ptr
	ldy #$12
	lda (ptr1),y
	cmp #$c4
	beq @dead
	lda #$c7
	sta (ptr1),y
	ldy #$1a
	lda (ptr1),y
	ldy #$18
	sta (ptr1),y
	ldy #$1b
	lda (ptr1),y
	ldy #$19
	sta (ptr1),y
@dead:
	dec currplayer
	bne @next
	rts

decode_bcd_value:
	cmp #$00
	beq @done
	ldx #$00
	sed
@inc:
	inx
	sec
	sbc #$01
	bne @inc
	txa
	cld
@done:
	rts

exit_conversation:
	lda $0d
	pha
	lda $0c
	pha
	rts
