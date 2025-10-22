 org 100h
        jmp inicio
        archivo db "C:\emu8086\MyBuild\prueba.txt", 0   ;ascii del nombre del archivo 
inicio: mov cx, 00H                                     ;Atributos del archivo
        mov dx, offset archivo                          ;offset lugar de memoria donde esta la variable
        mov ah, 3Ch                                     ;Abre archivo, DS:DX apunta al archivo
        int 21h   
        
        mov al, 0                                       ;modo de acceso para abrir arhivo, modo lectura/escritura
        mov dx, offset archivo                          ;offset lugar de memoria donde esta la variable
        mov ah, 3dh                                     ;Abre archivo, DS:DX apunta al archivo
                                                         ;AL = 0 (solo lectura), 1 (solo escritura) o 2 (escritura / lectura).
        int 21h                                         ;llamada a la interrupcion DOS

        ret 
