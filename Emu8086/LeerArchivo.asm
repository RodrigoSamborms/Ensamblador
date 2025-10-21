org 100h
        jmp inicio
        archivo db "C:\emu8086\MyBuild\prueba.txt", 0   ;ascii del nombre del archivo 
        leido db "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
        handle dw ?                                     ;identificador del arhivo
inicio: mov al, 0                                       ;modo de acceso para abrir arhivo, modo lectura/escritura
        mov dx, offset archivo                          ;offset lugar de memoria donde esta la variable
        mov ah, 3dh                                     ;Abre archivo, DS:DX apunta al archivo
                                                         ;AL = 0 (solo lectura), 1 (solo escritura) o 2 (escritura / lectura).
        int 21h                                         ;llamada a la interrupcion DOS
        jc error                                        ;si se prendio la bandera c ir a error
        mov handle, ax                                  ;si no paso mover a lo que le dio el SO
        jmp leer

 error:                                                 
        
 leer:  mov bx, handle                                   ;leer archivo 
        mov cx, 9
        mov dx, offset leido
        mov ah, 3fh                                     ; Lectura desde archivo / dispositivo, 
                                                        ; BX = manejador de archivo, 
                                                        ; CX = numero de bytes que se desea leer y 
                                                        ; DS:DX = buffer a ser cargado; después de la llamada
                                                        ; AX = numero de bytes leidos.
        int 21h

        mov bx, handle                                  ;cerramos archivo
        mov ah, 3eh                                     ;Cierra manejador de archivo
                                                        ;BX = manejador de archivo; se cierra el archivo, 
                                                        ;se actualiza el directorio y se remueven los buffers internos del archivo.
        int 21h 

        mov dx, offset leido                            ;imprimir el contenido de leido
        mov ah, 9
        int 21h
        ret 
