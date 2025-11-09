org 100h
jmp start

;============
; Constantes
;============
CENTERX  EQU 160        ; Centro X de la pantalla 320x200
CENTERY  EQU 100        ; Centro Y de la pantalla
RADIUS   EQU 60         ; Radio del círculo
COLOR    EQU 0Fh        ; Color blanco
MAX_POINTS EQU 500      ; Máximo de puntos para la tabla

;============
; Tablas Lookup (generadas dinámicamente)
;============
tabla_x  dw MAX_POINTS dup(?)   ; Coordenadas X absolutas
tabla_y  dw MAX_POINTS dup(?)   ; Coordenadas Y absolutas
num_puntos dw ?                  ; Número total de puntos generados

;============
; Programa Principal
;============
start:
    ; Generar la tabla lookup usando Bresenham
    call generar_tabla_bresenham
    
    ; Establecer modo de video 13h (320x200, 256 colores)
    mov ah, 0
    mov al, 13h
    int 10h

    ; Dibujar el círculo usando la tabla lookup
    call dibujar_desde_tabla

    ; Esperar tecla
    mov ah, 0
    int 16h

    ; Restaurar modo texto
    mov ax, 0003h
    int 10h

    ; Salir
    mov ax, 4C00h
    int 21h
    ret

;============
; Subrutina: Generar tabla lookup con Bresenham
;============
generar_tabla_bresenham:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    
    ; Inicializar algoritmo de Bresenham
    xor si, si              ; SI = x = 0
    mov di, RADIUS          ; DI = y = radius
    
    ; d = 3 - 2*radius
    mov ax, RADIUS
    shl ax, 1
    mov bp, 3
    sub bp, ax              ; BP = d
    
    ; BX = índice en la tabla (contador de puntos)
    xor bx, bx

gen_loop:
    ; Verificar si x > y
    cmp si, di
    jg gen_done

    ; Guardar los 8 puntos simétricos en la tabla
    call guardar_8_puntos
    
    ; Actualizar d y coordenadas
    mov ax, bp
    cmp ax, 0
    jl gen_d_negative

gen_d_positive:
    ; d >= 0: d = d + 4*(x-y) + 10
    mov ax, si
    sub ax, di
    shl ax, 1
    shl ax, 1
    add ax, 10
    add bp, ax
    dec di
    inc si
    jmp gen_loop

gen_d_negative:
    ; d < 0: d = d + 4*x + 6
    mov ax, si
    shl ax, 1
    shl ax, 1
    add ax, 6
    add bp, ax
    inc si
    jmp gen_loop

gen_done:
    ; Guardar el número total de puntos
    mov [num_puntos], bx
    
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

;============
; Subrutina: Guardar 8 puntos simétricos en la tabla
;============
; Entrada: SI = x, DI = y, BX = índice actual
; Salida: BX = índice actualizado
;============
guardar_8_puntos:
    push ax
    push cx
    push dx
    
    ; Punto 1: (cx+x, cy+y)
    mov ax, CENTERX
    add ax, si
    mov cx, ax
    mov ax, CENTERY
    add ax, di
    mov dx, ax
    call agregar_punto_tabla
    
    ; Punto 2: (cx-x, cy+y)
    mov ax, CENTERX
    sub ax, si
    mov cx, ax
    mov ax, CENTERY
    add ax, di
    mov dx, ax
    call agregar_punto_tabla
    
    ; Punto 3: (cx+x, cy-y)
    mov ax, CENTERX
    add ax, si
    mov cx, ax
    mov ax, CENTERY
    sub ax, di
    mov dx, ax
    call agregar_punto_tabla
    
    ; Punto 4: (cx-x, cy-y)
    mov ax, CENTERX
    sub ax, si
    mov cx, ax
    mov ax, CENTERY
    sub ax, di
    mov dx, ax
    call agregar_punto_tabla
    
    ; Punto 5: (cx+y, cy+x)
    mov ax, CENTERX
    add ax, di
    mov cx, ax
    mov ax, CENTERY
    add ax, si
    mov dx, ax
    call agregar_punto_tabla
    
    ; Punto 6: (cx-y, cy+x)
    mov ax, CENTERX
    sub ax, di
    mov cx, ax
    mov ax, CENTERY
    add ax, si
    mov dx, ax
    call agregar_punto_tabla
    
    ; Punto 7: (cx+y, cy-x)
    mov ax, CENTERX
    add ax, di
    mov cx, ax
    mov ax, CENTERY
    sub ax, si
    mov dx, ax
    call agregar_punto_tabla
    
    ; Punto 8: (cx-y, cy-x)
    mov ax, CENTERX
    sub ax, di
    mov cx, ax
    mov ax, CENTERY
    sub ax, si
    mov dx, ax
    call agregar_punto_tabla
    
    pop dx
    pop cx
    pop ax
    ret

;============
; Subrutina: Agregar punto a la tabla
;============
; Entrada: CX = X, DX = Y, BX = índice
; Salida: BX = índice + 1
;============
agregar_punto_tabla:
    push ax
    push di
    
    ; Calcular offset en tabla_x (BX * 2 porque son words)
    mov di, bx
    shl di, 1
    
    ; Guardar X
    lea ax, [tabla_x]
    add di, ax
    mov [di], cx
    
    ; Calcular offset en tabla_y
    mov di, bx
    shl di, 1
    lea ax, [tabla_y]
    add di, ax
    mov [di], dx
    
    ; Incrementar índice
    inc bx
    
    pop di
    pop ax
    ret

;============
; Subrutina: Dibujar círculo desde tabla lookup
;============
dibujar_desde_tabla:
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; SI = índice del punto actual
    xor si, si

dibujar_loop:
    ; Verificar si terminamos
    cmp si, [num_puntos]
    jge dibujar_fin
    
    ; Calcular offset (SI * 2 porque son words)
    mov bx, si
    shl bx, 1
    
    ; Leer coordenada X
    lea ax, [tabla_x]
    add bx, ax
    mov cx, [bx]
    
    ; Calcular offset para Y
    mov bx, si
    shl bx, 1
    lea ax, [tabla_y]
    add bx, ax
    mov dx, [bx]
    
    ; Dibujar píxel
    mov ah, 0Ch
    mov al, COLOR
    xor bh, bh
    int 10h
    
    ; Siguiente punto
    inc si
    jmp dibujar_loop

dibujar_fin:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
