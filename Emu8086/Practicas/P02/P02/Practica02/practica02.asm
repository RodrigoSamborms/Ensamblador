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
mov dl, 7
mov dh, 13
mov bp, offset msg2
mov ah, 13h
int 10h

mov dx, 17B0h     ; 16 bits mas significativos del codigo de alumno (397423431 -> 17B0 3347H -> 17B0h)
mov cx, 3347h     ; 16 bits menos significativos del codigo de alumno (397423431 -> 17B0 3347H -> 3347h)

mov bx, 1499h      ; 16 bits mas significativos del NRC del curso (84374 -> 1 4996H -> 1 499h)
mov ax, 4996h      ; 16 bits menos significativos del NRC del curso (84374 -> 1 4996H-> 4996h)



; Ajustar el registro SP para que tenga el valor FFF8
;mov sp, 0FFF8h

; Finalizar el programa con int 0x20
int 20h

msg1    db "Rodrigo Torres Rivera"
msg2    db "Codigo del alumno: 397423431, NRC del curso: 84374"

msgend:
mov ah,0
int 16h
int 20h

