; Programa simple para sumar dos n�meros (Tipo .COM)
; Autor: Rodrigo Samborms
; Fecha: 19 de Octubre, 2025

ORG 100h               ; Los programas .COM comienzan en 100h

; Saltar sobre los datos al inicio del programa
JMP INICIO

; ============================================================
; DATOS DEL PROGRAMA
; ============================================================
num1 DW ?              ; Primer n�mero (word para soportar hasta 999)
num2 DW ?              ; Segundo n�mero
resultado DW ?         ; Variable para almacenar el resultado
msg1 DB 'Programa de suma de dos numeros', 0DH, 0AH, '$'
msg2 DB 'Ingrese el primer numero (max 3 digitos): $'
msg3 DB 0DH, 0AH, 'Ingrese el segundo numero (max 3 digitos): $'
msg4 DB 0DH, 0AH, 'El resultado es: $'
msgOverflow DB 0DH, 0AH, 'ERROR: Overflow detectado! El resultado excede 65535.', 0DH, 0AH, '$'

; ============================================================
; PROCEDIMIENTOS
; ============================================================

; Procedimiento para leer un n�mero de hasta 3 d�gitos (ASCII a Binario)
; Retorna el n�mero en AX
LeerNumero PROC
PUSH BX
PUSH CX
PUSH DX

XOR BX, BX         ; BX = 0 (acumulador del n�mero)
MOV CX, 3          ; M�ximo 3 d�gitos

LeerDigito:
MOV AH, 01H        ; Leer car�cter del teclado
INT 21H

CMP AL, 0DH        ; �Es Enter?
JE FinLectura      ; Si es Enter, terminar

CMP AL, '0'        ; Verificar si es d�gito v�lido
JB LeerDigito      ; Si es menor que '0', ignorar
CMP AL, '9'
JA LeerDigito      ; Si es mayor que '9', ignorar

; Convertir ASCII a n�mero
SUB AL, 30H        ; AL = d�gito num�rico

; BX = BX * 10 + AL
PUSH AX            ; Guardar AL
MOV AX, BX         ; AX = BX
MOV DX, 10
MUL DX             ; AX = AX * 10
MOV BX, AX         ; BX = AX
POP AX             ; Recuperar AL
XOR AH, AH         ; AH = 0
ADD BX, AX         ; BX = BX + AL

LOOP LeerDigito    ; Repetir hasta 3 d�gitos

FinLectura:
MOV AX, BX         ; Retornar n�mero en AX

POP DX
POP CX
POP BX
RET
LeerNumero ENDP

; Procedimiento para mostrar un n�mero (Binario a ASCII)
; Recibe el n�mero en AX
MostrarNumero PROC
PUSH AX
PUSH BX
PUSH CX
PUSH DX

XOR CX, CX         ; Contador de d�gitos
MOV BX, 10         ; Divisor

; Caso especial: si el n�mero es 0
CMP AX, 0
JNE Dividir
PUSH AX
INC CX
JMP MostrarDigitos

Dividir:
XOR DX, DX         ; DX = 0
DIV BX             ; AX = AX / 10, DX = resto
PUSH DX            ; Guardar d�gito en la pila
INC CX             ; Incrementar contador
CMP AX, 0          ; �Quedan m�s d�gitos?
JNE Dividir        ; Si quedan, continuar

MostrarDigitos:
POP DX             ; Recuperar d�gito
ADD DL, 30H        ; Convertir a ASCII
MOV AH, 02H        ; Mostrar car�cter
INT 21H
LOOP MostrarDigitos ; Repetir para todos los d�gitos

POP DX
POP CX
POP BX
POP AX
RET
MostrarNumero ENDP

; ============================================================
; C�DIGO PRINCIPAL
; ============================================================
INICIO:
; Mostrar mensaje inicial
LEA DX, msg1
MOV AH, 09H
INT 21H

; Pedir primer n�mero
LEA DX, msg2
MOV AH, 09H
INT 21H
CALL LeerNumero    ; Lee n�mero de hasta 3 d�gitos
MOV [num1], AX     ; Guardar primer n�mero

; Pedir segundo n�mero
LEA DX, msg3
MOV AH, 09H
INT 21H
CALL LeerNumero    ; Lee n�mero de hasta 3 d�gitos
MOV [num2], AX     ; Guardar segundo n�mero

; Realizar la suma
MOV AX, [num1]
ADD AX, [num2]
JC Overflow        ; Si hay acarreo, hay overflow
MOV [resultado], AX

; Mostrar resultado
LEA DX, msg4
MOV AH, 09H
INT 21H
MOV AX, [resultado]
CALL MostrarNumero ; Mostrar resultado sin restricci�n de d�gitos
JMP Continuar

Overflow:
; Mostrar mensaje de overflow
LEA DX, msgOverflow
MOV AH, 09H
INT 21H

Continuar:

; Salto de l�nea final
MOV DL, 0DH
MOV AH, 02H
INT 21H
MOV DL, 0AH
MOV AH, 02H
INT 21H

; Terminar el programa
MOV AH, 4CH
INT 21H


