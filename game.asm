%PAGESIZE 255, 255
IDEAL
P486N
MODEL small
STACK 200h

PUBLIC Main

INCLUDE "Types.inc"


DATASEG
BorderSmb	sString		<1, "#">		;
SnakeSmb	sString		<1, "*">		;
FoodSmb		sString		<1, "@">		;
VoidSmb		sString		<1, " ">		;

SystemTime	sTime		<>			;
FakeTime	sTime		<>			;
SysTimeString	sString		<>			;
FakeTimeString	sString		<>			;
SnakeBody			db	SNAKEMEMSIZE - 1	dup	(?)
SnakeBodyEnd			db	size sBodyChunk dup (?)
Snake		sSnake		<>
GameState	sGameState	<>


ENDS


CODESEG
EXTRN ClearScreen:proc, PrintString:proc, SetCursorPosition:proc, GetCharAtCursor:proc

EXTRN TimeToString:proc

EXTRN Seed:proc, Rnd:proc


;----------------------------------------------------------------------------------
; Main			Main Game Loop
;----------------------------------------------------------------------------------
; Input:
;	none
; Output:	
;	none
; Registers:
;	AX, CX, SI
;----------------------------------------------------------------------------------
PROC Main
		call ClearScreen			;
		call DrawField
		call InitTimers
		call InitGame
	@@MainLoop:
		call Pause10ms
		call GetUserInput
		call GameLogic
		call DrawFrame
		jmp @@MainLoop
		ret
ENDP



;----------------------------------------------------------------------------------
; DrawField		Drawing game field
;----------------------------------------------------------------------------------
; Input:
;	none
; Output:	
;	none
; Registers:
;	AX, CX, SI
;----------------------------------------------------------------------------------
PROC DrawField
		mov si, offset BorderSmb		;
		mov cx, 80				;
		mov ax, 0001h				;
	@@UpBorder:
		call SetCursorPosition			;
		call PrintString			;
		inc ah					;
		loop @@UpBorder				;
		mov cx, 80				;
		mov ax, 0018h				;
	@@DownBorder:
		call SetCursorPosition			;
		call PrintString			;
		inc ah					;
		loop @@DownBorder			;
		mov cx, 22				;
		mov ax, 0002h				;
	@@LeftBorder:
		call SetCursorPosition			;
		call PrintString			;
		inc al					;
		loop @@LeftBorder			;
		mov cx, 22				;
		mov ax, 4F02h				;
	@@RightBorder:
		call SetCursorPosition			;
		call PrintString			;
		inc al					;
		loop @@RightBorder			;
		ret
ENDP



PROC Pause10ms
		xor cx, cx
		mov dx, DelayCount
		mov ax, 8600h
		int 15h
		inc [GameState.TimeTicks]
		cmp [GameState.TimeTicks], 100
		jne @@Exit
		xor ax, ax
		mov [GameState.TimeTicks], ah
		inc [Snake.SnakeAge]
		inc [FakeTime.Second]
		cmp [FakeTime.Second], 60
		jne @@SameMinute
		mov [FakeTime.Second], ah
		inc [FakeTime.Minute]		
	@@SameMinute:
		cmp [FakeTime.Minute], 60
		jne @@SameHour
		mov [FakeTime.Minute], ah
		inc [FakeTime.Hour]
	@@SameHour:
		cmp [FakeTime.Hour], 24
		jne @@Exit
		mov [FakeTime.Hour], ah
	@@Exit:
		mov ah, 2Ch
		int 21h
		mov [SystemTime.Hour], ch
		mov [SystemTime.Minute], cl
		mov [SystemTime.Second], dh
		ret
ENDP



PROC GetUserInput
		mov ah, 01h
		int 16h
		jz @@Exit
		mov ah, Null
		int 16h
		cmp ax, UP_ARROW
		jne @@Down
		mov [Snake.SnakeDirection], dirNorth
		jmp @@Exit
	@@Down:
		cmp ax, DOWN_ARROW
		jne @@Right
		mov [Snake.SnakeDirection], dirSouth
		jmp @@Exit
	@@Right:
		cmp ax, RIGHT_ARROW
		jne @@Left
		mov [Snake.SnakeDirection], dirEast
		jmp @@Exit
	@@Left:
		cmp ax, LEFT_ARROW
		jne @@Esc
		mov [Snake.SnakeDirection], dirWest
		jmp @@Exit
	@@Esc:
		cmp ax, ESC_CODE
		jne @@Exit
		EXITCODE 0
	@@Exit:
		ret
ENDP



PROC GameLogic
		inc [Snake.TicksFromLastMove]
		mov al, [Snake.TicksFromLastMove]
		cmp al, [Snake.SnakeSpeed]
		jne @@NoMove
		mov [Snake.TicksFromLastMove], Null
		call CheckMoveOutcome
		jc @@NoMove
		cmp cl, [FoodSmb.Text]
		je @@Growth
		call CutTail
		jmp @@Move
	@@Growth:
		inc [Snake.SnakeLength]
		dec [GameState.FoodCount]
		dec [Snake.SnakeSpeed]
		call InitFood
	@@Move:
		call MoveHead
	@@NoMove:
		ret
ENDP


PROC CutTail
		push ax
		mov bx, [Snake.TailPtr]
		mov dx, [(sBodyChunk bx).NextChunk]
		mov [Snake.TailPtr], dx
		mov ax, [word (sBodyChunk bx).posY]
		call SetCursorPosition
		mov si, offset VoidSmb
		call PrintString
		pop ax
		ret
ENDP


PROC MoveHead
		mov bx, [Snake.HeadPtr]
		cmp bx, offset SnakeBodyEnd
		jne @@NoRollover
		mov dx, offset SnakeBody
		jmp @@Move
	@@NoRollover:
		mov dx, bx
		add dx, size sBodyChunk
	@@Move:
		mov [Snake.HeadPtr], dx
		mov [(sBodyChunk bx).NextChunk], dx
		mov bx, dx
		mov [word (sBodyChunk bx).posY], ax
		call SetCursorPosition
		mov si, offset SnakeSmb
		call PrintString
		ret
ENDP


PROC DrawFrame
		mov bx, offset SystemTime		; take address of SystemTime
		mov di, offset SysTimeString		; take address of string representation
		mov [byte di], Null			; init string
		call TimeToString			; convert time to string
		xor ax, ax				; set cursor position (x:0; y:0)
		call SetCursorPosition			; to top left corner
		mov si, offset SysTimeString		; print time
		call PrintString			; in cursor's current position

		mov bx, offset FakeTime			; take address of FakeTime
		mov di, offset FakeTimeString		; take address of string representation
		mov [byte di], Null			; init string
		call TimeToString			; convert time to string
		mov ax, 0A00h				; set cursor position (x:10; y:0)
		call SetCursorPosition			; to top left corner
		mov si, offset FakeTimeString		; print time
		call PrintString			; in cursor's current position
		ret					; return
ENDP



PROC InitTimers
		mov ah, 2Ch
		int 21h
		mov [SystemTime.Hour], ch
		mov [SystemTime.Minute], cl
		mov [SystemTime.Second], dh
	@@Sync:
		mov ah, 2Ch
		int 21h
		cmp [SystemTime.Second], dh
		je @@Sync
		mov [SystemTime.Hour], ch
		mov [SystemTime.Minute], cl
		mov [SystemTime.Second], dh
		mov [FakeTime.Hour], ch
		mov [FakeTime.Minute], cl
		mov [FakeTime.Second], dh
		mov [GameState.TimeTicks], Null
		ret
ENDP



PROC InitGame
		mov [GameState.FoodCount], 0
		call InitSnake
		call Seed
		call InitFood
		ret
ENDP



PROC InitSnake
		mov di, offset SnakeBody				; Clear
		mov cx, SNAKEMEMSIZE / 2				; ring
		xor ax, ax						; buffer
		rep stosw						; for snake body chunks
									
		mov bx, offset SnakeBody				; Init Snake Tail chunk
		mov [(sBodyChunk bx).posX], MAXWIDTH / 2
		mov [(sBodyChunk bx).posY], (MAXHEIGHT / 2)
		;mov [(sBodyChunk bx).PrevChunk], Null
		mov [(sBodyChunk bx).NextChunk], \
			offset SnakeBody + size sBodyChunk
		
		mov bx, offset SnakeBody + size sBodyChunk		; Init Snake Head chunk
		mov [(sBodyChunk bx).posX], MAXWIDTH / 2
		mov [(sBodyChunk bx).posY], MAXHEIGHT / 2 - 1
		;mov [(sBodyChunk bx).PrevChunk], \
		;	offset SnakeBody
		mov [(sBodyChunk bx).NextChunk], Null

		mov bx, offset Snake					; Init Snake structure
		mov [(sSnake bx).SnakeLength], InitSnakeLength
		mov [(sSnake bx).SnakeSpeed], InitSnakeSpeed
		mov [(sSnake bx).SnakeDirection], InitSnakeDir
		mov [(sSnake bx).SnakeAge], Null
		mov [(sSnake bx).HeadPtr], \
			offset SnakeBody + size sBodyChunk
		mov [(sSnake bx).TailPtr], offset SnakeBody
		mov [(sSnake bx).TicksFromLastMove], Null

		mov bx, offset Snake					; Display head
		mov bx, [(sSnake bx).HeadPtr]
		mov ax, [word (sBodyChunk bx).posY]
		call SetCursorPosition
		mov si, offset SnakeSmb
		call PrintString
		
		mov bx, offset Snake					; Display tail
		mov bx, [(sSnake bx).TailPtr]
		mov ax, [word (sBodyChunk bx).posY]
		call SetCursorPosition
		mov si, offset SnakeSmb
		call PrintString

		ret
ENDP



PROC InitFood
		push cx
		push si
		push ax
		mov cl, FoodCountMax
		sub cl, [GameState.FoodCount]
		mov si, offset FoodSmb
	@@FoodPlacement:
		mov ax, MAXWIDTH
		call Rnd
		inc ax
		mov ch, al
		mov ax, MAXHEIGHT
		call Rnd
		add ax, 2
		mov ah, ch
		call SetCursorPosition
		call GetCharAtCursor
		cmp al, ' '
		jne @@FoodPlacement
		call PrintString
		dec cl
		jnz @@FoodPlacement
		mov [GameState.FoodCount], FoodCountMax
		pop ax
		pop si
		pop cx
		ret
ENDP


;----------------------------------------------------------------------------------
; CheckMoveOutcome	Check destination block for allouance of movement (i.e. destination block empty or contain food)
;----------------------------------------------------------------------------------
; Input:
;	none
; Output:	
;	AX	-	Coordinates of target block (current, if target block not passable (wall or snake body))
;	CL	-	Type of target block (wall, body, void or food)
;	CF	-	Set if movement is not possible, cleared, if otherwise
; Registers:
;	AX, CX
;----------------------------------------------------------------------------------
PROC CheckMoveOutcome
		mov bx, [Snake.HeadPtr]
		mov al, [Snake.SnakeDirection]
		mov cx, [word (sBodyChunk bx).posY]
	@@MoveNorth:
		cmp al, dirNorth
		jne @@MoveEast
		dec cl
		jmp @@CheckDest
	@@MoveEast:
		cmp al, dirEast
		jne @@MoveSouth
		inc ch
		jmp @@CheckDest
	@@MoveSouth:
		cmp al, dirSouth
		jne @@MoveWest
		inc cl
		jmp @@CheckDest
	@@MoveWest:
		dec ch
	@@CheckDest:
		mov ax, cx
		call SetCursorPosition
		call GetCharAtCursor
		xchg ax, cx
		cmp cl, [byte VoidSmb.Text]
		je @@MoveOk
		cmp cl, [byte FoodSmb.Text]
		je @@MoveOk
	@@NoMove:
		stc
		jmp @@Exit
	@@MoveOk:
		clc
	@@Exit:	
		ret
ENDP

END
