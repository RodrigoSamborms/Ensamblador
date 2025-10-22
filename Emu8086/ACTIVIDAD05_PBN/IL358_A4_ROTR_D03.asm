; IL358_A4_ROTR_D03.asm - Crear y escribir archivo con INT 21h (.COM)
; Autor: Rodrigo Samborms
; Fecha: 21 de Octubre, 2025

ORG 100h                              ; Programas .COM inician en 100h

; Saltar sobre datos
JMP INICIO

; ============================================================
; DATOS
; ============================================================
rutaArchivo db 'C:\emu8086\MyBuild\Rodrigo.txt', 0

msgEncabezado  db 'Crear archivo y escribir frase (INT 21h)', 0Dh, 0Ah, '$'
msgCrear       db 'Creando archivo: C:\emu8086\MyBuild\Rodrigo.txt', 0Dh, 0Ah, '$'
msgYaExiste    db 'CREATE fallo; se abrira para escribir (archivo existente).', 0Dh, 0Ah, '$'
msgEscribir    db 'Escribiendo frase...', 0Dh, 0Ah, '$'
msgOk          db 'Operacion completada y archivo cerrado.', 0Dh, 0Ah, '$'
msgError       db 'ERROR en crear/abrir/escribir/cerrar.', 0Dh, 0Ah, '$'

; Frase a escribir (sin terminador) — longitud calculada en ensamblado
frase db 'Parangaricutirimicuaroy hipopotomonstrosesquipedaliofobia'
frase_len EQU $ - frase
crlf db 0Dh, 0Ah

manejador dw 0

; ============================================================
; CODIGO
; ============================================================
INICIO:
	; Modelo .COM: DS = CS
	push cs
	pop ds

	; Encabezado
	lea dx, msgEncabezado
	mov ah, 09h
	int 21h

	; Intentar crear archivo
	lea dx, msgCrear
	mov ah, 09h
	int 21h

	mov cx, 0                      ; atributos normales
	lea dx, rutaArchivo
	mov ah, 3Ch                    ; CREATE
	int 21h
	jc  ABRIR_EXISTENTE            ; si existe u otro error, intentar abrir
	mov [manejador], ax
	jmp HACER_ESCRITURA

ABRIR_EXISTENTE:
	; Notificar y abrir lectura/escritura (modo 2)
	lea dx, msgYaExiste
	mov ah, 09h
	int 21h
	mov al, 2                      ; modo 2 = read/write
	lea dx, rutaArchivo
	mov ah, 3Dh                    ; OPEN
	int 21h
	jc  FATAL_ERROR
	mov [manejador], ax
	; por defecto el puntero esta al inicio

HACER_ESCRITURA:
	; Escribir frase
	lea dx, msgEscribir
	mov ah, 09h
	int 21h

	mov bx, [manejador]
	mov cx, frase_len
	lea dx, frase
	mov ah, 40h                    ; WRITE
	int 21h
	jc  CERRAR_Y_ERROR
	cmp ax, cx
	jne CERRAR_Y_ERROR

	; Escribir CRLF
	mov bx, [manejador]
	mov cx, 2
	lea dx, crlf
	mov ah, 40h                    ; WRITE
	int 21h
	jc  CERRAR_Y_ERROR
	cmp ax, cx
	jne CERRAR_Y_ERROR

	; Cerrar
	mov bx, [manejador]
	mov ah, 3Eh                    ; CLOSE
	int 21h
	jc  FATAL_ERROR

	; OK y salir
	lea dx, msgOk
	mov ah, 09h
	int 21h
	mov ax, 4C00h
	int 21h

CERRAR_Y_ERROR:
	; intentar cerrar si se abrio
	push ax
	mov bx, [manejador]
	mov ah, 3Eh
	int 21h
	pop ax

FATAL_ERROR:
	lea dx, msgError
	mov ah, 09h
	int 21h
	mov ax, 4C01h
	int 21h

