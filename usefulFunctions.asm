; usefulFunctions
; Nick Larsen
; 2024.09.19
; Functions that will be useful in my code

.386P
.model flat

extern _GetStdHandle@4: near
extern _WriteConsoleA@20: near
extern _GetConsoleMode@8: near
extern _SetConsoleMode@8: near

extern _HeapCreate@12: near
extern _HeapAlloc@12: near
extern _HeapDestroy@4: near
extern _HeapUnlock@4: near

extern _Sleep@4: near

extern frameMain: near

.data
	
outHan dword ?
curConsoleMode dword ?

bufHeapHan dword ?
bufferPtr dword ?

xAscii byte "X"

worldString byte "Hello World!", 0

numCharsWritten dword ?

resetCursor byte 27, "[0;0f"


.code

;-------------------------------------------------------


; This is a sample function that is going to be the base for all my functions going forward
; ALL NEEDED REGISTERS SHOULD BE PUSHED AND POPPED OUTSIDE OF THE FUNCTION
;
; sampleFunction PROC near

; _functionSetup:
;
; add esp, 4
;
; POP ALL VARIABLES IN REVERSE ORDER
;
; sub esp, 4
;
; push ebp
; mov ebp, esp


; _sampleFunction:
;
; ALL FUNCTION CODE
; CAN USE ALL VARIBALES
; DONT HAVE TO POP ANY MEMORY OFF THE STACK


; _functionExit:
;
; mov esp, ebp
; pop ebp
; 
; ret

; sampleFunction ENDP




;*******************************************************
;*******************************************************

; Just getting the Handles and changing the console mode to virtual terminal mode

handleSetup PROC near
_functionSetup:

push ebp
mov ebp, esp

;---------------------------------------------------------
_handleSetup:

push -11
call _GetStdHandle@4
mov outHan, eax

push offset curConsoleMode
push eax
call _GetConsoleMode@8

mov eax, curConsoleMode
or eax, 0200h
mov curConsoleMode, eax

push eax
push outHan
call _SetConsoleMode@8



;---------------------------------------------------------


_functionExit:

mov esp, ebp
pop ebp

ret

handleSetup ENDP


;*******************************************************
;*******************************************************

; Creating a heap and allocating enough heap for a buffer of the screen

bufferSetup PROC near
_functionSetup:

push ebp
mov ebp, esp

;---------------------------------------------------------
_bufferSetup:



push 3000
push 3000
push 0
call _HeapCreate@12

mov bufHeapHan, eax


;push eax
;call _HeapUnlock@4

push 2525
push 0
push eax
call _HeapAlloc@12

mov bufferPtr, eax



;---------------------------------------------------------

_functionExit:

mov esp, ebp
pop ebp

ret

bufferSetup ENDP


;*******************************************************
;*******************************************************

; Destroying the heap to not cause any memory leaks

bufferDestroy PROC near
_functionSetup:

push ebp
mov ebp, esp

;---------------------------------------------------------
_bufferDestroy:
push bufHeapHan
call _HeapDestroy@4


;---------------------------------------------------------

_functionExit:

mov esp, ebp
pop ebp

ret

bufferDestroy ENDP


;*******************************************************
;*******************************************************

bufferPrint PROC near
_functionSetup:

push ebp
mov ebp, esp

;---------------------------------------------------------
_bufferPrint:
call cursorReset
push 0
push offset numCharsWritten
push 2525
push bufferPtr
push outHan
call _WriteConsoleA@20


;---------------------------------------------------------

_functionExit:

mov esp, ebp
pop ebp

ret

bufferPrint ENDP


;*******************************************************
;*******************************************************

; Writing blanks to all the positions of the buffer
; Also writing the lineFeeds

bufferReset PROC near
_functionSetup:

push ebp
mov ebp, esp

;---------------------------------------------------------
mov ecx, 0


mov eax, bufferPtr
_bufferReset:

mov edi, bufferPtr
add edi, ecx

push eax
push ebx
push ecx
push edx

mov edx, 0
mov eax, ecx
add eax, 1
mov ecx, 101
idiv ecx
cmp edx, 0
je _lineFeed

mov byte ptr [edi], 'a'
jmp _cont

_lineFeed:
mov byte ptr [edi], 10

_cont:
pop edx
pop ecx
pop ebx
pop eax

inc ecx
cmp ecx, 2525
jl _bufferReset

;---------------------------------------------------------

_functionExit:

mov esp, ebp
pop ebp

ret

bufferReset ENDP


;*******************************************************
;*******************************************************

; Writing hello World to the console

helloWorld PROC near
_functionSetup:

push ebp
mov ebp, esp

;---------------------------------------------------------
_helloWorld:
push 0
push offset numCharsWritten
push 12
push offset worldString
push outHan
call _WriteConsoleA@20
;---------------------------------------------------------

_functionExit:

mov esp, ebp
pop ebp

ret

helloWorld ENDP

;*******************************************************
;*******************************************************

; Reseting the cursor to 0,0

cursorReset PROC near
_functionSetup:

push ebp
mov ebp, esp

;---------------------------------------------------------
_cursorReset:

push 0
push offset numCharsWritten
push 6
push offset resetCursor
push outHan
call _WriteConsoleA@20

;---------------------------------------------------------

_functionExit:

mov esp, ebp
pop ebp

ret

cursorReset ENDP

;*******************************************************
;*******************************************************

; Writing a string to the console

writeString PROC near
_functionSetup:

pop edx
pop eax
push edx

push ebp
mov ebp, esp

;---------------------------------------------------------
_writeString:
push 0
push offset numCharsWritten

mov ecx, 0
_findChars:
mov ebx, [eax + ecx]

shl ebx, 24
shr ebx, 24

cmp ebx, 0
je _doneFindChars
inc ecx
jmp _findChars

_doneFindChars:
push ecx

push eax
push outHan
call _WriteConsoleA@20
;---------------------------------------------------------

_functionExit:

mov esp, ebp
pop ebp

ret

writeString ENDP


;*******************************************************
;*******************************************************

; Takes a coord and calculates the position in the buffer based on that coord

coordToPosition PROC near
_functionSetup:

pop edx
pop ebx
pop eax
push edx

push ebp
mov ebp, esp

;---------------------------------------------------------
_coordToPosition:


cmp eax, 100
jge _outOfRange
cmp eax, 0
jl _outOfRange

cmp ebx, 25
jge _outOfRange
cmp ebx, 0
jl _outOfRange


imul ebx, 101
add ebx, eax

mov eax, ebx
mov ebx, 1
jmp _functionExit


_outOfRange:
mov eax, 0
mov ebx, 0


;---------------------------------------------------------

_functionExit:

mov esp, ebp
pop ebp

ret

coordToPosition ENDP


;*******************************************************
;*******************************************************

; Takes an ascii image and draws it at the coord. Note that it draws the image from the top left corner of the image

drawImageAtCoordA PROC near
_functionSetup:

pop edx
pop eax
pop ebx
pop ecx
push edx

push ebp
mov ebp, esp

;---------------------------------------------------------
_drawImageAtCoordA:

push eax
mov edx, 0

_drawLoop:

push eax
mov eax, 0
cmp byte ptr [ecx+edx], al
pop eax
je _functionExit

push eax
mov eax, 10
cmp byte ptr [ecx+edx], al
pop eax
je _lineFeed

push eax
mov eax, 32
cmp byte ptr [ecx+edx], al
pop eax
jl _transparent

push eax
mov eax, 127
cmp byte ptr [ecx+edx], al
pop eax
jg _transparent

push eax
push ebx
push ecx
push edx

push eax
push ebx
call coordToPosition

cmp ebx, 0
je _outOfRange

_validLetterAndPosition:
pop edx
pop ecx
mov edi, bufferPtr
add edi, eax
mov bl, byte ptr [ecx+edx]
mov byte ptr [edi], bl
pop ebx
pop eax
add edx, 1
add eax, 1
jmp _drawLoop


_outOfRange:
pop edx
pop ecx
pop ebx
pop eax
add edx, 1
add eax, 1
jmp _drawLoop

_transparent:
add edx, 1
add eax, 1
jmp _drawLoop

_lineFeed:
pop eax
push eax
add edx, 1
add ebx, 1
jmp _drawLoop




;---------------------------------------------------------

_functionExit:

mov esp, ebp
pop ebp

ret

drawImageAtCoordA ENDP


;*******************************************************
;*******************************************************

; All the logic for running the frames of the games

frameRun PROC near
_functionSetup:

pop edx
pop ebx
pop eax
push edx

push ebp
mov ebp, esp

;---------------------------------------------------------
mov ecx, 600
_frameRun:
push ecx

call frameMain

call bufferPrint

push 33
call _Sleep@4

pop ecx
sub ecx, 1
cmp ecx, 0
jne _frameRun

;---------------------------------------------------------

_functionExit:

mov esp, ebp
pop ebp

ret

frameRun ENDP




END