; Frame Logic
; Nick Larsen
; 2024.09.19
; The logic of everything per frame
.386P
.model flat


extern bufferPrint: near
extern bufferReset: near
extern drawImageAtCoordA: near

.data

asciiImage byte "  __   ___.--'_`.     .'_`--.___   __  ", 10
		   byte " ( _`.'. -   'o` )   ( 'o`   - .`.'_ ) ", 10
		   byte " _\.'_'      _.-'     `-._      `_`./_ ", 10
		   byte "( \`. )    //\`         '/\\    ( .'/ )", 10
		   byte " \_`-'`---'\\__,       ,__//`---'`-'_/ ", 10
		   byte "  \`        `-\         /-'        '/  ", 0

asciiImageConsole byte ".------------------------------------------.", 10
				  byte "|  ____ ___  _   _ ____   ___  _     _____ |", 10
				  byte "| / ___/ _ \| \ | / ___| / _ \| |   | ____||", 10
				  byte "|| |  | | | |  \| \___ \| | | | |   |  _|  |", 10
				  byte "|| |__| |_| | |\  |___) | |_| | |___| |___ |", 10
				  byte "| \____\___/|_| \_|____/ \___/|_____|_____||", 10
				  byte "'------------------------------------------'", 0

coord dword 10, 10

direction dword 2,1

.code

frameMain PROC near
_functionSetup:
push ebp
mov ebp, esp


_frameMain:
call bufferReset

;Checks to see if the image hits the borders

push eax
mov eax, 56
cmp [coord], eax
jge _changeDirXLeft
mov eax, 0
cmp [coord], eax
jl _changeDirXRight
mov eax, 18
cmp [coord+4], eax
jge _changeDirYUp
mov eax, 0
cmp [coord+4], eax
jl _changeDirYDown


jmp _cont

; If the image hits any of the borders then the direction is changed based on what border it hits
_changeDirXLeft:
mov [direction], -2
pop eax
jmp _cont

_changeDirXRight:
mov [direction], 2
pop eax
jmp _cont

_changeDirYUp:
mov [direction+4], -1
pop eax
jmp _cont

_changeDirYDown:
mov [direction+4], 1
pop eax
jmp _cont

; Adds to the coords to update the position of the image
; Also prints the image out after that
_cont:
push eax
mov eax, [direction]
add [coord], eax
mov eax, [direction+4]
add [coord+4], eax
pop eax

push offset asciiImageConsole
push [coord+4]
push [coord]
call drawImageAtCoordA




_functionEnd:

mov esp, ebp
pop ebp
ret

frameMain ENDP


END