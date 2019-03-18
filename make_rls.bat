@echo off
cls
rem debug build
rem tasm /r /l /m3 /z /zi /t /n *.asm
rem tlink /m /v /c snake.obj menu.obj strings.obj display.obj game.obj
rem release buid
tasm /r /l /m3 /z /zn /t *.asm
tlink /m snake.obj menu.obj strings.obj display.obj game.obj math.obj, snake_rl.exe
