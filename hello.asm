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
	LDA	#78
	STA	_TIA_COLUPF

	STA	_TIA_WSYNC
	LDA	#6
	STA	_TIA_PF2
	LDA	#142
	STA	_TIA_COLUPF

	LDX	#95
Lines:
	STA	_TIA_WSYNC
	LDA	#1
	STA	_TIA_PF2
	LDA	#78
	STA	_TIA_COLUPF

	STA	_TIA_WSYNC
	LDA	#6
	STA	_TIA_PF2
	LDA	#142
	STA	_TIA_COLUPF

	DEX
        BNE	Lines

	JMP	Loop

; Reset / Start vectors
	.org	$FFFC
	.word	Init
	.word	Init

; Notes

; Address space repeats every 8kB

; Bottom 4kB: repeat every 1kB
; each copy is split in slices of 128 bytes, with 3 possible slices
; 2 copies of TIA registers
; RAM
; 2 copies of TIA registers
; RAM
; 2 copies of TIA registers
; 4 copies of RIOT registers
; 2 copies of TIA registers
; 4 copies of RIOT registers

; Top 4kB: ROM

; 345678901234567890123456789012345678901234567890123456789012345678901234567890
