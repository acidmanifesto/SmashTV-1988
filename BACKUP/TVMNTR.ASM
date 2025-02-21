 	.FILE	'TVMNTR.ASM'
	.TITLE	'ROBO-RAMA GAME PROGRAM'
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST
;
; INITIATED:		 APRIL 26,1989
; MODIFIED:		 !
; SOFTWARE:		 MARK TURMELL
;
; COPYRIGHT (C) 1989 WILLIAMS ELECTRONICS GAMES, INC.
;
;
; GET THE SYSTEM STUFF

	.INCLUDE	"MPROC.EQU"		;MPROC EQUATES
	.INCLUDE	"DISP.EQU"		;DISPLAY PROC. EQUATES
	.INCLUDE	"\VIDEO\SYS\SYS.INC"	;Z UNIT SYSTEM EQUATES
	.INCLUDE	"\VIDEO\SYS\MACROS.HDR"	;MACROS DEFINITIONS
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"ROBO.EQU"
	.INCLUDE	"MNTR.TBL"
	.INCLUDE	"AUDIT.EQU"
	.INCLUDE	"MAC2.ASM"		;MACRO 2 DEFINITIONS

;
;SOUNDS
;
	.REF	BEEP1,MONIN,MCSPK7,MCSPK8,MCSPK2,MCSPK3,MCSPK4
	.REF	CROWD1A,MCSPK10,MCSPK11
;
;SYMBOLS EXTERNALLY DEFINED
;
	.REF	AP_LIT,DOCHS,PALRAM,CLNPAL,GET_ADJ
	.REF	GPALOBJ,TTORSO,FRANIM,RANGRAND,SHAKER,XYSKOBJ,CVRT
	.REF	GETHDR,RANDPER,PLYROBJS,STATUS,SHK_ON,DELPAL,SPRKL
	.REF	OBJON,OBJOFF,EHALT,HALT,STUD_LIT
;
;SYMBOLS DEFINED IN THIS FILE
;
	.DEF	DOMNTR,SPEECH
;
;UNINITIALIZED RAM DEFINITIONS
;
	.BSS	FIXBUG,32
	.BSS	SPEECH,16
;
;EQUATES FOR THIS FILE
;
;
;MONITOR DATA STRUCTURE
;
MNTRP		.EQU	PDATA		;UHL TANK LEFT PTR	
;
	.SECT SHIT
;
	
DOMNTR:
;A9=1 MONITOR WITHOUT CASH
;   2 MONITOR WITH CASH
;   3 NO SPEECH/NO CASH
;   4 MAP1
;   5 MAP2
;   6 MAP3
;A9 WILL CONTROL MOUTH/SPEECH TIMINGS
;TURN ON ALL PIECES
;	MOVI	CROWD1,A0
;	CALLA	ONESND
	MOVI	PALRAM,A0
	MOVI	100,A1
	MOVE	A1,*A0(>20),W

	MOVE	A9,A10
	SLL	5,A9
	ADDI	LISTS,A9
	MOVE	*A9,A7,L
	MOVK	21,A9
	CMPI	2,A10
	JRNE	TP
	MOVI	28,A9		;WITH CASH
TP	MOVE	A9,A0
	SLL	5,A0
	ADD	A7,A0		;ONLIST,A0
	MOVE	*A0,A14,L
	CALLA	GPALOBJ			;ALLOCATE A COLOR PALETTE 
	CALLA	STFOBJ			;STUFF OBJECT DATA 
	MOVE	A13,*A0(OPLINK),L
	CALLA	INSOBJ			;INSERT OBJECT INTO LIST
	MOVE	A0,A8
	MOVI	-099H,A1			;X
	MOVE	A1,*A8(OXPOS),W
	MOVI	130,A1			;Y
	MOVE	A1,*A8(OYPOS),W
	CALLA	ADJSTWTL

	MOVE	A9,A0
	DEC	A0
	SLL	5,A0
	ADD	A13,A0
	ADDI	MNTRP,A0
	MOVE	A8,*A0,L
	DEC	A9
	CMPI	1,A9
	JRNZ	ERTH
	MOVE	A8,@FIXBUG,L
ERTH	MOVE	A9,A9
	JRNZ	TP
;OBJECTS ALL ON
	MOVE	A10,A9
	MOVE	*A13(MNTRP),A8,L
	MOVE	A13,A10
	CREATE	TVPID,SCRL
	CREATE	TV2PID,AP_LIT
	CMPI	4,A9
	JRNC	MAP
;NOT A MAP
	CREATE	TVPID,GEYEL
	CREATE	TVPID,GEYER
	CREATE	TVPID,GMTHL
	CREATE	TVPID,GMTHR
;SOUNDS OFF IN DEMO
	ADJUST	ADJMUSIC	;GET MUSIC ON OFF FOR DEMO
	MOVE	A0,A0
	JRNZ	TOID_TOP
	MOVI	CROWD1A,A0
	CALLA	ONESND
	JRUC	TOID_TOP
MAP
;CREATE	A BLINK OF ARROWS
;COLOR CYCLE START
	CREATE	TVPID,BLINK4
	CREATE	TV2PID,STUD_LIT		;STUDIO X CYCLE
TOID_TOP
	CALLR	LINE_UP			;ADJUST ALL PARTS TO MATCH TANK LEFT
	SLEEP	1
	JRUC 	TOID_TOP
BLINK4
;BLINK 2 ARROWS, AND 2 WORDS
BKZ
	MOVE	*A10(MNTRP+10*32),A0,L
	CALLA	OBJOFF
	MOVE	*A10(MNTRP+11*32),A0,L
	CALLA	OBJOFF
	MOVE	*A10(MNTRP+12*32),A0,L
	CALLA	OBJOFF
	MOVE	*A10(MNTRP+9*32),A0,L
	CALLA	OBJOFF
	SLEEP	8
	MOVI	BEEP1,A0
	CALLA	ONESND
	MOVE	*A10(MNTRP+10*32),A0,L
	CALLA	OBJON
	MOVE	*A10(MNTRP+11*32),A0,L
	CALLA	OBJON
	MOVE	*A10(MNTRP+12*32),A0,L
	CALLA	OBJON
	MOVE	*A10(MNTRP+9*32),A0,L
	CALLA	OBJON
	SLEEP	01FH
	JRUC	BKZ
SCRL
;SOUNDS OFF IN DEMO
	ADJUST	ADJMUSIC	;GET MUSIC ON OFF FOR DEMO
	MOVE	A0,A0
	JRNZ	NONO3
	MOVI	MONIN,A0
	CALLA	ONESND
NONO3	MOVI	026H,A11
SC2
	MOVE	*A8(OXVAL),A0,L
	ADDI	050000H,A0
	MOVE	A0,*A8(OXVAL),L
	SLEEP	01
	DSJS	A11,SC2
	CMPI	4,A9
	JRC	REGMN
;MAP ON SCRN
	SLEEP	10*60
	CREATE	ARWPID,DOCHS		;START CHASER AFTER A TIME!

	MOVI	MONIN,A0
	CALLA	ONESND

	MOVI	-30000H,A0	;C000
	MOVE	A0,*A8(OXVEL),L
;	SLEEP	40
	CLR	A1
	NOT	A1
	MOVI	TV2PID,A0
	CALLA	KILALL
	MOVI	CLSNEUT|TYPTEXT|SUBTV2,A0
	CALLA	KILOBJ
	SLEEP	2*60
;KILL OFF ALL PCS
	CLR	A1
	NOT	A1
	MOVI	TVPID,A0
	CALLA	KILALL
	MOVI	CLSNEUT|TYPTEXT|SUBTV,A0
	CALLA	KILOBJ
;KILL OFF MONITOR PALS
;	MOVI	DLSTM,A1
;	CALLA	UNGET
	CALLA	CLNPAL
	DIE
REGMN
	CREATE	TV2PID,SPARK2
	CREATE	TVPID,MCEYE
	CMPI	3,A9		;3=NO SPEECH
	JRNE	SPK0
	CREATE	TVPID,MCMTH
	SLEEP	7*60
	CLR	A1
	NOT	A1
	MOVI	TV2PID,A0
	CALLA	KILALL
	MOVI	CLSNEUT|TYPTEXT|SUBTV2,A0
	CALLA	KILOBJ
;KILL OFF ALL PCS
	CLR	A1
	NOT	A1
	MOVI	TVPID,A0
	CALLA	KILALL
	MOVI	CLSNEUT|TYPTEXT|SUBTV,A0
	CALLA	KILOBJ
;TURN OFF MONITOR PALS
;	MOVI	DLST,A1
;	CALLA	UNGET
	CALLA	CLNPAL
	DIE
;DLST	.LONG	MNTR,FIGCOL,0
;DLSTM	.LONG	MNTR,MAPP,FIGCOL,0
SPK0
;SPEAK
	CREATE	500,MCTALK
	MOVE	@SPEECH,A0
	CMPI	3,A0
	JRNZ	OPOP
	SLEEP	105H-0B8H
OPOP
	SLEEP	0B8H	;3*60-20		;-30
	CLR	A1
	NOT	A1
	MOVI	500,A0
	CALLA	KILALL

	CREATE	TVPID,MCMTH
	SLEEP	1		;*60-30

	MOVI	MONIN,A0
	CALLA	ONESND

	MOVI	010000H,A0	;C000
	MOVE	A0,*A8(OYVEL),L
	SLEEP	40
	CLR	A1
	NOT	A1
	MOVI	TV2PID,A0
	CALLA	KILALL
	MOVI	CLSNEUT|TYPTEXT|SUBTV2,A0
	CALLA	KILOBJ

;CAN TAKE OUT!
	CLR	A0
	MOVE	A0,@EHALT
	MOVE	A0,@HALT

	SLEEP	4*60
;KILL OFF ALL PCS
	CLR	A1
	NOT	A1
	MOVI	TVPID,A0
	CALLA	KILALL
	MOVI	CLSNEUT|TYPTEXT|SUBTV,A0
	CALLA	KILOBJ
;KILL OFF MONITOR PALS
;	MOVI	DLST,A1
;	CALLA	UNGET
	CALLA	CLNPAL
	DIE

MCTALK
	SLEEP	1
;	CMPI	2,A9
;	JRNZ	MCT1
;	
;	CREATE	0,SPKIT2	;CASH IN MONITOR
;	MOVE	*A10(PDATA+15*32),A8,L
;	JRUC	MTHT
;MCT1 
	CREATE	0,SPKIT
	MOVE	*A10(PDATA+15*32),A8,L
MTHT
	MOVE	@SPEECH,A0
	SLL	5,A0
	ADDI	SPTBL,A0
	MOVE	*A0,A9,L
;	MOVI	MCTLK,A9
	MOVK	1,A1
	JSRP	FRANIM
	JRUC	MTHT
SPTBL	.LONG	MCTLKA,MCTLKB,MCTLKC,MCTLKD

SPKIT
	MOVE	@SPEECH,A0
	JRNZ	JOB1
;GOOD LUCK
	SLEEP	12
	MOVI	MCSPK4,A0
	CALLA	ONESND
	SLEEP	100
	MOVI	MCSPK10,A0
	CALLA	ONESND
	DIE
JOB1	CMPI	1,A0
	JRNZ	JOB2
;BUY THAT FOR A DOLLAR
	SLEEP	12
	MOVI	MCSPK11,A0
	CALLA	ONESND
	DIE
JOB2	
	CMPI	2,A0
	JRNZ	JOB3
;TOTAL CARNAGE / I LOVE IT
	SLEEP	12
	MOVI	MCSPK7,A0
	CALLA	ONESND
	SLEEP	70H
	MOVI	MCSPK8,A0
	CALLA	ONESND
JOB3
	CMPI	3,A0
	JRNZ	JOB4
;BIG MONEY/ BIG PRIZES/ I LOVE IT
;CASH SCRN
	SLEEP	12
	MOVI	MCSPK2,A0
	CALLA	ONESND
	SLEEP	57H
	MOVI	MCSPK3,A0
	CALLA	ONESND
	SLEEP	67H
	MOVI	MCSPK8,A0
	CALLA	ONESND
JOB4
	DIE
	
MCMTH
	SLEEP	30
	MOVE	*A10(PDATA+15*32),A8,L
MTH	MOVI	MCLIPS,A9
	MOVK	1,A1
	JSRP	FRANIM
	JRUC	MTH
GMTHL
	SLEEP	10
	MOVE	*A10(PDATA+11*32),A8,L
GMTH	MOVI	GLIPS,A9
	MOVK	1,A1
	JSRP	FRANIM
	JRUC	GMTH
GMTHR
	SLEEP	3*60
	MOVE	*A10(PDATA+12*32),A8,L
	JRUC	GMTH

MCEYE
	MOVE	*A10(PDATA+16*32),A8,L
MEYS	MOVI	MCEYES,A9
	MOVK	1,A1
	JSRP	FRANIM
	JRUC	MEYS
GEYEL
	SLEEP	70
	MOVE	*A10(PDATA+13*32),A8,L
EYS	MOVI	EYES,A9
	MOVK	1,A1
	JSRP	FRANIM
	JRUC	EYS

GEYER	SLEEP	150
	MOVE	*A10(PDATA+14*32),A8,L
	JRUC	EYS

SPARK
;SPARKLES ON SUIT
;	SLEEP	60
	SLEEP	120
SPARK2
;TURN ON OBJECT
	MOVI	SPK,A14
	CALLA	GPALOBJ			;ALLOCATE A COLOR PALETTE 
	CALLA	STFOBJ			;STUFF OBJECT DATA 
	CALLA	INSOBJ			;INSERT OBJECT INTO LIST
	MOVE	A0,A8
;	CALLA	ADJSTWTL

STP	MOVI	0,B0
	MOVK	4,B1
	CALLA	RANGRAND
	DEC	A0
	SLL	4,A0
	MOVI	SPRKX,A1
	ADD	A0,A1
	MOVE	*A1,A1,W		;A1=X OF SPARKLE
	ADDI	SPRKY,A0
	MOVE	*A0,A0,W		;A0=Y
	MOVE	A1,*A8(OXPOS),W
	MOVE	A0,*A8(OYPOS),W
	MOVE	A8,A0
	CALLA	ADJSTWTL
	CALLA	OBJON
	MOVI	SPRKL,A9
	MOVK	1,A1		;TILL END OF LIST
	JSRP	FRANIM
	MOVE	A8,A0
	CALLA	OBJOFF
	SLEEP	1
	JRUC	STP

SPRKX:	.WORD	057H,05AH,074H,077H
SPRKY:	.WORD	0A9H,0CDH,0D9H,0A6H

LINE_UP
;A9=1 OR 2
;RIGHT SIDE OF TANK
	CALLA	GETANIXY
	MOVE	@FIXBUG,A0,L
	MOVE	A0,*A13(PDATA+1*32),L
	MOVE	*A13(PDATA+1*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	SUBI	030000H,A3		;SUB 1 FROM X
;	SUBI	00000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;DO HEAD
	CALLA	GETANIXY
	MOVE	*A13(PDATA+2*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	ADDI	010000H,A3		;SUB 1 FROM X
	ADDI	040000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;ADJUST LEFT SIDE TORSO
	CALLA	GETANIXY
	MOVE	*A13(PDATA+3*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	ADDI	010000H,A3		;SUB 1 FROM X
	ADDI	03C0000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;ADJUST RGT TORSO
	CALLA	GETANIXY
	MOVE	*A13(PDATA+4*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
;	SUBI	010000H,A3		;SUB 1 FROM X
	SUBI	030000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;ADJUST LEFT SIDE ARM
	CALLA	GETANIXY
	MOVE	*A13(PDATA+5*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	SUBI	030000H,A3		;SUB 1 FROM X
	SUBI	030000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;ADJUST RIGHT SIDE ARM
	CALLA	GETANIXY
	MOVE	*A13(PDATA+6*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
;	SUBI	010000H,A3		;SUB 1 FROM X
	ADDI	08E0000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;ADJUST LEFT SIDE TREAD
	CALLA	GETANIXY
	MOVE	*A13(PDATA+7*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	SUBI	030000H,A3		;SUB 1 FROM X
	ADDI	08E0000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;ADJUST RIGHT SIDE TREAD
	CALLA	GETANIXY
	MOVE	*A13(PDATA+8*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	ADDI	030000H,A3		;SUB 1 FROM X
	ADDI	050000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;ADJUST LEFT FRONT TREAD
	CALLA	GETANIXY
	MOVE	*A13(PDATA+9*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	SUBI	010000H,A3		;SUB 1 FROM X
	SUBI	010000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;ADJUST RIGHT FRONT TREAD
	CALLA	GETANIXY
	MOVE	*A13(PDATA+10*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	SUBI	010000H,A3		;SUB 1 FROM X
	SUBI	010000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;DO RIGHT SIDE SHADOW
	CALLA	GETANIXY
	MOVE	*A13(PDATA+11*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
;	SUBI	010000H,A3		;SUB 1 FROM X
;	SUBI	010000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;DO FRONT SHADOW
	CALLA	GETANIXY
	MOVE	*A13(PDATA+12*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	SUBI	030000H,A3		;SUB 1 FROM X
;	SUBI	00000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;DO FRONT SHADOW
	CALLA	GETANIXY
	MOVE	*A13(PDATA+13*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
;	SUBI	010000H,A3		;SUB 1 FROM X
;	SUBI	010000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;DO FRONT SHADOW
	CALLA	GETANIXY
	MOVE	*A13(PDATA+14*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	SUBI	030000H,A3		;SUB 1 FROM X
;	SUBI	010000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;DO FRONT SHADOW
	CALLA	GETANIXY
	MOVE	*A13(PDATA+15*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
;	SUBI	010000H,A3		;SUB 1 FROM X
;	SUBI	010000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;DO FRONT SHADOW
	CALLA	GETANIXY
	MOVE	*A13(PDATA+16*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
;	SUBI	030000H,A3		;SUB 1 FROM X
	SUBI	010000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;DO FRONT SHADOW
	CALLA	GETANIXY
	MOVE	*A13(PDATA+17*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	SUBI	010000H,A3		;SUB 1 FROM X
	ADDI	010000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;DO FRONT SHADOW
	CALLA	GETANIXY
	MOVE	*A13(PDATA+18*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	SUBI	010000H,A3		;SUB 1 FROM X
	ADDI	010000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;DO FRONT SHADOW
	CALLA	GETANIXY
	MOVE	*A13(PDATA+19*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	ADDI	020000H,A3		;SUB 1 FROM X
	SUBI	040000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;DO FRONT SHADOW
	CALLA	GETANIXY
	MOVE	*A13(PDATA+20*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	SUBI	030000H,A3		;SUB 1 FROM X
	SUBI	040000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG


	CMPI	2,A9
	JRNE	RTS
;YES CASH


;DO FRONT SHADOW
	CALLA	GETANIXY
	MOVE	*A13(PDATA+21*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
;	SUBI	030000H,A3		;SUB 1 FROM X
;	SUBI	040000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;DO FRONT SHADOW
	CALLA	GETANIXY
	MOVE	*A13(PDATA+22*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
; ;	SUBI	030000H,A3		;SUB 1 FROM X
;	SUBI	040000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;DO FRONT SHADOW
	CALLA	GETANIXY
	MOVE	*A13(PDATA+23*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	ADDI	040000H,A3		;SUB 1 FROM X
	SUBI	010000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;DO FRONT SHADOW
	CALLA	GETANIXY
	MOVE	*A13(PDATA+24*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
;	SUBI	030000H,A3		;SUB 1 FROM X
;	SUBI	040000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;DO FRONT SHADOW
	CALLA	GETANIXY
	MOVE	*A13(PDATA+25*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
;	SUBI	030000H,A3		;SUB 1 FROM X
	ADDI	030000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG
;DO FRONT SHADOW
	CALLA	GETANIXY
	MOVE	*A13(PDATA+26*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	SUBI	040000H,A3		;SUB 1 FROM X
;	SUBI	040000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG

	CALLA	GETANIXY
	MOVE	*A13(PDATA+27*32),A0,L
	MOVE	*A0(OFLAGS),A4,W	;SAME FLAGS AS BEFORE
	SUBI	030000H,A3		;SUB 1 FROM X
	ADDI	030000H,A2		;SUB 1 FROM Y
	CALLA	GANISAG

RTS	RETS

LISTS	.LONG	0,ONLIST,ONLIST,ONLIST,ON1,ON2,ON3
ONLIST	.LONG	0,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17
	.LONG	T18,T19,T20,T21,T22,T23,T24,T25,T26,T27,T28
ON1	.LONG	0,T1,T2A,T3,T4,T5,T6,T7,T8,T9A,T10A,T11A,T12A,T13A
	.LONG	FAKE,FAKE,FAKE,FAKE
	.LONG	T18,T19,T20,T21
ON2	.LONG	0,T1,T2B,T3,T4,T5,T6,T7,T8,T9B,T10B,T11A,T12A,T13A
	.LONG	FAKE,FAKE,FAKE,FAKE
	.LONG	T18,T19,T20,T21
ON3	.LONG	0,T1,T2C,T3,T4,T5,T6,T7,T8,T9C,T10C,T11A,T12A,T13A
	.LONG	FAKE,FAKE,FAKE,FAKE
	.LONG	T18,T19,T20,T21
T1	;FIGS LFT
	.LONG	0,0,FIGS1
	.WORD	06FF0H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T2	;
	.LONG	0,0,FIGS1
	.WORD	06FF0H,DMAWNZ+M_NOCOLL+M_FLIPH,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T2A	;
	.LONG	0,0,MTDMP
	.WORD	06FF1H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T2B	;
	.LONG	0,0,SCRMP
	.WORD	06FF1H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T2C	;
	.LONG	0,0,SNKMP
	.WORD	06FF1H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T3	;
	.LONG	0,0,TVCLMP1
	.WORD	06FF8H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T4	;TORSO RGT
	.LONG	0,0,TVCLMP1
	.WORD	06FF8H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T5	;
	.LONG	0,0,MNTRPC3
	.WORD	06FF5H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T6	;ARM RGT
	.LONG	0,0,MNTRPC3
	.WORD	06FF5H,DMAWNZ+M_NOCOLL+M_FLIPH,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T7	;TREAD LFT FRONT
	.LONG	0,0,MNTRPC3
	.WORD	06FF5H,DMAWNZ+M_NOCOLL+M_FLIPV,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T8	;TREAD RGT FRONT
	.LONG	0,0,MNTRPC3
	.WORD	06FF5H,DMAWNZ+M_NOCOLL+M_FLIPV+M_FLIPH,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T9	;TREAD LEFT SIDE
	.LONG	0,0,SGN1
	.WORD	06FF8H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T9A	;TREAD LEFT SIDE
	.LONG	0,0,MP1
	.WORD	06FF8H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T9B	;TREAD LEFT SIDE
	.LONG	0,0,MP2
	.WORD	06FF8H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T9C	;TREAD LEFT SIDE
	.LONG	0,0,MP3
	.WORD	06FF8H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T10	;TREAD RGT SIDE
	.LONG	0,0,GLRM1
	.WORD	06FF6H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T10A	;TREAD RGT SIDE
	.LONG	0,0,MTDMN
	.WORD	06FFAH,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T10B	;TREAD RGT SIDE
	.LONG	0,0,SCRFC
	.WORD	06FFAH,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T10C	;TREAD RGT SIDE
	.LONG	0,0,DCBRS
	.WORD	06FFAH,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T13A	;TREAD RGT SIDE
	.LONG	0,0,AIR2
	.WORD	06FFAH,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
;T13B	;TREAD RGT SIDE
;	.LONG	0,0,AIR2
;	.WORD	07000H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
;	.LONG	0,0
T12A	;TREAD RGT SIDE
	.LONG	0,0,AIR1
	.WORD	06FFAH,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T11A	;TREAD RGT SIDE
	.LONG	0,0,TVSTD
	.WORD	06FFAH,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T11	;SHAD RGT
	.LONG	0,0,GLRM2
	.WORD	06FF6H,DMAWNZ+M_FLIPH+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T12	
	.LONG	0,0,GRLM3	;MOUTH
	.WORD	06FF8H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T13
	.LONG	0,0,GRLM3
	.WORD	06FF8H,DMAWNZ+M_FLIPH+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T14	
	.LONG	0,0,GRLI3
	.WORD	06FF8H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T15	
	.LONG	0,0,GRLI3
	.WORD	06FF8H,DMAWNZ+M_FLIPH+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T16
	.LONG	0,0,MCM3
	.WORD	06FF8H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
FAKE
	.LONG	0,0,MCM3
	.WORD	06H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T17
	.LONG	0,0,MCI3
	.WORD	06FF8H,DMAWNZ+M_FLIPH+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T18
	.LONG	0,0,MNTRPC2
	.WORD	06FF7H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T19
	.LONG	0,0,MNTRPC2
	.WORD	06FF7H,DMAWNZ+M_FLIPH+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T20
	.LONG	0,0,MNTRPC1
	.WORD	06FF7H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T21
	.LONG	0,0,MNTRPC1
	.WORD	06FF7H,DMAWNZ+M_FLIPH+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T22
	.LONG	0,0,MNY1
	.WORD	06FF7H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T23
	.LONG	0,0,MNY2
	.WORD	06FF7H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T24
	.LONG	0,0,MNY3
	.WORD	06FF7H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T25
	.LONG	0,0,MNY4
	.WORD	06FF7H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T26
	.LONG	0,0,MNY5
	.WORD	06FF7H,DMAWNZ+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T27
	.LONG	0,0,MNY2
	.WORD	06FF7H,DMAWNZ+M_FLIPH+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
T28
	.LONG	0,0,MNY5
	.WORD	06FF7H,DMAWNZ+M_FLIPH+M_NOCOLL,CLSNEUT|TYPTEXT|SUBTV
	.LONG	0,0
SPK
	.LONG	0,0,GLM0
	.WORD	06FF9H,DMAWNZ,CLSNEUT|TYPTEXT|SUBTV2
	.LONG	0,0


MCEYES
	.LONG	MCI3
	.WORD	FLIPBITS|1*60,0
	.LONG	MCI2
	.WORD	FLIPBITS|20,0
	.LONG	MCI2A
	.WORD	FLIPBITS|20,(M_FLIPH)
	.LONG	MCI2
	.WORD	FLIPBITS|20,0
	.LONG	MCI2A
	.WORD	FLIPBITS|20,(M_FLIPH)
	.LONG	MCI2
	.WORD	FLIPBITS|20,0
	.LONG	MCI2A
	.WORD	FLIPBITS|20,(M_FLIPH)
	.LONG	MCI1
	.WORD	FLIPBITS|10,0
	.LONG	MCI3
	.WORD	10
	.LONG	MCI1
	.WORD	FLIPBITS|10,0
	.LONG	MCI3
	.WORD	10
	.LONG	MCI1
	.WORD	FLIPBITS|20,0
	.LONG	MCI3
	.WORD	20
	.LONG	MCI1
	.WORD	FLIPBITS|20,0
	.LONG	MCI3
;	.WORD	2*60
	.WORD	30
	.LONG	MCI2
	.WORD	30
	.LONG	MCI3
;	.WORD	60
	.WORD	30
	.LONG	MCI2A
	.WORD	FLIPBITS|20,(M_FLIPH)
	.LONG	MCI2
	.WORD	FLIPBITS|30,0
	.LONG	MCI1
	.WORD	60
	.LONG	MCI2A
	.WORD	FLIPBITS|60,(M_FLIPH)
	.LONG	MCI3
	.WORD	FLIPBITS|20,0
	.LONG	MCI2A
	.WORD	FLIPBITS|20,(M_FLIPH)
	.LONG	MCI2
	.WORD	FLIPBITS|60,0
	.LONG	MCI3
;	.WORD	1*60
	.WORD	1
	.LONG	0

EYES			;GIRLS
	.LONG	GRLI3
	.WORD	5
	.LONG	GRLI1
	.WORD	5
	.LONG	GRLI2
	.WORD	9
	.LONG	GRLI1
	.WORD	5
	.LONG	GRLI3
	.WORD	3*60
	.LONG	GRLI1
	.WORD	4
	.LONG	GRLI2
	.WORD	4
	.LONG	GRLI1
	.WORD	4
	.LONG	GRLI3
	.WORD	30
	.LONG	GRLI1
	.WORD	4
	.LONG	GRLI2
	.WORD	4
	.LONG	GRLI1
	.WORD	4
	.LONG	GRLI3
	.WORD	5*60
	.LONG	GRLI1
	.WORD	5
	.LONG	GRLI2
	.WORD	20
	.LONG	GRLI1
	.WORD	5
	.LONG	GRLI3
	.WORD	3*60
	.LONG	0
MCLIPS			;GIRLS
	.LONG	MCM3
	.WORD	1*60
	.LONG	MCM1
	.WORD	2*60
	.LONG	MCM3
	.WORD	2*60
	.LONG	MCM1
	.WORD	3*60
	.LONG	0
MCTLKA		;GOOD LUCK SPEECH
	.LONG	MCM3
	.WORD	10
	.LONG	MCM2
	.WORD	8
	.LONG	MCM3
	.WORD	8
	.LONG	MCM2
	.WORD	10
	.LONG	MCM3
	.WORD	48H
	.LONG	MCM2
	.WORD	12
	.LONG	MCM3
	.WORD	13H
	.LONG	MCM2
	.WORD	8
	.LONG	MCM3
	.WORD	8
	.LONG	MCM2
	.WORD	10
	.LONG	MCM3
	.WORD	40H
	.LONG	MCM2
	.WORD	10
	.LONG	0
MCTLKB		;I'D BUY THAT FOR A DOLLAR
	.LONG	MCM3
	.WORD	8
	.LONG	MCM2
	.WORD	8
	.LONG	MCM3
	.WORD	8
	.LONG	MCM2
	.WORD	8
	.LONG	MCM3
	.WORD	8H
	.LONG	MCM2
	.WORD	8
	.LONG	MCM3
	.WORD	8
	.LONG	MCM2
	.WORD	8
	.LONG	MCM3
	.WORD	8
	.LONG	MCM2
	.WORD	8
	.LONG	MCM3
	.WORD	8
	.LONG	MCM2
	.WORD	0FFH
	.LONG	0
MCTLKC		;TOTAL CARNAGE, I LOVE IT
	.LONG	MCM3
	.WORD	10
	.LONG	MCM2
	.WORD	10
	.LONG	MCM3
	.WORD	10
	.LONG	MCM2
	.WORD	15
	.LONG	MCM3
	.WORD	10
	.LONG	MCM2
	.WORD	10
	.LONG	MCM3
	.WORD	10
	.LONG	MCM2
	.WORD	10
	.LONG	MCM3
	.WORD	28H
	.LONG	MCM2
	.WORD	0AH
	.LONG	MCM3
	.WORD	0AH
	.LONG	MCM2
	.WORD	0AH
	.LONG	0
MCTLKD		;BIG MONEY/ BIG PRIZES/ I LOVE IT
	.LONG	MCM3
	.WORD	8
	.LONG	MCM2
	.WORD	0CH
	.LONG	MCM3
	.WORD	1AH
	.LONG	MCM2
	.WORD	0CH
	.LONG	MCM3
	.WORD	8
	.LONG	MCM2
	.WORD	1CH
	.LONG	MCM3
	.WORD	8
	.LONG	MCM2
	.WORD	0CH
	.LONG	MCM3
	.WORD	11H
	.LONG	MCM2
	.WORD	0CH
	.LONG	MCM3
	.WORD	8
	.LONG	MCM2
	.WORD	8
	.LONG	MCM3
	.WORD	30H
	.LONG	MCM2
	.WORD	8
	.LONG	MCM3
	.WORD	0CH
	.LONG	MCM2
	.WORD	0CH
	.LONG	MCM3
	.WORD	8
	.LONG	MCM2
	.WORD	8
	.LONG	0
GLIPS			;GIRLS
	.LONG	GRLM3
	.WORD	7*60
	.LONG	GRLM2
	.WORD	30
	.LONG	0

	.END

