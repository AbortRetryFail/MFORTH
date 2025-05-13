S" TESTER" INCLUDED
\ From https://forth-standard.org
CR
S" Running tests for DOUBLE word set." TYPE CR

\ Constants for testing
0 INVERT 1 RSHIFT \ 32767
    CONSTANT MAX-INT
0 INVERT 1 RSHIFT INVERT \ -32768
	CONSTANT MIN-INT
0 INVERT 1 RSHIFT \ 32767
	CONSTANT MID-UINT
0 INVERT 1 RSHIFT INVERT \ 32768
	CONSTANT MID-UINT+1

MAX-INT 2/ \ 16383
	CONSTANT HI-INT
MIN-INT 2/ \ -16384
	CONSTANT LO-INT

S" Tests for text interpreter" TYPE CR
T{ 1. -> 1 0 }T
T{ -2. -> -2 -1 }T
T{ : rdl1 3. ; rdl1 -> 3 0 }T
T{ : rdl2 -4. ; rdl2 -> -4 -1 }T

S" Tests for 2VARIABLE" TYPE CR
T{ 2VARIABLE 2v1 -> }T
T{ 0. 2v1 2! -> }T
T{ 2v1 2@ -> 0. }T
T{ -1 -2 2v1 2! -> }T
T{ 2v1 2@ -> -1 -2 }T
T{ : cd2 2VARIABLE ; -> }T
T{ cd2 2v2 -> }T
T{ : cd3 2v2 2! ; -> }T
T{ -2 -1 cd3 -> }T
T{ 2v2 2@ -> -2 -1 }T
T{ 2VARIABLE 2v3 IMMEDIATE 5 6 2v3 2! -> }T
T{ 2v3 2@ -> 5 6 }T

S" Tests for 2CONSTANT" TYPE CR

T{ 1 2 2CONSTANT 2c1 -> }T
T{ 2c1 -> 1 2 }T
T{ : cd1 2c1 ; -> }T
T{ cd1 -> 1 2 }T

T{ : cd2 2CONSTANT ; -> }T
T{ -1 -2 cd2 2c2 -> }T
T{ 2c2 -> -1 -2 }T

T{ 4 5 2CONSTANT 2c3 IMMEDIATE 2c3 -> 4 5 }T
T{ : cd6 2c3 2LITERAL ; cd6 -> 4 5 }T

\ More constants
-1 MAX-INT \ 2147483647
	2CONSTANT MAX-2INT
0 MIN-INT \ -2147483648
	2CONSTANT MIN-2INT

MAX-2INT 2/ \ 1073741823
	2CONSTANT HI-2INT
MIN-2INT 2/ \ -1073741824
	2CONSTANT LO-2INT

S" Tests for 2LITERAL" TYPE CR
T{ : cd1 [ MAX-2INT ] 2LITERAL ; -> }T
T{ cd1 -> MAX-2INT }T
T{ 2VARIABLE 2v4 IMMEDIATE 5 6 2v4 2! -> }T
T{ : cd7 2v4 [ 2@ ] 2LITERAL ; cd7 -> 5 6 }T
T{ : cd8 [ 6 7 ] 2v4 [ 2! ] ; 2v4 2@ -> 6 7 }T

S" Tests for D+" TYPE CR

T{  0.   5. D+ ->  5. }T
T{ -5.   0. D+ -> -5. }T
T{  1.   2. D+ ->  3. }T
T{  1.  -2. D+ -> -1. }T
T{ -1.  -2. D+ -> -3. }T
T{ -1.   1. D+ ->  0. }T

T{  0  0  0  5 D+ ->  0  5 }T
T{ -1  5  0  0 D+ -> -1  5 }T
T{  0  0  0 -5 D+ ->  0 -5 }T
T{  0 -5 -1  0 D+ -> -1 -5 }T
T{  0  1  0  2 D+ ->  0  3 }T
T{ -1  1  0 -2 D+ -> -1 -1 }T
T{  0 -1  0  2 D+ ->  0  1 }T
T{  0 -1 -1 -2 D+ -> -1 -3 }T
T{ -1 -1  0  1 D+ -> -1  0 }T 

T{ MIN-INT 0 2DUP D+ -> 0 1 }T
T{ MIN-INT S>D MIN-INT 0 D+ -> 0 0 }T 

T{  HI-2INT 1. D+ -> 0 HI-INT 1+ }T
T{  HI-2INT     2DUP D+ -> -1 1- MAX-INT }T
T{ MAX-2INT MIN-2INT D+ -> -1. }T
T{ MAX-2INT  LO-2INT D+ -> HI-2INT }T
T{  LO-2INT     2DUP D+ -> MIN-2INT }T
T{  HI-2INT MIN-2INT D+ 1. D+ -> LO-2INT }T

S" Tests for D-" TYPE CR

T{  0.  5. D- -> -5. }T
T{  5.  0. D- ->  5. }T
T{  0. -5. D- ->  5. }T
T{  1.  2. D- -> -1. }T
T{  1. -2. D- ->  3. }T
T{ -1.  2. D- -> -3. }T
T{ -1. -2. D- ->  1. }T
T{ -1. -1. D- ->  0. }T
T{  0  0  0  5 D- ->  0 -5 }T
T{ -1  5  0  0 D- -> -1  5 }T
T{  0  0 -1 -5 D- ->  1  4 }T
T{  0 -5  0  0 D- ->  0 -5 }T
T{ -1  1  0  2 D- -> -1 -1 }T
T{  0  1 -1 -2 D- ->  1  2 }T
T{  0 -1  0  2 D- ->  0 -3 }T
T{  0 -1  0 -2 D- ->  0  1 }T
T{  0  0  0  1 D- ->  0 -1 }T
T{ MIN-INT 0 2DUP D- -> 0. }T
T{ MIN-INT S>D MAX-INT 0 D- -> 1 -1 }T
T{ MAX-2INT MAX-2INT D- -> 0. }T   
T{ MIN-2INT MIN-2INT D- -> 0. }T
T{ MAX-2INT  HI-2INT D- -> LO-2INT DNEGATE }T
T{  HI-2INT  LO-2INT D- -> MAX-2INT }T
T{  LO-2INT  HI-2INT D- -> MIN-2INT 1. D+ }T
T{ MIN-2INT MIN-2INT D- -> 0. }T
T{ MIN-2INT  LO-2INT D- -> LO-2INT }T

S" Tests for D0<" TYPE CR

T{                0. D0< -> FALSE }T
T{                1. D0< -> FALSE }T
T{  MIN-INT        0 D0< -> FALSE }T
T{        0  MAX-INT D0< -> FALSE }T
T{          MAX-2INT D0< -> FALSE }T
T{               -1. D0< -> TRUE  }T
T{          MIN-2INT D0< -> TRUE  }T

S" Tests for D0=" TYPE CR

T{               1. D0= -> FALSE }T
T{ MIN-INT        0 D0= -> FALSE }T
T{         MAX-2INT D0= -> FALSE }T
T{      -1  MAX-INT D0= -> FALSE }T
T{               0. D0= -> TRUE  }T
T{              -1. D0= -> FALSE }T
T{       0  MIN-INT D0= -> FALSE }T

S" Tests for D2*" TYPE CR

T{              0. D2* -> 0. D2* }T
T{ MIN-INT       0 D2* -> 0 1 }T
T{         HI-2INT D2* -> MAX-2INT 1. D- }T
T{         LO-2INT D2* -> MIN-2INT }T

S" Tests for D2/" TYPE CR

T{       0. D2/ -> 0.        }T
T{       1. D2/ -> 0.        }T
T{      0 1 D2/ -> MIN-INT 0 }T
T{ MAX-2INT D2/ -> HI-2INT   }T
T{      -1. D2/ -> -1.       }T
T{ MIN-2INT D2/ -> LO-2INT   }T

S" Tests for D<" TYPE CR

T{       0.       1. D< -> TRUE  }T
T{       0.       0. D< -> FALSE }T
T{       1.       0. D< -> FALSE }T
T{      -1.       1. D< -> TRUE  }T
T{      -1.       0. D< -> TRUE  }T
T{      -2.      -1. D< -> TRUE  }T
T{      -1.      -2. D< -> FALSE }T
T{      -1. MAX-2INT D< -> TRUE  }T
T{ MIN-2INT MAX-2INT D< -> TRUE  }T
T{ MAX-2INT      -1. D< -> FALSE }T
T{ MAX-2INT MIN-2INT D< -> FALSE }T

T{ MAX-2INT 2DUP -1. D+ D< -> FALSE }T
T{ MIN-2INT 2DUP  1. D+ D< -> TRUE  }T

S" Tests for D=" TYPE CR

T{      -1.      -1. D= -> TRUE  }T
T{      -1.       0. D= -> FALSE }T
T{      -1.       1. D= -> FALSE }T
T{       0.      -1. D= -> FALSE }T
T{       0.       0. D= -> TRUE  }T
T{       0.       1. D= -> FALSE }T
T{       1.      -1. D= -> FALSE }T
T{       1.       0. D= -> FALSE }T
T{       1.       1. D= -> TRUE  }T

T{   0   -1    0  -1 D= -> TRUE  }T
T{   0   -1    0   0 D= -> FALSE }T
T{   0   -1    0   1 D= -> FALSE }T
T{   0    0    0  -1 D= -> FALSE }T
T{   0    0    0   0 D= -> TRUE  }T
T{   0    0    0   1 D= -> FALSE }T
T{   0    1    0  -1 D= -> FALSE }T
T{   0    1    0   0 D= -> FALSE }T
T{   0    1    0   1 D= -> TRUE  }T

T{ MAX-2INT MIN-2INT D= -> FALSE }T
T{ MAX-2INT       0. D= -> FALSE }T
T{ MAX-2INT MAX-2INT D= -> TRUE  }T
T{ MAX-2INT HI-2INT  D= -> FALSE }T
T{ MAX-2INT MIN-2INT D= -> FALSE }T
T{ MIN-2INT MIN-2INT D= -> TRUE  }T
T{ MIN-2INT LO-2INT  D= -> FALSE }T
T{ MIN-2INT MAX-2INT D= -> FALSE }T

S" Tests for DABS" TYPE CR

T{       1. DABS -> 1.       }T
T{      -1. DABS -> 1.       }T
T{ MAX-2INT DABS -> MAX-2INT }T
T{ MIN-2INT 1. D+ DABS -> MAX-2INT }T

S" Tests for DMAX" TYPE CR

T{       1.       2. DMAX ->  2.      }T
T{       1.       0. DMAX ->  1.      }T
T{       1.      -1. DMAX ->  1.      }T
T{       1.       1. DMAX ->  1.      }T
T{       0.       1. DMAX ->  1.      }T
T{       0.      -1. DMAX ->  0.      }T
T{      -1.       1. DMAX ->  1.      }T
T{      -1.      -2. DMAX -> -1.      }T

T{ MAX-2INT  HI-2INT DMAX -> MAX-2INT }T
T{ MAX-2INT MIN-2INT DMAX -> MAX-2INT }T
T{ MIN-2INT MAX-2INT DMAX -> MAX-2INT }T
T{ MIN-2INT  LO-2INT DMAX -> LO-2INT  }T

T{ MAX-2INT       1. DMAX -> MAX-2INT }T
T{ MAX-2INT      -1. DMAX -> MAX-2INT }T
T{ MIN-2INT       1. DMAX ->  1.      }T
T{ MIN-2INT      -1. DMAX -> -1.      }T

S" Tests for DMIN" TYPE CR

T{       1.       2. DMIN ->  1.      }T
T{       1.       0. DMIN ->  0.      }T
T{       1.      -1. DMIN -> -1.      }T
T{       1.       1. DMIN ->  1.      }T
T{       0.       1. DMIN ->  0.      }T
T{       0.      -1. DMIN -> -1.      }T
T{      -1.       1. DMIN -> -1.      }T
T{      -1.      -2. DMIN -> -2.      }T

T{ MAX-2INT  HI-2INT DMIN -> HI-2INT  }T
T{ MAX-2INT MIN-2INT DMIN -> MIN-2INT }T
T{ MIN-2INT MAX-2INT DMIN -> MIN-2INT }T
T{ MIN-2INT  LO-2INT DMIN -> MIN-2INT }T

T{ MAX-2INT       1. DMIN ->  1.      }T
T{ MAX-2INT      -1. DMIN -> -1.      }T
T{ MIN-2INT       1. DMIN -> MIN-2INT }T
T{ MIN-2INT      -1. DMIN -> MIN-2INT }T

S" Tests for DNEGATE" TYPE CR

T{   0. DNEGATE ->  0. }T
T{   1. DNEGATE -> -1. }T
T{  -1. DNEGATE ->  1. }T
T{ MAX-2INT DNEGATE -> MIN-2INT SWAP 1+ SWAP }T
T{ MIN-2INT SWAP 1+ SWAP DNEGATE -> MAX-2INT }T

S" Tests for M*/" TYPE CR
\ : ?floored [ -3 2 / -2 = ] LITERAL IF 1. D- THEN ;

T{       5.       7             11 M*/ ->  3. }T
\ T{       5.      -7             11 M*/ -> -3. ?floored }T
T{ 5. -7 11 M*/ -> -4. }T
\ T{      -5.       7             11 M*/ -> -3. ?floored }T
T{ -5. 7 11 M*/ -> -4. }T
T{      -5.      -7             11 M*/ ->  3. }T
T{ MAX-2INT       8             16 M*/ -> HI-2INT }T
\ T{ MAX-2INT      -8             16 M*/ -> HI-2INT DNEGATE ?floored }T
T{ MIN-2INT       8             16 M*/ -> LO-2INT }T
T{ MIN-2INT      -8             16 M*/ -> LO-2INT DNEGATE }T

T{ MAX-2INT MAX-INT        MAX-INT M*/ -> MAX-2INT }T
T{ MAX-2INT MAX-INT 2/     MAX-INT M*/ -> MAX-INT 1- HI-2INT NIP }T
T{ MIN-2INT LO-2INT NIP DUP NEGATE M*/ -> MIN-2INT }T
T{ MIN-2INT LO-2INT NIP 1- MAX-INT M*/ -> MIN-INT 3 + HI-2INT NIP 2 + }T
T{ MAX-2INT LO-2INT NIP DUP NEGATE M*/ -> MAX-2INT DNEGATE }T
T{ MIN-2INT MAX-INT            DUP M*/ -> MIN-2INT }T

S" Tests for 2ROT" TYPE CR

T{       1.       2. 3. 2ROT ->       2. 3.       1. }T
T{ MAX-2INT MIN-2INT 1. 2ROT -> MIN-2INT 1. MAX-2INT }T


S" Tests for DU<" TYPE CR

T{       1.       1. DU< -> FALSE }T
T{       1.      -1. DU< -> TRUE  }T
T{      -1.       1. DU< -> FALSE }T
T{      -1.      -2. DU< -> FALSE }T

T{ MAX-2INT  HI-2INT DU< -> FALSE }T
T{  HI-2INT MAX-2INT DU< -> TRUE  }T
T{ MAX-2INT MIN-2INT DU< -> TRUE  }T
T{ MIN-2INT MAX-2INT DU< -> FALSE }T
T{ MIN-2INT  LO-2INT DU< -> TRUE  }T

