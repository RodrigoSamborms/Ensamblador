org 100h
            jmp inicio
            directorio db "C:\emu8086\MyBuild\prueba1", 0   ;ascii del nombre del 
                                                                                                       ;directorio 
inicio:                                             
            mov dx, offset directorio    ; offset lugar de memoria donde esta la variable
            mov ah, 39h                  ; crea directorio DS:DX apunta al directorio
                                                            
            int 21h                      ;llamada a la interrupcion DOS
            ret 
