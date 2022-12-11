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

	.org	$F000
Init:
; Set up CPU
	CLD
	LDX	#$FF
	TXS

; Clear zero-page (TIA + RAM)
	INX
	TXA
Clear:	STA	0,X
	INX
	BNE	Clear

Loop:
; Overscan
	.repeat 29
	STA	2
	.repend

; Vsync
	LDA	#2
	STA	0
	.repeat 3
	STA	2
	.repend
	LDA	#0
	STA	0

; Vblank
	.repeat 37
	STA	2
	.repend
	LDA	#0
	STA	1

	.repeat 192
	STA	2
	.repend

; Start Overscan
	STA	2
	LDA	#2
	STA	1

	JMP	Loop

; Reset / Start vectors
	.org	$FFFC
	.word	Init
	.word	Init
