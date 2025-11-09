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
mensaje_nuevoDir  db 'Ingrese ruta (ej: C:\MiCarpeta): ', 0
mensaje_nombre    db 'Ingrese nombre del archivo .asm: ', 0
mensaje_leyendo   db 'Leyendo archivo...', 13, 10, 0
mensaje_generando db 'Generando archivo .lst...', 13, 10, 0
mensaje_exito     db 'Archivo generado exitosamente!', 13, 10, 0
mensaje_err_abrir db 'ERROR: No se pudo abrir el archivo', 13, 10, 0
mensaje_err_crear db 'ERROR: No se pudo crear archivo de salida', 13, 10, 0
mensaje_err_leer  db 'ERROR: Error al leer archivo', 13, 10, 0
mensaje_err_dir   db 'ERROR: No se pudo cambiar directorio', 13, 10, 0
mensaje_archivos  db 13, 10, 'Archivos .asm en el directorio:', 13, 10, 0
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
opcion_menu      db 0            ; opción seleccionada del menú
buffer_dir       db 128 dup(0)  ; buffer para directorio actual
buffer_ruta      db 128 dup(0)  ; buffer para nueva ruta
dta_buffer       db 43 dup(0)   ; DTA para búsqueda de archivos

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
    mov [temp_char], al
    lea si, temp_char
    call print_string
    print ':'
    print '\'
    
    ; Imprimir directorio
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


;------ SUBRUTINA: listar_archivos_asm ------
; Lista todos los archivos .asm en el directorio actual
; Usa: INT 21h funciones 1Ah (set DTA), 4Eh (find first), 4Fh (find next)
listar_archivos_asm:
    push ax
    push cx
    push dx
    push si
    
    ; Establecer DTA
    mov ah, 1Ah
    lea dx, dta_buffer
    int 21h
    
    ; Buscar primer archivo
    mov ah, 4Eh         ; find first
    mov cx, 0           ; atributos: archivos normales
    lea dx, mascara_asm
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
    
.laa_no_archivos:
    printn ""
    
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
    push dx
    
    mov ah, 3Dh         ; función DOS: abrir archivo
    mov al, 0           ; modo: solo lectura
    lea dx, nombre_entrada
    int 21h
    
    jc .aae_error       ; si carry set, hubo error
    mov [handle_entrada], ax
    jmp .aae_fin
    
.aae_error:
    mov word ptr [handle_entrada], 0
    
.aae_fin:
    pop dx
    pop ax
    ret


;------ SUBRUTINA: crear_archivo_salida ------
; Crea el archivo de salida en modo escritura
; Entrada: nombre_salida
; Salida: handle_salida (0 si error)
crear_archivo_salida:
    push ax
    push cx
    push dx
    
    mov ah, 3Ch         ; función DOS: crear archivo
    mov cx, 0           ; atributos: normal
    lea dx, nombre_salida
    int 21h
    
    jc .cas_error
    mov [handle_salida], ax
    jmp .cas_fin
    
.cas_error:
    mov word ptr [handle_salida], 0
    
.cas_fin:
    pop dx
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
    
    pop si
    pop dx
    pop cx
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
    
    call cambiar_directorio
    jnc .cambio_ok
    
    lea si, mensaje_err_dir
    call print_string
    jmp .menu_principal
    
.cambio_ok:
    printn "Directorio cambiado exitosamente"
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
    
    ; Actualizar acumulado
    mov ax, [acumulado]
    add ax, [longitud_linea]
    mov [acumulado], ax
    
    ; Escribir línea en salida
    call escribir_linea_salida
    
    jmp .procesar_lineas
    
.fin_archivo:
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
