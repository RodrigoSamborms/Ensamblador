 org 100h  
        jmp inicio
inicio: mov ah, 2Ch
        int 21h         ; CH = hora, CL = minutos, 
                        ; DH = segundos y DL = centésimos de segundo
        ret
