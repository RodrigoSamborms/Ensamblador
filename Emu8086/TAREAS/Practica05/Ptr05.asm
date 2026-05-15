
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt
include 'emu8086.inc'

org 100h
jmp inicio
;--------------------
;|SEGMENTO DE DATOS |
;--------------------
msj1 db "Escribe un numero de 16 bits en HEX usando mayusculas (ejemp FFFF) ",0
msj2 db 13, 10,"El numero escrito fue: $",0

;Variables
cadena db 5 dup(0); debe tomar en cuenta el caracter NULL
invertida db 4 dup(0),0;cadena invertida

;###MacroDefiniciones###
DEFINE_PRINT_STRING
DEFINE_GET_STRING

inicio:
    PRINT "TORRES RIVERA RODRIGO"
    PRINTN '';salto de liena
    LEA    SI, msj1       ;cargamos el mensaje a enviar
    CALL   PRINT_STRING   ;imprimimos el mensaje
    PRINTN ''
    LEA DI, cadena;definimos donde se guarda la cadena
    MOV DX, 5   ;cuantos caracteres se leeran
    CALL GET_STRING;leemos la cadena
    ;PRINTN '';salto de liena
    ;LEA    SI, msj2       ;cargamos el mensaje a enviar
    ;CALL   PRINT_STRING   ;imprimimos el mensaje
    ;PRINTN ''
    PRINTN '';salto de liena
    LEA    SI, cadena       ;cargamos el mensaje a enviar
    CALL   PRINT_STRING   ;imprimimos el mensaje
    PRINTN ''
    
    ;conocemos de antemano el numero de elementos a meter a la pila 
    LEA SI, cadena  ;metemos la direccion de la cadena 
    MOV CX, 4   ;debido a que el ultimo elemento es null    
Voltear:
    MOV AL,[SI] ;movemos el caracter al registro
    MOV AH, 0   ;solo AX entra a la pila
    PUSH AX ;metemos el valor a la pila
    INC SI
    LOOP Voltear:
    
    LEA SI, Invertida
    MOV CX, 4
Invertir:
    POP AX
    ;el valor de AH es 0 y no lo necesitamos
    MOV [SI], AL
    INC SI
    LOOP Invertir
    
    PRINTN '';salto de liena
    LEA    SI, Invertida  ;cargamos el mensaje a enviar
    CALL   PRINT_STRING   ;imprimimos el mensaje
    PRINTN ''   
    
fin_programa:
    INT 20H
ret




