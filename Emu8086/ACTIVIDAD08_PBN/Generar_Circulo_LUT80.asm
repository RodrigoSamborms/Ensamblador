; Generar_Circulo_LUT80.asm
; Genera la tabla precalculada de 360 pares (x_off,y_off) para radio=80
; y la escribe en el archivo de texto 'Circulo_LUT80.inc' lista para incluirse.
; Formato de salida:
;   tabla_circulo dw x0,y0,x1,y1,...,x359,y359
;
; Puede ajustarse el radio cambiando la constante R.

org 100h

jmp start

; Constantes
R           dw 80
CRLF        db 13,10
SEP_COMA    db ','
SEP_ESP     db ' '
HEADER      db 'tabla_circulo dw ',0
FNAME       db 'Circulo_LUT80.inc',0

; Buffers
num_buf     db 7 dup(0)     ; buffer para numero con signo (-32768..32767) + 0
sin_tab     dw 0,4,9,13,18,22,27,31,36,40,44,49,53,58,62,66
            dw 71,75,79,83,88,92,96,100,104,108,112,116,120,124,128,132
            dw 136,139,143,147,150,154,158,161,165,168,171,175,178,181,184,187
            dw 190,193,196,199,202,204,207,210,212,215,217,219,222,224,226,228
            dw 230,232,234,236,237,239,241,242,243,245,246,247,248,249,250,251
            dw 252,253,253,254,254,255,255,255,255,255
cos_tab     dw 256,256,256,255,255,255,254,254,253,253,252,251,250,249,248,247
            dw 246,245,243,242,241,239,237,236,234,232,230,228,226,224,222,219
            dw 217,215,212,210,207,204,202,199,196,193,190,187,184,181,178,175
            dw 171,168,165,161,158,154,150,147,143,139,136,132,128,124,120,116
            dw 112,108,104,100,96,92,88,83,79,75,71,66,62,58,53,49
            dw 44,40,36,31,27,22,18,13,9,4

handle      dw 0

; Prototipos
; obtener_sin / obtener_cos devuelven valor *256 en AX para 0..359
; (mismas rutinas del programa educativo)

; ---- Rutinas trig (cuadrantes) ----
obtener_sin:
    push bx
    push dx
    cmp ax,360
    jb .ok
    xor dx,dx
    mov bx,360
    div bx
    mov ax,dx
.ok:
    cmp ax,90
    jb .q1
    cmp ax,180
    jb .q2
    cmp ax,270
    jb .q3
    jmp .q4
.q1:
    mov bx,ax
    shl bx,1
    mov ax,[sin_tab+bx]
    jmp .fin
.q2:
    mov bx,180
    sub bx,ax
    shl bx,1
    mov ax,[sin_tab+bx]
    jmp .fin
.q3:
    sub ax,180
    mov bx,ax
    shl bx,1
    mov ax,[sin_tab+bx]
    neg ax
    jmp .fin
.q4:
    mov bx,360
    sub bx,ax
    shl bx,1
    mov ax,[sin_tab+bx]
    neg ax
.fin:
    pop dx
    pop bx
    ret

obtener_cos:
    push bx
    push dx
    cmp ax,360
    jb .ok
    xor dx,dx
    mov bx,360
    div bx
    mov ax,dx
.ok:
    cmp ax,90
    jb .q1
    cmp ax,180
    jb .q2
    cmp ax,270
    jb .q3
    jmp .q4
.q1:
    mov bx,ax
    shl bx,1
    mov ax,[cos_tab+bx]
    jmp .fin
.q2:
    mov bx,180
    sub bx,ax
    shl bx,1
    mov ax,[cos_tab+bx]
    neg ax
    jmp .fin
.q3:
    sub ax,180
    mov bx,ax
    shl bx,1
    mov ax,[cos_tab+bx]
    neg ax
    jmp .fin
.q4:
    mov bx,360
    sub bx,ax
    shl bx,1
    mov ax,[cos_tab+bx]
.fin:
    pop dx
    pop bx
    ret

; ---- conversión número con signo en AX -> num_buf terminado en 0 ----
; Devuelve SI apuntando al inicio del string
itoa_signed:
    push ax
    push bx
    push cx
    push dx
    mov bx,10
    mov cx,0
    mov dx,0
    cmp ax,0
    jge .pos
    neg ax
    mov dl,'-'
.pos:
    ; convertir valor absoluto en pila
    mov cx,0
.conv_loop:
    xor dx,dx
    div bx        ; AX/10, resto en DX
    push dx       ; guardar dígito
    inc cx
    cmp ax,0
    jne .conv_loop
    ; escribir signo si era negativo
    lea si,num_buf
    cmp dl,'-'
    jne .write_digits
    mov byte ptr [si],'-'
    inc si
.write_digits:
    ; sacar dígitos en orden
.wd_loop:
    pop dx
    add dl,'0'
    mov [si],dl
    inc si
    loop .wd_loop
    mov byte ptr [si],0
    ; reposicionar SI al inicio real
    lea si,num_buf
    ret

; ---- escribir string 0-terminado al archivo ----
write_str:
    push ax
    push cx
    push dx
    mov ah,40h
    mov bx,[handle]
    ; calcular longitud
    push si
    mov cx,0
.len_loop:
    mov al,[si]
    cmp al,0
    je .len_done
    inc si
    inc cx
    jmp .len_loop
.len_done:
    pop si
    mov dx,si
    int 21h
    pop dx
    pop cx
    pop ax
    ret

; ---- escribir caracter en DL ----
write_ch:
    push ax
    push bx
    push cx
    push dx
    mov ah,40h
    mov bx,[handle]
    mov cx,1
    lea dx,SEP_COMA  ; dummy init
    ; usar DL como dato, escribimos desde la pila
    ; colocamos DL en num_buf[0]
    mov [num_buf],dl
    mov byte ptr [num_buf+1],0
    lea dx,num_buf
    int 21h
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ---- escribir CRLF ----
write_crlf:
    push ax
    push bx
    push cx
    push dx
    mov ah,40h
    mov bx,[handle]
    mov cx,2
    lea dx,CRLF
    int 21h
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ---- escribir número en AX con signo y opcional separador ----
; Entrada: AX = numero, BL = separador (0 para none, ',' o ' ')
write_num_sep:
    push si
    call itoa_signed
    call write_str
    cmp bl,0
    je .wns_exit
    mov dl,bl
    call write_ch
.wns_exit:
    pop si
    ret

; ---- Programa principal ----
start:
    ; crear/abrir archivo de salida
    mov ah,3Ch
    mov cx,0
    lea dx,FNAME
    int 21h
    jc .err
    mov [handle],ax

    ; escribir encabezado
    lea si,HEADER
    call write_str

    ; generar 360 pares
    xor cx,cx          ; angulo
    mov dl,0           ; contador para saltos de linea
.gen_loop:
    ; X = round(R*cos(theta))
    mov ax,cx
    call obtener_cos   ; AX = cos*256
    imul [R]
    mov bx,256
    idiv bx            ; AX = cos*R
    mov bl,','
    call write_num_sep ; escribe X,

    ; Y = -round(R*sin(theta))
    mov ax,cx
    call obtener_sin   ; AX = sin*256
    imul [R]
    mov bx,256
    idiv bx
    neg ax
    ; Si no es el ultimo par, escribe coma; si es ultimo, no
    mov bl,','
    cmp cx,359
    jne .not_last
    mov bl,0
.not_last:
    call write_num_sep

    ; insertar salto de línea cada 8 pares para legibilidad
    inc dl
    cmp dl,8
    jb .no_crlf
    call write_crlf
    mov dl,0
.no_crlf:

    inc cx
    cmp cx,360
    jb .gen_loop

    ; finalizar con CRLF
    call write_crlf

    ; cerrar archivo
    mov ah,3Eh
    mov bx,[handle]
    int 21h
    jmp .done

.err:
    ; no se pudo crear el archivo
    ; regresar a DOS con error code
    mov ax,4C01h
    int 21h

.done:
    mov ax,4C00h
    int 21h

ret
