; Copyright (c) 2009-2010, Michael Alyn Miller <malyn@strangeGizmo.com>.
; All rights reserved.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
;
; 1. Redistributions of source code must retain the above copyright notice
;    unmodified, this list of conditions, and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright notice,
;    this list of conditions and the following disclaimer in the documentation
;    and/or other materials provided with the distribution.
; 3. Neither the name of Michael Alyn Miller nor the names of the contributors
;    to this software may be used to endorse or promote products derived from
;    this software without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS "AS IS" AND ANY
; EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
; DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
; THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


; ======================================================================
; STRING Words
; ======================================================================

; ----------------------------------------------------------------------
; /STRING [STRING] 17.6.1.0245 "slash-string" ( c-addr1 u1 n -- c-addr2 u2 )
;
; Adjust the character string at c-addr1 by n characters.  The resulting
; character string, specified by c-addr2 u2, begins at c-addr1 plus n
; characters and is u1 minus n characters long.

            LINKTO(LINK_STRING,0,7,'G',"NIRTS/")
SLASHSTRING:SAVEDE
            MOV     D,B         ; Save BC
            MOV     E,C         ; ..in DE.
            POP     B           ; Pop the adjustment value into BC.
            POP     H           ; Pop the length into HL.
            DSUB                ; Adjust the length.
            XTHL                ; Swap the adjusted length with the address.
            DAD     B           ; Adjust the address.
            XTHL                ; Swap the address and length again.
            PUSH    H           ; Push the length onto the stack.
            MOV     B,D         ; Restore BC
            MOV     C,E         ; ..from DE.
            RESTOREDE
            NEXT


; ----------------------------------------------------------------------
; CMOVE [STRING] 17.6.1.0910 "c-move" ( c-addr1 c-addr2 u -- )
;
; If u is greater than zero, copy u consecutive characters from the data
; space starting at c-addr1 to that starting at c-addr2, proceeding
; character-by-character from lower addresses to higher addresses.

            LINKTO(SLASHSTRING,0,5,'E',"VOMC")
CMOVE:      SAVEDE
            SAVEBC
            POP     B           ; Pop u into BC.
            POP     D           ; Pop addr2 into DE.
            POP     H           ; Pop addr1 into HL.
_cmove1:    MOV     A,B         ; We're done if B
            ORA     C           ; ..and C
            JZ      _cmoveDONE  ; ..are zero.
            MOV     A,M         ; Copy the next byte from [HL]
            STAX    D           ; ..to [DE]
            INX     H           ; ..and then increment both HL
            INX     D           ; ..and DE.
            DCX     B           ; Decrement BC
            JMP     _cmove1     ; ..and continue looping.
_cmoveDONE: RESTOREBC
            RESTOREDE
            NEXT


; ----------------------------------------------------------------------
; CMOVE> [STRING] 17.6.1.0920 "c-move-up" ( c-addr1 c-addr2 u -- )
;
; If u is greater than zero, copy u consecutive characters from the data
; space starting at c-addr1 to that starting at c-addr2, proceeding
; character-by-character from higher addresses to lower addresses.

            LINKTO(CMOVE,0,6,'>',"EVOMC")
CMOVEUP:    SAVEDE
            SAVEBC
            POP     B           ; Pop u into BC.
            POP     D           ; Pop addr2 into DE.
            POP     H           ; Pop addr1 into HL.
            DAD     B           ; Add u to addr1.
            XCHG                ; Swap addr1 and addr2,
            DAD     B           ; ..add u to addr2,
            XCHG                ; ..then swap addr2 and addr1 again.
_cmoveup1:  MOV     A,B         ; We're done if B
            ORA     C           ; ..and C
            JZ      _cmoveupDONE; ..are zero.
            DCX     H           ; Decrement both HL
            DCX     D           ; ..and DE.
            MOV     A,M         ; Copy the next byte from [HL]
            STAX    D           ; ..to [DE].
            DCX     B           ; Decrement BC
            JMP     _cmoveup1   ; ..and continue looping.
_cmoveupDONE:RESTOREBC
            RESTOREDE
            NEXT

; ----------------------------------------------------------------------
; COMPARE [STRING] 17.6.1.0935 ( c-addr1 u1 c-addr2 u2 -- n )
;
; Compare the string specified by c-addr1 u1 to the string specified by
; c-addr2 u2. The strings are compared, beginning at the given addresses,
; character by character, up to the length of the shorter string or until a
; difference is found. If the two strings are identical, n is zero. If the
; two strings are identical up to the length of the shorter string, n is
; minus-one (-1) if u1 is less than u2 and one (1) otherwise. If the two
; strings are not identical up to the length of the shorter string, n is
; minus-one (-1) if the first non-matching character in the string specified
; by c-addr1 u1 has a lesser numeric value than the corresponding character in
; the string specified by c-addr2 u2 and one (1) otherwise.
;
; From Jim Peterson's reference implementation
; https://forth-standard.org/standard/string/COMPARE#contribution-398
; ---
; : _cmp ( x1 x2 -- -1|0|1 ) - DUP IF 0< 1 OR THEN ;

;: COMPARE ( addr1 u1 addr2 u2 -- -1|0|1 )
;  ROT 2DUP SWAP _cmp >R
;  MIN ?DUP IF
;    0 DO
;      COUNT >R SWAP COUNT R> _cmp ?DUP IF
;        NIP NIP UNLOOP R> DROP EXIT
;      THEN
;      SWAP
;    LOOP
;  THEN
;  2DROP
;  R> ;

_cmp:		JMP 	ENTER
			.WORD	MINUS,DUP,zbranch,_cmpexit,ZEROLESS,ONE,OR
_cmpexit:	.WORD	EXIT

			LINKTO(CMOVEUP,0,7,'E',"RAPMOC")
LAST_STRING:
COMPARE:	JMP		ENTER
			.WORD	ROT,TWODUP,SWAP,_cmp,TOR
			.WORD	MIN,QDUP,zbranch,_compexit
			.WORD	ZERO,pdo
_comploop:	.WORD	COUNT,TOR,SWAP,COUNT,RFROM,_cmp,QDUP,zbranch,_comp1
			.WORD	NIP,NIP,UNLOOP,RFROM,DROP,EXIT
_comp1:		.WORD	SWAP
			.WORD	ploop,_comploop
_compexit:	.WORD	TWODROP
			.WORD	RFROM,EXIT
