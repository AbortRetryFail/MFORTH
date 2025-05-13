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
; DOUBLE Words
; ======================================================================

; ----------------------------------------------------------------------
; 2, [MFORTH] "two-comma" ( x1 x2 -- )
;
; Reserve two cells of data space and store x1 and x2 in the cells.
;
; ---
; : 2, HERE 2! 2 CELLS ALLOT ;

			LINKTO(LINK_DOUBLE,0,2,02ch,"2")
TWOCOMMA:	JMP		ENTER
			.WORD	HERE,TWOSTORE,LIT,2,CELLS,ALLOT
			.WORD	EXIT

; ----------------------------------------------------------------------
; 2CONSTANT [DOUBLE] 8.6.1.0360 "two-constant" ( x1 x2 "<spaces>name" -- )
;
; Skip leading space delimiters. Parse name delimited by a space.
; Create a definition for name with the execution semantics below.
;
; name is referred to as a "two-constant".
;
; name Execution: ( -- x1 x2 )
;   Place cell pair x1 x2 on the stack.
;
; ---
; : 2CONSTANT CREATE 2, DOES> 2@ ; 		/ I wish...
; --
; : 2CONSTANT CREATE CFASZ NEGATE ALLOT 195
;		C, DOTWOCONST , 2, ;

			LINKTO(TWOCOMMA,0,9,'T',"NATSNOC2")
TWOCONSTANT:JMP		ENTER
			.WORD	CREATE,LIT,-CFASZ,ALLOT,LIT,195,CCOMMA,LIT,DOTWOCONST,COMMA
			.WORD	TWOCOMMA,EXIT

; ----------------------------------------------------------------------
; 2LITERAL [DOUBLE] 8.6.1.0390 "two-literal" ( x1 x2 -- )
;
; Compilation:
; ( x1 x2 -- ) Append the run-time semantics below to the current definition
; Run-time:
; ( -- x1 x2 ) Place cell pair x1 x2 on the stack.
;
; ---
; : 2LITERAL SWAP POSTPONE LITERAL POSTPONE LITERAL ; IMMEDIATE

			LINKTO(TWOCONSTANT,1,8,'L',"ARETIL2")
TWOLITERAL:	JMP		ENTER
			.WORD	SWAP,LITERAL,LITERAL,EXIT

; ----------------------------------------------------------------------
; 2VARIABLE [DOUBLE] 8.6.1.0440 "two-variable" ( "<spaces>name" -- )
;
; Skip leading space delimiters. Parse name delimited by a space.
; Create a definition for name with the execution semantics below.
; Reserve two consecutive cells of data space.
;
; name is referred to as a "two-variable".
;
; name Execution ( -- a-addr )
;   a-addr is the address of the first of two consecutive cells
;   reserved by 2VARIABLE when it defined name. A program is responsible
;   for initializing the contents of the reserved cells.
;
; ---
; : 2VARIABLE ( "<spaces>name" -- )
;   CREATE CFASZ NEGATE ALLOT 195 C, DOVARIABLE , 0 0 2, ;

			LINKTO(TWOLITERAL,0,9,'E',"LBAIRAV2")
TWOVARIABLE:JMP		ENTER
			.WORD	CREATE,LIT,-CFASZ,ALLOT,LIT,195,CCOMMA,LIT,DOVARIABLE,COMMA
			.WORD	ZERO,ZERO,TWOCOMMA,EXIT

; ----------------------------------------------------------------------
; D+ [DOUBLE] 8.6.1.1040 "d-plus" ( d1|ud1 d2|ud2 -- d3|ud3 )
;
; Add d1|ud1 and d2|ud2, giving the sum d3|ud3.

			LINKTO(TWOVARIABLE,0,2,'+',"D")
DPLUS:		SAVEDE
			LDES	2			; Get the address of d2l
			XCHG				; ..and move that address into HL.
			LDES	6			; Get the address of d1h into DE.
			ANA		A			; Clear the carry flag.
			LDAX	D			; Get d1ll into A,
			ADD		M			; ..add d2ll to d1ll,
			STAX	D			; ..and put the result into d1ll.
            INX     D           ; Increment to d1lh.
            INX     H           ; Increment to d2lh.
            LDAX    D           ; Get d1lh into A,
            ADC     M           ; ..add d2lh to d1l,
            STAX    D           ; ..and put the result into d1lh.
			LDES	0			; Get the address of d2h
			XCHG				; ..and move that address into HL.
			LDES	4			; Get the address of d1h into DE.
            LDAX    D           ; Get d1hl into A,
            ADC     M           ; ..add d2hl to d1hl,
            STAX    D           ; ..and put the result into d1hl.
            INX     D           ; Increment to d1hh.
            INX     H           ; Increment to d2hh.
            LDAX    D           ; Get d1hh into A,
            ADC     M           ; ..add d2hh to d1hh,
            STAX    D           ; ..and put the result into d1hh.
            POP     H           ; Pop d2l.
            POP     H           ; Pop d2h.
            RESTOREDE
            NEXT

; ----------------------------------------------------------------------
; D- [DOUBLE] 8.6.1.1050 "d-minus" ( d1|ud1 d2|ud2 -- d3|ud3 )
;
; Subtract d2|ud2 from d1|ud1, giving the difference d3|ud3.

            LINKTO(DPLUS,0,2,'-',"D")
DMINUS:     SAVEDE
            LDES    2           ; Get the address of d2l
            XCHG                ; ..and move that address into HL
            LDES    6           ; Get the address of d1h into DE.
            ANA     A           ; Clear the carry flag.
            LDAX    D           ; Get d1ll into A,
            SUB     M           ; ..subtract d2ll from d1ll,
            STAX    D           ; ..and put the result into d1ll.
            INX     D           ; Increment to d1lh.
            INX     H           ; Increment to d2lh.
            LDAX    D           ; Get d1lh into A,
            SBB     M           ; ..subtract d2lh from d1l,
            STAX    D           ; ..and put the result into d1lh.
			LDES	0			; Get the address of d2h
			XCHG				; ..and move that address into HL.
			LDES	4			; Get the address of d1h into DE.
            LDAX    D           ; Get d1hl into A,
            SBB     M           ; ..subtract d2hl from d1hl,
            STAX    D           ; ..and put the result into d1hl.
            INX     D           ; Increment to d1hh.
            INX     H           ; Increment to d2hh.
            LDAX    D           ; Get d1hh into A,
            SBB     M           ; ..subtract d2hh from d1hh,
            STAX    D           ; ..and put the result into d1hh.
            POP     H           ; Pop d2l.
            POP     H           ; Pop d2h.
            RESTOREDE
            NEXT


; ----------------------------------------------------------------------
; D. [DOUBLE] 8.6.1.1060 "d-dot" ( d -- )
;
; Display d in free field format.
;
; ---
; : D. ( d -- )
;   BASE @ 10 <>  IF UD. EXIT THEN
;   2DUP D0< >R DABS <# #S R> SIGN #> TYPE SPACE ;

            LINKTO(DMINUS,0,2,'.',"D")
DDOT:       JMP     ENTER
            .WORD   BASE,FETCH,LIT,10,NOTEQUALS,zbranch,_ddot1,UDDOT,EXIT
_ddot1:     .WORD   TWODUP,DZEROLESS,TOR
            .WORD   DABS,LESSNUMSIGN,NUMSIGNS,RFROM,SIGN,NUMSIGNGRTR
            .WORD   TYPE,SPACE
            .WORD   EXIT


; ----------------------------------------------------------------------
; D0< [DOUBLE] 8.6.1.1075 "d-zero-less" ( d -- flag )
;
; flag is true if and only if d is less than zero.
;
; ---
; : D0< ( d -- flag)   SWAP DROP 0< ;

            LINKTO(DDOT,0,3,'<',"0D")
DZEROLESS:  JMP     ENTER
            .WORD   SWAP,DROP,ZEROLESS,EXIT


; ----------------------------------------------------------------------
; D0= [DOUBLE] 8.6.1.1080 "d-zero-equals" ( xd -- flag )
;
; flag is true if and only if xd is equal to zero.
;
; ---
; : D0= ( xd -- flag ) 0= SWAP 0= AND ;

		LINKTO(DZEROLESS,0,3,'=',"0D")
DZEROEQUALS:JMP		ENTER
			.WORD	ZEROEQUALS,SWAP,ZEROEQUALS,AND,EXIT


; ----------------------------------------------------------------------
; D2* [DOUBLE] 8.6.1.1090 "d-two-star" ( xd1 -- xd2 )
;
; xd2 is the result of shifting xd1 one bit toward the most-significant
; bit, filling the vacated least-significant bit with zero.

            LINKTO(DZEROEQUALS,0,3,'*',"2D")
DTWOSTAR:   POP     H           ; Pop xd1h,
            XTHL                ; ..then swap it for xd1l.
            DAD     H           ; Double xd1l.
            XTHL                ; Swap xd2l with xd1h.
            JNC     _dtwostar1  ; No carry?  Then just double xd1h,
            DAD     H           ; ..otherwise double xd1h
            INX     H           ; ..and then propagate the carry.
            JMP     _dwostarDONE; We're done.
_dtwostar1: DAD     H           ; No carry bit, so just double xd1h.
_dwostarDONE:PUSH    H          ; Push xd2h to the stack.
            NEXT


; ----------------------------------------------------------------------
; D2/ [DOUBLE] 8.6.1.1100 "d-two-slash" ( xd1 -- xd2 )
;
; xd2 is the result of shifting xd1 one bit toward the least-significant
; bit, leaving the most-significant bit unchanged.

            LINKTO(DTWOSTAR,0,3,'/',"2D")
DTWOSLASH:	SUB		A			; Clear accumulator and carry
			POP		H			; Pop xd1h
			ADD		H			; Get xd1hh into A
			JP		_d2slash_p	; If MSB is one...
			STC					; ...save MSB
_d2slash_p:	RAR					; Rotate xd1hh right
			MOV		H,A			; Put xd2hh back
			MOV		A,L			; Get xd1hl into A
			RAR					; Rotate xd1hl right
			MOV		L,A			; Put xd2hl back
			XTHL				; Swap xd2h for xd1l
			MOV		A,H			; Get xd1lh into A
			RAR					; Rotate xd1lh right
			MOV		H,A			; Put xd2lh back
			MOV		A,L			; Get xd1ll into A
			RAR					; Rotate xd1ll right
			MOV		L,A			; Put xd2ll back
			XTHL				; Swap xd2l for xd2h PUSH	H			; Push xd2h to the stack.
			NEXT

; ----------------------------------------------------------------------
; D< [DOUBLE] 8.6.1.1110 "d-less-than" ( d1 d2 -- flag )
;
; flag is true if and only if d1 is less than d2.
;
; ---
; D< ( d1 d2 -- flag ) SWAP >R 2DUP < IF R> 2DROP 2DROP TRUE
;    ELSE = IF R> < ELSE R> 2DROP FALSE THEN THEN ;

			LINKTO(DTWOSLASH,0,2,'<',"D")
DLESSTHAN:	JMP		ENTER
			.WORD	SWAP,TOR,TWODUP,LESSTHAN,zbranch,_dless_ge
			.WORD	RFROM,TWODROP,TWODROP,LIT,0FFFFh,branch,_dless_exit
_dless_ge:	.WORD	EQUALS,zbranch,_dless_g
			.WORD	RFROM,LESSTHAN,branch,_dless_exit
_dless_g:	.WORD	RFROM,TWODROP,LIT,0h
_dless_exit:.WORD	EXIT

; ----------------------------------------------------------------------
; D= [DOUBLE] 8.6.1.1120 "d-equals" ( xd1 xd2 -- flag )
;
; flag is true if and only if xd1 is bit-for-bit the same as xd2.
;
; ---
; D= D- D0= ;

			LINKTO(DLESSTHAN,0,2,'=',"D")
DEQUALS:	JMP		ENTER
			.WORD	DMINUS,DZEROEQUALS,EXIT

; ----------------------------------------------------------------------
; DABS [DOUBLE] 8.6.1.1160 "d-abs" ( d -- ud )
;
; ud is the absolute value of d.
;
; ---
; : DABS ( d -- ud )   DUP ?DNEGATE ;

            LINKTO(DEQUALS,0,4,'S',"BAD")
DABS:       JMP     ENTER
            .WORD   DUP,QDNEGATE,EXIT

; ----------------------------------------------------------------------
; DMAX [DOUBLE] 8.6.1.1210 "d-max" ( d1 d2 -- d3 )
;
; d3 is the greater of d1 and d2.
;
; ---
; : DMAX ( d1 d2 -- d3 ) 2OVER 2OVER D< IF 2SWAP THEN 2DROP ;

			LINKTO(DABS,0,4,'X',"AMD")
DMAX:		JMP		ENTER
			.WORD	TWOOVER,TWOOVER,DLESSTHAN,zbranch,_dmax_exit
			.WORD	TWOSWAP
_dmax_exit:	.WORD	TWODROP,EXIT

; ----------------------------------------------------------------------
; DMIN [DOUBLE] 8.6.1.1220 "d-min" ( d1 d2 -- d3 )
;
; d3 is the lesser of d1 and d2.
;
; ---
; : DMIN (d1 d2 -- d3 ) 2OVER 2OVER D< =0 IF 2SWAP THEN 2DROP ;

			LINKTO(DMAX,0,4,'N',"IMD")
DMIN:		JMP		ENTER
			.WORD	TWOOVER,TWOOVER,DLESSTHAN,ZEROEQUALS,zbranch,_dmin_exit
			.WORD	TWOSWAP
_dmin_exit:	.WORD	TWODROP,EXIT

; ----------------------------------------------------------------------
; DNEGATE [DOUBLE] 8.6.1.1230 ( d1 -- d2 )
;
; d2 is the negation of d1.
;
; ---
; : DNEGATE ( d1 -- d2)   INVERT SWAP INVERT SWAP 1 UM+ ;

            LINKTO(DMIN,0,7,'E',"TAGEND")
DNEGATE:    JMP     ENTER
            .WORD   INVERT,SWAP,INVERT,SWAP,ONE,UMPLUS,EXIT


; ----------------------------------------------------------------------
; M*/ [DOUBLE] 8.6.1.1820 "m-star-slash" ( d1 n1 +n2 -- d2 )
;
; Multiply d1 by n1 producing the triple-cell intermediate result t.
; Divide t by +n2 giving the double-cell quotient d2.
;
; This is how gforth does it:
; ---
; : M*/ >R S>D >R ABS -ROT S>D R> XOR R> SWAP
;       >R >R DABS ROT TUCK UM* 2SWAP UM* SWAP >R
;       0 D+ R> -ROT I UM/MOD -ROT R>
;       UM/MOD -ROT R>
;       IF
;         IF 1 0 D+
;		  THEN DNEGATE
;       ELSE DROP
;       THEN ;

			LINKTO(DNEGATE,0,3,'/',"*M")
MSTARSLASH:	JMP		ENTER
			.WORD	TOR,STOD,TOR,ABS,DASHROT,STOD,RFROM,XOR,RFROM,SWAP
			.WORD	TOR,TOR,DABS,ROT,TUCK,UMSTAR,TWOSWAP,UMSTAR,SWAP,TOR
			.WORD	ZERO,DPLUS,RFROM,DASHROT,I,UMSLASHMOD,DASHROT,RFROM
			.WORD	UMSLASHMOD,DASHROT,RFROM
			.WORD	zbranch,_mss_drop
			.WORD	zbranch,_mss_negate,ONE,ZERO,DPLUS
_mss_negate:.WORD	DNEGATE,branch,_mss_exit
_mss_drop:	.WORD	DROP
_mss_exit:	.WORD	EXIT


; ----------------------------------------------------------------------
; M+ [DOUBLE] 8.6.1.1830 "m-plus" ( d1|ud1 n -- d2|ud2 )
;
; Add n to d1|ud1, giving the sum d2|ud2.
;
; ---
; : M+ ( d1|ud1 n -- d2|ud2 ) S>D D+ ;

            LINKTO(MSTARSLASH,0,2,'+',"M")
MPLUS:      JMP		ENTER
			.WORD	STOD,DPLUS,EXIT

; ----------------------------------------------------------------------
; 2ROT [DOUBLE] 8.6.2.0420 "two-rote" ( x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2 )
;
; Rotate the top three cell pairs on the stack
; bringing cell pair x1 x2 to the top of the stack.
;
; ---
; : 2ROT 2>R 2SWAP 2R> 2SWAP ;

			LINKTO(MPLUS,0,4,'T',"OR2")
TWOROT:		JMP		ENTER
			.WORD	TWOTOR,TWOSWAP,TWORFROM,TWOSWAP,EXIT

; ----------------------------------------------------------------------
; DU< [DOUBLE] 8.6.2.1270 "d-u-less" ( ud1 ud2 -- flag )
;
; flag is true if and only if ud1 is less than ud2.
;
; ---
; : DU< ( ud1 ud2 -- flag ) SWAP >R 2DUP U< IF R> 2DROP 2DROP TRUE
;    ELSE = IF R> U< ELSE R> 2DROP FALSE THEN THEN ;

			LINKTO(TWOROT,0,3,'<',"UD")
LAST_DOUBLE:
DULESSTHAN:	JMP		ENTER
			.WORD	SWAP,TOR,TWODUP,ULESSTHAN,zbranch,_duless_ge
			.WORD	RFROM,TWODROP,TWODROP,LIT,0FFFFh,branch,_duless_x
_duless_ge:	.WORD	EQUALS,zbranch,_duless_g
			.WORD	RFROM,ULESSTHAN,branch,_duless_x
_duless_g:	.WORD	RFROM,TWODROP,LIT,0h
_duless_x:	.WORD	EXIT
