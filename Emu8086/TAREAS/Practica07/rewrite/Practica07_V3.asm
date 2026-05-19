;PROGRAMA PARA EJEMPLIFICAR EL MANEJO BASICO DE ARCHIVOS
include 'emu8086.inc'

org 100h
JMP inicio:

;--------------------
;| SEGMENTO DE DATOS |
;--------------------
max_caracteres  EQU 60
; Estructura requerida por la INT 21h / AH=0Ah: [Max], [Leídos], [Espacio]
buffer db max_caracteres, 0, max_caracteres dup(' ')
nombre_archivo  db 60 dup(0)
handler dw ?    ; Variable para almacenar el identificador del archivo

; Variables
caracter db ? ;alamacenamiento del caracter leido
cont_caracteres dw 0 ;contador de caracteres
nueva_linea     db 1    ; Bandera: 1 = Imprimir contador al inicio de línea, 0 = No imprimir

; Funciones de la librería emu8086.inc
DEFINE_PRINT_STRING
DEFINE_PRINT_NUM_UNS

;definir funciones y procedimientos
; Funcion: PRINT_NUM_CARA
; Entrada: AX = Valor numérico a imprimir (ej. cont_caracteres)
; Salida: Imprime el numero en consola con formato estricto de 3 digitos (000)
; funcionamiento:
; el numero esta almacenado en binario, asi que vamos a extraer
; los digitos equivalentes a las centenas, decenas y unidades
; mediante divisiones sucesivas entre 10
; el caracter binario obtenido como cociente se le suma 30h
; para generar el caracter ASCII correspondiente
; el valor del residuo es lo siguiente a dividir para
; obtener el siguiente digito
PRINT_NUM_CARA PROC
PUSH AX   ;Guardamos los registros en la pila para no
PUSH BX   ;alterar los valores del programa principal
PUSH CX   ;esta es una practica comun arquitecturas
PUSH DX   ;posteriores tienen instrucciones que facilitan ester proceso

MOV BX, AX;Pasamos el numero a BX para trabajar cómodamente

;Centenas
MOV AX, BX  ;Colocamos el numero completo en AX
MOV DX, 0   ;Limpiamos DX para la division de 16 bits
MOV CX, 100 ;Divisor = 100
DIV CX      ;AX = Cociente (Centenas), DX = Residuo

MOV BX, DX  ;Guardamos provisionalmente el residuo en BX para despues

;Imprimir las Centenas
MOV DL, AL   ;Movemos el cociente a DL
ADD DL, 30h  ;Convertimos el número a su carácter ASCII (ej: 0 -> '0')
MOV AH, 02h  ;Funcion 02h de la INT 21h para imprimir caracter
INT 21h

;Decenas y unidades
;la ultima division nos entrega las decenas en el cociente
;y las unidades en el residuo
MOV AX, BX ;Recuperamos el residuo anterior (lo que quedó de las centenas)
MOV DX, 0  ;Limpiamos DX
MOV CX, 10 ;Divisor = 10
DIV CX     ;AX = Cociente (Decenas), DX = Residuo (Unidades)

MOV BX, DX ;Guardamos el residuo final (unidades) en BX

;Imprimir las Decenas
MOV DL, AL  ;Movemos las decenas a DL
ADD DL, 30h ;Convertimos a ASCII
MOV AH, 02h
INT 21h

; Imprimir las Unidades
MOV DL, BL  ;Recuperamos el residuo final (unidades) de BX
ADD DL, 30h ;Convertimos a ASCII
MOV AH, 02h
INT 21h

POP DX   ;Restauramos los registros de la pila en orden inverso
POP CX   ;Lo cual es una practica comun
POP BX   ;arquitecturas posteriores tienen instrucciones
POP AX   ;que facilitan este proceso
RET                 ; Regresamos al flujo principal del programa
PRINT_NUM_CARA ENDP

inicio:
PRINTN "Rodrigo Torres Rivera"
PRINTN "Escribe el nombre del archivo (ej. rodrigo.txt)"

;-->Leer el nombre del archivo desde el teclado
LEA DX, buffer    ;variable buffer de entrada
MOV AH, 0Ah       ;AH cargado para llamar la INT
INT 21h

;Necesitamos darle formato a la cadena leida para
;eliminar los datos no requeridos para el nombre
;del archivo a abrir
XOR BX, BX          ;reinciamos BX para cargar el numero de caracteres
MOV BL, buffer[1]   ;BL obtiene cuántos caracteres se escribieron realmente
MOV SI, offset buffer + 2   ;Origen cadena buffer mas dos desplazamientos
LEA DI, nombre_archivo      ;Destino cadena nombre_archivo para abrir archivo
MOV CX, BX                  ;Usamos el contador de caracteres para el bucle
copiar_cadena_for:
MOV AL, [SI]
MOV [DI], AL
INC SI
INC DI
LOOP copiar_cadena_for;Se repite la cantidad de veces que indique CX
MOV byte ptr [DI], 0 ;terminador para PRINT_STRING y apertura de archivos
;nombre_archivo ahora ya tienen el archivo sin caracteres extranios

;####ABRIR EL ARCHIVO####
MOV AH, 3Dh             ; Funcion 3Dh: Abrir archivo
MOV AL, 0               ; Modo de acceso: 0 = Solo lectura
LEA DX, nombre_archivo  ; DX debe apuntar al nombre con terminación 0
INT 21h
;Si no se puede abir saltamos a error_abrir
JC error_abrir ;Si la bandera Carry (CF) es 1, hubo un error
;Si se pudo abrir tendremos un HANDLER
MOV handler, AX   ;Si fue exitoso, guardamos el manejador (handler)

;####PROCESAR EL ARCHIVO####
PRINTN ''
PRINTN " Datos del Archivo "

leer_caracter:
MOV AH, 3Fh     ;Leer de un archivo AH= 3Fh
MOV BX, handler ;Manejador del archivo
MOV CX, 1       ;leeremos exactamente 1 caracter
LEA DX, caracter;Direccion de memoria donde se guardará el byte leido
INT 21h         ;INT que lee el dato

JC error_lectura;Si hay error en la lectura, saltamos
CMP AX, 0       ;AX devuelve cuantos bytes leyo realmente.
JE fin_archivo  ;Si AX = 0, llegamos al final del archivo (EOF)

; --- Control del inicio de linea ---
;para verificar si el caracter sigue a un salto de linea
CMP nueva_linea, 1      ; ¿Es el inicio de una linea?
JNE verificar_filtros   ; Si no es, saltamos directo a las verificaciones

;la primera lectura del caracter lleva por defacto el valor 0
;Imprimimos el contador antes del texto
MOV AX, cont_caracteres ;Cargamos el valor actual en AX
CALL PRINT_NUM_CARA     ;Funcion para formato de tres digitos
PRINT " "               ;Espacio decorativo entre el número y el texto
MOV nueva_linea, 0      ;Apagamos la bandera para que no repita el numero en la misma linea

verificar_filtros:
; --- FILTRO: No contar caracteres de control (Enter) ---
CMP caracter, 0Dh     ;0Dh = Carriage Return (Retorno de carro)
JE mostrar_pantalla   ;Si es 0Dh, saltamos la suma y solo lo mandamos a pantalla

CMP caracter, 0Ah     ;0Ah = Line Feed (Salto de línea)
JE activar_nueva_linea;Si es 0Ah, saltamos la suma y vamos a activar la bandera

; Si no fue ninguno de los anteriores, es un carácter válido. ¡Lo contamos!
INC cont_caracteres
JMP mostrar_pantalla

activar_nueva_linea:
MOV nueva_linea, 1      ; Activamos la bandera para la siguiente línea

mostrar_pantalla:
; --> Mostrar el caracter leido en la pantalla
MOV AH, 02h    ;Funcion 02h: Escribir caracter en pantalla
MOV DL, caracter;El caracter a imprimir debe ir en DL
INT 21h         ;LLamamos a MS-DOS para imprimir

JMP leer_caracter       ; Bucle: saltamos a leer el siguiente caracter

error_lectura:
PRINTN ''
PRINTN "Error al leer del archivo"

fin_archivo:
PRINTN ''                ; Un salto de línea al terminar el volcado
PRINTN " Termino el archivo "

;####CERRAMOS EL ARCHIVO####
MOV AH, 3Eh      ;Funcion 3Eh: Cerrar archivo
MOV BX, handler  ;Pasamos el identificador del archivo a BX
INT 21h          ;llamamos a la INT
;Mensaje de que el archivo se ha cerrado
PRINTN ''
PRINTN " Cerrado con exito "
JMP fin_programa

error_abrir:
PRINTN ''
PRINTN "No se pudo abrir el archivo"

fin_programa:
INT 20h     ;Termina el programa
ret




; [SOURCE]: C:\emu8086\MySource\Practica07_V3.asm
