%PAGESIZE 255, 255
IDEAL
P486N
MODEL small
STACK 200h


INCLUDE		"Types.inc"

PUBLIC ShowMenu

DATASEG

Menu	sString		<60, "************************************************************">
	sString		<60, "*                          SNAKE                           *">
	sString		<60, "*                                                          *">
	sString		<60, "*                       >Let's go                          *">
	sString		<60, "*                        Define keys                       *">
	sString		<60, "*                        Difficulty                        *">
	sString		<60, "*                        Exit                              *">
	sString		<60, "*                                                          *">
	sString		<60, "************************************************************">
Selector	sString		<1,">">
Space		sString		<1," ">

SelectedItem		db	0
PrevSelectedItem	db	0

CODESEG

; Declare procedures from Display.asm
EXTRN PrintString:proc, ClearScreen:proc, SetCursorPosition:proc, DisableCursor:proc

PROC ShowMenu
		call ClearScreen
		call DisableCursor
		call DrawMenu
		call MenuLogic
		ret
ENDP ShowMenu


PROC DrawMenu
		mov cx, 9
		mov ax, 0A06h
		mov si, offset Menu
	@@Loop:
		call SetCursorPosition
		call PrintString
		add si, size sString
		inc ax
		loop @@Loop
		ret
ENDP DrawMenu


PROC MenuLogic
		xor ax, ax				; Initialize
		mov [SelectedItem], al			; menu
		mov [PrevSelectedItem], al		; variables
	@@loop:
		mov al, [SelectedItem]			;
		mov [PrevSelectedItem], al		;
		mov ah, KEYBOARD_STATUS			;
		int 16h					;
		cmp ax, UP_ARROW			;
		je @@UpArrow				;
		cmp ax, DOWN_ARROW			;
		je @@DownArrow				;
		cmp ax, ENTER_CODE			;
		je @@SelectItem				;
		cmp ax, ESC_CODE			;
		je @@Exit				;
		jmp @@loop				;
	@@UpArrow:
		dec [SelectedItem]			;
		jmp @@EndSwitch				;
	@@DownArrow:
		inc [SelectedItem]			;
		jmp @@EndSwitch				;
	@@SelectItem:
		movzx ax, [SelectedItem]		;
		jmp @@Exit
	@@EndSwitch:
		and [SelectedItem], 03h			;
		mov ax, 2209h
		add al, [PrevSelectedItem]
		call SetCursorPosition
		mov si, offset Space
		call PrintString
		mov ax, 2209h
		add al, [SelectedItem]
		call SetCursorPosition
		mov si, offset Selector
		call PrintString
		jmp @@loop
	@@Exit:
		ret
ENDP MenuLogic


END
