; Circulo_LookupTable.asm
; Dibuja un círculo usando tabla Look-Up de 360 valores (uno por grado)
; Pre-Calculada con la ecuación: x = r*cos(?), y = r*sin(?)
; Modo gráfico 13h: 320x200, 256 colores
; Autor: Rodrigo Torres Rivera
; Fecha: 2025-11-12

org 100h

jmp inicio

;=== DATOS ===
centro_x    dw 160          ; Centro X (mitad de 320)
centro_y    dw 100          ; Centro Y (mitad de 200)
radio       dw 80           ; Radio del círculo
color       db 15           ; Color blanco (0-255)

; Tabla Look-Up: 360 pares de valores (x_offset, y_offset)
; Cada entrada: WORD x_offset, WORD y_offset (relativos al centro)
; Total: 360 * 4 bytes = 1440 bytes
; Esta tabla será generada al inicio del programa
;tabla_circulo dw 720 dup(0)           ; 360 pares (x,y) inicializados en 0
; tabla precomputada para r=80 (x_offset,y_offset)
; generado automaticamente
tabla_circulo dw 80,0
   dw 80,-1,80,-3,80,-4,80,-6,80,-7,79,-8,79,-10,79,-11,79,-12,79,-14
   dw 78,-15,78,-17,78,-18,78,-19,77,-21,77,-22,77,-23,76,-25,76,-26,75,-28
   dw 75,-29,74,-30,74,-31,73,-32,72,-34,72,-35,71,-36,71,-38,70,-39,69,-40
   dw 68,-41,68,-42,67,-43,66,-45,66,-46,65,-47,64,-48,63,-49,62,-50,61,-52
   dw 60,-52,59,-53,58,-55,58,-56,57,-57,56,-58,55,-58,53,-59,52,-60,52,-61
   dw 50,-62,49,-63,48,-64,47,-65,46,-66,45,-66,43,-67,42,-68,41,-68,40,-69
   dw 39,-70,38,-71,36,-71,35,-72,34,-72,32,-73,31,-74,30,-74,29,-75,28,-75
   dw 26,-76,25,-76,23,-77,22,-77,21,-77,19,-78,18,-78,17,-78,15,-78,14,-79
   dw 12,-79,11,-79,10,-79,8,-79,7,-80,6,-80,4,-80,3,-80,1,-80,0,0
   dw -1,-80,-3,-80,-4,-80,-6,-80,-7,-80,-8,-79,-10,-79,-11,-79,-12,-79,-14,-79
   dw -15,-78,-17,-78,-18,-78,-19,-78,-21,-77,-22,-77,-23,-77,-25,-76,-26,-76,-28,-75
   dw -29,-75,-30,-74,-31,-74,-32,-73,-34,-72,-35,-72,-36,-71,-38,-71,-39,-70,-40,-69
   dw -41,-68,-42,-68,-43,-67,-45,-66,-46,-66,-47,-65,-48,-64,-49,-63,-50,-62,-52,-61
   dw -52,-60,-53,-59,-55,-58,-56,-58,-57,-57,-58,-56,-58,-55,-59,-53,-60,-52,-61,-52
   dw -62,-50,-63,-49,-64,-48,-65,-47,-66,-46,-66,-45,-67,-43,-68,-42,-68,-41,-69,-40
   dw -70,-39,-71,-38,-71,-36,-72,-35,-72,-34,-73,-32,-74,-31,-74,-30,-75,-29,-75,-28
   dw -76,-26,-76,-25,-77,-23,-77,-22,-77,-21,-78,-19,-78,-18,-78,-17,-78,-15,-79,-14
   dw -79,-12,-79,-11,-79,-10,-79,-8,-80,-7,-80,-6,-80,-4,-80,-3,-80,-1,-80,0
   dw -80,1,-80,3,-80,4,-80,6,-80,7,-79,8,-79,10,-79,11,-79,12,-79,14
   dw -78,15,-78,17,-78,18,-78,19,-77,21,-77,22,-77,23,-76,25,-76,26,-75,28
   dw -75,29,-74,30,-74,31,-73,32,-72,34,-72,35,-71,36,-71,38,-70,39,-69,40
   dw -68,41,-68,42,-67,43,-66,45,-66,46,-65,47,-64,48,-63,49,-62,50,-61,52
   dw -60,52,-59,53,-58,55,-58,56,-57,57,-56,58,-55,58,-53,59,-52,60,-52,61
   dw -50,62,-49,63,-48,64,-47,65,-46,66,-45,66,-43,67,-42,68,-41,68,-40,69
   dw -39,70,-38,71,-36,71,-35,72,-34,72,-32,73,-31,74,-30,74,-29,75,-28,75
   dw -26,76,-25,76,-23,77,-22,77,-21,77,-19,78,-18,78,-17,78,-15,78,-14,79
   dw -12,79,-11,79,-10,79,-8,79,-7,80,-6,80,-4,80,-3,80,-1,80,0,0
   dw 1,80,3,80,4,80,6,80,7,80,8,79,10,79,11,79,12,79,14,79
   dw 15,78,17,78,18,78,19,78,21,77,22,77,23,77,25,76,26,76,28,75
   dw 29,75,30,74,31,74,32,73,34,72,35,72,36,71,38,71,39,70,40,69
   dw 41,68,42,68,43,67,45,66,46,66,47,65,48,64,49,63,50,62,52,61
   dw 52,60,53,59,55,58,56,58,57,57,58,56,58,55,59,53,60,52,61,52
   dw 62,50,63,49,64,48,65,47,66,46,66,45,67,43,68,42,68,41,69,40
   dw 70,39,71,38,71,36,72,35,72,34,73,32,74,31,74,30,75,29,75,28
   dw 76,26,76,25,77,23,77,22,77,21,78,19,78,18,78,17,78,15,79,14
   dw 79,12,79,11,79,10,79,8,80,7,80,6,80,4,80,3,80,1

;=== SUBRUTINAS ===
;--- dibujar_pixel ---
; Dibuja un pixel en modo gráfico 13h
; Entrada: CX = X, DX = Y, AL = color
dibujar_pixel:
    push ax
    push bx
    
    ; Verificar límites (0-319, 0-199)
    cmp cx, 320
    jae .dp_fin
    cmp dx, 200
    jae .dp_fin
    
    ; INT 10h, AH=0Ch: escribir pixel
    mov ah, 0Ch
    xor bh, bh              ; Página 0
    int 10h
    
.dp_fin:
    pop bx
    pop ax
    ret

;--- dibujar_circulo ---
; Dibuja el círculo usando la tabla lookup
dibujar_circulo:
    push ax
    push bx
    push cx
    push dx
    push si
    
    xor bx, bx              ; BX = índice del ángulo (0-359)
    lea si, tabla_circulo   ; SI apunta a la tabla
    
.dc_bucle:
    ; Leer x_offset
    mov cx, [si]
    add si, 2
    
    ; Leer y_offset
    mov dx, [si]
    add si, 2
    
    ; Sumar centro
    add cx, [centro_x]
    add dx, [centro_y]
    
    ; Dibujar pixel
    mov al, [color]
    call dibujar_pixel
    
    ; Siguiente punto
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
    ; Establecer modo gráfico 13h (320x200, 256 colores)
    mov ah, 0
    mov al, 13h
    int 10h
    
    ; Dibujar círculo
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
