org 100h
jmp start
X EQU 15
Y EQU 15
cOLOR EQU 0fh

prueba macro EjeX,EjeY,CColor
PUSHA
mov cx,EjeX ; coordenada en X
mov dx,EjeY ; coordenada en Y
mov al,CColor ; color
mov ah,0Ch ; Escribe un punto, DX = Y, CX = X, AL = color
int 10h
POPA
endm
start: mov ah, 0 ; establece el modo de vide
mov al, 13h ; 320 x 200 en grafico
int 10h ; establece el modo
; Dibujar una circunferencia usando el algoritmo de punto medio (Bresenham)
; Centro y radio (ajustar si hace falta)
CENTERX  EQU 160
CENTERY  EQU 100
RADIUS   EQU 60

; Inicializar variables
mov bx, RADIUS   ; BX = r
xor si, si       ; SI = x = 0
mov di, bx       ; DI = y = r
mov ax, 1
sub ax, bx       ; AX = 1 - r
mov bp, ax       ; BP = d (decision)

; Bucle principal: mientras x <= y
draw_loop:
	cmp si, di
	jg draw_done

	; Plotear los 8 puntos simétricos
	; Punto 1: (cx + x, cy + y)
	mov ax, CENTERX
	add ax, si
	mov cx, ax
	mov ax, CENTERY
	add ax, di
	mov dx, ax
	mov ah, 0Ch
	mov al, cOLOR
	xor bh, bh
	int 10h

	; Punto 2: (cx - x, cy + y)
	mov ax, CENTERX
	sub ax, si
	mov cx, ax
	mov ax, CENTERY
	add ax, di
	mov dx, ax
	mov ah, 0Ch
	mov al, cOLOR
	xor bh, bh
	int 10h

	; Punto 3: (cx + x, cy - y)
	mov ax, CENTERX
	add ax, si
	mov cx, ax
	mov ax, CENTERY
	sub ax, di
	mov dx, ax
	mov ah, 0Ch
	mov al, cOLOR
	xor bh, bh
	int 10h

	; Punto 4: (cx - x, cy - y)
	mov ax, CENTERX
	sub ax, si
	mov cx, ax
	mov ax, CENTERY
	sub ax, di
	mov dx, ax
	mov ah, 0Ch
	mov al, cOLOR
	xor bh, bh
	int 10h

	; Punto 5: (cx + y, cy + x)
	mov ax, CENTERX
	add ax, di
	mov cx, ax
	mov ax, CENTERY
	add ax, si
	mov dx, ax
	mov ah, 0Ch
	mov al, cOLOR
	xor bh, bh
	int 10h

	; Punto 6: (cx - y, cy + x)
	mov ax, CENTERX
	sub ax, di
	mov cx, ax
	mov ax, CENTERY
	add ax, si
	mov dx, ax
	mov ah, 0Ch
	mov al, cOLOR
	xor bh, bh
	int 10h

	; Punto 7: (cx + y, cy - x)
	mov ax, CENTERX
	add ax, di
	mov cx, ax
	mov ax, CENTERY
	sub ax, si
	mov dx, ax
	mov ah, 0Ch
	mov al, cOLOR
	xor bh, bh
	int 10h

	; Punto 8: (cx - y, cy - x)
	mov ax, CENTERX
	sub ax, di
	mov cx, ax
	mov ax, CENTERY
	sub ax, si
	mov dx, ax
	mov ah, 0Ch
	mov al, cOLOR
	xor bh, bh
	int 10h

	; Actualizar parámetros
	mov ax, bp
	cmp ax, 0
	jl d_negative
	; d >= 0
	; d = d + 2*(x - y) + 5
	mov ax, si
	shl ax, 1       ; 2*x
	mov dx, di
	shl dx, 1       ; 2*y
	sub ax, dx      ; 2*x - 2*y
	add ax, 5
	add bp, ax
	dec di          ; y = y - 1
	inc si          ; x = x + 1
	jmp draw_loop

d_negative:
	; d < 0
	; d = d + 2*x + 3
	mov ax, si
	shl ax, 1
	add ax, 3
	add bp, ax
	inc si
	jmp draw_loop

draw_done:
	; Esperar tecla
	mov ah, 0
	int 16h
	; Restaurar modo texto 80x25 (modo 03h)
	mov ax, 0003h
	int 10h
	ret