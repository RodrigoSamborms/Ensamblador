 org 100h  
        jmp inicio
inicio: mov ah, 2Ah
        int 21h         ; AL = dia de la semana (Dom=0, Lun=1,….Sab=6)
                        ; CX = año, DH = mes DL = dia del mes.
        ret
