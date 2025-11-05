name "PRACTICA06"
include 'emu8086.inc'

org 100h

; Programa .COM: pide un numero hexadecimal (hasta 4 cifras), lo convierte y muestra decimal
start:
    push cs
    pop ds

    ; Mensaje prompt
    lea si, msg_prompt
    call print_string
    call print_nl

    ; Leer cadena hex (max 4 chars + CR)
    lea di, buffer
    mov dx, tammax
    call get_string

    ; Convertir ASCII hex a valor (AX)
    lea si, buffer
    mov cx, tammax
    call HexStringToAX

    ; Convertir AX a BCD8421 almacenado en ConvBCD (cada byte = digit 0..9)
    push ax
    call AX_to_BCD_array
    pop ax

    ; Convertir AX a cadena decimal en dec_buf y mostrarla
    call AX_to_decimal_string ; resultado en SI -> cadena terminada en 0
    call print_string
    call print_nl

    ; Salir limpio
    mov ax, 4C00h
    int 21h

; Datos
msg_prompt db 'Ingrese numero HEX (hasta 4 digitos): ',0
tammax   equ 5            ; permitir hasta 4 caracteres + terminador
buffer   db tammax dup(?) ; buffer para get_string
dec_buf  db '00000',0    ; 5 digitos + terminador

ConvBCD  db tammax dup(?) ; BCD 8421: cada byte contiene un digito 0..9

; Rutinas auxiliares proporcionadas por include
DEFINE_GET_STRING
DEFINE_PRINT_STRING
DEFINE_PRINT_NL

; --------------------------------------------------
; HexStringToAX: convierte cadena ASCII hex a valor en AX
; espera SI=offset buffer, CX=numero max/caracteres
; detiene al encontrar byte 0
HexStringToAX:
    push bx
    push si
    push cx

    xor ax, ax        ; accumulator
    xor bx, bx        ; temp for nibble

Hex_loop2:
    cmp cx, 0
    je Hex_done2
    mov al, [si]
    cmp al, 0
    je Hex_done2
    ; Convert ASCII to nibble in BL
    mov bl, al
    cmp bl, '0'
    jb Hex_bad2
    cmp bl, '9'
    jle Hex_digit2
    cmp bl, 'A'
    jb Hex_check_lower2
    cmp bl, 'F'
    jle Hex_upper2
    jmp Hex_bad2

Hex_check_lower2:
    cmp bl, 'a'
    jb Hex_bad2
    cmp bl, 'f'
    ja Hex_bad2
    sub bl, 'a'
    add bl, 10
    jmp Hex_store2

Hex_upper2:
    sub bl, 'A'
    add bl, 10
    jmp Hex_store2

Hex_digit2:
    sub bl, '0'

Hex_store2:
    ; shift AX left 4 bits (multiply by 16)
    shl ax, 4
    ; add nibble (BL) to AX
    add ax, bx
    inc si
    dec cx
    jmp Hex_loop2

Hex_bad2:
    ; treat invalid char as 0
    shl ax, 4
    add ax, 0
    inc si
    dec cx
    jmp Hex_loop2

Hex_done2:
    pop cx
    pop si
    pop bx
    ret

; --------------------------------------------------
; AX_to_decimal_string: convierte AX a cadena decimal ASCII terminada en 0
; Resultado: SI apunta al inicio de la cadena (para usar con print_string)
AX_to_decimal_string:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    lea di, dec_buf
    ; asegurar terminador
    mov byte [di+5], 0
    lea di, [di+4]    ; posición del último dígito

    cmp ax, 0
    jne ax_not_zero2
    mov byte [di], '0'
    lea si, dec_buf
    ; restaurar y salir
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

ax_not_zero2:
    ; generar dígitos en reversa
    xor cx, cx
ax_div_loop2:
    mov bx, 10
    xor dx, dx
    div bx        ; AX = AX/10, DX = remainder
    add dl, '0'
    mov [di], dl
    dec di
    inc cx
    cmp ax, 0
    jne ax_div_loop2

    lea si, [di+1]
    ; restaurar
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; --------------------------------------------------
; AX_to_BCD_array: convierte AX a 5 digitos BCD (8421) almacenados en ConvBCD
; Entrada: AX = valor
; Salida : ConvBCD[0..4] contienen digitos (0..9)
AX_to_BCD_array:
    push ax
    push bx
    push cx
    push dx
    push di

    lea di, ConvBCD
    lea di, [di+4]    ; empezar desde el ultimo digito
    mov cx, 5
ax2bcd_loop:
    mov bx, 10
    xor dx, dx
    div bx        ; AX = AX/10, DX = remainder
    mov [di], dl  ; almacenar digito (0..9)
    dec di
    dec cx
    cmp cx, 0
    jne ax2bcd_loop

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
*** End Of File