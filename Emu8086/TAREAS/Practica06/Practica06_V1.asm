include 'emu8086.inc'

org 100h
jmp Inicio

;--------------------
;| SEGMENTO DE DATOS |
;--------------------
max_caracteres EQU 60
; Estructura: [Tamaño Max], [Leídos], [Espacio para caracteres]
buffer db max_caracteres, 0, max_caracteres dup(' ')
cadena db 60 dup(0)
tam_cadena db 0 ;para saber cuantos elementos hay en la cadena
cadena_binario db 60 dup(0) ;contiene los digitos en binario de la cadena original
; Funciones de la librería emu8086.inc
DEFINE_PRINT_STRING
DEFINE_GET_STRING
DEFINE_PRINT_NUM_UNS
DEFINE_PRINT_NUM

Inicio:
PRINT "Rodrigo Torres Rivera"
PRINTN ''
PRINT "Escribe la cadena a traducir:"
PRINTN ''

;LEEMOS LOS DATOS
;como la cadena puede ser de tamano variable se utilizara INT21h/0Ah
LEA DX, buffer      ;variable donde se guardan los datos a leer
MOV AH, 0ah         ;indicamos la opcion de INT para lectura del teclado
INT 21h
XOR BX, BX          ;procesamos la cadena
MOV BL, buffer[1]   ; Obtenemos cuántos caracteres se escribieron realmente
MOV buffer[BX+2], '$' ; Ponemos el centinela para poder imprimir con AH=09h
;termina la lectura de datos de cadena variable

;MOSTRAR LOS DATOS
;PRINTN ''           ; Salto de línea antes de mostrar el resultado
;MOV DX, offset buffer + 2 ; Saltamos los dos bytes de control
;MOV AH, 9           ;
;INT 21h

;detemos para debug paso a paso
;PRINT "cambie a ejecucion paso a paso para DEBUG"
;mov ah, 0
;int 16h


;copiaremos los datos del buffe a cadena para evitar los ajustes del inicio del buffer
MOV AX, 0       ; Inicializamos AX en 0 para el ejemplo
MOV SI, offset buffer + 2;indice fuente direccion
LEA DI, cadena  ;indice destino direccion
MOV BL, 0
inicio_while:
MOV AL, [SI]        ;Tomamos el dato de la casilla fuente
CMP AL, '$'         ;Si es el centinela terminamos
JE fin_while
MOV [DI], AL        ;Lo copiamos a la casilla destino
INC SI              ;Movemos el apuntador a la siguiente direccion
INC DI
INC BL              ;Aumentamos la cuenta sólo si copiamos un carácter
JMP inicio_while
fin_while: ;salimos del bucle while
MOV [DI], '$'         ;terminador para INTs
MOV [DI+1], 0         ;terminador para PRINT_STRING
MOV [tam_cadena], BL ;guardamos el numero de elementos en la cadena

;MOV BL, 0

PRINTN '';salto de linea
LEA    SI, cadena       ;cargamos el mensaje a enviar
CALL   PRINT_STRING   ;imprimimos el mensaje
PRINTN ''
PRINT "tamio de la cadena: "
XOR AX, AX
MOV AL, [tam_cadena]
call PRINT_NUM_UNS
PRINT ''


;detemos para debug paso a paso
;PRINT "cambie a ejecucion paso a paso para DEBUG"
;mov ah, 0
;int 16h


;ahora convertiremos en esa cade los digitos numericos
;a su valor de binario, usando un for loop gracias al
;valor tama_cadena
MOV CL, [tam_cadena] ;inicializamos el contador parte baja
MOV CH, 0          ;parte alta 0
LEA SI, cadena ;cadena de origen
LEA DI, cadena_binario ;cadena destino
MOV BL, 0   ;preparamos el contador de caracteres
ASCII_Binario:
MOV AL, [SI] ;leemos el primer dato
;inicia_conversion ASCCII->Binario
CMP AL, 30h    ;verificamos el rango menor
JB no_digito   ;si el caracter esta dentro
CMP AL, 39h    ;verificamos el rango mayor
JA no_digito   ;en caso de no ser digito
SUB AL, 30h    ;restamos 30h para convertir
JMP termina_conversion
no_digito:
;no hacemos nada al dato se envia un mensaje de
;error en caso de ser requerido dejado a futuro
;para revision si es cadena valida
termina_conversion:
;se ha terminado la conversion
;independientemente si se convirtio o no
MOV [DI], AL ;Movemos el dato convertido a la cadena destino
INC SI   ;Nos movemos al siguiente caracter
INC DI   ;en las cadenas fuente SI destino DI
INC BL   ;incrementamos el contador de caracteres
LOOP ASCII_Binario
MOV [DI], '$'         ;terminador para INTs
MOV [DI+1], 0         ;terminador para PRINT_STRING
MOV [tam_cadena], BL ;guardamos el numero de elementos en la cadena

;veerificamos el resultado
PRINTN '';salto de linea
LEA    SI, cadena_binario ;cargamos el mensaje a enviar
CALL   PRINT_STRING   ;imprimimos el mensaje
PRINTN ''
PRINT "tamio de la cadena: "
XOR AX, AX
MOV AL, [tam_cadena]
call PRINT_NUM_UNS
PRINT ''


Fin_programa:
INT 20h             ; Terminar programa de forma segura

ret



