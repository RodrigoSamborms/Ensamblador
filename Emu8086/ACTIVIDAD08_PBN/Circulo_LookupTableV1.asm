; Circulo_LookupTable.asm
; Dibuja un círculo usando tabla Look-Up de 360 valores (uno por grado)
; Calculada con la ecuación: x = r*cos(θ), y = r*sin(θ)
; Modo gráfico 13h: 320x200, 256 colores
; Autor: [Tu nombre]
; Fecha: 2025-11-12

; Nota de uso (opcional):
; Si deseas evitar el cálculo en tiempo de ejecución, puedes usar una tabla
; precomputada. Genera/usa el archivo `Circulo_LookupTable_Datos.asm` y:
;   1) Sustituye la definición de `tabla_circulo` por:
;        include "Circulo_LookupTable_Datos.asm"
;   2) Comenta la llamada a `generar_tabla_circulo` en `inicio`.
; Esto dibuja el círculo directamente con la tabla ya calculada.

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
tabla_circulo dw 720 dup(0)           ; 360 pares (x,y) inicializados en 0

; Tabla de senos/cosenos aproximados para 0-89 grados (primer cuadrante)
; Multiplicados por 256 para mantener precisión (punto fijo 8.8)
; cos(θ) y sin(θ) * 256
tabla_sin dw 0,4,9,13,18,22,27,31,36,40,44,49,53,58,62,66
    dw 71,75,79,83,88,92,96,100,104,108,112,116,120,124,128,132
    dw 136,139,143,147,150,154,158,161,165,168,171,175,178,181,184,187
    dw 190,193,196,199,202,204,207,210,212,215,217,219,222,224,226,228
    dw 230,232,234,236,237,239,241,242,243,245,246,247,248,249,250,251
    dw 252,253,253,254,254,255,255,255,255,255

tabla_cos dw 256,256,256,255,255,255,254,254,253,253,252,251,250,249,248,247
    dw 246,245,243,242,241,239,237,236,234,232,230,228,226,224,222,219
    dw 217,215,212,210,207,204,202,199,196,193,190,187,184,181,178,175
    dw 171,168,165,161,158,154,150,147,143,139,136,132,128,124,120,116
    dw 112,108,104,100,96,92,88,83,79,75,71,66,62,58,53,49
    dw 44,40,36,31,27,22,18,13,9,4

;=== SUBRUTINAS ===

;--- obtener_sin ---
; Entrada: AX = ángulo en grados (0-359)
; Salida: AX = sin(θ) * 256 (con signo)
obtener_sin:
    push bx
    push dx
    
    ; Reducir a 0-359
    cmp ax, 360
    jb .sin_rango_ok
    xor dx, dx
    mov bx, 360
    div bx
    mov ax, dx              ; AX = ángulo mod 360
    
.sin_rango_ok:
    ; Determinar cuadrante y ajustar
    cmp ax, 90
    jb .sin_q1              ; 0-89: usar tabla directa
    cmp ax, 180
    jb .sin_q2              ; 90-179: sin(θ) = sin(180-θ)
    cmp ax, 270
    jb .sin_q3              ; 180-269: sin(θ) = -sin(θ-180)
    jmp .sin_q4             ; 270-359: sin(θ) = -sin(360-θ)
    
.sin_q1:
    ; 0-89: usar tabla directa
    mov bx, ax
    shl bx, 1               ; * 2 (cada entrada es WORD)
    mov ax, [tabla_sin + bx]
    jmp .sin_fin
    
.sin_q2:
    ; 90-179: sin(θ) = sin(180-θ)
    mov bx, 180
    sub bx, ax
    shl bx, 1
    mov ax, [tabla_sin + bx]
    jmp .sin_fin
    
.sin_q3:
    ; 180-269: sin(θ) = -sin(θ-180)
    sub ax, 180
    mov bx, ax
    shl bx, 1
    mov ax, [tabla_sin + bx]
    neg ax
    jmp .sin_fin
    
.sin_q4:
    ; 270-359: sin(θ) = -sin(360-θ)
    mov bx, 360
    sub bx, ax
    shl bx, 1
    mov ax, [tabla_sin + bx]
    neg ax
    
.sin_fin:
    pop dx
    pop bx
    ret

;--- obtener_cos ---
; Entrada: AX = ángulo en grados (0-359)
; Salida: AX = cos(θ) * 256 (con signo)
obtener_cos:
    push bx
    push dx
    
    ; Reducir a 0-359
    cmp ax, 360
    jb .cos_rango_ok
    xor dx, dx
    mov bx, 360
    div bx
    mov ax, dx
    
.cos_rango_ok:
    ; Determinar cuadrante
    cmp ax, 90
    jb .cos_q1              ; 0-89
    cmp ax, 180
    jb .cos_q2              ; 90-179
    cmp ax, 270
    jb .cos_q3              ; 180-269
    jmp .cos_q4             ; 270-359
    
.cos_q1:
    ; 0-89: usar tabla directa
    mov bx, ax
    shl bx, 1
    mov ax, [tabla_cos + bx]
    jmp .cos_fin
    
.cos_q2:
    ; 90-179: cos(θ) = -cos(180-θ)
    mov bx, 180
    sub bx, ax
    shl bx, 1
    mov ax, [tabla_cos + bx]
    neg ax
    jmp .cos_fin
    
.cos_q3:
    ; 180-269: cos(θ) = -cos(θ-180)
    sub ax, 180
    mov bx, ax
    shl bx, 1
    mov ax, [tabla_cos + bx]
    neg ax
    jmp .cos_fin
    
.cos_q4:
    ; 270-359: cos(θ) = cos(360-θ)
    mov bx, 360
    sub bx, ax
    shl bx, 1
    mov ax, [tabla_cos + bx]
    
.cos_fin:
    pop dx
    pop bx
    ret

;--- generar_tabla_circulo ---
; Genera los 360 puntos del círculo en la tabla lookup
; Usa la ecuación: x = r*cos(θ), y = r*sin(θ)
generar_tabla_circulo:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    xor cx, cx              ; CX = ángulo (0-359)
    lea di, tabla_circulo   ; DI apunta a la tabla
    
.gen_bucle:
    ; Calcular cos(θ)
    mov ax, cx
    call obtener_cos        ; AX = cos(θ) * 256
    
    ; Multiplicar por radio: (cos * radio) / 256
    imul [radio]            ; DX:AX = cos * radio * 256
    mov bx, 256
    idiv bx                 ; AX = (cos * radio * 256) / 256 = cos * radio
    
    ; Guardar x_offset
    mov [di], ax
    add di, 2
    
    ; Calcular sin(θ)
    mov ax, cx
    call obtener_sin        ; AX = sin(θ) * 256
    
    ; Multiplicar por radio
    imul [radio]
    mov bx, 256
    idiv bx
    
    ; Guardar y_offset (negado porque Y crece hacia abajo en pantalla)
    neg ax
    mov [di], ax
    add di, 2
    
    ; Siguiente ángulo
    inc cx
    cmp cx, 360
    jb .gen_bucle
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

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
    ; Generar tabla lookup
    call generar_tabla_circulo
    
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
