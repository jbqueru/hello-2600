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
_TIA_CO_YLW_GRN	.equ	$D0
_TIA_CO_YLW_GRN	.equ	$D0

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
	STA	_TIA_WSYNC
	LDA	#2
	STA	_TIA_VBLANK
; Then 29 lines of overscan without anything in them
	.repeat 29
	STA	_TIA_WSYNC
	.repend

; Vsync
; First line of Vsync: turn sync on
	STA	_TIA_WSYNC
	LDA	#2
	STA	_TIA_VSYNC
; Then 2 lines of vsync without anything in them
	.repeat 2
	STA	_TIA_WSYNC
	.repend

; Vblank
; First line of Vblank: turn sync off
	STA	_TIA_WSYNC
	LDA	#0
	STA	_TIA_VSYNC
; Then 36 lines of vsync without anything in them
	.repeat 36
	STA	_TIA_WSYNC
	.repend

; Active area
; First line of Vblank: turn display on
	STA	_TIA_WSYNC
	LDA	#0
	STA	_TIA_VBLANK
	LDA	#1
	STA	_TIA_PF2
	LDA	#_TIA_CO_PINK+_TIA_LU_MAX
	STA	_TIA_COLUPF

	STA	_TIA_WSYNC
	LDA	#6
	STA	_TIA_PF2
	LDA	#_TIA_CO_BLUE+_TIA_LU_MAX
	STA	_TIA_COLUPF

	LDX	#94
Lines:
	STA	_TIA_WSYNC
	LDA	#1
	STA	_TIA_PF2
	LDA	#_TIA_CO_PINK+_TIA_LU_M_LIGHT
	STA	_TIA_COLUPF

	STA	_TIA_WSYNC
	LDA	#6
	STA	_TIA_PF2
	LDA	#_TIA_CO_BLUE+_TIA_LU_M_LIGHT
	STA	_TIA_COLUPF

	DEX
        BNE	Lines

	STA	_TIA_WSYNC
	LDA	#1
	STA	_TIA_PF2
	LDA	#_TIA_CO_PINK+_TIA_LU_MAX
	STA	_TIA_COLUPF

	STA	_TIA_WSYNC
	LDA	#6
	STA	_TIA_PF2
	LDA	#_TIA_CO_BLUE+_TIA_LU_MAX
	STA	_TIA_COLUPF


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
