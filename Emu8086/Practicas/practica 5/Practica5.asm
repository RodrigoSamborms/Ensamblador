    name "p5d01"
    include 'emu8086.inc'
    
    org 0100h  
    jmp start
    
    ;declaracion de variables
    cadnum  db      "00000", 0   
    n16     db      ?,?       
    c16     db      ?,?
    b       db      ? 
                                                             
;____________________________________________ 
             
;mensajes a imprimir en pantalla    
msg1:   db "Bryan Eduardo Zarate Miramontes"
msg2:   db "Este programa convierte un numero de 2 bytes"
msg3:   db "ingresada por el usuario de hexadecimal a decimal."
msg4:   db "Si el valor ingresado es menor a 4 digitos, es"
msg5:   db "necesario rellenar con ceros a la izquierda"
msg6:   db "Ejemplo: valor a ingresar 10h, se ingresa 0010h"
msg7:	db "Ingrese un valor hexadecimal: "
msg8:   db "El numero convertido a decimal es: "
msg_tail:

;tamanio de mensajes
msg1_size = msg2 - msg1
msg2_size = msg3 - msg2
msg3_size = msg4 - msg3
msg4_size = msg5 - msg4
msg5_size = msg6 - msg5
msg6_size = msg7 - msg6 
msg7_size = msg8 - msg7
msg8_size = msg_tail - msg8
                                                              
;____________________________________________ 
             
;declaracion de subrutinas 

Hex2Dec:
    mov     ah,n16[0]
    mov     al,n16[1] 
    ;primera division
    mov     bx, 10
    xor     dx, dx
    div     bx 
    add     dl,48           
    mov     cadnum[4], dl   
    ;segunda division
    xor     dx, dx
    div     bx
    add     dl,48
    mov     cadnum[3], dl 
    ;tercera division 
    xor     dx, dx
    div     bx
    add     dl,48
    mov     cadnum[2], dl 
    ;cuarta division
    xor     dx, dx
    div     bx
    add     dl,48
    mov     cadnum[1], dl 
    ;quinta division
    xor     dx, dx
    div     bx
    add     dl,48
    mov     cadnum[0], dl 
    ret
 
numbyte:    
    call    asc2num
    mov     bl,16
    mul     bl
    mov     [b],al
    inc     di
    mov     al,[di]
    call    asc2num
    add     al,[b]
    mov     [b],al
    ret 

asc2num:    
    sub     al,48
    cmp     al,9
    jle     f_asc
    sub     al,7
    cmp     al,15
    jle     f_asc
    sub     al,32
f_asc:  ret                                                   
;____________________________________________   

;subrutinas de libreria de emu8086.inc
DEFINE_GET_STRING
DEFINE_PRINT_STRING 

;____________________________________________ 

start:
;configuracion de la consola para 80x25
    mov ax, 1003h  
    mov bx, 0        
    int 10h
;____________________________________________ 
    
;impresion de mensajes en pantalla

;Mensaje 1
    mov dx, 0305h     
    mov bx, 0         
    mov bl, 10011111b 
    mov cx, msg1_size  
    mov al, 01b       
    mov bp, msg1
    mov ah, 13h       
    int 10h  
    
;Mensaje 2
    mov dx, 0505h     
    mov bx, 0         
    mov bl, 10011111b 
    mov cx, msg2_size  
    mov al, 01b       
    mov bp, msg2
    mov ah, 13h       
    int 10h           

;Mensaje 3         
    mov dx, 0705h     
    mov bx, 0         
    mov bl, 10011111b 
    mov cx, msg3_size  
    mov al, 01b       
    mov bp, msg3
    mov ah, 13h       
    int 10h           

;Mensaje 4
    mov dx, 0905h     
    mov bx, 0         
    mov bl, 10011111b 
    mov cx, msg4_size  
    mov al, 01b       
    mov bp, msg4
    mov ah, 13h       
    int 10h           

;Mensaje 5
    mov dx, 0B05h     
    mov bx, 0         
    mov bl, 10011111b 
    mov cx, msg5_size  
    mov al, 01b       
    mov bp, msg5
    mov ah, 13h       
    int 10h           

;Mensaje 6 
    mov dx, 0D05h     
    mov bx, 0         
    mov bl, 10011111b 
    mov cx, msg6_size  
    mov al, 01b       
    mov bp, msg6
    mov ah, 13h       
    int 10h       

;Mensaje 7 
    mov dx, 0F05h     
    mov bx, 0         
    mov bl, 10011111b 
    mov cx, msg7_size  
    mov al, 01b       
    mov bp, msg7
    mov ah, 13h       
    int 10h           
;_____________________________________

main:        
    xor     ax,ax
    lea     di,cadnum
    lea     si,n16
    mov     dx,5 
    call    get_string 
    printn ""
    mov     al,[di]
    call    numbyte
    mov     al,[b]
    mov     [si],al                                      
    inc     si
    inc     di
    mov     al,[di]
    call    numbyte
    mov     al,[b]
    mov     [si],al                                       
    call    Hex2Dec
    
    ;Mensaje 8 
    mov dx, 1105h     
    mov bx, 0         
    mov bl, 10011111b 
    mov cx, msg8_size  
    mov al, 01b       
    mov bp, msg8
    mov ah, 13h       
    int 10h
    
    lea     si,cadnum
	call    PRINT_STRING 
	    
    int 20h
    end                  