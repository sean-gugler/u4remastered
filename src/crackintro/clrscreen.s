	.export init

	.import basicstub
	.import basiclen
	.import programstub

	.code
;	.segment "CLRSCREEN"

init:
	; Restore basic startup for main program.
	ldx #<basiclen - 1
:	lda programstub,x
	sta basicstub,x
	dex
	bpl :-

	; Set all text color to be same as background
	lda $d021
	ldx #0
:	sta $d800,x
	sta $d900,x
	sta $da00,x
	sta $db00,x
	inx
	bne :-

	; ASSUME "loader.prg" begins with "SYS 2061"
	jmp 2061 ; $080d
