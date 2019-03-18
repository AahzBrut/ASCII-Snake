%PAGESIZE 255, 255
IDEAL
P486N
MODEL small
STACK 200h

INCLUDE		"Types.inc"



DATASEG



CODESEG
EXTRN ShowMenu:proc, Main:proc

Start:
		mov ax, @data
		mov ds, ax
		mov es, ax
@@Loop:
		call ShowMenu
		cmp ax, miPlayGame
		je @@PlayGame
		cmp ax, miExit
		je @@Exit
		jmp @@Loop
@@PlayGame:
		call Main
@@Exit:
		EXITCODE 0

END Start
