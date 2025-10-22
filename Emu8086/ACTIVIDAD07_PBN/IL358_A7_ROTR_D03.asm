; IL358_A7_ROTR_D03.asm - Dibujar onda seno usando INT 10h (.COM)
; Autor: Rodrigo Samborms
; Fecha: 21 de Octubre, 2025

ORG 100h                              ; Programas .COM inician en 100h

; Saltar sobre datos
JMP INICIO

; ============================================================
; DATOS
; ============================================================
; Coordenadas precalculadas para onda seno (50 puntos)
; X: 0 a 255 (distribuidos uniformemente)
; Y: 100 + amplitud*sin(x) donde amplitud = 50, centrado en Y=100

coordX db 0,5,10,15,20,26,31,36,41,46,51,56,61,66,71,77,82,87,92,97
       db 102,107,112,117,122,128,133,138,143,148,153,158,163,168,173,179,184,189,194,199
       db 204,209,214,219,224,230,235,240,245,250

coordY db 100,106,112,118,124,129,134,139,143,147,150,153,155,157,158,159,159,158,157,155
       db 153,150,147,143,139,134,129,124,118,112,106,100,94,88,82,76,71,66,61,57
       db 53,50,47,45,43,42,41,41,42,43

numPuntos EQU 50

msgEncabezado db 'Dibujando onda seno con INT 10h', 0Dh, 0Ah
              db 'Presiona cualquier tecla para salir...', 0Dh, 0Ah, '$'

; ============================================================
; CODIGO
; ============================================================
INICIO:
    ; Modelo .COM: DS = CS
    push cs
    pop ds

    ; Mostrar mensaje
    lea dx, msgEncabezado
    mov ah, 09h
    int 21h

    ; Establecer modo video 320x200 256 colores (modo 13h)
    mov ax, 0013h
    int 10h

    ; Dibujar la onda seno punto por punto
    xor si, si                     ; indice = 0
    
DIBUJAR_LOOP:
    cmp si, numPuntos
    jge DIBUJAR_FIN
    
    ; Obtener coordenadas del punto actual
    lea bx, coordX
    add bx, si
    mov al, [bx]                   ; AL = coordenada X
    xor ah, ah
    mov dx, ax                     ; DX = X (columna)
    
    lea bx, coordY
    add bx, si
    mov al, [bx]                   ; AL = coordenada Y
    xor ah, ah
    mov cx, dx                     ; CX = X (columna)
    mov dx, ax                     ; DX = Y (fila)
    
    ; Dibujar pixel en (CX, DX) con color blanco (0Fh)
    mov ah, 0Ch                    ; INT 10h, AH=0Ch: Write Graphics Pixel
    mov al, 0Fh                    ; Color blanco brillante
    xor bh, bh                     ; Pagina 0
    int 10h
    
    inc si
    jmp DIBUJAR_LOOP

DIBUJAR_FIN:
    ; Esperar tecla
    mov ah, 00h                    ; INT 16h, AH=00h: esperar tecla
    int 16h
    
    ; Restaurar modo texto 80x25 (modo 03h)
    mov ax, 0003h
    int 10h
    
    ; Mensaje de salida
    lea dx, msgSalida
    mov ah, 09h
    int 21h
    
    ; Terminar programa
    mov ax, 4C00h
    int 21h

msgSalida db 'Programa terminado.', 0Dh, 0Ah, '$'
