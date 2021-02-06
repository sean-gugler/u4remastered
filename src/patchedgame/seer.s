	.include "uscii.i"

;
; **** ZP ABSOLUTE ADDRESSES **** 
;
last_meditated = $29
move_counter_lo = $2f
console_xpos = $4e
currplayer = $54
zptemp = $6a
zptmp_mismatches = $70
ptr1 = $7e
;ptr1 + 1 = $7f
;
; **** ZP POINTERS **** 
;
;ptr1 = $7e
;
; **** USER LABELS **** 
;
j_waitkey = $0800
j_primm = $0821
j_console_out = $0824
j_get_stats_ptr = $082d
j_printname = $0830
stats = $ab00
stat_spirit = $ab06
inbuf = $af00



	.segment "OVERLAY"

	lda #$01
	sta currplayer
	jsr j_get_stats_ptr
	ldy #$12
	lda (ptr1),y
	cmp #$c7     ;(g)ood
	beq welcome
	cmp #$d0     ;(p)oisoned
	beq welcome
	jsr j_primm
	.byte $8d
	.byte "THE SEER SAYS:", $8d
	.byte "I WILL SPEAK", $8d
	.byte "ONLY WITH", $8d
	.byte 0
	jsr j_printname
	jsr j_primm
	.byte $8d
	.byte "RETURN WHEN", $8d
	.byte 0
	jsr j_printname
	jsr j_primm
	.byte $8d
	.byte "IS REVIVED!", $8d
	.byte 0
	rts 

welcome:
	jsr j_primm
	.byte $8d
	.byte "WELCOME,", $8d
	.byte 0
	jsr j_printname
	jsr j_primm
	.byte $8d
	.byte "I AM HAWKWIND,", $8d
	.byte "SEER OF SOULS.", $8d
	.byte "I SEE THAT WHICH", $8d
	.byte "IS WITHIN THEE", $8d
	.byte "AND DRIVES THEE", $8d
	.byte "TO DEEDS OF GOOD", $8d
	.byte "OR EVIL...", $8d
	.byte 0
	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "FOR WHAT PATH", $8d
	.byte "DOTH THOU SEEK", $8d
	.byte "ENLIGHTENMENT?", $8d
	.byte 0
	jmp input_word

ask_again:
	jsr j_primm
	.byte $8d
	.byte "HAWKWIND ASKS:", $8d
	.byte "WHAT OTHER PATH", $8d
	.byte "SEEKS CLARITY?", $8d
	.byte 0
input_word:
	jsr get_input
	jsr check_inline_keyword
	.byte "    ", 0
	beq @bye
	jsr check_inline_keyword
	.byte "BYE", 0
	beq @bye
	jsr check_inline_keyword
	.byte "NONE", 0
	beq @bye
	jsr find_token
	bpl @found
	jsr j_primm
	.byte $8d
	.byte "HE SAYS:", $8d
	.byte "THAT IS NOT A", $8d
	.byte "SUBJECT FOR", $8d
	.byte "ENLIGHTENMENT.", $8d
	.byte 0
	jmp ask_again

@found:
	jmp check_avatar

@bye:
	jsr j_primm
	.byte $8d
	.byte "HAWKWIND SAYS:", $8d
	.byte "FARE THEE WELL", $8d
	.byte "AND MAY THOU", $8d
	.byte "COMPLETE THE", $8d
	.byte "QUEST OF", $8d
	.byte "THE AVATAR!", $8d
	.byte 0
	lda move_counter_lo
	cmp last_meditated
	beq @done
	sta last_meditated
	sed 
	clc 
	lda stat_spirit
	beq @skip
	adc #$03
	bcc @skip
	lda #$99
@skip:
	sta stat_spirit
	cld 
@done:
	rts 

check_avatar:
	jsr print_newline
	ldy zptemp
	lda stats,y
	bne lookup_advice
	jsr j_primm
	.byte "HE SAYS:", $8d
	.byte "THOU HAST BECOME", $8d
	.byte "A PARTIAL AVATAR", $8d
	.byte "IN THAT", $8d
	.byte "ATTRIBUTE. THOU", $8d
	.byte "NEED NOT MY", $8d
	.byte "INSIGHTS.", $8d
	.byte 0
	jmp ask_again

lookup_advice:
	ldy zptemp
	lda stats,y
	tax 
	lda #$01
	cpx #$20
	bcc print_advice
	lda #$09
	cpx #$40
	bcc print_advice
	lda #$11
	cpx #$60
	bcc print_advice
	lda #$19
	cpx #$99
	bcc print_advice
	lda #$21
print_advice:
	clc 
	adc zptemp
	jsr print_string
	ldy zptemp
	lda stats,y
	cmp #$99
	bne @done
	jsr j_primm
	.byte $8d
	.byte "GO TO THE SHRINE", $8d
	.byte "AND MEDITATE FOR", $8d
	.byte "THREE CYCLES!", $8d
	.byte 0
	jsr j_waitkey
@done:
	jmp ask_again

tokens:
	.byte "HONE"
	.byte "COMP"
	.byte "VALO"
	.byte "JUST"
	.byte "SACR"
	.byte "HONO"
	.byte "SPIR"
	.byte "HUMI"
	.byte 0,0,0,0

find_token:
	lda #$00
	sta zptemp
@compare_token:
	lda zptemp
	asl 
	asl 
	tay 
	ldx #$00
@next_char:
	lda tokens,y
	beq @not_found
	cmp inbuf,x
	bne @next_token
	iny 
	inx 
	cpx #$04
	bcc @next_char
	lda zptemp
	rts 

@next_token:
	inc zptemp
	jmp @compare_token

@not_found:
	lda #$ff
	sta zptemp
	rts 

get_input:
	lda #$bf
	jsr j_console_out
	lda #$00
	sta zptemp
@get_char:
	jsr j_waitkey
	cmp #$8d
	beq @got_input
	cmp #$94
	beq @backspace
	cmp #$a0
	bcc @get_char
	ldx zptemp
	sta inbuf,x
	jsr j_console_out
	inc zptemp
	lda zptemp
	cmp #$0f
	bcc @get_char
	bcs @got_input
@backspace:
	lda zptemp
	beq @get_char
	dec zptemp
	dec console_xpos
	lda #$a0
	jsr j_console_out
	dec console_xpos
	jmp @get_char

@got_input:
	ldx zptemp
	lda #$a0
@pad_spaces:
	sta inbuf,x
	inx 
	cpx #$06
	bcc @pad_spaces
	lda #$8d
	jsr j_console_out
	rts 

check_inline_keyword:
	pla 
	sta ptr1
	pla 
	sta ptr1 + 1
	ldy #$00
	sty zptmp_mismatches
	ldx #$ff
@next:
	inx 
	inc ptr1
	bne :+
	inc ptr1 + 1
:	lda (ptr1),y
	beq @done
	cmp inbuf,x
	beq @next
	inc zptmp_mismatches
	jmp @next
@done:
	lda ptr1 + 1
	pha 
	lda ptr1
	pha 
	lda zptmp_mismatches
	rts 

	rts 

print_newline:
	lda #$8d
	jsr j_console_out
	rts 

print_string:
	tay 
	lda #<string_table
	sta ptr1
	lda #>string_table
	sta ptr1 + 1
	ldx #$00
@next_char:
	lda (ptr1,x)
	beq @end_string
@next_string:
	jsr inc_ptr
	jmp @next_char

@end_string:
	dey 
	beq @print_char
	jmp @next_string

@print_char:
	jsr inc_ptr
	ldx #$00
	lda (ptr1,x)
	beq @done
	jsr j_console_out
	jmp @print_char

@done:
	rts 

inc_ptr:
	inc ptr1
	bne :+
	inc ptr1 + 1
:	rts 

string_table:
	.byte 0
	.byte "THOU ART A THIEF", $8d
	.byte "AND A SCOUNDREL.", $8d
	.byte "THOU MAY NOT", $8d
	.byte "EVER BECOME AN", $8d
	.byte "AVATAR!", $8d
	.byte 0
	.byte "THOU ART A COLD", $8d
	.byte "AND CRUEL BRUTE.", $8d
	.byte "THOU SHOULDST GO", $8d
	.byte "TO PRISON FOR", $8d
	.byte "THY CRIMES!", $8d
	.byte 0
	.byte "THOU ART A", $8d
	.byte "COWARD, THOU", $8d
	.byte "DOST FLEE FROM", $8d
	.byte "THE HINT OF", $8d
	.byte "DANGER!", $8d
	.byte 0
	.byte "THOU ART AN", $8d
	.byte "UNJUST WRETCH.", $8d
	.byte "THOU ART A", $8d
	.byte "FULSOME MEDDLER!", $8d
	.byte 0
	.byte "THOU ART A", $8d
	.byte "SELF-SERVING", $8d
	.byte "TUFTHUNTER, THOU", $8d
	.byte "DESERVETH NOT", $8d
	.byte "MY HELP, YET I", $8d
	.byte "GRANT IT!", $8d
	.byte 0
	.byte "THOU ART A CAD", $8d
	.byte "AND A BOUNDER.", $8d
	.byte "THY PRESENCE IS", $8d
	.byte "AN AFFRONT, THOU", $8d
	.byte "ART LOW AS A", $8d
	.byte "SLUG!", $8d
	.byte 0
	.byte "THY SPIRIT IS", $8d
	.byte "WEAK AND FEEBLE.", $8d
	.byte "THOU DOST NOT", $8d
	.byte "STRIVE FOR", $8d
	.byte "PERFECTION!", $8d
	.byte 0
	.byte "THOU ART PROUD", $8d
	.byte "AND VAIN,", $8d
	.byte "ALL OTHER VIRTUE", $8d
	.byte "IN THEE IS", $8d
	.byte "A LOSS!", $8d
	.byte 0
	.byte "THOU ART NOT", $8d
	.byte "AN HONEST SOUL,", $8d
	.byte "THOU MUST LIVE", $8d
	.byte "A MORE HONEST", $8d
	.byte "LIFE TO BE", $8d
	.byte "AN AVATAR!", $8d
	.byte 0
	.byte "THOU DOST KILL", $8d
	.byte "WHERE THERE IS", $8d
	.byte "NO NEED AND GIVE", $8d
	.byte "TOO LITTLE UNTO", $8d
	.byte "OTHERS!", $8d
	.byte 0
	.byte "THOU DOST NOT", $8d
	.byte "DISPLAY A GREAT", $8d
	.byte "DEAL OF VALOR,", $8d
	.byte "THOU DOST FLEE", $8d
	.byte "BEFORE THE NEED!", $8d
	.byte 0
	.byte "THOU ART CRUEL", $8d
	.byte "AND UNJUST, IN", $8d
	.byte "TIME THOU WILL", $8d
	.byte "SUFFER FOR THY", $8d
	.byte "CRIMES!", $8d
	.byte 0
	.byte "THOU DOST NEED", $8d
	.byte "TO THINK MORE", $8d
	.byte "OF THE LIFE OF", $8d
	.byte "OTHERS AND LESS", $8d
	.byte "OF THY OWN!", $8d
	.byte 0
	.byte "THOU DOST NOT", $8d
	.byte "FIGHT WITH HONOR", $8d
	.byte "BUT WITH MALICE", $8d
	.byte "AND DECEIT!", $8d
	.byte 0
	.byte "THOU DOST NOT", $8d
	.byte "TAKE THE TIME TO", $8d
	.byte "CARE ABOUT THY", $8d
	.byte "INNER BEING, A", $8d
	.byte "MUST TO BE AN", $8d
	.byte "AVATAR!", $8d
	.byte 0
	.byte "THOU ART TOO", $8d
	.byte "PROUD OF THY", $8d
	.byte "LITTLE DEEDS,", $8d
	.byte "HUMILITY IS THE", $8d
	.byte "ROOT OF ALL", $8d
	.byte "VIRTUE!", $8d
	.byte 0
	.byte "THOU HAST MADE", $8d
	.byte "LITTLE PROGRESS", $8d
	.byte "ON THE PATHS", $8d
	.byte "OF HONESTY,", $8d
	.byte "STRIVE TO PROVE", $8d
	.byte "THY WORTH!", $8d
	.byte 0
	.byte "THOU HAST NOT", $8d
	.byte "SHOWN THY", $8d
	.byte "COMPASSION WELL.", $8d
	.byte "BE MORE KIND", $8d
	.byte "UNTO OTHERS!", $8d
	.byte 0
	.byte "THOU ART NOT YET", $8d
	.byte "A VALIANT", $8d
	.byte "WARRIOR, FIGHT", $8d
	.byte "TO DEFEATE EVIL", $8d
	.byte "AND PROVE", $8d
	.byte "THYSELF!", $8d
	.byte 0
	.byte "THOU HAST NOT", $8d
	.byte "PROVEN THYSELF", $8d
	.byte "TO BE JUST.", $8d
	.byte "STRIVE TO DO", $8d
	.byte "JUSTICE UNTO", $8d
	.byte "ALL THINGS!", $8d
	.byte 0
	.byte "THY SACRIFICE", $8d
	.byte "IS SMALL.", $8d
	.byte "GIVE OF THY", $8d
	.byte "LIFE'S BLOOD SO", $8d
	.byte "THAT OTHERS MAY", $8d
	.byte "LIVE.", $8d
	.byte 0
	.byte "THOU DOST NEED", $8d
	.byte "TO SHOW THYSELF", $8d
	.byte "TO BE MORE", $8d
	.byte "HONORABLE, THE", $8d
	.byte "PATH LIES BEFORE", $8d
	.byte "THEE!", $8d
	.byte 0
	.byte "STRIVE TO KNOW", $8d
	.byte "AND MASTER MORE", $8d
	.byte "OF THINE INNER", $8d
	.byte "BEING.", $8d
	.byte "MEDITATION", $8d
	.byte "LIGHTS THE PATH!", $8d
	.byte 0
	.byte "THY PROGRESS ON", $8d
	.byte "THIS PATH IS", $8d
	.byte "MOST UNCERTAIN.", $8d
	.byte "WITHOUT HUMILITY", $8d
	.byte "THOU ART", $8d
	.byte "EMPTY!", $8d
	.byte 0
	.byte "THOU DOST SEEM", $8d
	.byte "TO BE AN HONEST", $8d
	.byte "SOUL, CONTINUED", $8d
	.byte "HONESTY WILL", $8d
	.byte "REWARD THEE!", $8d
	.byte 0
	.byte "THOU DOST SHOW", $8d
	.byte "THY COMPASSION", $8d
	.byte "WELL, CONTINUED", $8d
	.byte "GOODWILL SHOULD", $8d
	.byte "BE THY GUIDE!", $8d
	.byte 0
	.byte "THOU ART SHOWING", $8d
	.byte "VALOR IN THE", $8d
	.byte "FACE OF DANGER.", $8d
	.byte "STRIVE TO BECOME", $8d
	.byte "YET MORE SO!", $8d
	.byte 0
	.byte "THOU DOST SEEM", $8d
	.byte "FAIR AND JUST.", $8d
	.byte "STRIVE TO UPHOLD", $8d
	.byte "JUSTICE EVEN", $8d
	.byte "MORE STERNLY!", $8d
	.byte 0
	.byte "THOU ART GIVING", $8d
	.byte "OF THYSELF IN", $8d
	.byte "SOME WAYS, SEEK", $8d
	.byte "YE NOW TO FIND", $8d
	.byte "YET MORE!", $8d
	.byte 0
	.byte "THOU DOST SEEM", $8d
	.byte "TO BE HONORABLE", $8d
	.byte "IN NATURE, SEEK", $8d
	.byte "TO BRING HONOR", $8d
	.byte "UPON OTHERS AS", $8d
	.byte "WELL!", $8d
	.byte 0
	.byte "THOU ART DOING", $8d
	.byte "WELL ON THE PATH", $8d
	.byte "TO INNER SIGHT.", $8d
	.byte "CONTINUE TO SEEK", $8d
	.byte "THE INNER LIGHT!", $8d
	.byte 0
	.byte "THOU DOST SEEM", $8d
	.byte "A HUMBLE SOUL.", $8d
	.byte "THOU ART SETTING", $8d
	.byte "STRONG STONES TO", $8d
	.byte "BUILD VIRTUES", $8d
	.byte "UPON!", $8d
	.byte 0
	.byte "THOU ART TRULY", $8d
	.byte "AN HONEST SOUL.", $8d
	.byte "SEEK YE NOW TO", $8d
	.byte "REACH ELEVATION!", $8d
	.byte 0
	.byte "COMPASSION IS", $8d
	.byte "A VIRTUE THAT", $8d
	.byte "THOU HAST SHOWN", $8d
	.byte "WELL. SEEK YE", $8d
	.byte "NOW ELEVATION!", $8d
	.byte 0
	.byte "THOU ART A TRULY", $8d
	.byte "VALIANT WARRIOR.", $8d
	.byte "SEEK YE NOW", $8d
	.byte "ELEVATION IN THE", $8d
	.byte "VIRTUE OF VALOR!", $8d
	.byte 0
	.byte "THOU ART JUST", $8d
	.byte "AND FAIR. SEEK", $8d
	.byte "YE NOW THE", $8d
	.byte "ELEVATION!", $8d
	.byte 0
	.byte "THOU ART GIVING", $8d
	.byte "AND GOOD. THY", $8d
	.byte "SELF-SACRIFICE", $8d
	.byte "IS GREAT. SEEK", $8d
	.byte "NOW ELEVATION!", $8d
	.byte 0
	.byte "THOU HAST PROVEN", $8d
	.byte "THYSELF TO BE", $8d
	.byte "HONORABLE, SEEK", $8d
	.byte "YE NOW FOR THE", $8d
	.byte "ELEVATION!", $8d
	.byte 0
	.byte "SPIRITUALITY", $8d
	.byte "IS IN THY", $8d
	.byte "NATURE. SEEK YE", $8d
	.byte "NOW THE", $8d
	.byte "ELEVATION!", $8d
	.byte 0
	.byte "THY HUMILITY", $8d
	.byte "SHINES BRIGHT", $8d
	.byte "UPON THY BEING.", $8d
	.byte "SEEK YE NOW FOR", $8d
	.byte "ELEVATION!", $8d
	.byte 0

; Garbage leftover in sector at end of file

;	.byte $04,$05,$04,$05,$04,$05,$04,$05
;	.byte $04,$05,$04,$05,$04,$13,$ff,$20
;	.byte $e5,$16,$00,$01,$0a,$0a,$0a,$0a
;	.byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
;	.byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
;	.byte $0a,$0a,$14,$ff,$20,$ed,$16,$01
;	.byte $17,$03,$02,$03,$02,$03,$02,$03
;	.byte $02,$03,$02,$03,$02,$03,$02,$03
;	.byte $02,$03,$02,$03,$02,$03,$02,$ff
;	.byte $20,$e5,$16,$17,$01,$0d,$0d,$0d
;	.byte $0d,$0d,$0d,$0d,$0d,$09,$0d,$09
;	.byte $0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d
;	.byte $0d,$0d,$0d,$0b,$ff,$20,$e5,$16
;	.byte $27,$01,$09,$09,$09,$09,$09,$09
;	.byte $09,$09,$01,$09,$05,$ff,$20,$ed
;	.byte $16,$18,$09,$06,$07,$06,$07,$06
;	.byte $07,$06,$07,$06,$07,$06,$07,$06
;	.byte $07,$06,$ff,$20,$ed,$16,$18,$0b
;	.byte $06,$07,$06,$07,$06,$07,$06,$07
