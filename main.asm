; MASM Template
; Nick Larsen
; 2024.09.19
; Create a template for assembler files.
.386P
.model flat

extern	_ExitProcess@4: near

extern handleSetup: near
extern bufferSetup: near
extern bufferDestroy: near
extern bufferReset: near

extern frameRun: near


.data


.code
main PROC near
_main:

	; All of these are needed to run the engine
	call handleSetup
	call bufferSetup
	call bufferReset


	call frameRun


	call bufferDestroy
	call _ExitProcess@4

main ENDP

END


