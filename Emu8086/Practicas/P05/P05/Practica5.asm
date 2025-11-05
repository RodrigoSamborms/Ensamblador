name "practica05"
include 'emu8086.inc'

        org 100h 
_set_string: xor ax,ax 
             lea di,input    
             lea si,n16    
              mov dx,5

     
             GOTOXY  18,4
             PRINT   "Lopez Avina Christopher"
             GOTOXY  15,7 
             PRINT   "Ingresa numero de 16 bits: " 
             call get_string 
MAIN:
        call PRIMERDEC

        xor cx,cx
        mov ax,b
        mov ch,0
        mov cx,2
 
        call HEXDEC
        mov al,0
        mov decimal[5],al
        mov ax,0
        mov bx,0
        mov ax,tmp
        mov bx,10000
        mov dx,0
        div bx
        mov decimal[0],al

        mov bx,0
        mov ax,0
        mov bl,10
        mov al,decimal[0]
        mov b,bx
        mul b
        mov b,ax

        mov bx,1000
        mov ax,b
        mov b,bx
        mul b
        mov b,ax
        mov ax,tmp
        sub ax,b
        mov tmp,ax

        mov ax,tmp
        mov bx,1000
        div bx
        mov decimal[1],al

        mov ax,0
        mov al,decimal[1]
        mov bx,1000
        mov b,bx
        mul b
        mov b,ax
        mov ax,tmp
        sub ax,b
        mov tmp,ax

        mov bx,100
        mov ax,tmp
        div bx
        mov decimal[2],al

        mov ax,0
        mov bx,0
        mov al,decimal[2]
        mov bx,100
        mov b,bx
        mul b
        mov b,ax
        mov ax,tmp
        sub ax,b
        mov tmp,ax

        mov ax,0
        mov bx,10
        mov ax,tmp
        div bx
        mov decimal[3],al

        mov ax,0
        mov al,decimal[3]
        mov bx,10
        mov b,bx
        mul b
        mov b,ax
        mov ax,tmp
        sub ax,b
        mov tmp,ax
        mov ax,tmp
        mov decimal[4],al

        mov ax, 0
        mov ah, 30h


        add decimal[0], ah
        add decimal[1], ah
        add decimal[2], ah
        add decimal[3], ah
        add decimal[4], ah

 ; MOSTRAR ARREGLO

 GOTOXY 21,9
 print "El numero convertido es: "

        lea di, decimal
        lea si, decimal

        call print_string ;

        int 20h
; DECIMALES CMP ENTRE RANGOS

PRIMERDEC:
        sub input[0], 30h
        cmp input[0], 9h
        jle SEGUNDODEC
        sub input[0], 7h
        cmp input[0], 15
        jle SEGUNDODEC
        sub input[0], 20h

SEGUNDODEC:
        sub input[1],30h
        cmp input[1],9h
        jle TERCERDEC
        sub input[1],7h
        cmp input[1],15
        jle TERCERDEC
        sub input[1],20h

TERCERDEC: 
        sub input[2],30h
        cmp input[2],9h
        jle CUARTODEC
        sub input[2],7h
        cmp input[2],15
        jle CUARTODEC
        sub input[2],20h

CUARTODEC:

        sub input[3],30h
        cmp input[3],9h
        jle FINCONV
        sub input[3],7h
        cmp input[3],15
        jle FINCONV
        sub input[3],20h

FINCONV:
        ret 
        ;Hex a Dec

INIHEX: ; Apartado del Primer Dato

        mul b
        loop INIHEX
        mov b,ax
        mov bl,input[0]
        mov tmp,bx

        mul tmp
        mov tmp,ax
        ret
                                   
RESHEX: ; Apartado resto

        mov ax,16
        mov b,ax
        mul b
        mov bl,input[1]
        mov b,bx 
        mul b
        mov b,ax
        add tmp,ax

        mov ax,16
        mov bl,input[2]
        mov b,bx
        mul b
        add tmp,ax

        mov al,input[3]
        add tmp,ax
        ret
HEXDEC:

        call INIHEX
        call RESHEX
        lea di,decimal ; Preparamos la salida de datos por print
        lea si,n16
        mov dx,6 ; Buffer

        ret



 input db 0,0,0,0
 n16 db 0,0
 b dw 16
 tmp dw 0
 decimal db 0,0,0,0,0

DEFINE_GET_STRING
DEFINE_PRINT_STRING
END ; directive to stop the compiler. 