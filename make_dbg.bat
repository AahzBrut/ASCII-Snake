@echo off
cls
rem debug build
tasm /r /l /m3 /z /zi /t /n *.asm
tlink /m /v /c snake.obj menu.obj strings.obj display.obj game.obj math.obj
rem release buid
rem tasm /r /l /m3 /z /zn /t *.asm
rem tlink /m snake.obj menu.obj strings.obj display.obj game.obj, snake_rl.exe
