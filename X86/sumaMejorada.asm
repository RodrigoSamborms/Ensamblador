; sumaMejorada.asm - Solicita 2 numeros, suma y muestra el resultado (Win32, MASM)
; Autor: Rodrigo Samborms
; Fecha: 22-Oct-2025

; Ensamblar y enlazar con el script X86/build.ps1 (linkea kernel32.lib)

	.386
	.model flat, stdcall

; Prototipos de funciones Win32
GetStdHandle    PROTO :DWORD
ReadConsoleA    PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
WriteConsoleA   PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ExitProcess     PROTO :DWORD

; Prototipos utilitarios
StrLen          PROTO :DWORD                 ; devuelve longitud en EAX
AsciiToInt      PROTO :DWORD                 ; EAX = valor convertido (con signo)
IntToAscii      PROTO :SDWORD, :DWORD        ; EAX = longitud escrita, buffer 0-terminado

; Constantes
STD_INPUT_HANDLE  EQU -10
STD_OUTPUT_HANDLE EQU -11

	.data
prompt1         db "Ingrese el primer numero: ",0
prompt2         db "Ingrese el segundo numero: ",0
resultMsg       db "Resultado: ",0
newline         db 13,10,0

inputBuf        db 64 dup(0)
charsRead       dd 0
charsWritten    dd 0

outputNum       db 32 dup(0)
revBuf          db 32 dup(0)                ; buffer temporal para IntToAscii

inHandle        dd 0
outHandle       dd 0

val1            sdword 0
val2            sdword 0
sumVal          sdword 0

	.code

; ------------------------------------------------------------
; main
; ------------------------------------------------------------
main PROC
	; Obtener handles de consola
	invoke GetStdHandle, STD_INPUT_HANDLE
	mov     inHandle, eax
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov     outHandle, eax

	; Mostrar prompt1
	invoke StrLen, ADDR prompt1
	mov     ecx, eax
	mov     eax, outHandle
	invoke  WriteConsoleA, eax, ADDR prompt1, ecx, ADDR charsWritten, 0

	; Leer primera linea
	mov     eax, inHandle
	invoke  ReadConsoleA, eax, ADDR inputBuf, 63, ADDR charsRead, 0
	; Recortar CRLF y 0-terminar
	mov     eax, charsRead
	cmp     eax, 2
	jb      short rl1_no_trim
	mov     byte ptr inputBuf[eax-2], 0
	jmp     short rl1_done
rl1_no_trim:
	mov     byte ptr inputBuf[eax], 0
rl1_done:
	; Convertir a entero
	invoke  AsciiToInt, ADDR inputBuf
	mov     val1, eax

	; Mostrar prompt2
	invoke StrLen, ADDR prompt2
	mov     ecx, eax
	mov     eax, outHandle
	invoke  WriteConsoleA, eax, ADDR prompt2, ecx, ADDR charsWritten, 0

	; Leer segunda linea
	mov     eax, inHandle
	invoke  ReadConsoleA, eax, ADDR inputBuf, 63, ADDR charsRead, 0
	mov     eax, charsRead
	cmp     eax, 2
	jb      short rl2_no_trim
	mov     byte ptr inputBuf[eax-2], 0
	jmp     short rl2_done
rl2_no_trim:
	mov     byte ptr inputBuf[eax], 0
rl2_done:
	invoke  AsciiToInt, ADDR inputBuf
	mov     val2, eax

	; Sumar
	mov     eax, val1
	add     eax, val2
	mov     sumVal, eax

	; Convertir resultado a ASCII
	invoke  IntToAscii, sumVal, ADDR outputNum
	mov     ebx, eax                     ; ebx = longitud del numero

	; Mostrar "Resultado: "
	invoke StrLen, ADDR resultMsg
	mov     ecx, eax
	mov     eax, outHandle
	invoke  WriteConsoleA, eax, ADDR resultMsg, ecx, ADDR charsWritten, 0

	; Mostrar numero
	mov     eax, outHandle
	invoke  WriteConsoleA, eax, ADDR outputNum, ebx, ADDR charsWritten, 0

	; Nueva linea
	invoke StrLen, ADDR newline
	mov     ecx, eax
	mov     eax, outHandle
	invoke  WriteConsoleA, eax, ADDR newline, ecx, ADDR charsWritten, 0

	; Salir
	invoke ExitProcess, 0
	ret
main ENDP

; ------------------------------------------------------------
; StrLen(lpStr) -> EAX = longitud (excluye el byte 0)
; ------------------------------------------------------------
StrLen PROC uses esi lpStr:DWORD
	mov     esi, lpStr
	xor     eax, eax
@@:     cmp     byte ptr [esi+eax], 0
	je      short sl_done
	inc     eax
	jmp     short @B
sl_done:ret
StrLen ENDP

; ------------------------------------------------------------
; AsciiToInt(lpStr) -> EAX = entero (soporta espacios y signo +/-)
; ------------------------------------------------------------
AsciiToInt PROC uses esi edi ebx ecx edx lpStr:DWORD
	mov     esi, lpStr
	xor     eax, eax                 ; acumulador
	mov     ebx, 10
	xor     edi, edi                 ; signo: 0=pos, 1=neg

; saltar espacios en blanco (espacio y tab)
ati_skip:
	mov     dl, [esi]
	cmp     dl, ' '
	je      short ati_inc
	cmp     dl, 9
	jne     short ati_sign
ati_inc: inc     esi
	jmp     short ati_skip

ati_sign:
	mov     dl, [esi]
	cmp     dl, '-'
	jne     short ati_chk_plus
	mov     edi, 1
	inc     esi
	jmp     short ati_digits
ati_chk_plus:
	cmp     dl, '+'
	jne     short ati_digits
	inc     esi

ati_digits:
	mov     dl, [esi]
	cmp     dl, 0
	je      short ati_done
	cmp     dl, '0'
	jb      short ati_done
	cmp     dl, '9'
	ja      short ati_done
	sub     dl, '0'                  ; DL = digito 0..9
	; EAX = EAX*10 + DL
	lea     eax, [eax*4+eax]         ; eax *= 5
	shl     eax, 1                   ; eax *= 10
	movzx   edx, dl
	add     eax, edx
	inc     esi
	jmp     short ati_digits

ati_done:
	test    edi, edi
	jz      short ati_ret
	neg     eax
ati_ret: ret
AsciiToInt ENDP

; ------------------------------------------------------------
; IntToAscii(value, pBuf) -> EAX = longitud, buffer 0-terminado
; Usa revBuf para almacenar temporalmente los dígitos.
; ------------------------------------------------------------
IntToAscii PROC uses eax ebx ecx edx esi edi value:SDWORD, pBuf:DWORD
	mov     esi, pBuf
	mov     eax, value
	mov     ebx, 10
	xor     ecx, ecx                 ; cuenta de caracteres en revBuf
	xor     edi, edi                 ; signo: 0=pos, 1=neg

	cmp     eax, 0
	jne     short ita_chkneg
	; valor == 0
	mov     byte ptr [esi], '0'
	mov     byte ptr [esi+1], 0
	mov     eax, 1
	ret

ita_chkneg:
	jge     short ita_divloop
	neg     eax
	mov     edi, 1

ita_divloop:
	xor     edx, edx
	div     ebx                      ; EDX = resto, EAX = cociente
	add     dl, '0'
	mov     revBuf[ecx], dl
	inc     ecx
	test    eax, eax
	jnz     short ita_divloop

	test    edi, edi
	jz      short ita_copy
	mov     revBuf[ecx], '-'         ; agregar signo
	inc     ecx

ita_copy:
	; copiar en orden inverso a pBuf
	mov     edx, ecx                 ; edx = len
	dec     ecx                      ; idx ultima pos valida en revBuf
	xor     eax, eax                 ; usar AL para copiar
	mov     edi, esi                 ; destino = pBuf
ita_cp_loop:
	mov     al, revBuf[ecx]
	mov     [edi], al
	inc     edi
	dec     ecx
	jns     short ita_cp_loop
	mov     byte ptr [edi], 0        ; terminador
	mov     eax, edx                 ; longitud
	ret
IntToAscii ENDP

	end main

