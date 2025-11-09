name "practica06.asm"
include 'emu8086.inc'
org 100h
jmp Principal
;============
;   Mensajes
;============
mensaje0    db 'Escriba una cadena: ', 0
mensaje1    db 'La cadena escrita fue: ', 0
nuevlin     db 13,10,0
mensaje_err db 'ERROR: formato invalido. Use: digito operador digito ...',0
;============
;   Variables
;============
buffer  db 20 dup(?)  ;tomando el caracter
bufferlong equ ($ - buffer -1) ;tam del buffer
tammax  equ 20        ;para el "ENTER"

; Variables para evaluación
vals dw 10 dup(0)     ; máximo 10 valores
ops db 10 dup(0)      ; máximo 10 operadores
nvals db 0            ; contador de valores
nops db 0             ; contador de operadores
resultado dw 0        ; resultado final
resbuf db 8 dup(0)    ; buffer para imprimir resultado

;==============
;   Subrutinas
;==============
;+++++++++ RUTINA: validar_expresion+++++++++
;  Comprueba que la cadena en [buffer] siga el patrón:
;  DIGITO (OPERADOR DIGITO)*
;  Acepta espacios en blanco entre tokens. Si inválida, imprime mensaje
;  de error y vuelve a `Principal` para reintentar.
; Entrada: SI -> buffer (string terminado en 0)
; Salida: retorna (si válida), no retorna si inválida (salta a Principal)
validar_expresion:
push si
xor bl, bl        ; BL = 0 -> esperamos DIGITO, 1 -> esperamos OPERADOR
.ve_loop:
mov al, [si]
cmp al, 0
je .ve_end
cmp al, ' '
je .ve_skip
cmp bl, 0
je .ve_expect_digit
; esperar operador
cmp al, '+'
je .ve_op_ok
cmp al, '-'
je .ve_op_ok
cmp al, '*'
je .ve_op_ok
cmp al, '/'
je .ve_op_ok
jmp .ve_invalid
.ve_expect_digit:
cmp al, '0'
jb .ve_invalid
cmp al, '9'
ja .ve_invalid
; dígito válido
mov bl, 1
inc si
jmp .ve_loop
.ve_op_ok:
mov bl, 0
inc si
jmp .ve_loop
.ve_skip:
inc si
jmp .ve_loop
.ve_end:
; Al finalizar, el último token debe haber sido un dígito (BL=1)
cmp bl, 1
je .ve_valid
jmp .ve_invalid
.ve_valid:
pop si
ret
.ve_invalid:
pop si
; imprimir mensaje de error desde la variable usando la macro print_string
printn ""
lea si, mensaje_err
call print_string
printn ""
jmp Principal


;+++++++++ RUTINA: parsear_expresion +++++++++
; Convierte la cadena en buffer a arrays vals[] y ops[]
; Entrada: SI -> buffer
; Salida: vals[], ops[], nvals, nops llenos
parsear_expresion:
push ax
push bx
push si
push di

mov byte ptr [nvals], 0
mov byte ptr [nops], 0
lea di, vals
lea bx, ops

.pe_loop:
mov al, [si]
cmp al, 0
je .pe_done
cmp al, ' '
je .pe_skip

; verificar si es dígito
cmp al, '0'
jb .pe_operador
cmp al, '9'
ja .pe_operador

; es dígito: convertir '0'..'9' a 0..9 y guardar como word
sub al, '0'
cbw                ; AX = valor 0..9 sign-extended
mov [di], ax
add di, 2
inc byte ptr [nvals]
inc si
jmp .pe_loop

.pe_operador:
; guardar operador
mov [bx], al
inc bx
inc byte ptr [nops]
inc si
jmp .pe_loop

.pe_skip:
inc si
jmp .pe_loop

.pe_done:
pop di
pop si
pop bx
pop ax
ret


;+++++++++ RUTINA: evaluar_expresion +++++++++
; Evalúa vals[] y ops[] aplicando precedencia: / * - +
; Entrada: vals[], ops[], nvals, nops
; Salida: [resultado] contiene el valor final
evaluar_expresion:
push ax
push bx
push cx
push dx

; Pasada 1: resolver divisiones
mov dl, '/'
call procesar_operador

; Pasada 2: resolver multiplicaciones
mov dl, '*'
call procesar_operador

; Pasada 3: resolver restas
mov dl, '-'
call procesar_operador

; Pasada 4: resolver sumas
mov dl, '+'
call procesar_operador

; El resultado final está en vals[0]
lea si, vals
mov ax, [si]
mov [resultado], ax

pop dx
pop cx
pop bx
pop ax
ret


;+++++++++ RUTINA: procesar_operador +++++++++
; Procesa todas las instancias de un operador específico
; Entrada: DL = operador a procesar
procesar_operador:
push ax
push bx
push cx
push si
push di
push bp

.po_restart:
xor bx, bx          ; i = 0
mov cl, [nops]
cmp cl, 0
je .po_done

.po_loop:
cmp bl, cl
jae .po_done

; verificar si ops[i] == DL
lea si, ops
add si, bx
mov al, [si]
cmp al, dl
jne .po_next

; Encontrado: calcular vals[i] op vals[i+1]
lea si, vals
mov ax, bx
shl ax, 1           ; i*2
add si, ax
mov ax, [si]        ; vals[i]
mov cx, [si+2]      ; vals[i+1]

; Realizar operación según DL
cmp dl, '/'
je .po_div
cmp dl, '*'
je .po_mul
cmp dl, '-'
je .po_sub
; debe ser '+'
add ax, cx
jmp .po_guardar

.po_div:
cmp cx, 0
je .po_div_zero
cwd
idiv cx
jmp .po_guardar
.po_div_zero:
xor ax, ax
jmp .po_guardar

.po_mul:
imul cx
jmp .po_guardar

.po_sub:
sub ax, cx

.po_guardar:
; Guardar resultado en vals[i]
lea si, vals
mov cx, bx
shl cx, 1
add si, cx
mov [si], ax

; Compactar: eliminar vals[i+1] y ops[i]
call compactar_arrays

; Reiniciar búsqueda desde el inicio
jmp .po_restart

.po_next:
inc bl
jmp .po_loop

.po_done:
pop bp
pop di
pop si
pop cx
pop bx
pop ax
ret


;+++++++++ RUTINA: compactar_arrays +++++++++
; Elimina vals[i+1] y ops[i] moviendo elementos hacia la izquierda
; Entrada: BL = índice i
compactar_arrays:
push ax
push bx
push cx
push si
push di

; Compactar vals: mover vals[i+2..] a vals[i+1..]
mov al, [nvals]
mov cl, bl
inc cl              ; start = i+1
cmp al, cl
jle .ca_skip_vals

lea si, vals
mov al, bl
inc al
shl al, 1           ; (i+1)*2
xor ah, ah
add si, ax          ; si = &vals[i+1]
mov di, si
add si, 2           ; si = &vals[i+2]

mov al, [nvals]
sub al, bl
sub al, 2           ; moves = nvals - i - 2
cmp al, 0
jle .ca_skip_vals

xor ah, ah
mov cx, ax
.ca_vals_loop:
mov ax, [si]
mov [di], ax
add si, 2
add di, 2
loop .ca_vals_loop

.ca_skip_vals:
dec byte ptr [nvals]

; Compactar ops: mover ops[i+1..] a ops[i..]
mov al, [nops]
cmp bl, al
jae .ca_skip_ops

lea si, ops
xor bh, bh
add si, bx          ; si = &ops[i]
mov di, si
inc si              ; si = &ops[i+1]

mov al, [nops]
sub al, bl
dec al              ; moves = nops - i - 1
cmp al, 0
jle .ca_skip_ops

xor ah, ah
mov cx, ax
.ca_ops_loop:
mov al, [si]
mov [di], al
inc si
inc di
loop .ca_ops_loop

.ca_skip_ops:
dec byte ptr [nops]

pop di
pop si
pop cx
pop bx
pop ax
ret


;+++++++++ RUTINA: imprimir_resultado +++++++++
; Imprime el valor en [resultado]
imprimir_resultado:
push ax
push bx
push cx
push dx
push si
push di

printn ""
print "Resultado: "

mov ax, [resultado]
lea di, resbuf

; Manejar signo
cmp ax, 0
jge .ir_positivo
neg ax
mov byte ptr [di], '-'
inc di

.ir_positivo:
; Convertir a decimal
cmp ax, 0
jne .ir_convertir
mov byte ptr [di], '0'
inc di
jmp .ir_terminar

.ir_convertir:
xor cx, cx
.ir_div_loop:
xor dx, dx
mov bx, 10
div bx
push dx
inc cx
cmp ax, 0
jne .ir_div_loop

.ir_escribir:
pop dx
add dl, '0'
mov [di], dl
inc di
loop .ir_escribir

.ir_terminar:
mov byte ptr [di], 0
lea si, resbuf
call print_string
printn ""

pop di
pop si
pop dx
pop cx
pop bx
pop ax
ret


;==============
;   Macro Funciones
;==============
DEFINE_PRINT_STRING
DEFINE_GET_STRING
;==============
;   Programa Principal
;==============
Principal:
;esciribir cadenas version corta
printn "Escriba una cadena:"

;leer los datos en buffer
lea di, buffer
mov dx, tammax
call get_string

;Validar la expresión ingresada: solo dígitos y operadores (+ - * /)
;Formato requerido: digito operador digito operador ... (termina en dígito)
lea si, buffer
call validar_expresion

; Parsear la expresión a arrays vals[] y ops[]
lea si, buffer
call parsear_expresion

; Evaluar con precedencia de operadores
call evaluar_expresion

; Imprimir resultado
call imprimir_resultado

;printn ""
;printn "La cadena escrita fue:"
;lea si,buffer
;call print_string
;printn ""

;Salir al Sistema Operativo
mov ax, 4c00h
int 21h
ret


