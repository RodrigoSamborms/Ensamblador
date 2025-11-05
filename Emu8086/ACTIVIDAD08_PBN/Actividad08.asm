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

; Dibujar usando tablas lookup precalculadas (reducidas y en words)
NUMP     EQU 90

; Semicirculo superior (arriba)
coordX_top:
	db 220,220,219,219,218,216,215,213,211,208,206,203,200,196,193
	db 189,186,182,178,174,169,165,161,157,153,148,144,140,136
	db 132,129,125,122,119,116,113,110,108,106,104,103,102,101,100

coordY_top:
	db 100,104,108,113,117,121,125,128,132,136,139,142,145,148,150
	db 152,154,156,157,158,159,160,160,160,160,159,158,157,155,153
	db 151,149,146,144,141,137,134,130,127,123,119,115,111,106,102

; Semicirculo inferior (abajo)
coordX_bot:
	db 100,100,101,102,103,104,106,108,110,113,116,119,122,125,129
	db 132,136,140,144,148,153,157,161,165,169,174,178,182,186,189
	db 193,196,200,203,206,208,211,213,215,216,218,219,219,220,220

coordY_bot:
	db 98,94,89,85,81,77,73,70,66,63,59,56,54,51,49
	db 47,45,43,42,41,40,40,40,40,41,42,43,44,46,48
	db 50,52,55,58,61,64,68,72,75,79,83,87,92,96,100

; Dibujar primero el semiciclo superior luego el inferior
	xor si, si        ; índice = 0
	mov cx, 45        ; NUM_HALF = 45

draw_top_loop:
	cmp si, cx
	jge draw_bottom_setup

	lea bx, coordX_top
	add bx, si
	mov al, [bx]
	xor ah, ah
	mov cx, ax

	lea bx, coordY_top
	add bx, si
	mov al, [bx]
	xor ah, ah
	mov dx, ax

	mov ah, 0Ch
	mov al, cOLOR
	xor bh, bh
	int 10h

	inc si
	jmp draw_top_loop

draw_bottom_setup:
	xor si, si
	mov cx, 45

draw_bot_loop:
	cmp si, cx
	jge draw_table_done

	lea bx, coordX_bot
	add bx, si
	mov al, [bx]
	xor ah, ah
	mov cx, ax

	lea bx, coordY_bot
	add bx, si
	mov al, [bx]
	xor ah, ah
	mov dx, ax

	mov ah, 0Ch
	mov al, cOLOR
	xor bh, bh
	int 10h

	inc si
	jmp draw_bot_loop

draw_table_done:
	mov ah, 0
	int 16h
	mov ax, 0003h
	int 10h
	ret