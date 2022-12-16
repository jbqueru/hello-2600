; Copyright 2022 Jean-Baptiste M. "JBQ" "Djaybee" Queru
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;    http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

	.processor	6502

_TIA_VSYNC	.equ	$00
_TIA_VBLANK	.equ	$01
_TIA_WSYNC	.equ	$02
;_TIA_RSYNC	.equ	$03
_TIA_NUSIZ0	.equ	$04
_TIA_NUSIZ1	.equ	$05
_TIA_COLUP0	.equ	$06
_TIA_COLUP1	.equ	$07
_TIA_COLUPF	.equ	$08
_TIA_COLUBK	.equ	$09
_TIA_CTRLPF	.equ	$0A
_TIA_REFP0	.equ	$0B
_TIA_REFP1	.equ	$0C
_TIA_PF0	.equ	$0D
_TIA_PF1	.equ	$0E
_TIA_PF2	.equ	$0F
_TIA_RESP0	.equ	$10
_TIA_RESP1	.equ	$11
_TIA_RESM0	.equ	$12
_TIA_RESM1	.equ	$13
_TIA_RESBL	.equ	$14
_TIA_AUDC0	.equ	$15
_TIA_AUDC1	.equ	$16
_TIA_AUDF0	.equ	$17
_TIA_AUDF1	.equ	$18
_TIA_AUDV0	.equ	$19
_TIA_AUDV1	.equ	$1A
_TIA_GRP0	.equ	$1B
_TIA_GRP1	.equ	$1C
_TIA_ENAM0	.equ	$1D
_TIA_ENAM1	.equ	$1E
_TIA_ENABL	.equ	$1F
_TIA_HMP0	.equ	$20
_TIA_HMP1	.equ	$21
_TIA_HMM0	.equ	$22
_TIA_HMM1	.equ	$23
_TIA_HMBL	.equ	$24
_TIA_VDELP0	.equ	$25
_TIA_VDELP1	.equ	$26
_TIA_VDELBL	.equ	$27
_TIA_RESMP0	.equ	$28
_TIA_RESMP1	.equ	$29
_TIA_HMOVE	.equ	$2A
_TIA_HMCLR	.equ	$2B
_TIA_CXCLR	.equ	$2C

_TIA_CO_GRAY	.equ	$00
_TIA_CO_GOLD	.equ	$10
_TIA_CO_ORANGE	.equ	$20
_TIA_CO_BRT_ORG	.equ	$30
_TIA_CO_PINK	.equ	$40
_TIA_CO_PURPLE	.equ	$50
_TIA_CO_PUR_BLU	.equ	$60
_TIA_CO_BLU_PUR	.equ	$70
_TIA_CO_BLUE	.equ	$80
_TIA_CO_LT_BLUE	.equ	$90
_TIA_CO_TURQ	.equ	$A0
_TIA_CO_GRN_BLU	.equ	$B0
_TIA_CO_GREEN	.equ	$C0
_TIA_CO_YLW_GRN	.equ	$D0
_TIA_CO_ORG_GRN	.equ	$E0
_TIA_CO_LT_ORG	.equ	$F0

_TIA_LU_MIN	.equ	$0
_TIA_LU_V_DARK	.equ	$2
_TIA_LU_DARK	.equ	$4
_TIA_LU_M_DARK	.equ	$6
_TIA_LU_M_LIGHT	.equ	$8
_TIA_LU_LIGHT	.equ	$A
_TIA_LU_V_LIGHT	.equ	$C
_TIA_LU_MAX	.equ	$E

	.org	$F000
Init:
; Set up CPU
	CLD
	LDX	#$FF
	TXS

; Wait a bit, so things can stabilize
	LDA	#0
	TAX
	TAY
Wait:	INY
	BNE	Wait
        INX
        BNE	Wait

; Clear zero-page (TIA + RAM)
	TAX
Clear:	STA	0,X
	INX
	BNE	Clear

Loop:
; A line is a WSync followed by other things

; Overscan
; First line of overscan: turn display off
	STA	_TIA_WSYNC	; overscan line 1
	LDA	#2
	STA	_TIA_VBLANK
; Then 29 lines of overscan without anything in them
	.repeat 29
	STA	_TIA_WSYNC	; overscan line 2-30
	.repend

; Vsync
; First line of Vsync: turn sync on
	STA	_TIA_WSYNC	; vsync line 1
	LDA	#2
	STA	_TIA_VSYNC
; Then 2 lines of vsync without anything in them
	.repeat 2
	STA	_TIA_WSYNC	; vsync line 2-3
	.repend

; Vblank
; First line of Vblank: turn sync off
	STA	_TIA_WSYNC	; vblank line 1
	LDA	#0
	STA	_TIA_VSYNC
        STA	_TIA_PF0
        STA	_TIA_PF1
        STA	_TIA_PF2
; Then 36 lines of vsync without anything in them
	.repeat 36
	STA	_TIA_WSYNC	; vblank line 2-37
	.repend

; 1111 00000100 11100100 0101 11100111 11011111
; 1000 10000101 00010100 0101 00010100 00010000
; 1000 10000101 00010010 1001 00010100 00010000
; 1000 10000101 11110001 0001 11100111 10011110
; 1000 10000101 00010001 0001 00010100 00010000
; 1000 10100101 00010001 0001 00010100 00010000
; 1111 00011001 00010001 0001 11110111 11011111

; Active area
; First line of Vblank: turn display on
	STA	_TIA_WSYNC	; line 1
	LDA	#0
	STA	_TIA_VBLANK
	STA	_TIA_WSYNC	; line 2
	STA	_TIA_WSYNC	; line 3
	LDA	#_TIA_CO_GOLD+_TIA_LU_LIGHT
	STA	_TIA_COLUPF
	STA	_TIA_WSYNC	; line 4

; 1111 00000100 11100100 0101 11100111 11011111
	LDY	8
Gfx1:
	STA	_TIA_WSYNC	; line 5-12
	LDA	#%11110000	; cycle 0
	STA	_TIA_PF0	; cycle 2
	LDA	#%00000100	; cycle 5
	STA	_TIA_PF1	; cycle 7
	LDA	#%00100111	; cycle 10
	STA	_TIA_PF2	; cycle 12

; magic 21-cycle sequence
	CLC
	LDA	#$2A		; hides 'ROL A'
	BCC	*-1

	LDA	#%10100000	; cycle 36
	STA	_TIA_PF0	; cycle 38
	LDA	#%11100111	; cycle 41
	STA	_TIA_PF1	; cycle 43
	LDA	#%11111011	; cycle 46
	STA	_TIA_PF2	; cycle 48

	DEY
        BNE	Gfx1

; 1000 10000101 00010100 0101 00010100 00010000
	LDY	8
Gfx2:
	STA	_TIA_WSYNC	; line 13-20
	LDA	#%00010000	; cycle 0
	STA	_TIA_PF0	; cycle 2
	LDA	#%10000101	; cycle 5
	STA	_TIA_PF1	; cycle 7
	LDA	#%00101000	; cycle 10
	STA	_TIA_PF2	; cycle 12

; magic 21-cycle sequence
	CLC
	LDA	#$2A		; hides 'ROL A'
	BCC	*-1

	LDA	#%10100000	; cycle 36
	STA	_TIA_PF0	; cycle 38
	LDA	#%00010100	; cycle 41
	STA	_TIA_PF1	; cycle 43
	LDA	#%00001000	; cycle 46
	STA	_TIA_PF2	; cycle 48

	DEY
        BNE	Gfx2

; 1000 10000101 00010010 1001 00010100 00010000
	LDY	8
Gfx3:
	STA	_TIA_WSYNC	; line 21-28
	LDA	#%00010000	; cycle 0
	STA	_TIA_PF0	; cycle 2
	LDA	#%10000101	; cycle 5
	STA	_TIA_PF1	; cycle 7
	LDA	#%01001000	; cycle 10
	STA	_TIA_PF2	; cycle 12

; magic 21-cycle sequence
	CLC
	LDA	#$2A		; hides 'ROL A'
	BCC	*-1

	LDA	#%10010000	; cycle 36
	STA	_TIA_PF0	; cycle 38
	LDA	#%00010100	; cycle 41
	STA	_TIA_PF1	; cycle 43
	LDA	#%00001000	; cycle 46
	STA	_TIA_PF2	; cycle 48

	DEY
        BNE	Gfx3

; 1000 10000101 11110001 0001 11100111 10011110
	LDY	8
Gfx4:
	STA	_TIA_WSYNC	; line 29-36
	LDA	#%00010000	; cycle 0
	STA	_TIA_PF0	; cycle 2
	LDA	#%10000101	; cycle 5
	STA	_TIA_PF1	; cycle 7
	LDA	#%10001111	; cycle 10
	STA	_TIA_PF2	; cycle 12

; magic 21-cycle sequence
	CLC
	LDA	#$2A		; hides 'ROL A'
	BCC	*-1

	LDA	#%10000000	; cycle 36
	STA	_TIA_PF0	; cycle 38
	LDA	#%11100111	; cycle 41
	STA	_TIA_PF1	; cycle 43
	LDA	#%01111001	; cycle 46
	STA	_TIA_PF2	; cycle 48

	DEY
        BNE	Gfx4

; 1000 10000101 00010001 0001 00010100 00010000
	LDY	8
Gfx5:
	STA	_TIA_WSYNC	; line 37-44
	LDA	#%00010000	; cycle 0
	STA	_TIA_PF0	; cycle 2
	LDA	#%10000101	; cycle 5
	STA	_TIA_PF1	; cycle 7
	LDA	#%10001000	; cycle 10
	STA	_TIA_PF2	; cycle 12

; magic 21-cycle sequence
	CLC
	LDA	#$2A		; hides 'ROL A'
	BCC	*-1

	LDA	#%10000000	; cycle 36
	STA	_TIA_PF0	; cycle 38
	LDA	#%00010100	; cycle 41
	STA	_TIA_PF1	; cycle 43
	LDA	#%00001000	; cycle 46
	STA	_TIA_PF2	; cycle 48

	DEY
        BNE	Gfx5

; 1000 10100101 00010001 0001 00010100 00010000
	LDY	8
Gfx6:
	STA	_TIA_WSYNC	; line 45-52
	LDA	#%00010000	; cycle 0
	STA	_TIA_PF0	; cycle 2
	LDA	#%10100101	; cycle 5
	STA	_TIA_PF1	; cycle 7
	LDA	#%10001000	; cycle 10
	STA	_TIA_PF2	; cycle 12

; magic 21-cycle sequence
	CLC
	LDA	#$2A		; hides 'ROL A'
	BCC	*-1

	LDA	#%10000000	; cycle 36
	STA	_TIA_PF0	; cycle 38
	LDA	#%00010100	; cycle 41
	STA	_TIA_PF1	; cycle 43
	LDA	#%00001000	; cycle 46
	STA	_TIA_PF2	; cycle 48

	DEY
        BNE	Gfx6

; 1111 00011001 00010001 0001 11100111 11011111
	LDY	8
Gfx7:
	STA	_TIA_WSYNC	; line 53-60
	LDA	#%11110000	; cycle 0
	STA	_TIA_PF0	; cycle 2
	LDA	#%00011001	; cycle 5
	STA	_TIA_PF1	; cycle 7
	LDA	#%10001000	; cycle 10
	STA	_TIA_PF2	; cycle 12

; magic 21-cycle sequence
	CLC
	LDA	#$2A		; hides 'ROL A'
	BCC	*-1

	LDA	#%10000000	; cycle 36
	STA	_TIA_PF0	; cycle 38
	LDA	#%11100111	; cycle 41
	STA	_TIA_PF1	; cycle 43
	LDA	#%11111011	; cycle 46
	STA	_TIA_PF2	; cycle 48

	DEY
        BNE	Gfx7

	STA	_TIA_WSYNC	; line 61
	LDA	#0
        STA	_TIA_PF0
        STA	_TIA_PF1
        STA	_TIA_PF2

	LDY	#131
Lines:
	STA	_TIA_WSYNC	; line 62-192
	DEY
        BNE	Lines

	JMP	Loop

; Reset / Start vectors
	.org	$FFFC
	.word	Init
	.word	Init

; Notes

; Address space repeats every 8kB (address bus only has 16 pins).
;
; Bottom 4kB: repeat every 1kB
; each copy is split in slices of 128 bytes, with 3 possible slices
; 2 copies of TIA registers
; RIOT RAM
; 2 copies of TIA registers
; RIOT RAM
; 2 copies of TIA registers
; 4 copies of RIOT registers
; 2 copies of TIA registers
; 4 copies of RIOT registers
;
; Top 4kB: ROM

; NTSC timings
;
; In the 1953 timings, a line is 227.5 cycles of color subcarrier,
; and a field is 262.5 lines.
; The vertical blank has 3 lines of equalizing pulse, 3 lines of sync,
; 3 lines of equalizing pulse, and a total blank duration of 7% to 8%
; of the total field time, i.e. 18.4 to 21 lines, for a total number of
; active lines therefore between 241.5 and 243.5 (NTSC fields contain
; a half-line).
; 
; In the 2600, lines are slightly longer than standard (228 cycles
; of color subcarrier), and 262 lines is the number that best approximates
; the standard frame rate and is closest to 60 fps. Following the spec
; to the letter, the total blank should be between 18.3 and 20 lines, with
; 21 lines being very slightly off-spec. 20 lines of blank results in 242
; active lines, a conveniently even number, with 3 lines before sync,
; 3 lines during sync, and 14 lines after sync.
;
; That matches the line counts in the NES, which however runs slightly fast
; with 227 1/3 cycles of color subcarrier per line. They could have squeezed
; an extra line of blank in there, to get closer to the official field rate.
; The NES is active for 242 lines, with 2 empty lines, i.e.
; 4 +/- 1 lines before sync, 3 lines of sync, 15 +/- 1 lines after sync.
;
; On the NES, the "guaranteed" drawing area is considered to be the middle
; 192 lines of the active area, while the top and bottom 8 lines can
; be considered to be near-invisible. In the 16 lines in between on either
; side, 8 are considered safe enough at the top and 12 at the bottom,
; probably a reflection of a desire for TVs to show slightly more at the bottom
; because of new channels' marquees at the bottom.
;
; Converting that in lines for the 2600:
; * Guaranteed: between 27+3+39 and 29+3+37
; * Safe: between 15+3+32 and 17+3+30
; * Likely visible: between 11+3+24 and 13+3+22
; * 240 lines: between 3+3+16 and 5+3+14
;
; Even for the traditional 192 lines, it's possible that going 3 lines
; lower than recommended by Atari (27+3+40) would produce better results
; on old-style analog TVs, but the risk of confusing emulators is probably
; not worth it.
;
; It's oddly ingrained that the 2600 has a fixed number of
; lines, when in fact it doesn't care and will happily generate 242 lines
; if you ask it to.
;
; For reference, Javatari renders 212 lines, with 17+3+30 timings, within the
; safe range reverse-engineered above.


; 345678901234567890123456789012345678901234567890123456789012345678901234567890
