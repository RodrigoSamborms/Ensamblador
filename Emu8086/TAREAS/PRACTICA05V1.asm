 
include 'emu8086.inc'

org 100h
    jmp Principal
  
;Mensajes
    msj1 db "Escribe un numero de 16 bits en HEX (ejemp FFF) ",0
    msj2 db 13, 10,"El numero escrito fue: ",0
    nuevlin db 13,10,0
;Variables
    buffer  db 5 dup(?)  ;tomando el caracter
    bufferlong equ ($ - buffer -1) ;tam del buffer
    tammax  equ 5        ;para el "ENTER" 
;funciones
DEFINE_PRINT_STRING
DEFINE_GET_STRING

;Subrutinas



Principal:        
    ;Preguntar datos msj1
    lea si, msj1
    call print_string 
    ;leer los datos en buffer
    lea di, buffer
    mov dx, tammax
    call get_string
    
    ;salto de linea
    lea si, nuevlin
    call print_string
    
    ;--Inicia Convertir el dato del buffer a formato BCD
    mov si, offset buffer ;inicio del buffer
    mov cx, bufferlong    ;incializamos contador
Convertir:
    mov al, [si]
    
    mov ah, 0Eh ;funcion 14 de int 10h
    ;mov al, [si] ;hecho antes
    sub al, 30h;
    int 10h     ;int imprimir un caracter 
    mov [si], al ;guardamos el valor convertido
    
    inc si      ;siguiente caracter
    loop convertir ;CX decrementa y repite lazo
    
    
    mov si, offset buffer ;inicio del buffer
    mov cx, bufferlong    ;incializamos contador
    sub ax, ax            ;AX = 0000_0000
Invertir:                 ;metemos el buffer
    mov al, [si]          ;en la pila para
    push ax               ;invertir el numero  
    
    inc si
    loop Invertir ;
      
    mov si, offset buffer ;inicio del buffer
    mov cx, bufferlong    ;incializamos contador
    sub ax, ax            ;AX = 0000_0000   
Rellenar:               ;recuperamos de la
    pop ax              ;pila el buffer
    mov [si], al        ;invertido ahora
    inc si
    loop Rellenar                        
    ;----Termina Convertir el dato del buffer a formato BCD

    ;Mostrar el resultado msj2
    lea si, msj2
    call print_string 
    
    lea si, buffer
    call print_string
           
    ;Salir al Sistema Operativo       
    mov ax, 4c00h
    int 21h
ret




