 ; Library for manipulating null-terminated strings
%PAGESIZE 255, 255
IDEAL
P486N
MODEL small
STACK 200h

INCLUDE "Types.inc"

PUBLIC WordToStr, StrLen, StrConcat, InitString, TimeToString

DATASEG
TimeDelimmiter	sString	<1, ":">		;
TTSBuffer	sString	<>			;
WTSBuffer	db 256 dup (?)			;

CODESEG
;----------------------------------------------------------------------------------
; WordToStr		Convert unsigned word value to ASCII string
;----------------------------------------------------------------------------------
; Input:
;	AX		- unsigned word to convert
;	DI		- pointer to result string struct
;	CX		- minimal number of digits (to add leading 0-s if number is smaller)
; Output:	
;	DI		- pointer to result string struct
; Registers:
;	AX, DX, CX
;----------------------------------------------------------------------------------
PROC WordToStr
		push bx					; save registers
		push si					; for later restore
		mov si, offset WTSBuffer + 255		; Buffer for result string (right to left)
		mov bx, 000Ah				; decimal base
	@@loop:
		xor dx, dx				; clear DX for div by r16 (mandatory)
		div bx					; divide value by 10
		add dl, '0'				; convert digit to ASCII
		dec si					; calculate address for next digit
		mov [si], dl				; store digit in temp buffer
		or ax, ax				; check if there is something left to divide again
		jnz @@loop				; repeat if something left (AX != 0)
		mov ax, cx				; save width parameter
		mov cx, offset WTSBuffer + 255		; count number of result's
		sub cx, si				; ASCII digits
		cmp ax, cx				; if 
		jbe @@skip				; biger then width, skip
		push ax					; save number of digits in result
		sub ax, cx				; count number of digits in left padding
		mov cx, ax				; and store cx
	@@ZeroFill:
		dec si					; move to previous position
		mov [byte si], '0'				; store '0'
		loop @@ZeroFill				; repeat until the end
		pop ax					; restore result length
	@@skip:
		mov cx, ax				; get result length
		mov ax, di				; save pointer
		mov [di], cl				; store result length
		inc di					; move pointer to string's text
		cld					; copying from left to right
		rep movsb				; copy result from temporary buffer
		mov di, ax				; restore pointer
		pop si					; restore 
		pop bx					; corrupted registers
		ret					; return
ENDP



;----------------------------------------------------------------------------------
; StrLen		Returns length in bytes of the null-terminated string
;----------------------------------------------------------------------------------
; Input:
;	DI		- Address of string
; Output:	
;	CX		- Length of null-terminated string
; Registers:
;	AX, CX, BX
;----------------------------------------------------------------------------------
PROC StrLen
		mov bx, di			; Save di
		xor ax, ax			; take null value 
	@@loop:
		scasb				; and search input string
		jnz @@loop			; until null will be found
		mov cx, di			; calculate
		sub cx, bx			; length of string
		dec cx				; excluding null terminator
		mov di, bx			; restore di
		ret				; return
ENDP



;----------------------------------------------------------------------------------
; StrConcat		Concatinate 2 string structs
;----------------------------------------------------------------------------------
; Input:
;	DI		- Address of first string struct
; 	SI		- Address of second string struct
; Output:	
;	DI		- Adress of resulting string struct
; Registers:
;	CX
;----------------------------------------------------------------------------------
PROC StrConcat
		push si
		push di
		xor cx, cx
		mov cl, [byte di]
		inc di
		add di, cx
		mov cl, [byte si]
		inc si
		cld
		rep movsb
		pop di
		pop si
		mov cl, [byte di]
		add cl, [byte si]
		mov [di], cl
		ret
ENDP




;----------------------------------------------------------------------------------
; InitString		Initialize string struct with null terminated string
;----------------------------------------------------------------------------------
; Input:
;	DI		- Address of string struct
; 	SI		- Address of null terminated string
; Output:	
;	DI		- Adress of resulting string struct
; Registers:
;	
;----------------------------------------------------------------------------------
PROC InitString
		push di				; Save struct address
		xchg di, si			; call strlen
		call StrLen			; on null terminated string
		xchg di, si			; return adresses as they were
		mov [di], cl			; set string length
		inc di				; skip String.StrLength
		rep movsb			; copy string to String.Text
		mov [byte di], Null		; Terminate text with null
		pop di				; restore struct address
		ret				; return to caller
ENDP



;----------------------------------------------------------------------------------
; TimeToString		Returns string representation of sTime structure
;----------------------------------------------------------------------------------
; Input:
;	BX		- Address of sTime struct
; 	DI		- Address of null terminated string
; Output:	
;	DI		- Adress of resulting string struct
; Registers:
;	AX, CX, DI, SI
;----------------------------------------------------------------------------------
PROC TimeToString
		push di
		mov di, offset TTSBuffer
		movzx ax, [(sTime bx).Hour]
		mov cx, 2
		call WordToStr
		mov si, di
		pop di
		call StrConcat
		mov si, offset TimeDelimmiter
		call StrConcat
		push di
		mov di, offset TTSBuffer
		movzx ax, [(sTime bx).Minute]
		mov cx, 2
		call WordToStr
		mov si, di
		pop di
		call StrConcat
		mov si, offset TimeDelimmiter
		call StrConcat
		push di
		mov di, offset TTSBuffer
		movzx ax, [(sTime bx).Second]
		mov cx, 2
		call WordToStr
		mov si, di
		pop di
		call StrConcat
		ret
ENDP


END
