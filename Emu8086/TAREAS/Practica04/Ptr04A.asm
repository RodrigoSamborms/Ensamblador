
; You may customize this and other start-up templates;
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h
jmp main

;segmento de datos
;mensajes a imprimir
msg1:   db "Seccion D08"
msg2:   db "Introduce tus datos en la memoria:"
msg3:   db "Base variable de entrada de 16 bits"
msg4:   db "Exponente variable de entrada de 8 bits"
msg5:   db "Respuesta variable salia de 32 bits"
;msg6:   db "Prod variable de salida de 16 bits"
msg_tail:
msg1_size = msg2 - msg1
msg2_size = msg3 - msg2
msg3_size = msg4 - msg3
msg4_size = msg5 - msg4
msg5_size = msg_tail - msg5;msg5_size = msg6 - msg5
;msg6_size = msg_tail - msg6
;variables del programa
;variables de entrada:
Base    db      ?,?     ;DW formato BigEndian
Exp     db      ?       ;Byte
;variables de salida:
Res     db      ?,?,?,? ;DD 32 bits DoubleWord BigEndian

;Funciones
;inicia funcion oper
oper:
;recibe la cantidad de veces a multiplicar
;por si mismo
sub cl,1        ;ajustamos el contador
cmp cl,0        ;no debe ser menor a 0
jle nada        ;si es menor a cero salta
otra:
mul bx          ;potencia mediante
loop otra       ;multiplicaciones repetidas
nada:
ret             ;regresa de funcion
;termina funcion oper

;programa principal
main:
mov ax, 1003h  ;configuracion de consola
mov bx, 0
int 10h

mov dx, 0705h
mov bx, 0
mov bl, 10011111b
mov cx, msg1_size
mov al, 01b
mov bp, msg1
mov ah, 13h
int 10h

mov dx, 0905h
mov bx, 0
mov bl, 10011111b
mov cx, msg2_size
mov al, 01b
mov bp, msg2
mov ah, 13h
int 10h

mov dx, 0B05h
mov bx, 0
mov bl, 10011111b
mov cx, msg3_size
mov al, 01b
mov bp, msg3
mov ah, 13h
int 10h

mov dx, 0C05h
mov bx, 0
mov bl, 10011111b
mov cx, msg4_size
mov al, 01b
mov bp, msg4
mov ah, 13h
int 10h

mov dx, 0D05h
mov bx, 0
mov bl, 10011111b
mov cx, msg5_size
mov al, 01b
mov bp, msg5
mov ah, 13h
int 10h

;mov dx, 0E05h
;mov bx, 0
;mov bl, 10011111b
;mov cx, msg6_size
;mov al, 01b
;mov bp, msg6
;mov ah, 13h
;int 10h

mov ah, 0          ;espera a presionar una tecla
int 16h

;programa potencia
mov al,[Base+1] ;resultado intermedio
mov ah,Base     ;alamacenado como BigE
mov bx,ax       ;Base al multiplicar
mov cl,Exp      ;numero de veces

call oper       ;llama a funcion de potencia

mov [Res],dh    ;DX en LSB de Res
mov [Res+1],dl  ;en formato de BigE

mov [Res+2],ah  ;AX en MSB de Res
mov [Res+3,al   ;en formato BigE

;termina el programa
int 20h
ret

;ejemplo multiplicar 8 cuatro veces el mismo:
;Base       00h, 08h
;Exponente  04h
;Res        00h, 00h, 10h, 00






; [SOURCE]: C:\emu8086\MySource\Ptr04A.asm
