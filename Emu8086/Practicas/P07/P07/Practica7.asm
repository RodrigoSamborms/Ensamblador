name "practica07"
include 'emu8086.inc'

.MODEL SMALL
.STACK 100h
.DATA
nombre_alumno DB 'Christopher Lopez Avina', '$'
nombre_entrada DB 100 DUP(0)             ; Espacio para el nombre del archivo .asm ingresado
extension_lst DB '.lst', 0                ; Extensión para el archivo de salida
mensaje_ingrese DB 'Ingrese el nombre del archivo .asm (con ruta completa): $'
mensaje_error DB 'Error al abrir o crear el archivo.$' ; Mensaje de error en caso de fallo
contador_caracteres DW 0                  ; Contador de caracteres acumulado

; Buffers de entrada y salida
buffer_linea DB 128 DUP(0)                ; Buffer para almacenar cada linea leida
buffer_salida DB 128 DUP(0)               ; Buffer para construir la linea de salida

.CODE
MAIN:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    ; Imprimir el nombre del alumno
    MOV AH, 09h
    MOV DX, OFFSET nombre_alumno
    INT 21h
    MOV AH, 09h
    MOV DX, OFFSET mensaje_ingrese
    INT 21h
    
    ; Leer el nombre del archivo de entrada
    MOV AH, 0Ah             ; Leer una linea del teclado
    MOV DX, OFFSET nombre_entrada
    INT 21h

    ; Cambiar la extension de .asm a .lst para el archivo de salida
    LEA DI, nombre_entrada
    MOV DI, OFFSET nombre_entrada
    ADD DI, [DI + 1]  ; ; Desplazar a la posicion del ultimo caracter ingresado
    SUB DI, 3                   ; Ubicar el ".asm"
    MOV CX, 4                   ; Longitud de ".lst"
    LEA SI, extension_lst
    REP MOVSB                   ; Cambiar la extension

    ; Abrir el archivo de entrada en modo lectura
    MOV AH, 3Dh                 ; Interrupcion para abrir archivo
    MOV AL, 0                   ; Modo de solo lectura
    MOV DX, OFFSET nombre_entrada
    INT 21h
    JC ERROR_ABRIR              ; Salir si hay error
    MOV BX, AX                  ; Guardar el handle del archivo en BX

    ; Crear el archivo de salida
    MOV AH, 3Ch                 ; Interrupcion para crear archivo
    MOV CX, 0                   ; Atributos (archivo normal)
    MOV DX, OFFSET nombre_entrada
    INT 21h
    JC ERROR_CREAR              ; Salir si hay error
    MOV CX, AX                  ; Guardar el handle de archivo de salida en CX

    ; Procesar cada linea del archivo de entrada
PROCESAR_LINEA:
    MOV AH, 3Fh                 ; Leer del archivo
    MOV BX, BX                  ; Usar el handle del archivo de entrada
    MOV CX, 128                 ; Leer hasta 128 caracteres (una linea)
    MOV DX, OFFSET buffer_linea
    INT 21h
    JC FIN_ARCHIVO              ; Si error, fin del archivo

    MOV SI, OFFSET buffer_linea
    XOR DX, DX                  ; DX servira como contador de longitud de linea

    ; Calcular longitud de la linea leida
CONTAR_CARACTERES:
    MOV AL, [SI]                ; Obtener carácter de la linea
    CMP AL, 0Dh                 ; Comparar con fin de linea
    JE FIN_CONTAR               ; Saltar si es fin de linea
    INC DX                      ; Incrementar contador
    INC SI
    JMP CONTAR_CARACTERES

FIN_CONTAR:
    ADD contador_caracteres, DX ; Sumar longitud de linea al contador total

    ; Preparar la linea de salida con el contador
    MOV DI, OFFSET buffer_salida
    MOV AX, contador_caracteres ; AX contiene el contador actual
    CALL CONVERTIR_A_HEX

    ; Copiar linea original al buffer de salida
    MOV SI, OFFSET buffer_linea
    MOV CX, DX
    REP MOVSB

    ; Escribir linea de salida en archivo de salida
    MOV AH, 40h                 ; Escribir en archivo
    MOV BX, CX                  ; Handle del archivo de salida
    MOV DX, OFFSET buffer_salida
    MOV CX, DI
    INT 21h

    JMP PROCESAR_LINEA          ; Leer la siguiente línea

FIN_ARCHIVO:
    MOV AX, 4C00h               ; Terminar programa
    MOV SP, 0FFF8h              ; SP en FFF8h para finalizar correctamente
    INT 21h

ERROR_ABRIR:
    MOV AH, 09h
    MOV DX, OFFSET mensaje_error
    INT 21h
    JMP FIN_ARCHIVO

ERROR_CREAR:
    MOV AH, 09h
    MOV DX, OFFSET mensaje_error
    INT 21h
    JMP FIN_ARCHIVO

; Conversion de numero a string (4 digitos, hexadecimal)
CONVERTIR_A_HEX:
    ; (Funcion que convierte AX a una cadena en hexadecimal en DI)
    RET
