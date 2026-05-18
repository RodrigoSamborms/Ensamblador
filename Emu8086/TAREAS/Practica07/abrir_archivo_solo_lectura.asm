include 'emu8086.inc'
org 100h
jmp inicio

mensaje_titulo      db 'Abrir archivo en modo solo lectura', 13, 10, 0
mensaje_pedir       db 'Escribe el nombre del archivo: ', 0
mensaje_ok_abrir    db 13, 10, 'Archivo abierto correctamente.', 13, 10, 0
mensaje_ok_cerrar   db 'Archivo cerrado correctamente.', 13, 10, 0
mensaje_err_abrir   db 13, 10, 'Error: no se pudo abrir el archivo.', 13, 10, 0
mensaje_err_cerrar  db 'Error: no se pudo cerrar el archivo.', 13, 10, 0
mensaje_fin         db 13, 10, 'Fin del programa.', 13, 10, 0

nombre_archivo      db 64 dup(0)
handle_archivo      dw 0

DEFINE_PRINT_STRING
DEFINE_GET_STRING

inicio:
    lea si, mensaje_titulo
    call print_string

    lea si, mensaje_pedir
    call print_string

    lea di, nombre_archivo
    mov dx, 63
    call get_string

    cmp byte ptr [nombre_archivo], 0
    je fin_programa

    ; Abrir archivo existente en modo solo lectura.
    mov ah, 3Dh
    mov al, 0
    lea dx, nombre_archivo
    int 21h
    jc error_abrir

    mov [handle_archivo], ax
    lea si, mensaje_ok_abrir
    call print_string

    ; Cerrar archivo abierto.
    mov ah, 3Eh
    mov bx, [handle_archivo]
    int 21h
    jc error_cerrar

    lea si, mensaje_ok_cerrar
    call print_string
    jmp fin_programa

error_abrir:
    lea si, mensaje_err_abrir
    call print_string
    jmp fin_programa

error_cerrar:
    lea si, mensaje_err_cerrar
    call print_string

fin_programa:
    lea si, mensaje_fin
    call print_string

    mov ax, 4C00h
    int 21h
