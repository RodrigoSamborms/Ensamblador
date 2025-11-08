; PRACTICA07.asm - Evaluador de expresiones aritméticas (.COM) para Emu8086
; Lee una expresión con al menos 4 operandos (16-bit con signo), operadores + - * /
; Respeta la jerarquía de operaciones (precedencia: * / > + -) y muestra el resultado
; Uso: ensambla como .COM (ORG 100h). Usa macros get_string y print_string de emu8086.inc

org 100h

INCLUDE "emu8086.inc"

; --- Datos ---
msg_prompt    db "Ingrese una expresion aritmetica (ej: -12 + 34 * 2 - 5 / 3):$"
msg_result    db "Resultado (16-bit signed): $"
msg_err_div0  db "Error: Division por cero.$"
msg_err_syn   db "Error: Sintaxis invalida.$"
msg_err_stack db "Error: Desbordamiento de pila.$"
msg_err_few   db "Error: Ingrese al menos 4 operandos.$"

tam_buffer    equ 80
buffer        db tam_buffer
; buffer para la llamada DOS (func 0Ah): [max][count][chars...]
dos_inbuf_max equ tam_buffer-1
dos_inbuf db dos_inbuf_max, 0, dos_inbuf_max dup(0)

; Pila de operandos (palabras) y operadores (bytes)
max_items     equ 32
operand_stack dw max_items dup(0)
operator_stack db max_items dup(0)
op_count      dw 0    ; numero de operandos en la pila
opr_count     db 0    ; numero de operadores en la pila
total_operands dw 0  ; contador total de operandos ingresados

; temporales
num_sign db 0

; buffer para imprimir decimal (terminado en $ para int21/ah=9)
dec_buf db 7 dup('$') ; sign + up to 5 digits + $

after_msg db 13,10, '$'

; --- Código ---
start:
    mov ax, cs
    mov ds, ax

    ; imprimir prompt
    lea dx, msg_prompt
    mov ah, 9
    int 21h

    ; leer linea de entrada
    lea di, buffer
    mov dx, tam_buffer
    call GET_STRING

    ; preparar puntero de parseo
    lea si, buffer

    ; inicializar contadores
    mov word [op_count], 0
    mov byte [opr_count], 0
    mov byte [prev_token], 0

parse_loop:
    mov al, [si]
    cmp al, 0Dh
    je parse_done
    cmp al, 0
    je parse_done
    ; saltar espacios
    cmp al, ' '
    je skip_space

    ; si es signo + or - y prev was operator/start -> part of number
    cmp al, '+'
    je maybe_sign
    cmp al, '-'
    je maybe_sign

    ; si digito -> parse number
    push ax
    mov al, [si]
    call is_digit_al
    pop ax
    jnz do_parse_number

    ; si es operador binario + - * /
    cmp al, '+'
    je handle_operator_token
    cmp al, '-'
    je handle_operator_token
    cmp al, '*'
    je handle_operator_token
    cmp al, '/'
    je handle_operator_token

    jmp syntax_error

skip_space:
    inc si
    jmp parse_loop

maybe_sign:
    mov al, [prev_token]
    cmp al, 0
    jne handle_operator_token ; si previo fue operando, esto es operador
    ; sino tratar como signo de numero
    jmp do_parse_number

; parse numero y apilar
do_parse_number:
    call parse_number_from_si ; AX <- valor, SI avanzado
    call push_operand_ax
    mov byte [prev_token], 1
    jmp parse_loop

handle_operator_token:
    ; AL tiene operador
    push ax
    ; llamar handler con AL = operador
    call handle_new_operator
    pop ax
    inc si
    mov byte [prev_token], 0
    jmp parse_loop

parse_done:
    call apply_all_operators
    mov bx, [op_count]
    cmp bx, 1
    jne syntax_error
    ; comprobar que hubo al menos 4 operandos en la expresion
    mov bx, [total_operands]
    cmp bx, 4
    jb not_enough
    call pop_operand_into_ax
    lea dx, msg_result
    mov ah, 9
    int 21h
    call print_ax_signed
    lea dx, after_msg
    mov ah, 9
    int 21h
    mov ah, 4Ch
    mov al, 0
    int 21h

not_enough:
    lea dx, msg_err_few
    mov ah, 9
    int 21h
    mov ah, 4Ch
    mov al, 4
    int 21h

; ---------- Utilidades ----------
prev_token db 0

; is_digit_al: usa AL, deja ZF según digit (JNZ si digit)

    cmp al, '0'
    jb .notdig
    cmp al, '9'
    ja .notdig
    ret
.notdig:
    xor al, al
    ret

; GET_STRING: lee linea de teclado via DOS AH=0Ah
; entrada: DI = destino (buffer), DX = max length (opcional)
; salida: escribe caracteres en [DI], seguido de CR (13) y 0
GET_STRING:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; llamada DOS buffered input
    lea dx, dos_inbuf
    mov ah, 0Ah
    int 21h

    ; preparar puntero fuente y longitud (byte en dos_inbuf+1)
    lea si, dos_inbuf+2
    mov cl, [dos_inbuf+1]
    xor ch, ch

    ; restaurar DI (destino) y copiar
    pop di
    cmp cx, 0
    je .write_cr
    rep movsb

.write_cr:
    mov byte [di], 13
    inc di
    mov byte [di], 0

    ; restaurar registros restantes
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; parse_number_from_si: devuelve AX y avanza SI
; soporta signo opcional + o - seguido de dígitos (al menos uno)
parse_number_from_si:
    push bx
    push cx
    push dx

    xor ax, ax
    mov byte [num_sign], 0

    mov al, [si]
    cmp al, '+'
    je .sign_plus
    cmp al, '-'
    jne .no_sign
    mov byte [num_sign], 1
    inc si
    jmp .no_sign
.sign_plus:
    inc si
.no_sign:
    xor cx, cx
.digit_loop:
    mov al, [si]
    cmp al, '0'
    jb .digits_done
    cmp al, '9'
    ja .digits_done
    mov cl, [si]
    sub cl, '0'
    mov ch, 0
    mov bx, 10
    mul bx        ; DX:AX = AX * 10
    add ax, cx
    inc si
    inc cx
    jmp .digit_loop
.digits_done:
    cmp cx, 0
    jne .apply_sign
    call syntax_error
.apply_sign:
    mov al, [num_sign]
    cmp al, 0
    je .retp
    neg ax
.retp:
    pop dx
    pop cx
    pop bx
    ret

; push operand (AX)
*** End of file
    push ax
    mov bx, [op_count]
    cmp bx, max_items
    jae stack_overflow
    lea si, operand_stack
    mov di, bx
    shl di, 1
    add si, di
    pop ax
    mov [si], ax
    inc word [op_count]
    inc word [total_operands]
    ret

; pop operand -> AX
pop_operand_into_ax:
    mov bx, [op_count]
    cmp bx, 0
    je syntax_error
    dec bx
    mov [op_count], bx
    lea si, operand_stack
    mov di, bx
    shl di, 1
    add si, di
    mov ax, [si]
    ret

; push operator (AL)

    mov bl, [opr_count]
    cmp bl, max_items
    jae stack_overflow
    lea si, operator_stack
    add si, bl
    mov [si], al
    inc byte [opr_count]
    ret

; pop operator -> AL
pop_operator_into_al:
    mov bl, [opr_count]
    cmp bl, 0
    je syntax_error
    dec bl
    mov [opr_count], bl
    lea si, operator_stack
    add si, bl
    mov al, [si]
    ret

; handle_new_operator: AL = operador entrante
; aplica operadores en stack según precedencia antes de apilar el nuevo
handle_new_operator:
    ; AL = newop
.loop_ops:
    mov bl, [opr_count]
    cmp bl, 0
    je .push_it
    ; obtener operador tope
    mov bh, bl
    dec bh
    lea si, operator_stack
    add si, bh
    mov dl, [si]
    ; si newop es '*' o '/', solo aplicar si top es '*' o '/'
    mov ah, al
    cmp ah, '*'
    je .is_muldiv
    cmp ah, '/'
    je .is_muldiv
    ; newop es + o - => aplicar cualquier operador top (left-assoc)
    call apply_top_operator
    jmp .loop_ops
.is_muldiv:
    cmp dl, '*'
    je .apply_top
    cmp dl, '/'
    je .apply_top
    jmp .push_it
.apply_top:
    call apply_top_operator
    jmp .loop_ops
.push_it:
    call push_operator_al
    ret

; aplicar todos los operadores restantes
apply_all_operators:
    mov bl, [opr_count]
    cmp bl, 0
    je .done_all
.loop_all:
    call apply_top_operator
    mov bl, [opr_count]
    cmp bl, 0
    jne .loop_all
.done_all:
    ret

; aplicar el operador tope: pop operator y dos operandos y calcular
apply_top_operator:
    call pop_operator_into_al ; AL = op
    call pop_operand_into_ax   ; AX = right operand (b)
    mov bx, ax                 ; BX = b
    call pop_operand_into_ax   ; AX = left operand (a)
    ; AX = a, BX = b
    cmp al, '+'
    je .do_add
    cmp al, '-'
    je .do_sub
    cmp al, '*'
    je .do_mul
    cmp al, '/'
    je .do_div
    jmp syntax_error
.do_add:
    add ax, bx
    jmp .push_res
.do_sub:
    sub ax, bx
    jmp .push_res
.do_mul:
    mov cx, bx
    imul cx    ; DX:AX = AX * CX
    ; tomamos AX como resultado (lo truncamos a 16-bit)
    jmp .push_res
.do_div:
    mov cx, bx
    cmp cx, 0
    je div_zero_error
    cwd
    idiv cx
    jmp .push_res
.div_zero_error:
    call div_zero_error
    ret
.push_res:
    call push_operand_ax
    ret

; errores y salidas
syntax_error:
    lea dx, msg_err_syn
    mov ah, 9
    int 21h
    mov ah, 4Ch
    mov al, 1
    int 21h

div_zero_error:
    lea dx, msg_err_div0
    mov ah, 9
    int 21h
    mov ah, 4Ch
    mov al, 2
    int 21h

stack_overflow:
    lea dx, msg_err_stack
    mov ah, 9
    int 21h
    mov ah, 4Ch
    mov al, 3
    int 21h

; imprimir AX como entero con signo (16-bit)
print_ax_signed:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    lea si, dec_buf
    ; colocar terminador inicial
    mov byte [si], '$'
    inc si
    ; si negativo, poner '-' y trabajar con valor absoluto
    mov bx, ax
    cmp bx, 0
    jge .conv_start
    neg bx
    mov byte [dec_buf], '-'
    ; ajustar si para escribir despues del signo
    lea si, dec_buf
    inc si
.conv_start:
    ; convertir BX a digitos (inversa)
    mov cx, 0
    mov ax, bx
    mov dx, 0
    mov bp, 10
    cmp ax, 0
    jne .conv_loop
    mov [si], '0'
    inc si
    inc cx
    jmp .conv_done
.conv_loop:
    xor dx, dx
    div bp
    add dl, '0'
    mov [si], dl
    inc si
    inc cx
    cmp ax, 0
    jne .conv_loop
.conv_done:
    ; invertir los digitos
    ; determinar inicio de digitos
    lea di, dec_buf
    cmp byte [di], '-'
    jne .no_sign_rev
    inc di
.no_sign_rev:
    ; di = inicio, si = fin (una past la ultima), cx = len
    dec si
.rev_loop:
    cmp di, si
    jge .rev_end
    mov al, [di]
    mov ah, [si]
    mov [di], ah
    mov [si], al
    inc di
    dec si
    jmp .rev_loop
.rev_end:
    ; imprimir
    lea dx, dec_buf
    mov ah, 9
    int 21h
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; fin

end start
