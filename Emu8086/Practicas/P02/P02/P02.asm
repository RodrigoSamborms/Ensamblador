name "practica02"

; este programa imprime dos mensajes en la pantalla
; escribiendo directamente en la memoria de video.
; en la memoria vga: el primer byte es el caracter ascii,
; el siguiente byte son los atributos del caracter.
; los atributos del caracter es un valor de 8 bits,
; los 4 bits altos ponen el color del fondo
; y los 4 bits bajos ponen el color de la letra.

; hex    bin        color
; 
; 0      0000      black
; 1      0001      blue
; 2      0010      green
; 3      0011      cyan
; 4      0100      red
; 5      0101      magenta
; 6      0110      brown
; 7      0111      light gray
; 8      1000      dark gray
; 9      1001      light blue
; a      1010      light green
; b      1011      light cyan
; c      1100      light red
; d      1101      light magenta
; e      1110      yellow
; f      1111      white

org 100h

    ; Guardar los datos en los registros de proposito general
    mov dx, 2175h      ; 16 bits mas significativos del codigo de alumno (217527185 -> 2175)
    mov cx, 7185h     ; 16 bits menos significativos del codigo de alumno (217527185 -> 7185)

    mov bx, 0001h      ; 16 bits mas significativos del NRC del curso (84374 -> 0001)
    mov ax, 4936h      ; 16 bits menos significativos del NRC del curso (84374 -> 4936)
    

    ; Mostrar en pantalla los datos del alumno
    mov al, 1
    mov bh, 0
    mov bl, 0001_1111b  ; color del texto blanco, fondo negro
    mov cx, msg2 - offset msg1  ; tamano del mensaje 1
    mov dl, 7
    mov dh, 11
    push cs
    pop es
    mov bp, offset msg1
    mov ah, 13h
    int 10h

    mov cx, msgend - offset msg2  ; tamano del mensaje 2
    mov dl, 36
    mov dh, 13
    mov bp, offset msg2
    mov ah, 13h
    int 10h

    ; Ajustar el registro SP para que tenga el valor FFF8
    mov sp, 0FFF8h

    ; Finalizar el programa con int 0x20
    int 20h

msg1    db "Christopher Lopez Avina"
msg2    db "Codigo del alumno: 217527185, NRC del curso: 84374"

msgend:
        mov ah,0
        int 16h
        int 20h