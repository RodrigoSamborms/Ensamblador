 org 100h
            jmp inicio
            directorio db "C:\emu8086\MyBuild\prueba1", 0   ;ascii del nombre del  
            directori1 db "C:\emu8086\MyBuild", 0   ;ascii del nombre del
            nombre     db "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$",0
                                                                                                       ;directorio 
inicio:                                             
            mov dx, offset directorio    ; offset lugar de memoria donde esta la variable
            mov ah, 39h                  ; crea directorio DS:DX apunta al directorio
                                                            
            int 21h                      ;llamada a la interrupcion DOS 
            
            
            mov dx, offset directorio    ; offset lugar de memoria donde esta la variable
            mov ah, 3Bh                  ; cambio directorio DS:DX apunta al directorio                                                          
            int 21h  
            
            mov dl,0  
            mov si,offset nombre
            mov ah, 47h                  ; Obtener directorio actual DS:SI apunta al directorio                                                          
            int 21h 
            
            mov dx, offset directori1    ; offset lugar de memoria donde esta la variable
            mov ah, 3Bh                  ; cambio de  directorio DS:DX apunta al directorio
                                                            
            int 21h                     ;llamada a la interrupcion DOS 
            
            mov dx, offset directorio    ; offset lugar de memoria donde esta la variable
            mov ah, 3AH                  ; borra directorio DS:DX apunta al directorio

            int 21h                      ;llamada a la interrupcion DOS

            
            ret
