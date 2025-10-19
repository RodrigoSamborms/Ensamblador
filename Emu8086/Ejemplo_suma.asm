; Programa simple para sumar dos números (Tipo .COM)
; Autor: Rodrigo Samborms
; Fecha: 19 de Octubre, 2025

ORG 100h               ; Los programas .COM comienzan en 100h

INICIO:
    ; Mostrar mensaje inicial
    LEA DX, msg1
    MOV AH, 09H
    INT 21H
    
    ; Pedir primer número
    LEA DX, msg2
    MOV AH, 09H
    INT 21H
    CALL LeerNumero    ; Lee número de hasta 3 dígitos
    MOV [num1], AX     ; Guardar primer número
    
    ; Pedir segundo número
    LEA DX, msg3
    MOV AH, 09H
    INT 21H
    CALL LeerNumero    ; Lee número de hasta 3 dígitos
    MOV [num2], AX     ; Guardar segundo número
    
    ; Realizar la suma
    MOV AX, [num1]
    ADD AX, [num2]
    MOV [resultado], AX
    
    ; Mostrar resultado
    LEA DX, msg4
    MOV AH, 09H
    INT 21H
    MOV AX, [resultado]
    CALL MostrarNumero ; Mostrar resultado sin restricción de dígitos
    
    ; Salto de línea final
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H
    
    ; Terminar el programa
    MOV AH, 4CH
    INT 21H

; Procedimiento para leer un número de hasta 3 dígitos (ASCII a Binario)
; Retorna el número en AX
LeerNumero PROC
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR BX, BX         ; BX = 0 (acumulador del número)
    MOV CX, 3          ; Máximo 3 dígitos
    
LeerDigito:
    MOV AH, 01H        ; Leer carácter del teclado
    INT 21H
    
    CMP AL, 0DH        ; ¿Es Enter?
    JE FinLectura      ; Si es Enter, terminar
    
    CMP AL, '0'        ; Verificar si es dígito válido
    JB LeerDigito      ; Si es menor que '0', ignorar
    CMP AL, '9'
    JA LeerDigito      ; Si es mayor que '9', ignorar
    
    ; Convertir ASCII a número
    SUB AL, 30H        ; AL = dígito numérico
    
    ; BX = BX * 10 + AL
    PUSH AX            ; Guardar AL
    MOV AX, BX         ; AX = BX
    MOV DX, 10
    MUL DX             ; AX = AX * 10
    MOV BX, AX         ; BX = AX
    POP AX             ; Recuperar AL
    XOR AH, AH         ; AH = 0
    ADD BX, AX         ; BX = BX + AL
    
    LOOP LeerDigito    ; Repetir hasta 3 dígitos
    
FinLectura:
    MOV AX, BX         ; Retornar número en AX
    
    POP DX
    POP CX
    POP BX
    RET
LeerNumero ENDP

; Procedimiento para mostrar un número (Binario a ASCII)
; Recibe el número en AX
MostrarNumero PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR CX, CX         ; Contador de dígitos
    MOV BX, 10         ; Divisor
    
    ; Caso especial: si el número es 0
    CMP AX, 0
    JNE Dividir
    PUSH AX
    INC CX
    JMP MostrarDigitos
    
Dividir:
    XOR DX, DX         ; DX = 0
    DIV BX             ; AX = AX / 10, DX = resto
    PUSH DX            ; Guardar dígito en la pila
    INC CX             ; Incrementar contador
    CMP AX, 0          ; ¿Quedan más dígitos?
    JNE Dividir        ; Si quedan, continuar
    
MostrarDigitos:
    POP DX             ; Recuperar dígito
    ADD DL, 30H        ; Convertir a ASCII
    MOV AH, 02H        ; Mostrar carácter
    INT 21H
    LOOP MostrarDigitos ; Repetir para todos los dígitos
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
MostrarNumero ENDP

; Datos del programa
num1 DW ?              ; Primer número (word para soportar hasta 999)
num2 DW ?              ; Segundo número
resultado DW ?         ; Variable para almacenar el resultado
msg1 DB 'Programa de suma de dos numeros', 0DH, 0AH, '$'
msg2 DB 'Ingrese el primer numero (max 3 digitos): $'
msg3 DB 0DH, 0AH, 'Ingrese el segundo numero (max 3 digitos): $'
msg4 DB 0DH, 0AH, 'El resultado es: $'
