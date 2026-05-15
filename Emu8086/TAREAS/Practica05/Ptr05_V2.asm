
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
invertidanum db 4 dup(0)
decimal dw 0    ;valor convertido a decimal

;Variables para BCD
decimales db 5 dup(0)  ;array para almacenar los 5 digitos decimales
num_digitos db 0       ;cantidad de digitos
BCD_Num db 21 dup(0)   ;array de 20 caracteres ('0' y '1') + null terminator

;Tablas Look up
CaracteresHEX db '0123456789ABCDEF';caracteres
ValoresHEX  db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;numeros

;Tabla para conversion a binario (4 caracteres por digito 0-9)
BinarioDígitos:
    db '0000'  ;0
    db '0001'  ;1
    db '0010'  ;2
    db '0011'  ;3
    db '0100'  ;4
    db '0101'  ;5
    db '0110'  ;6
    db '0111'  ;7
    db '1000'  ;8
    db '1001'  ;9

;Procedimientos
TablaLookup:
;dato a verificar debe estar en AL
;retorna valor buscado en AL y CF=0
;o error con CF=1 y AL=0FFh
;resguardamos los registros
PUSH SI
PUSH CX
PUSH DI
PUSH BX
;codigo del procedimiento
MOV BL, AL          ;conservar valor incial de AL en BL
LEA SI, CaracteresHEX;nos preparamos para revisar los caracteres
XOR DI, DI          ;reesetea DI
MOV CX, 16          ;contador del bucle
HL_loop:
MOV DL, [SI]        ;cargamos el primer elemento de la tabla
CMP BL, DL          ;verificamos
JE  HL_found        ;si encontrado no se continua la busqueda
INC SI              ;movemos el apuntador de CaracteresHEX
INC DI              ;movemos el apuntador de ValoresHEX
LOOP HL_loop        ;cuerpo del bucle de busqueda

; no encontrado se revisaron todos los elementos
MOV AL, 0FFh        ;se carga con un valor que indica error
STC                 ; CF=1 indica error
JMP TL_end
;en caso de error AL=0FFh y CF=1
HL_found:
LEA BX, ValoresHEX  ;BX base de la tabla de valores
MOV AL, [BX+DI]     ; AL = valor 0..15
CLC                 ; CF=0 indica exito
;caso de exito AL con el valor 0..15 y CF=0

;reestablecemos los registros
TL_end:
POP BX
POP DI
POP CX
POP SI
RET    ;termina el procedimiento
;###MacroDefiniciones###
DEFINE_PRINT_STRING
DEFINE_GET_STRING
DEFINE_PRINT_NUM_UNS

inicio:
PRINT "TORRES RIVERA RODRIGO"
PRINTN '';salto de liena
LEA    SI, msj1       ;cargamos el mensaje a enviar
CALL   PRINT_STRING   ;imprimimos el mensaje
PRINTN ''
LEA DI, cadena;definimos donde se guarda la cadena
MOV DX, 5   ;cuantos caracteres se leeran
CALL GET_STRING;leemos la cadena


;metemos los valores en pila para voltear
;conocemos de antemano el numero de elementos a meter a la pila
LEA SI, cadena  ;metemos la direccion de la cadena
MOV CX, 4   ;debido a que el ultimo elemento es null
Voltear:
MOV AL,[SI] ;movemos el caracter al registro
MOV AH, 0   ;solo AX entra a la pila
PUSH AX ;metemos el valor a la pila
INC SI
LOOP Voltear

;sacamos los valores en pila volteados para rellenar la tabla invertida
LEA SI, Invertida
MOV CX, 4
Invertir:
POP AX
;el valor de AH es 0 y no lo necesitamos
MOV [SI], AL
INC SI
LOOP Invertir


LEA SI, Invertida    ;arreglo fuente
LEA DI, invertidanum ;arreglo destino
MOV CX, 4
Rellenar_invertidanum:
MOV AL, [SI]      ;movemos el valor de la tabla a buscar
CALL TablaLookup  ;procedimiento para buscar en las tablas
JNC exito              ; CF=0 ? éxito, AL contiene 0..15
; aquí manejas error (AL = 0FFh)
PRINT "ERROR EN LOS DATOS TERMINA EL PROGRAMA"
JMP fin_programa    ;termina el programa
;JMP fin_valida
exito:          ; aqui AL = valor numérico (0..15)
MOV [DI], AL
INC SI ;nos movemos al siguiente valor
INC DI ;a verificar
LOOP Rellenar_invertidanum
;fin_valida: ;continua el programa

;como ya tenemos en invertidanum los valores decimales
;para cada digito y estan en orden de menor a mayor peso
;de izquierda a derecha podemos comenzar la operacion para
;calcular el valro en decimal
LEA SI, invertidanum   ;apuntamos al arreglo con los digitos
MOV CX, 4              ;son cuatro digitos
MOV BX, 1              ; peso = 16^0
MOV decimal, 0
AcumularHex:
XOR AX, AX         ;reseteamos AX a 0
MOV AL, [SI]       ;apuntamos al primer elemento del arreglo
MUL BX             ;AX = digito * peso (DX:AX, aqui DX queda 0)
ADD decimal, AX    ;la salida se va acumulando sistema numerico posicional

; peso *= 16 ;calculo del siguiente peso mediante desplazamientos
SHL BX, 1    ;desplazamientos a la izquierda
SHL BX, 1
SHL BX, 1
SHL BX, 1

INC SI        ;nos movemos al siguiente elemento del arreglo
LOOP AcumularHex ;continua el ciclo

PRINTN ''
MOV AX, decimal
CALL PRINT_NUM_UNS

;-----CONVERSION A BCD BINARIO-----
;Extraccion de digitos decimales dividiendo entre 10
LEA DI, decimales
MOV AX, decimal
MOV CX, 10
XOR BX, BX              ;BX = contador de digitos

ExtraerDigitos:
    XOR DX, DX
    DIV CX              ;AX = cociente, DX = residuo
    MOV [DI], DL        ;guardar el digito
    INC DI
    INC BX              ;contar digitos
    CMP AX, 0
    JNE ExtraerDigitos

MOV num_digitos, BL    ;guardar cantidad de digitos
;Concatenar los digitos binarios
;Meter los digitos en pila (de derecha a izquierda del arreglo)
LEA SI, decimales
MOV CX, BX              ;CX = num_digitos
MetEnPila:
    MOV AL, [SI]
    PUSH AX
    INC SI
    LOOP MetEnPila

;Sacar de pila y convertir cada digito a sus 4 bits binarios
LEA DI, BCD_Num        ;apuntador destino
MOV CX, BX             ;CX = num_digitos
ConvertirABinario:
    POP AX
    MOV BL, AL         ;BL = digito (0-9)
    
    ;calcular desplazamiento en tabla: AL * 4
    MOV AL, BL
    SHL AL, 1          ;AL * 2
    SHL AL, 1          ;AL * 4
    XOR AH, AH         ;limpiar AH para extender sin signo (8086)
    
    ;copiar 4 caracteres desde tabla a BCD_Num
    LEA SI, BinarioDígitos
    ADD SI, AX         ;SI = tabla + offset
    
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    ;cada digito decimal viene en formato de 4 bits
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    
    MOV AL, [SI]
    MOV [DI], AL
    INC DI
    
    LOOP ConvertirABinario

;Terminar string con null
MOV byte [DI], 0

;Mostrar resultado BCD
PRINTN ''
PRINT "BCD Binario: "
LEA SI, BCD_Num
CALL PRINT_STRING

fin_programa:
INT 20H
ret






