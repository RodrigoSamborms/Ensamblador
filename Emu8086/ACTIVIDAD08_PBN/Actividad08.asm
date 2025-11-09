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
; Tablas Lookup para Semicírculo Superior
;============
; Coordenadas X relativas al centro (offsets desde CENTERX)
coordX_top:
    dw 60,60,60,60,59,59,59,59,58,58,58,58,57,57,57,56,56,56,55,55
    dw 55,54,54,54,53,53,52,52,51,51,51,50,50,49,49,48,48,47,47,46
    dw 46,45,45,44,44,43,43,42,41,41,40,40,39,39,38,38,37,36,36,35
    dw 35,34,34,33,32,32,31,31,30,29,29,28,28,27,26,26,25,25,24,23
    dw 23,22,22,21,20,20,19,19,18,17,17,16,16,15,14,14,13,13,12,11
    dw 11,10,10,9,8,8,7,7,6,5,5,4,4,3,2,2,1,1,0,0
    dw -1,-1,-2,-2,-3,-4,-4,-5,-5,-6,-7,-7,-8,-8,-9,-10,-10,-11,-11,-12
    dw -13,-13,-14,-14,-15,-16,-16,-17,-17,-18,-19,-19,-20,-20,-21,-22,-22,-23,-23,-24
    dw -25,-25,-26,-26,-27,-28,-28,-29,-29,-30,-31,-31,-32,-32,-33,-34,-34,-35,-35,-36
    dw -36,-37,-38,-38,-39,-39,-40,-40,-41,-41,-42,-43,-43,-44,-44,-45,-45,-46,-46,-47
    dw -47,-48,-48,-49,-49,-50,-50,-51,-51,-51,-52,-52,-53,-53,-54,-54,-54,-55,-55,-55
    dw -56,-56,-56,-57,-57,-57,-58,-58,-58,-58,-59,-59,-59,-59,-60,-60,-60,-60

; Coordenadas Y relativas al centro (offsets desde CENTERY, negativos = arriba)
coordY_top:
    dw 0,0,-1,-1,-2,-2,-3,-4,-4,-5,-5,-6,-7,-7,-8,-8,-9,-10,-10,-11
    dw -11,-12,-13,-13,-14,-14,-15,-16,-16,-17,-17,-18,-19,-19,-20,-20,-21,-22,-22,-23
    dw -23,-24,-25,-25,-26,-26,-27,-28,-28,-29,-29,-30,-31,-31,-32,-32,-33,-34,-34,-35
    dw -35,-36,-36,-37,-38,-38,-39,-39,-40,-40,-41,-41,-42,-43,-43,-44,-44,-45,-45,-46
    dw -46,-47,-47,-48,-48,-49,-49,-50,-50,-51,-51,-51,-52,-52,-53,-53,-54,-54,-54,-55
    dw -55,-55,-56,-56,-56,-57,-57,-57,-58,-58,-58,-58,-59,-59,-59,-59,-60,-60,-60,-60
    dw -60,-60,-60,-60,-59,-59,-59,-59,-58,-58,-58,-58,-57,-57,-57,-56,-56,-56,-55,-55
    dw -55,-54,-54,-54,-53,-53,-52,-52,-51,-51,-51,-50,-50,-49,-49,-48,-48,-47,-47,-46
    dw -46,-45,-45,-44,-44,-43,-43,-42,-41,-41,-40,-40,-39,-39,-38,-38,-37,-36,-36,-35
    dw -35,-34,-34,-33,-32,-32,-31,-31,-30,-29,-29,-28,-28,-27,-26,-26,-25,-25,-24,-23
    dw -23,-22,-22,-21,-20,-20,-19,-19,-18,-17,-17,-16,-16,-15,-14,-14,-13,-13,-12,-11
    dw -11,-10,-10,-9,-8,-8,-7,-7,-6,-5,-5,-4,-4,-3,-2,-2,-1,-1,0

NUM_POINTS_TOP EQU 238   ; Número de puntos en semicírculo superior

;============
; Tablas Lookup para Semicírculo Inferior
;============
; Coordenadas X (de izquierda a derecha)
coordX_bot:
    dw -60,-60,-60,-60,-59,-59,-59,-59,-58,-58,-58,-58,-57,-57,-57,-56,-56,-56,-55,-55
    dw -55,-54,-54,-54,-53,-53,-52,-52,-51,-51,-51,-50,-50,-49,-49,-48,-48,-47,-47,-46
    dw -46,-45,-45,-44,-44,-43,-43,-42,-41,-41,-40,-40,-39,-39,-38,-38,-37,-36,-36,-35
    dw -35,-34,-34,-33,-32,-32,-31,-31,-30,-29,-29,-28,-28,-27,-26,-26,-25,-25,-24,-23
    dw -23,-22,-22,-21,-20,-20,-19,-19,-18,-17,-17,-16,-16,-15,-14,-14,-13,-13,-12,-11
    dw -11,-10,-10,-9,-8,-8,-7,-7,-6,-5,-5,-4,-4,-3,-2,-2,-1,-1,0,0
    dw 1,1,2,2,3,4,4,5,5,6,7,7,8,8,9,10,10,11,11,12
    dw 13,13,14,14,15,16,16,17,17,18,19,19,20,20,21,22,22,23,23,24
    dw 25,25,26,26,27,28,28,29,29,30,31,31,32,32,33,34,34,35,35,36
    dw 36,37,38,38,39,39,40,40,41,41,42,43,43,44,44,45,45,46,46,47
    dw 47,48,48,49,49,50,50,51,51,51,52,52,53,53,54,54,54,55,55,55
    dw 56,56,56,57,57,57,58,58,58,58,59,59,59,59,60,60,60,60

; Coordenadas Y (positivos = abajo)
coordY_bot:
    dw 0,0,1,1,2,2,3,4,4,5,5,6,7,7,8,8,9,10,10,11
    dw 11,12,13,13,14,14,15,16,16,17,17,18,19,19,20,20,21,22,22,23
    dw 23,24,25,25,26,26,27,28,28,29,29,30,31,31,32,32,33,34,34,35
    dw 35,36,36,37,38,38,39,39,40,40,41,41,42,43,43,44,44,45,45,46
    dw 46,47,47,48,48,49,49,50,50,51,51,51,52,52,53,53,54,54,54,55
    dw 55,55,56,56,56,57,57,57,58,58,58,58,59,59,59,59,60,60,60,60
    dw 60,60,60,60,59,59,59,59,58,58,58,58,57,57,57,56,56,56,55,55
    dw 55,54,54,54,53,53,52,52,51,51,51,50,50,49,49,48,48,47,47,46
    dw 46,45,45,44,44,43,43,42,41,41,40,40,39,39,38,38,37,36,36,35
    dw 35,34,34,33,32,32,31,31,30,29,29,28,28,27,26,26,25,25,24,23
    dw 23,22,22,21,20,20,19,19,18,17,17,16,16,15,14,14,13,13,12,11
    dw 11,10,10,9,8,8,7,7,6,5,5,4,4,3,2,2,1,1,0

NUM_POINTS_BOT EQU 238   ; Número de puntos en semicírculo inferior

;============
; Programa Principal
;============
start:
    ; Establecer modo de video 13h (320x200, 256 colores)
    mov ah, 0
    mov al, 13h
    int 10h

    ; Dibujar semicírculo superior
    xor si, si              ; índice = 0

draw_top_loop:
    cmp si, NUM_POINTS_TOP
    jge draw_bottom_setup   ; si terminamos, pasar al semicírculo inferior

    ; Obtener coordenada X relativa
    lea bx, coordX_top
    shl si, 1               ; multiplicar índice por 2 (words)
    add bx, si
    mov ax, [bx]            ; AX = offset X
    shr si, 1               ; restaurar índice

    ; Calcular X absoluta = CENTERX + offset
    add ax, CENTERX
    mov cx, ax              ; CX = coordenada X absoluta

    ; Obtener coordenada Y relativa
    lea bx, coordY_top
    shl si, 1
    add bx, si
    mov ax, [bx]            ; AX = offset Y
    shr si, 1

    ; Calcular Y absoluta = CENTERY + offset
    add ax, CENTERY
    mov dx, ax              ; DX = coordenada Y absoluta

    ; Dibujar píxel
    mov ah, 0Ch             ; INT 10h función 0Ch: escribir píxel
    mov al, COLOR
    xor bh, bh              ; página 0
    int 10h

    inc si
    jmp draw_top_loop

draw_bottom_setup:
    xor si, si              ; reiniciar índice

draw_bot_loop:
    cmp si, NUM_POINTS_BOT
    jge draw_done

    ; Obtener coordenada X relativa
    lea bx, coordX_bot
    shl si, 1
    add bx, si
    mov ax, [bx]
    shr si, 1

    ; Calcular X absoluta
    add ax, CENTERX
    mov cx, ax

    ; Obtener coordenada Y relativa
    lea bx, coordY_bot
    shl si, 1
    add bx, si
    mov ax, [bx]
    shr si, 1

    ; Calcular Y absoluta
    add ax, CENTERY
    mov dx, ax

    ; Dibujar píxel
    mov ah, 0Ch
    mov al, COLOR
    xor bh, bh
    int 10h

    inc si
    jmp draw_bot_loop

draw_done:
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