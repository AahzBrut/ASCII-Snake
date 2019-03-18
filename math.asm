%PAGESIZE 255, 255
IDEAL
P486N
MODEL small
STACK 200h

PUBLIC Seed, Rnd


DATASEG

RNGSEED		DW	?

CODESEG



;----------------------------------------------------------------------------------
; Seed			Seed LCG 
;----------------------------------------------------------------------------------
; Input:
;	none
; Output:	
;	none
; Registers:
;	
;----------------------------------------------------------------------------------
PROC Seed
		push ax
		push cx
		push dx
		xor ax, ax
		int 1Ah
		mov [RNGSEED], dx
		pop dx
		pop cx
		pop ax
		ret
ENDP



;----------------------------------------------------------------------------------
; Rnd			Random numbers generator
;----------------------------------------------------------------------------------
; Input:
;	AX	-	Highest random number (1 - 65536)
; Output:	
;	AX	-	Random number
; Registers:
;	
;----------------------------------------------------------------------------------
PROC Rnd	
		push dx
		push cx
		mov cx, ax
		xor dx, dx
		mov ax, 25173
		mul [RNGSEED]
		add ax, 13849
		mov [RNGSEED], ax		
		xor dx, dx
		mov ax, 0FFFFh
		div cx
		mov cx, ax
		xor dx, dx
		mov ax, [RNGSEED]
		div cx
		pop cx
		pop dx
		ret
ENDP





END
