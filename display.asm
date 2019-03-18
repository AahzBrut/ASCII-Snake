; library to work with default for MS DOS CGA mode (80 x 25)
%PAGESIZE 255, 255
IDEAL
P486N
MODEL small
STACK 200h

INCLUDE "Types.inc"


PUBLIC PrintString, ClearScreen, SetCursorPosition, DisableCursor, GetCharAtCursor

DATASEG

CurYPos		DB	0			; Cursor Y position
CurXPos		DB	0			; Cursor X position
BytesPerRow	DB	ScreenWidth * 2		; Bytes oer screen row (80 characters, each having ASCII code and color attribute)



CODESEG
;----------------------------------------------------------------------------------
; PrintString		Procedure for printing string structures
;----------------------------------------------------------------------------------
; Input:
;		SI - Address of string structure to print
; Output:	
;	none
; Registers:
;	
;----------------------------------------------------------------------------------
PROC PrintString
		push es					; save extra segment pointer
		push si					; save address of string
		push ax					;
		push cx					;
		push dx
		push di
		mov ax, VideoBuffer			; load in ES address of the
		mov es, ax				; Video buffer segment
		movzx ax, [CurYPos]			; Get Y coordinate
		mul [BytesPerRow]			; multiply by number of bytes per row
		movzx dx, [CurXPos]			; and add x coordinate
		add ax, dx				; multiply by 2 
		add ax, dx				; (2 bytes per character)
		mov di, ax				; set screen offset to starting position
		movzx cx, [(sString si).sLength]	; get string length
		inc si					; get address of string's text buffer
		or cx, cx				; check for empty string
		jz @@end				; if yes - exit loop
		cld					; forward direction of copying
	@@loop:
		lodsb					; get string character
		cmp al, CR				; check if it's "Carriage return"
		jne @@LF				; skip if not
		movzx dx, [CurXPos]			; if yes, get cursor x position
		add dx, dx				; multiply by 2
		sub di, dx				; and subtract from current screen position
		mov [CurXPos], 0			; zeroing Cursor X position
		jmp @@skip				; skip printing current symbol and move on to the next
	@@LF:	
		cmp al, LF				; check if current symbol is "Line Feed"
		jne @@PRN				; if not skip this block and go to symbol printing
		inc [CurYPos]				; increse cursor y position
		movzx dx, [BytesPerRow]			; get number of bytes per row
		add di, dx				; and forward current screen adress by row
		jmp @@skip				; skip printing current symbol
	@@PRN:
		stosb					; print character 
		inc [CurXPos]				; advance cursor forward
		inc di					; skip attribute byte
		cmp [CurXPos], ScreenWidth		; check cursor X position
		jbe @@skip				; if more then screen width
		mov [CurXPos], 0			; reset it to zero
		inc [CurYPos]				; and increase Y position
	@@skip:
		loop @@loop				; loop to the end of string
	@@end:
		pop di
		pop dx
		pop cx
		pop ax
		pop si					; restore address of string
		pop es					; restore extra segment pointer
		ret					; return
ENDP 


;----------------------------------------------------------------------------------
; ClearScreen		Procedure for clearing screen
;----------------------------------------------------------------------------------
; Input:
;	none
; Output:	
;	none
; Registers:
;	AX, CX
;----------------------------------------------------------------------------------
PROC ClearScreen
	push di				; save caller's DI
	push es				; save extra segment pointer
	mov ax, VideoBuffer		; load in ES address of
	mov es, ax			; Video buffer segment
	mov ax, SpaceChar		; get space character with default attributes 
	xor di, di			; set offset to screen start
	mov cx, VideoMemSize / 2	; as we will store words, we need half 
	cld				; from start to end
	rep stosw			; clear screen
	pop es				; restore ES segment
	pop di				; restore caller's DI
	ret 				; return
ENDP 



;----------------------------------------------------------------------------------
; SetCursorPosition			Set cursor at certain position
;----------------------------------------------------------------------------------
; Input:
;		AH	-	X position
;		AL	-	Y position
; Output:	
;	none
; Registers:
;	none
;----------------------------------------------------------------------------------
PROC SetCursorPosition
		mov [CurXPos], ah
		mov [CurYPos], al
		ret
ENDP 



;----------------------------------------------------------------------------------
; DisableCursor			Hide cursor
;----------------------------------------------------------------------------------
; Input:
;	none
; Output:	
;	none
; Registers:
;	none
;----------------------------------------------------------------------------------
PROC DisableCursor
		push ax
		push cx
		mov ah, 01h
		mov cx, 2000h
		int 10h
		pop cx
		pop ax
		ret
ENDP



;----------------------------------------------------------------------------------
; GetCharAtCursor		Get character from cursor's position
;----------------------------------------------------------------------------------
; Input:
;	none
; Output:	
;	AL	-	Character code
;	AH	-	Attribute code
; Registers:
;	AX
;----------------------------------------------------------------------------------
PROC GetCharAtCursor
		push es
		mov ax, VideoBuffer			; load in ES address of the
		mov es, ax				; Video buffer segment
		movzx ax, [CurYPos]			; Get Y coordinate
		mul [BytesPerRow]			; multiply by number of bytes per row
		movzx dx, [CurXPos]			; and add x coordinate
		add ax, dx				; multiply by 2 
		add ax, dx				; (2 bytes per character)
		mov bx, ax				; move offset to bx
		mov ax, [es:bx]				; get character (AL) and attribute (AH)
		pop es					; restore ES
		ret
ENDP

END
