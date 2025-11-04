; IL358_A7_ROTR_D03.asm - Dibujar onda seno usando INT 10h (.COM)
; Autor: Rodrigo Samborms
; Fecha: 21 de Octubre, 2025

ORG 100h                              ; Programas .COM inician en 100h

; Saltar sobre datos
JMP INICIO

; ============================================================
; DATOS
; ============================================================
; Coordenadas precalculadas para onda seno (75 puntos)
; X: valores entre 0 y 250 (distribuidos aproximadamente)
; Y: 100 + amplitud*sin(x) donde amplitud = 50, centrado en Y=100

coordX db 0,3,7,10,14,17,20,24,27,30,34,37,41,44,47,51,54,57,61,64
    db 68,71,74,78,81,84,88,91,95,98,101,105,108,111,115,118,122,125,128,132
    db 135,139,142,145,149,152,155,159,162,166,169,172,176,179,182,186,189,193,196
    db 199,203,206,209,213,216,220,223,226,230,233,236,240,243,247,250

coordY db 100,104,108,113,117,121,124,128,131,135,138,140,143,145,146,148,149,150,150,150
    db 150,149,148,146,145,143,140,138,135,131,128,124,121,117,113,108,104,100,96,92
    db 87,83,79,76,72,69,65,62,60,57,55,54,52,51,50,50,50,50,51,52
    db 54,55,57,60,62,65,69,72,76,79,83,87,92,96,100

numPuntos EQU 75

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
