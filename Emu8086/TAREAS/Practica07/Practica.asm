include 'emu8086.inc'
org 100h
    jmp Principal

;============
;   Mensajes
;============
mensaje_inicio    db 'Programa generador de archivo .lst', 13, 10, 0
mensaje_menu      db 13, 10, '--- MENU ---', 13, 10
                  db '1. Mostrar directorio actual', 13, 10
                  db '2. Cambiar directorio', 13, 10
                  db '3. Listar archivos .asm', 13, 10
                  db '4. Procesar archivo', 13, 10
                  db '5. Salir', 13, 10
                  db 'Opcion: ', 0
mensaje_dirActual db 'Directorio actual: ', 0
mensaje_nuevoDir  db 'Ingrese ruta (ej: C./MiCarpeta o ./SubDir): ', 0
mensaje_nombre    db 'Ingrese nombre del archivo .asm: ', 0
mensaje_leyendo   db 'Leyendo archivo...', 13, 10, 0
mensaje_generando db 'Generando archivo .lst...', 13, 10, 0
mensaje_exito     db 'Archivo generado exitosamente!', 13, 10, 0
mensaje_err_abrir db 'ERROR: No se pudo abrir el archivo', 13, 10, 0
mensaje_err_crear db 'ERROR: No se pudo crear archivo de salida', 13, 10, 0
mensaje_err_leer  db 'ERROR: Error al leer archivo', 13, 10, 0
mensaje_err_dir   db 'ERROR: No se pudo cambiar directorio', 13, 10, 0
mensaje_err_ext   db 'ERROR: Nombre invalido. Debe terminar en .asm', 13, 10, 0
mensaje_err_creardir db 'ERROR: No se pudo crear directorio', 13, 10, 0
mensaje_crearDir  db 'Nombre del nuevo directorio: ', 0
mensaje_dirCreado db 'Directorio creado exitosamente!', 13, 10, 0
mensaje_infoCrear db 'Se creara en el directorio actual', 13, 10, 0
mensaje_debugRuta db 'Ruta convertida: ', 0
mensaje_archivos  db 13, 10, 'Archivos .asm en el directorio:', 13, 10, 0
mensaje_noAsm     db 'No se encontraron archivos .asm', 13, 10, 0
mascara_asm       db '*.asm', 0

;============
;   Variables
;============
nombre_entrada   db 64 dup(0)   ; nombre archivo entrada
nombre_salida    db 64 dup(0)   ; nombre archivo salida (.lst)
handle_entrada   dw 0            ; handle del archivo de entrada
handle_salida    dw 0            ; handle del archivo de salida
buffer_linea     db 256 dup(0)  ; buffer para una línea
longitud_linea   dw 0            ; longitud de la línea actual
acumulado        dw 0            ; caracteres acumulados
buffer_numero    db 4 dup(0)    ; buffer para el número de 3 dígitos + espacio
temp_char        db 0            ; caracter temporal
drive_str        db 2 dup(0)     ; buffer para imprimir letra de unidad + 0
opcion_menu      db 0            ; opción seleccionada del menú
buffer_dir       db 128 dup(0)  ; buffer para directorio actual
buffer_ruta      db 128 dup(0)  ; buffer para nueva ruta
dta_buffer       db 43 dup(0)   ; DTA para búsqueda de archivos
longitud_visible dw 0           ; longitud visible (sin CR/LF) de la línea
crlf             db 13, 10      ; fin de línea para escribir totales
search_path      db 256 dup(0)  ; buffer para construir ruta absoluta X:\path\*.asm

;==============
;   Subrutinas
;==============

;------ SUBRUTINA: mostrar_directorio_actual ------
; Muestra el directorio de trabajo actual
; Usa: INT 21h función 47h
mostrar_directorio_actual:
    push ax
    push dx
    push si
    
    ; Obtener directorio actual
    mov ah, 47h         ; función DOS: obtener directorio actual
    mov dl, 0           ; 0 = drive actual
    lea si, buffer_dir
    int 21h
    
    ; Imprimir mensaje
    lea si, mensaje_dirActual
    call print_string
    
    ; Imprimir letra de unidad
    mov ah, 19h         ; obtener drive actual
    int 21h
    add al, 'A'
    mov [drive_str], al
    mov byte ptr [drive_str+1], 0
    lea si, drive_str
    call print_string
    print ':'
    
    ; Imprimir directorio (AH=47h devuelve ruta comenzando con '\\')
    lea si, buffer_dir
    call print_string
    printn ""
    
    pop si
    pop dx
    pop ax
    ret


;------ SUBRUTINA: cambiar_directorio ------
; Cambia al directorio especificado por el usuario
; Entrada: buffer_ruta con la ruta
; Salida: CF=1 si error
cambiar_directorio:
    push ax
    push dx
    
    mov ah, 3Bh         ; función DOS: cambiar directorio
    lea dx, buffer_ruta
    int 21h
    
    pop dx
    pop ax
    ret


;------ SUBRUTINA: crear_directorio ------
; Crea un directorio en la ubicación actual
; Entrada: buffer_ruta con el nombre del directorio (sin rutas completas)
; Salida: CF=1 si error
crear_directorio:
    push ax
    push dx
    
    mov ah, 39h         ; función DOS: crear directorio
    lea dx, buffer_ruta
    int 21h
    
    pop dx
    pop ax
    ret


;------ SUBRUTINA: convertir_slash_a_backslash ------
; Reemplaza todos los caracteres '/' por '\\' en buffer_ruta
; Además, si la cadena inicia con <letra>'.', lo convierte a <letra>':'
; Normaliza: elimina duplicados de '\\' y recorta espacios/barras al final
; Entrada: buffer_ruta (string terminado en 0)
; Salida:  buffer_ruta modificado in-place
convertir_slash_a_backslash:
    push ax
    push bx
    push si
    push di

    lea si, buffer_ruta

    ;--- Soporte de ruta relativa ./SubDir -> X:\ruta\actual\SubDir ---
    mov al, [si]
    cmp al, '.'
    jne .csab_check_drivepattern
    mov ah, [si+1]
    cmp ah, '/'
    je .csab_build_rel
    cmp ah, 92            ; '\\'
    je .csab_build_rel
    jmp .csab_check_drivepattern

.csab_build_rel:
    ; Obtener directorio actual en buffer_dir (usar SI para INT 21h/47h)
    mov ah, 47h
    mov dl, 0
    lea si, buffer_dir
    int 21h                ; DOS usa DS:SI, antes se usaba DI por error
    ; Obtener unidad actual
    mov ah, 19h
    int 21h
    add al, 'A'
    lea di, search_path
    mov [di], al           ; X
    inc di
    mov byte ptr [di], ':' ; X:
    inc di
    mov byte ptr [di], 92  ; X:\
    inc di
    ; Copiar buffer_dir saltando primer '\\' si existiera
    lea si, buffer_dir
    mov al, [si]
    cmp al, 92
    jne .csab_copy_cdir
    inc si                 ; saltar barra inicial
.csab_copy_cdir:
    mov al, [si]
    cmp al, 0
    je .csab_after_cdir
    mov [di], al
    inc si
    inc di
    jmp .csab_copy_cdir
.csab_after_cdir:
    ; Asegurar separador antes de resto
    dec di
    mov al,[di]
    inc di
    cmp al,92
    je .csab_have_sep
    mov byte ptr [di],92
    inc di
.csab_have_sep:
    ; Copiar resto tras "./"
    lea si, buffer_ruta
    add si, 2
.csab_copy_rest_rel:
    mov al,[si]
    mov [di],al
    cmp al,0
    je .csab_overwrite_rel
    inc si
    inc di
    jmp .csab_copy_rest_rel
.csab_overwrite_rel:
    ; Copiar search_path a buffer_ruta
    lea si, search_path
    lea di, buffer_ruta
.csab_cp_back_rel:
    mov al,[si]
    mov [di],al
    inc si
    inc di
    cmp al,0
    jne .csab_cp_back_rel
    ; Reiniciar SI para continuar flujo normal (reemplazo de '/','\\' normalización)
    lea si, buffer_ruta

.csab_check_drivepattern:

    ; Si comienza con <letra>'.' convertir a <letra>':'
    mov al, [si]
    cmp al, 0
    je .csab_normalize     ; cadena vacía
    mov ah, [si+1]
    cmp ah, '.'
    jne .csab_loop
    mov byte ptr [si+1], ':'

.csab_loop:
    ; Reemplazar '/' con '\'
    mov al, [si]
    cmp al, 0
    je .csab_normalize
    cmp al, '/'
    jne .csab_next
    mov byte ptr [si], 92      ; '\\' = ASCII 92
.csab_next:
    inc si
    jmp .csab_loop

.csab_normalize:
    ; Eliminar duplicados de '\' y recortar trailing '\'  y espacios
    lea si, buffer_ruta
    lea di, buffer_ruta
    xor bx, bx              ; BX = último carácter no-backslash

.csab_norm_loop:
    mov al, [si]
    cmp al, 0
    je .csab_trim
    
    ; Si es '\', verificar si el anterior también lo era
    cmp al, 92              ; '\'
    jne .csab_norm_copy
    
    ; Verificar si DI apunta a una posición donde ya hay '\'
    cmp di, offset buffer_ruta
    je .csab_norm_copy      ; primera posición, copiar
    mov ah, [di-1]
    cmp ah, 92
    je .csab_norm_skip      ; duplicado, omitir
    
.csab_norm_copy:
    mov [di], al
    inc di
    ; Recordar posición si no es '\' ni espacio
    cmp al, 92
    je .csab_norm_continue
    cmp al, ' '
    je .csab_norm_continue
    mov bx, di              ; BX = última posición de carácter significativo
    
.csab_norm_continue:
.csab_norm_skip:
    inc si
    jmp .csab_norm_loop

.csab_trim:
    ; Recortar trailing '\' y espacios (excepto si es C:\ raíz)
    cmp di, offset buffer_ruta
    je .csab_done           ; cadena vacía
    
    ; Retroceder DI eliminando '\' y espacios al final
.csab_trim_loop:
    cmp di, offset buffer_ruta
    jbe .csab_done
    dec di
    mov al, [di]
    cmp al, 92              ; '\'
    je .csab_check_root
    cmp al, ' '
    je .csab_trim_loop
    ; No es '\' ni espacio, restaurar y salir
    inc di
    jmp .csab_done
    
.csab_check_root:
    ; Si es '\' verificar si es raíz (C:\)
    cmp di, offset buffer_ruta + 2
    jne .csab_trim_loop     ; no es raíz, eliminar
    ; Es raíz, restaurar y salir
    inc di
    jmp .csab_done

.csab_done:
    ; Terminar cadena
    mov byte ptr [di], 0

    pop di
    pop si
    pop bx
    pop ax
    ret
;------ SUBRUTINA: listar_archivos_asm ------
; Lista todos los archivos .asm en el directorio actual
; Usa: INT 21h funciones 1Ah (set DTA), 4Eh (find first), 4Fh (find next)
listar_archivos_asm:
    push ax
    push cx
    push dx
    push si
    push di
    
    ; Construir ruta absoluta X:\path\*.asm en search_path
    ; 1) Obtener unidad actual
    mov ah, 19h
    int 21h
    add al, 'A'
    lea di, search_path
    mov [di], al
    inc di
    mov byte ptr [di], ':'
    inc di
    mov byte ptr [di], 92  ; backslash
    inc di
    
    ; 2) Obtener directorio actual
    mov ah, 47h
    mov dl, 0
    lea si, buffer_dir
    int 21h
    
    ; 3) Copiar directorio a search_path
    lea si, buffer_dir
.laa_cp_dir:
    mov al, [si]
    cmp al, 0
    je .laa_add_mask
    mov [di], al
    inc si
    inc di
    jmp .laa_cp_dir
    
.laa_add_mask:
    ; 4) Asegurar separador antes de *.asm
    cmp di, offset search_path+3  ; justo después de X:\
    je .laa_append
    dec di
    mov al, [di]
    inc di
    cmp al, 92
    je .laa_append
    mov byte ptr [di], 92
    inc di
    
.laa_append:
    ; 5) Anexar *.asm
    mov byte ptr [di], '*'
    inc di
    mov byte ptr [di], '.'
    inc di
    mov byte ptr [di], 'a'
    inc di
    mov byte ptr [di], 's'
    inc di
    mov byte ptr [di], 'm'
    inc di
    mov byte ptr [di], 0
    
    ; Establecer DTA
    mov ah, 1Ah
    lea dx, dta_buffer
    int 21h
    
    ; Buscar primer archivo con ruta absoluta
    mov ah, 4Eh         ; find first
    mov cx, 0           ; atributos: archivos normales
    lea dx, search_path
    int 21h
    jc .laa_no_archivos
    
    ; Imprimir encabezado
    lea si, mensaje_archivos
    call print_string
    
.laa_mostrar:
    ; El nombre del archivo está en DTA offset 30 (1Eh)
    lea si, dta_buffer
    add si, 30
    call print_string
    printn ""
    
    ; Buscar siguiente
    mov ah, 4Fh         ; find next
    int 21h
    jnc .laa_mostrar
    jmp .laa_fin

.laa_no_archivos:
    ; Mostrar mensaje explícito si no hay archivos
    lea si, mensaje_noAsm
    call print_string
    printn ""

.laa_fin:
    pop di
    pop si
    pop dx
    pop cx
    pop ax
    ret


;------ SUBRUTINA: construir_nombre_salida ------
; Toma el nombre del archivo de entrada y genera el nombre de salida
; cambiando la extensión .asm por .lst
; Entrada: nombre_entrada (string terminado en 0)
; Salida: nombre_salida (string terminado en 0)
construir_nombre_salida:
    push ax
    push si
    push di
    
    lea si, nombre_entrada
    lea di, nombre_salida
    
    ; Copiar hasta encontrar el punto o fin de cadena
.cns_copiar:
    mov al, [si]
    cmp al, 0
    je .cns_agregar_ext
    cmp al, '.'
    je .cns_agregar_ext
    mov [di], al
    inc si
    inc di
    jmp .cns_copiar
    
.cns_agregar_ext:
    ; Agregar extensión .lst
    mov byte ptr [di], '.'
    inc di
    mov byte ptr [di], 'l'
    inc di
    mov byte ptr [di], 's'
    inc di
    mov byte ptr [di], 't'
    inc di
    mov byte ptr [di], 0
    
    pop di
    pop si
    pop ax
    ret


;------ SUBRUTINA: abrir_archivo_entrada ------
; Abre el archivo de entrada en modo lectura
; Entrada: nombre_entrada
; Salida: handle_entrada (0 si error)
abrir_archivo_entrada:
    push ax
    push bx
    push dx
    push si
    push di
    ; Construir ruta absoluta si nombre_entrada no es absoluto
    lea si, nombre_entrada
    mov al, [si]
    mov ah, [si+1]
    cmp ah, ':'
    je .aae_use_input         ; ya es X:...
    cmp al, 92                ; empieza con '\\' ? -> raíz de unidad actual
    je .aae_rooted
    ; relativo: X:\buffer_dir\nombre
    mov ah, 19h
    int 21h
    add al, 'A'
    lea di, search_path
    mov [di], al
    inc di
    mov byte ptr [di], ':'
    inc di
    mov byte ptr [di], 92
    inc di
    ; obtener dir actual
    mov ah, 47h
    mov dl, 0
    lea si, buffer_dir
    int 21h
    ; copiar buffer_dir
    lea si, buffer_dir
.aae_cp_dir:
    mov al, [si]
    cmp al, 0
    je .aae_sep
    mov [di], al
    inc si
    inc di
    jmp .aae_cp_dir
.aae_sep:
    dec di
    mov al, [di]
    inc di
    cmp al, 92
    je .aae_append_name
    mov byte ptr [di], 92
    inc di
.aae_append_name:
    ; anexar nombre_entrada
    lea si, nombre_entrada
.aae_cp_name:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    cmp al, 0
    jne .aae_cp_name
    lea dx, search_path
    jmp .aae_do_open

.aae_rooted:
    ; construir X: + nombre_entrada (que empieza con '\\')
    mov ah, 19h
    int 21h
    add al, 'A'
    lea di, search_path
    mov [di], al
    inc di
    mov byte ptr [di], ':'
    inc di
    ; copiar nombre_entrada tal como viene (con '\\' inicial)
    lea si, nombre_entrada
.aae_cp_root:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    cmp al, 0
    jne .aae_cp_root
    lea dx, search_path
    jmp .aae_do_open

.aae_use_input:
    lea dx, nombre_entrada

.aae_do_open:
    mov ah, 3Dh         ; función DOS: abrir archivo
    mov al, 0           ; modo: solo lectura
    int 21h
    
    jc .aae_error       ; si carry set, hubo error
    mov [handle_entrada], ax
    jmp .aae_fin
    
.aae_error:
    mov word ptr [handle_entrada], 0
    
.aae_fin:
    pop di
    pop si
    pop dx
    pop bx
    pop ax
    ret

;------ SUBRUTINA: crear_archivo_salida ------
; Crea el archivo de salida en modo escritura
; Entrada: nombre_salida
; Salida: handle_salida (0 si error)
crear_archivo_salida:
    push ax
    push cx
    push bx
    push dx
    push si
    push di
    ; Construir ruta absoluta si nombre_salida no es absoluta
    lea si, nombre_salida
    mov al, [si]
    mov ah, [si+1]
    cmp ah, ':'
    je .cas_use_input
    cmp al, 92
    je .cas_rooted
    ; relativo: X:\buffer_dir\nombre_salida
    mov ah, 19h
    int 21h
    add al, 'A'
    lea di, search_path
    mov [di], al
    inc di
    mov byte ptr [di], ':'
    inc di
    mov byte ptr [di], 92
    inc di
    mov ah, 47h
    mov dl, 0
    lea si, buffer_dir
    int 21h
    lea si, buffer_dir
.cas_cp_dir:
    mov al, [si]
    cmp al, 0
    je .cas_sep
    mov [di], al
    inc si
    inc di
    jmp .cas_cp_dir
.cas_sep:
    dec di
    mov al, [di]
    inc di
    cmp al, 92
    je .cas_append
    mov byte ptr [di], 92
    inc di
.cas_append:
    lea si, nombre_salida
.cas_cp_name:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    cmp al, 0
    jne .cas_cp_name
    lea dx, search_path
    jmp .cas_do_create

.cas_rooted:
    mov ah, 19h
    int 21h
    add al, 'A'
    lea di, search_path
    mov [di], al
    inc di
    mov byte ptr [di], ':'
    inc di
    lea si, nombre_salida
.cas_cp_root:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    cmp al, 0
    jne .cas_cp_root
    lea dx, search_path
    jmp .cas_do_create

.cas_use_input:
    lea dx, nombre_salida

.cas_do_create:
    mov ah, 3Ch         ; función DOS: crear archivo
    mov cx, 0           ; atributos: normal
    int 21h
    
    jc .cas_error
    mov [handle_salida], ax
    jmp .cas_fin
    
.cas_error:
    mov word ptr [handle_salida], 0
    
.cas_fin:
    pop di
    pop si
    pop dx
    pop bx
    pop cx
    pop ax
    ret


;------ SUBRUTINA: leer_linea ------
; Lee una línea del archivo de entrada (hasta encontrar CR/LF o EOF)
; Entrada: handle_entrada
; Salida: buffer_linea con la línea leída
;         longitud_linea = número de caracteres (incluyendo CR/LF)
;         CF=1 si EOF o error
leer_linea:
    push ax
    push bx
    push cx
    push dx
    push si
    
    lea si, buffer_linea
    xor cx, cx          ; contador de caracteres
    
.ll_leer_char:
    ; Leer un caracter
    mov ah, 3Fh         ; función DOS: leer archivo
    mov bx, [handle_entrada]
    mov dx, si
    mov cx, 1
    int 21h
    
    jc .ll_error        ; error de lectura
    cmp ax, 0           ; EOF?
    je .ll_eof
    
    ; Caracter leído correctamente
    mov al, [si]
    inc si
    mov ax, [longitud_linea]
    inc ax
    mov [longitud_linea], ax
    
    ; Verificar si es LF (fin de línea)
    dec si
    mov al, [si]
    inc si
    cmp al, 10          ; LF
    je .ll_fin_linea
    
    jmp .ll_leer_char
    
.ll_fin_linea:
    clc                 ; clear carry (éxito)
    jmp .ll_salir
    
.ll_eof:
    ; Si leímos algo antes del EOF, es una línea válida
    cmp word ptr [longitud_linea], 0
    je .ll_error
    clc
    jmp .ll_salir
    
.ll_error:
    stc                 ; set carry (error/EOF)
    
.ll_salir:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret


;------ SUBRUTINA: convertir_numero ------
; Convierte un número de 0-999 a string de 3 dígitos
; Entrada: AX = número
; Salida: buffer_numero con 3 dígitos + 0
convertir_numero:
    push ax
    push bx
    push cx
    push dx
    push di
    
    lea di, buffer_numero
    mov cx, 3           ; 3 dígitos
    
.cn_extraer:
    xor dx, dx
    mov bx, 10
    div bx              ; AX = AX/10, DX = resto
    push dx             ; guardar dígito
    loop .cn_extraer
    
    ; Escribir dígitos en orden correcto
    lea di, buffer_numero
    pop dx
    add dl, '0'
    mov [di], dl
    inc di
    pop dx
    add dl, '0'
    mov [di], dl
    inc di
    pop dx
    add dl, '0'
    mov [di], dl
    inc di
    mov byte ptr [di], 0
    
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret


;------ SUBRUTINA: escribir_linea_salida ------
; Escribe en el archivo de salida: número de 3 dígitos + contenido de línea
; Entrada: handle_salida, acumulado, buffer_linea, longitud_linea
escribir_linea_salida:
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; Convertir acumulado a string de 3 dígitos
    mov ax, [acumulado]
    call convertir_numero
    
    ; Escribir número (3 dígitos)
    mov ah, 40h         ; función DOS: escribir archivo
    mov bx, [handle_salida]
    lea dx, buffer_numero
    mov cx, 3
    int 21h
    
    ; Escribir espacio
    mov byte ptr [temp_char], ' '
    mov ah, 40h
    mov bx, [handle_salida]
    lea dx, temp_char
    mov cx, 1
    int 21h
    
    ; Escribir contenido de la línea
    mov ah, 40h
    mov bx, [handle_salida]
    lea dx, buffer_linea
    mov cx, [longitud_linea]
    int 21h

    ; Asegurar fin de línea: si la línea no termina con LF (10), agregar CRLF
    mov ax, [longitud_linea]
    cmp ax, 0
    je .esl_write_crlf
    lea si, buffer_linea
    mov bx, [longitud_linea]
    dec bx
    add si, bx
    mov al, [si]
    cmp al, 10          ; LF?
    je .esl_skip_add
.esl_write_crlf:
    mov ah, 40h
    mov bx, [handle_salida]
    lea dx, crlf
    mov cx, 2
    int 21h
.esl_skip_add:
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret


;------ SUBRUTINA: escribir_total_final ------
; Escribe solo el total acumulado como número de 3 dígitos y CRLF
; Entrada: handle_salida, acumulado
escribir_total_final:
    push ax
    push bx
    push cx
    push dx

    ; Convertir acumulado
    mov ax, [acumulado]
    call convertir_numero

    ; Escribir número (3 dígitos)
    mov ah, 40h
    mov bx, [handle_salida]
    lea dx, buffer_numero
    mov cx, 3
    int 21h

    ; Escribir CRLF
    mov ah, 40h
    mov bx, [handle_salida]
    lea dx, crlf
    mov cx, 2
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret


;------ SUBRUTINA: validar_extension_asm ------
; Verifica que nombre_entrada termine exactamente en .ASM (insensible a mayúsculas)
; Entrada: nombre_entrada (0-terminado)
; Salida: CF=0 válido, CF=1 inválido
validar_extension_asm:
    push ax
    push bx
    push si

    xor bx, bx              ; BX=0 si no hay punto
    lea si, nombre_entrada
.vea_scan:
    mov al, [si]
    cmp al, 0
    je .vea_check
    cmp al, '.'
    jne .vea_next
    mov bx, si              ; guardar posición del último punto
.vea_next:
    inc si
    jmp .vea_scan

.vea_check:
    cmp bx, 0
    je .vea_invalid         ; no hay punto
    mov si, bx
    inc si                  ; SI = después del '.'

    mov al, [si]
    cmp al, 0
    je .vea_invalid
    and al, 0DFh            ; a mayúscula
    cmp al, 'A'
    jne .vea_invalid
    inc si

    mov al, [si]
    cmp al, 0
    je .vea_invalid
    and al, 0DFh
    cmp al, 'S'
    jne .vea_invalid
    inc si

    mov al, [si]
    cmp al, 0
    je .vea_invalid
    and al, 0DFh
    cmp al, 'M'
    jne .vea_invalid
    inc si

    mov al, [si]
    cmp al, 0              ; debe terminar aquí
    jne .vea_invalid

    clc
    jmp .vea_end

.vea_invalid:
    stc

.vea_end:
    pop si
    pop bx
    pop ax
    ret


;------ SUBRUTINA: cerrar_archivos ------
; Cierra ambos archivos si están abiertos
cerrar_archivos:
    push ax
    push bx
    
    ; Cerrar archivo de entrada
    cmp word ptr [handle_entrada], 0
    je .ca_skip_entrada
    mov ah, 3Eh
    mov bx, [handle_entrada]
    int 21h
    
.ca_skip_entrada:
    ; Cerrar archivo de salida
    cmp word ptr [handle_salida], 0
    je .ca_skip_salida
    mov ah, 3Eh
    mov bx, [handle_salida]
    int 21h
    
.ca_skip_salida:
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
    ; Mensaje de inicio
    lea si, mensaje_inicio
    call print_string
    
.menu_principal:
    ; Mostrar menú
    lea si, mensaje_menu
    call print_string
    
    ; Leer opción (un solo caracter)
    mov ah, 01h
    int 21h
    mov [opcion_menu], al
    printn ""
    
    ; Procesar opción
    cmp byte ptr [opcion_menu], '1'
    je .opcion_mostrar_dir
    cmp byte ptr [opcion_menu], '2'
    je .opcion_cambiar_dir
    cmp byte ptr [opcion_menu], '3'
    je .opcion_listar
    cmp byte ptr [opcion_menu], '4'
    je .opcion_procesar
    cmp byte ptr [opcion_menu], '5'
    je .salir
    
    ; Opción inválida
    printn "Opcion invalida"
    jmp .menu_principal
    
.opcion_mostrar_dir:
    call mostrar_directorio_actual
    jmp .menu_principal
    
.opcion_cambiar_dir:
    ; Solicitar nueva ruta
    lea si, mensaje_nuevoDir
    call print_string
    
    lea di, buffer_ruta
    mov dx, 120
    call get_string
    
    ; Convertir posibles '/' a '\' para DOS
    call convertir_slash_a_backslash
    
    ; Mostrar ruta convertida para verificar
    lea si, mensaje_debugRuta
    call print_string
    lea si, buffer_ruta
    call print_string
    printn ""
    
    call cambiar_directorio
    jnc .cambio_ok
    
    lea si, mensaje_err_dir
    call print_string
    jmp .menu_principal
    
.cambio_ok:
    printn "Directorio cambiado exitosamente"
    ; Mostrar directorio actual para confirmar
    call mostrar_directorio_actual
    jmp .menu_principal
    
.opcion_listar:
    call listar_archivos_asm
    jmp .menu_principal
    
.opcion_procesar:
    ; Solicitar nombre de archivo
    lea si, mensaje_nombre
    call print_string
    
    lea di, nombre_entrada
    mov dx, 60
    call get_string

    ; Mostrar ruta/archivo elegido (debug)
    print 'Nombre ingresado: '
    lea si, nombre_entrada
    call print_string
    printn ''
    
    ; Validar que termine en .asm
    call validar_extension_asm
    jnc .ext_ok
    lea si, mensaje_err_ext
    call print_string
    jmp .menu_principal
    
.ext_ok:
    ; Asegurar que cambios de directorio previos se reflejen en apertura usando ruta relativa + directorio actual
    ; Si nombre_entrada no contiene ':' asumimos relativo y no modificamos; DOS resolverá en CWD.
    ; (Opcional futuro: construir absoluto si necesario.)
    
    ; Construir nombre de salida
    call construir_nombre_salida
    
    ; Abrir archivo de entrada
    lea si, mensaje_leyendo
    call print_string
    
    call abrir_archivo_entrada
    cmp word ptr [handle_entrada], 0
    je .error_abrir
    
    ; Crear archivo de salida
    lea si, mensaje_generando
    call print_string
    
    call crear_archivo_salida
    cmp word ptr [handle_salida], 0
    je .error_crear
    
    ; Inicializar acumulado
    mov word ptr [acumulado], 0
    
    ; Procesar archivo línea por línea
.procesar_lineas:
    ; Limpiar buffer y longitud
    mov word ptr [longitud_linea], 0
    lea di, buffer_linea
    mov cx, 256
    xor al, al
    rep stosb
    
    ; Leer línea
    call leer_linea
    jc .fin_archivo     ; si CF=1, fin de archivo o error
    
    ; Calcular longitud visible (sin CR/LF)
    mov ax, [longitud_linea]
    mov [longitud_visible], ax
    cmp ax, 0
    je .lv_done
    lea si, buffer_linea
    mov bx, [longitud_linea]
    dec bx
    add si, bx          ; SI = último carácter leído
    mov al, [si]
    cmp al, 10          ; LF
    jne .chk_cr
    dec word ptr [longitud_visible]
.chk_cr:
    mov ax, [longitud_visible]
    cmp ax, 0
    je .lv_done
    dec si
    mov al, [si]
    cmp al, 13          ; CR
    jne .lv_done
    dec word ptr [longitud_visible]
.lv_done:
    
    ; Escribir línea en salida con acumulado PREVIO
    call escribir_linea_salida
    
    ; Actualizar acumulado sumando solo la longitud visible
    mov ax, [acumulado]
    add ax, [longitud_visible]
    mov [acumulado], ax
    
    jmp .procesar_lineas
    
.fin_archivo:
    ; Escribir total final (acumulado)
    call escribir_total_final
    
    ; Cerrar archivos
    call cerrar_archivos
    
    ; Mensaje de éxito
    lea si, mensaje_exito
    call print_string
    jmp .menu_principal
    
.error_abrir:
    lea si, mensaje_err_abrir
    call print_string
    jmp .menu_principal
    
.error_crear:
    call cerrar_archivos
    lea si, mensaje_err_crear
    call print_string
    jmp .menu_principal
    
.salir:
    ; Salir al Sistema Operativo
    mov ax, 4C00h
    int 21h
    ret
