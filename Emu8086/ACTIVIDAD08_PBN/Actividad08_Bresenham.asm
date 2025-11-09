org 100h
jmp start

;============
; Constantes
;============
CENTERX  EQU 160        ; Centro X de la pantalla 320x200
CENTERY  EQU 100        ; Centro Y de la pantalla
RADIUS   EQU 60         ; Radio del círculo
COLOR    EQU 0Fh        ; Color blanco

;============
; Programa Principal
;============
start:
    ; Establecer modo de video 13h (320x200, 256 colores)
    mov ah, 0
    mov al, 13h
    int 10h

    ; Inicializar algoritmo de Bresenham para círculos
    ; Registros usados:
    ; SI = x (inicia en 0)
    ; DI = y (inicia en radius)
    ; BP = d (variable de decisión)
    
    xor si, si              ; SI = x = 0
    mov di, RADIUS          ; DI = y = radius
    
    ; d = 3 - 2*radius
    mov ax, RADIUS
    shl ax, 1               ; ax = 2*radius
    mov bp, 3
    sub bp, ax              ; BP = d = 3 - 2*radius

bresenham_loop:
    ; Verificar si x > y (condición de parada)
    cmp si, di
    jg bresenham_done

    ; Dibujar los 8 puntos simétricos
    call draw_8_points

    ; Actualizar d y coordenadas
    mov ax, bp
    cmp ax, 0
    jl update_d_negative

update_d_positive:
    ; d >= 0: d = d + 4*(x-y) + 10
    mov ax, si
    sub ax, di
    shl ax, 1
    shl ax, 1               ; ax = 4*(x-y)
    add ax, 10
    add bp, ax
    
    ; Decrementar y
    dec di
    
    ; Incrementar x
    inc si
    jmp bresenham_loop

update_d_negative:
    ; d < 0: d = d + 4*x + 6
    mov ax, si
    shl ax, 1
    shl ax, 1               ; ax = 4*x
    add ax, 6
    add bp, ax
    
    ; Incrementar x
    inc si
    jmp bresenham_loop

bresenham_done:
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
; Subrutina: Dibujar 8 puntos simétricos
;============
; Dibuja los 8 puntos de simetría del círculo
; Entrada: SI = x, DI = y
;============
draw_8_points:
    push ax
    push bx
    push cx
    push dx

    ; Punto 1: (cx+x, cy+y)
    mov ax, CENTERX
    add ax, si
    mov cx, ax
    mov ax, CENTERY
    add ax, di
    mov dx, ax
    call plot_pixel

    ; Punto 2: (cx-x, cy+y)
    mov ax, CENTERX
    sub ax, si
    mov cx, ax
    mov ax, CENTERY
    add ax, di
    mov dx, ax
    call plot_pixel

    ; Punto 3: (cx+x, cy-y)
    mov ax, CENTERX
    add ax, si
    mov cx, ax
    mov ax, CENTERY
    sub ax, di
    mov dx, ax
    call plot_pixel

    ; Punto 4: (cx-x, cy-y)
    mov ax, CENTERX
    sub ax, si
    mov cx, ax
    mov ax, CENTERY
    sub ax, di
    mov dx, ax
    call plot_pixel

    ; Punto 5: (cx+y, cy+x)
    mov ax, CENTERX
    add ax, di
    mov cx, ax
    mov ax, CENTERY
    add ax, si
    mov dx, ax
    call plot_pixel

    ; Punto 6: (cx-y, cy+x)
    mov ax, CENTERX
    sub ax, di
    mov cx, ax
    mov ax, CENTERY
    add ax, si
    mov dx, ax
    call plot_pixel

    ; Punto 7: (cx+y, cy-x)
    mov ax, CENTERX
    add ax, di
    mov cx, ax
    mov ax, CENTERY
    sub ax, si
    mov dx, ax
    call plot_pixel

    ; Punto 8: (cx-y, cy-x)
    mov ax, CENTERX
    sub ax, di
    mov cx, ax
    mov ax, CENTERY
    sub ax, si
    mov dx, ax
    call plot_pixel

    pop dx
    pop cx
    pop bx
    pop ax
    ret

;============
; Subrutina: Dibujar píxel
;============
; Entrada: CX = coordenada X, DX = coordenada Y
;============
plot_pixel:
    push ax
    push bx
    
    mov ah, 0Ch             ; INT 10h función 0Ch: escribir píxel
    mov al, COLOR
    xor bh, bh              ; página 0
    int 10h
    
    pop bx
    pop ax
    ret
