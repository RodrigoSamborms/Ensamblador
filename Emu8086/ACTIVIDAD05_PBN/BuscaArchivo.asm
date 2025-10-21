org 100h
            jmp inicio 
            archivo db "C:\emu8086\MyBuild\prueba.txt", 0   ;ascii del nombre del archivo 
            leido db "$"
            handle dw ?                                     ;identificador del arhivo 
            aux db "$"
            cont db 0
 inicio:    mov al, 0                                       ; modo de acceso para abrir arhivo, modo lectura/escritura
            mov dx, offset archivo                          ; offset lugar de memoria donde esta la variable
            mov ah, 3dh                                     ; Abre archivo, DS:DX apunta al archivo
                                                            ; AL = 0 (solo lectura), 1 (solo escritura) o 2 (escritura / lectura).
            int 21h                                         ;llamada a la interrupcion DOS
            jc error                                        ; si se prendio la bandera c ir a error
            mov handle, ax                                  ; si no paso mover a lo que le dio el SO
            jmp leer

 error:     
 leer:      mov bx, handle                                  ;leer archivo 
            mov cx, 1                                       
            mov dx, offset leido                            
            mov ah, 3fh                                     ; Lectura desde archivo / dispositivo, BX = manejador de archivo, 
                                                            ; CX = numero de bytes que se desea leer y DS:DX = buffer a ser cargado;
                                                            ; despues de la llamada, AX = numero de bytes leidos.
            int 21h

            cmp ax, 0                                       ;ax queda en 0 cuando llega a EOF     
            jz FIN                                          ;si es 0 entonces va a fin para cerrar archivo 

            mov dl, leido[0]                                ;Detectar palabras que terminan con a

            cmp dl, " "                                     ;comparar si es espacio
            jnz mostrar                                      ;si es espacio entonces ir a mostrar
            jmp abajo                                       ;si no es espacio entonces ir a abajo
mostrar:    cmp aux, "a"                                    ;compara si el anterior es a
            jnz abajo
            inc cont                                        ;si es a entonces incrementar contador

abajo:      mov aux, dl                                     ;guardar en aux lo que hay en dl para comparar en la proxima vuelta
            jmp leer
FIN:        mov bx, handle                                   ;cerramos archivo
            mov ah, 3eh                                     ; Cierra manejador de archivo, BX = manejador de archivo
                                                            ; se cierra el archivo, se actualiza el directorio y 
                                                            ; se remueven los buffers internos del archivo
            int 21h                                                    ;

            ret
