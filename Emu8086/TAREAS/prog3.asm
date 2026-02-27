    name "p3"   ; 
    
;   Este programa realiza la suma de dos datos
;   el primero es un dato de 16 bits almacenado en
;   la dirección de memoria 210H y 211H, la dirección
;   210H tendra los 8 bits mas significativos y la 211H
;   los menos significativos (big endian), la direccion
;   212H tendra el dato 2. la suma se realiza usando solo
;   registros de 8 bits por que el microprocesador trabaja
;   en formato little endian.
    
    org  100h	
    jmp inicio

msg1:         db "Seccion D01"
msg2:         db "Introduce tus datos en la memoria:"
msg3:         db "Dato1 de 16 bits en direcciones 0700:0310 y 0700:0311"
msg4:         db "Dato2 de 8 bits en direcciones 0700:0312"
msg5:         db "Resultado en direcciones 0700:0313 y 0700:0314"
msg6:         db "Formato Big Endian"                            
msg7:         db "En direcciones 0700:0315 y 0700:0316 en little endian"
msg_tail:
msg1_size = msg2 - msg1
msg2_size = msg3 - msg2
msg3_size = msg4 - msg3
msg4_size = msg5 - msg4
msg5_size = msg6 - msg5
msg6_size = msg6 - msg5
msg7_size = msg_tail - msg7                  

inicio:
    mov ax, 1003h       ;cofiguracion del tama�o de la consola
    mov bx, 0           ;consolo de 80x25 caracteres 
    int 10h

    mov dx, 0705h       ;se imprime el primer mensaje en el renglon 0705
    mov bx, 0         
    mov bl, 10011111b   ;paleta de colores
    mov cx, msg1_size   ;guion bajo solo para visualizar mejor
    mov al, 01b       
    mov bp, msg1
    mov ah, 13h       
    int 10h  
    
    mov dx, 0905h      ;dos lienas depues del primer mensaje
    mov bx, 0         
    mov bl, 10011111b 
    mov cx, msg2_size  
    mov al, 01b       
    mov bp, msg2        ;
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
              ;-----------------
	mov ah, 0           ;pulse una tecla para continuar      
    int 10110b          ;22 en binario

    mov dx, 0D05h     
    mov bx, 0         
    mov bl, 11111001b 
    mov cx, msg5_size  
    mov al, 01b       
    mov bp, msg5
    mov ah, 13h       
    int 10h    
    
    mov dx, 0E05h     
    mov bx, 0         
    mov bl, 11111001b 
    mov cx, msg6_size  
    mov al, 01b       
    mov bp, msg6
    mov ah, 13h       
    int 10h
    
    mov dx, 0F05h     
    mov bx, 0         
    mov bl, 11111001b 
    mov cx, msg7_size  
    mov al, 01b       
    mov bp, msg7
    mov ah, 13h       
    int 10h
    
               

    mov ah, 0           ;pulse una tecla para continuar      
    int 10110b          ;22 en binario
    
    mov ax,0            ;asegurar registro ax esta vacio
    mov al,[0x311]
    add al,[0x312]
    adc ah,[0x310]
    mov [0313h],ah ;Formato big endian guardado en memoria
    mov [0314h],al
    
    mov [0315h],ax ;formato little endian guardado en memoria      

    int 20h  
    