; Circulo_LookTable_Precalculada.asm
; Variante optimizada: no calcula nada en tiempo de ejecución.
; Usa una tabla precalculada de 360 pares (x_off, y_off) incluida desde Circulo_LUT80.inc
; Modo gráfico 13h: 320x200, 256 colores

org 100h

jmp inicio

;=== DATOS ===
centro_x    dw 160          ; Centro X (mitad de 320)
centro_y    dw 100          ; Centro Y (mitad de 200)
color       db 15           ; Color blanco (0-255)

; La tabla precalculada debe existir en este mismo directorio.
; El archivo Circulo_LUT80.inc define la etiqueta 'tabla_circulo' como:
;   tabla_circulo dw <x0>,<y0>,<x1>,<y1>,...,<x359>,<y359>
; Para generarla automáticamente, use el programa Generar_Circulo_LUT80.asm
include 'Circulo_LUT80.inc'

;=== SUBRUTINAS ===

;--- dibujar_pixel ---
; Entrada: CX = X, DX = Y, AL = color
dibujar_pixel:
    push ax
    push bx
    
    ; Verificar límites (0-319, 0-199)
    cmp cx, 320
    jae .dp_fin
    cmp dx, 200
    jae .dp_fin
    
    mov ah, 0Ch            ; INT 10h: escribir pixel
    xor bh, bh             ; Página 0
    int 10h
    
.dp_fin:
    pop bx
    pop ax
    ret

;--- dibujar_circulo ---
; Recorre tabla_circulo (360 pares) y dibuja los puntos relativos al centro
dibujar_circulo:
    push ax
    push bx
    push cx
    push dx
    push si
    
    xor bx, bx              ; contador de pares
    lea si, tabla_circulo
.dc_bucle:
    mov cx, [si]            ; x_offset
    add si, 2
    mov dx, [si]            ; y_offset
    add si, 2
    
    add cx, [centro_x]
    add dx, [centro_y]
    mov al, [color]
    call dibujar_pixel
    
    inc bx
    cmp bx, 360
    jb .dc_bucle
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

;=== PROGRAMA PRINCIPAL ===
inicio:
    ; Establecer modo gráfico 13h
    mov ah, 0
    mov al, 13h
    int 10h
    
    ; Dibujar círculo usando la tabla precalculada
    call dibujar_circulo
    
    ; Esperar tecla
    mov ah, 0
    int 16h
    
    ; Restaurar modo texto
    mov ah, 0
    mov al, 3
    int 10h
    
    ; Salir
    mov ax, 4C00h
    int 21h

ret
