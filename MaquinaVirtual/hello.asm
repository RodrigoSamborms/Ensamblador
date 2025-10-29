; HOLA.ASM — Hola mundo para MSA (FreeDOS)
org 100h            ; programas .COM empiezan en 0100h

    mov dx, msg     ; DX -> cadena terminada en '$'
    mov ah, 09h     ; función 09h = imprimir cadena
    int 21h

    mov ax, 4C00h   ; terminar programa con código 00h
    int 21h

msg db 0Dh,0Ah, 'Hola, mundo desde MSA!', 0Dh,0Ah, '$'
