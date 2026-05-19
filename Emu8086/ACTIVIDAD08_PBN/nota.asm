nota:

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
popA
endm
start: mov ah, 0 ; establece el modo de vide
mov al, 13h ; 320 x 200 en grafico
int 10h ; establece el modo
prueba X,Y,cOLOR

mov ah, 0
int 16h
ret