; String constants
CR 			equ 	0Dh	; Carriage return symbol
LF			equ 	0Ah	; Line feed symbol
Null			equ	0	; Zero

; Keyboard constants
KEYBOARD_STATUS		equ	00h
UP_ARROW		equ	4800h
DOWN_ARROW		equ	5000h
LEFT_ARROW		equ	4B00h
RIGHT_ARROW		equ	4D00h
ESC_CODE		equ	011Bh
ENTER_CODE		equ	1C0Dh


; Time management
DelayCount	EQU	8974


; Display constants
VideoBuffer	EQU	0B800h	; Start of video buffer
SpaceChar	EQU	0720h	; Space character white on black (default for DOS)
VideoMemSize	EQU	0FA0h	; 4000 bytes (80*2*25)
ScreenWidth	EQU	80	; Width of screen in characters

; Game constants
MAXHEIGHT	EQU	22
MAXWIDTH	EQU	78
SNAKEMEMSIZE	= 	MAXHEIGHT * MAXWIDTH * size sBodyChunk
InitSnakeLength	EQU	2
InitSnakeSpeed	EQU	50
InitSnakeDir	EQU	dirNorth
FoodCountMax	EQU	5



;----------------------------------------------------------------------------------
; sBodyChunk		Structure for store information about body chunks of snake
;----------------------------------------------------------------------------------
; Members:
;	posX		- X position
;	posY		- Y position
;	PrevChunk	- Address of previous chunk
;	NextChunk	- Address of next chunk
;----------------------------------------------------------------------------------
STRUC sBodyChunk
		posY		db	?
		posX		db	?
		NextChunk	dw	?
ENDS sBodyChunk


;----------------------------------------------------------------------------------
; sString		Structure for store string
;----------------------------------------------------------------------------------
; Members:
;	sLength		- Length of string in bytes
;	sText		- Type of chunk
;----------------------------------------------------------------------------------
STRUC sString
		sLength		db	?
		Text		db	255	dup (?)
ENDS sString



;----------------------------------------------------------------------------------
; MenuItems		Menu items enumeration
;----------------------------------------------------------------------------------
; Members:
;----------------------------------------------------------------------------------
ENUM	MenuItems	{
		miPlayGame,
		miDefineKeys,
		miSetDifficulty,
		miExit
}



;----------------------------------------------------------------------------------
; Directions		Directions
;----------------------------------------------------------------------------------
; Members:
;		dirNorth	-	North (Up)
;		dirEast		- 	East (Right)
;		dirSouth	-	South (Down)
;		dirWest		- 	West (Left)
;----------------------------------------------------------------------------------
ENUM	Directions	{
		dirNorth,
		dirEast,
		dirSouth,
		dirWest
}


;----------------------------------------------------------------------------------
; sGameState		Runtime game parameters
;----------------------------------------------------------------------------------
; Members:
;		TimeTicks	- 	Current tick (0 - 99)
;----------------------------------------------------------------------------------
STRUC sGameState
		TimeTicks		db	?
		FoodCount		db	?
ENDS



;----------------------------------------------------------------------------------
; sTime		Time structure
;----------------------------------------------------------------------------------
; Members:
;		Hour	-	0..23
;		Minute	-	0..59
;		Second	-	0..59
;----------------------------------------------------------------------------------
STRUC sTime
		Hour		db	?
		Minute		db	?
		Second		db	?
ENDS sTime



;----------------------------------------------------------------------------------
; sSnake	Snake structure
;----------------------------------------------------------------------------------
; Members:
;		SnakeLength	-	Length of snake in blocks
;		SnakeSpeed	-	Time needed to move by 1 block
;		SnakeDirection	- 	Direction of head movement (N/E/S/W)
;		SnakeAge	-	Age of snake in seconds
;		HeadPtr		-	Address of Head body chunk
;		TailPtr		-	Address of Tail body chunk
;----------------------------------------------------------------------------------
STRUC sSnake
		SnakeLength		dw	?
		SnakeSpeed		db	?
		SnakeDirection		db	?
		SnakeAge		dw	?
		HeadPtr			dw	?
		TailPtr			dw	?
		TicksFromLastMove	db	?
ENDS
