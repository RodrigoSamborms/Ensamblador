    name "p4d01"    
    
;   Este programa realiza el calculo de la potencia de un
;   numero de 16 bits. El resultado se guardara en 32 bits
;   utilizand el formato big endian
    
    org  100h
    jmp start
    
;Variables de entrada
Dato1           dw      ?
Exponente       dw      ?
Resultado       dw      0,0
aux             dw      0,0 
aux2            dw      0   

;mensajes a imprimir en pantalla    
msg1:   db "Bryan Eduardo Zarate Miramontes"
msg2:   db "Seccion D01"
msg3:   db "Dato1 variable de entrada de 16 bits"
msg4:   db "Exponente variable de entrada de 16 bits"
msg5:   db "Resultado variable de salida de 32 bits"
msg_tail:

;tamanio de mensajes
msg1_size = msg2 - msg1
msg2_size = msg3 - msg2
msg3_size = msg4 - msg3
msg4_size = msg5 - msg4
msg5_size = msg_tail - msg5 


main:
    mov     bx,[Dato1]
    mov     cx,[Exponente]
    mov     [aux + 2],bx
    cmp     cx,1
    jg      mult           
;_______________________________________

;Depuracion de variables
start:      
    xor     ax, ax
    mov     [Resultado],ax
    mov     [Resultado+2],ax
    mov     ax,[Dato1]
     
;_______________________________________    

    
;impresion de mensajes en pantalla

;Mensaje 1
    mov dx, 0705h     
    mov bx, 0         
    mov bl, 10011111b 
    mov cx, msg1_size  
    mov al, 01b       
    mov bp, msg1
    mov ah, 13h       
    int 10h  
    
;Mensaje 2
    mov dx, 0905h     
    mov bx, 0         
    mov bl, 10011111b 
    mov cx, msg2_size  
    mov al, 01b       
    mov bp, msg2
    mov ah, 13h       
    int 10h           

;Mensaje 3         
    mov dx, 0B05h     
    mov bx, 0         
    mov bl, 10011111b 
    mov cx, msg3_size  
    mov al, 01b       
    mov bp, msg3
    mov ah, 13h       
    int 10h           

;Mensaje 4
    mov dx, 0D05h     
    mov bx, 0         
    mov bl, 10011111b 
    mov cx, msg4_size  
    mov al, 01b       
    mov bp, msg4
    mov ah, 13h       
    int 10h           

;Mensaje 5
    mov dx, 0F05h     
    mov bx, 0         
    mov bl, 10011111b 
    mov cx, msg5_size  
    mov al, 01b       
    mov bp, msg5
    mov ah, 13h       
    int 10h           
         
;_____________________________________


;Pulse una tecla para continuar
    mov ah, 0          
    int 10110b 
    jmp main
    
;Subrutina de multiplicacion
mult:   
    mov     ax,[aux + 2]  
    mul     bx            
    mov     [aux2],dx         
    mov     [Resultado + 2],ax     
    mov     ax,[aux]       
    mul     bx             
    mov     dx,[aux2]      
    add     dx,ax      
    mov     [Resultado],dx     
    mov     ax,[Resultado] 
    mov     [aux],ax
    mov     ax,[Resultado + 2]
    mov     [aux + 2],ax
    add     cx,-1
    cmp     cx,1
    jg      mult

    int 20h
    

    end  