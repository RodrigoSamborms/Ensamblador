 
include 'emu8086.inc'

org 100h
    jmp Principal
  
;Mensajes
    msj1 db "Escribe un numero de 16 bits en HEX (ejemp FFF) ",0
    msj2 db "El numero escrito fue: ",0
;Variables
    buffer  db 10 dup(?)
    tammax  equ 10

;funciones
DEFINE_PRINT_STRING
DEFINE_GET_STRING

Principal:        
    ;Escribir mensaje 1
    lea si, msj1
    call print_string 
    
    lea di, buffer
    mov dx, tammax
    call get_string
    
    
    lea si, msj2
    call print_string
           
    ;Salir al Sistema Operativo       
    mov ax, 4c00h
    int 21h
ret



