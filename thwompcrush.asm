;This block shatters when hit by a Thwomp
;by Roy, modified by spooonsss
;act like 130

print "Thwomp Crush Block\nA block that shatters when hit by a Thwomp."

db $37
JMP Return : JMP Return : JMP Return
JMP SpriteV : JMP Return
JMP Return : JMP Return
JMP Return : JMP Return : JMP Return
JMP Return : JMP Return


!CUSTOM_SPRITE = $26    ; set custom sprite
!NORMAL_SPRITE = $26    ; set normal sprite
!THWOMP_GOES_THROUGH = 0 ; 1 => thwomp crushes the block and goes straight through (this block acts as 025)

SpriteV:
	LDA !7FAB10,x           ; \ check if its a custom sprite...
	AND #$08                ;  |
	BEQ Normal              ; /
Custom:
	LDA !7FAB9E,x           ; \ if its a certain custom sprite...
	CMP #!CUSTOM_SPRITE     ;  |
	BNE Return              ; /
	BRA Status

Normal:
	LDA !9E,x               ; \ if the sprite is a thwomp...
	CMP #!NORMAL_SPRITE     ;  |
	BNE Return              ; /
Status:
	LDA !14C8,x             ; \ if the sprite is alive...
	CMP #$08                ;  |
	BNE Return              ; /

Crush:
	LDA $0F ; $0F must be preserved https://smwc.me/m/smw/rom/019138/ (shatter_block/ChangeMap16/$00BEB0 clobbers it)
	PHA
	%sprite_block_position()

	; preserve $98/$9A for vertical levels
	REP #$20
	LDA $98
	PHA
	LDA $9A
	PHA
	SEP #$30
	; shatter_block doesn't support this
	; LDY.b #!SHATTER_TYPE      ; set animation for the shatter
	%shatter_block()
	REP #$21
	PLA
	STA $9A
	PLA
	STA $98

	; offset to the block to the right
	LDA $9A
	; CLC
	ADC #$0010
	STA $9A
	SEP #$30

	%shatter_block()

	if !THWOMP_GOES_THROUGH
		LDA #$25 : STA $1693|!addr
		LDY #$00
	else
		LDA #$30 : STA $1693|!addr
		LDY #$01
	endif
	PLA
	STA $0F
Return:
	RTL
