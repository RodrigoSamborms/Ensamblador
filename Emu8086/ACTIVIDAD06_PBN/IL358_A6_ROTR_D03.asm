; ACTIVIAD05_PBN.asm - Manejo de directorios y archivos (tipo .COM)
; Autor: Rodrigo Samborms
; Fecha: 21 de Octubre, 2025

ORG 100h                                  ; Programas .COM inician en 100h

; Saltar sobre datos y procedimientos
JMP INICIO

; ============================================================
; DATOS DEL PROGRAMA
; ============================================================
rutaDirectorio db 'C:\emu8086\MyBuild\Rodrigo', 0
rutaArchivo    db 'C:\emu8086\MyBuild\Rodrigo\Torres.txt', 0
rutaPadre      db 'C:\emu8086\MyBuild', 0

msgEncabezado  db 'ACTIVIAD05_PBN - Directorios y Archivos', 0Dh, 0Ah, '$'
msgCrearDir    db 0Dh, 0Ah, 'Creando directorio: C:\emu8086\MyBuild\Rodrigo', 0Dh, 0Ah, '$'
msgDirCreado   db 'Directorio creado (o ya existente).', 0Dh, 0Ah, '$'
msgDirError    db 'ERROR al crear directorio.', 0Dh, 0Ah, '$'
msgDirExiste   db 'Directorio existente, la bandera CF se ha activado.', 0Dh, 0Ah, '$'
msgDirErrorCF  db 'ERROR al crear directorio, la bandera CF se ha activado.', 0Dh, 0Ah, '$'

msgCrearArchivo db 0Dh, 0Ah, 'Creando archivo y escribiendo fecha...', 0Dh, 0Ah, '$'
msgArchivoOk    db 'Escritura OK.', 0Dh, 0Ah, '$'
msgArchivoError db 'ERROR al crear/escribir/cerrar archivo.', 0Dh, 0Ah, '$'
msgArchivoExiste db 'Archivo existente (CREATE fallo), la bandera CF se ha activado. Se abrira para escribir.', 0Dh, 0Ah, '$'

msgCambiarDir   db 'Regresando al directorio padre...', 0Dh, 0Ah, '$'
msgDirCambiado  db 'Directorio cambiado a: C:\emu8086\MyBuild', 0Dh, 0Ah, '$'
msgErrorCambio  db 'ERROR al cambiar de directorio.', 0Dh, 0Ah, '$'

msgLeerArchivo  db 0Dh, 0Ah, 'Leyendo archivo...', 0Dh, 0Ah, '$'
msgContenidoLeido db 'Contenido leido:', 0Dh, 0Ah, '$'
msgLeerError    db 'ERROR al abrir/leer archivo.', 0Dh, 0Ah, '$'
msgArchivoVacio db 'Aviso: el archivo esta vacio.', 0Dh, 0Ah, '$'

msgFin         db 0Dh, 0Ah, 'Fin del programa.', 0Dh, 0Ah, '$'

; Buffer para fecha en formato DD/MM/AAAA + CRLF
bufferFecha   db 16 dup(0)
longitudFecha dw 0

manejador   dw 0
bytesLeidos dw 0
bufferLectura db 128 dup(0)

; ============================================================
; PROCEDIMIENTOS
; ============================================================

; Imprime cadena terminada en '$' apuntada por DX
ImprimirCadena PROC
push ax
mov ah, 09h
int 21h
pop ax
ret
ImprimirCadena ENDP

; Imprime CRLF
ImprimirCRLF PROC
push ax
push dx
mov dx, 0
mov dl, 0Dh
mov ah, 02h
int 21h
mov dl, 0Ah
mov ah, 02h
int 21h
pop dx
pop ax
ret
ImprimirCRLF ENDP

; Imprime CX bytes de DS:SI
ImprimirBuffer PROC
push ax
push dx
push cx
push si
@@loop:
cmp cx, 0
je @@done
lodsb
mov dl, al
mov ah, 02h
int 21h
dec cx
jmp @@loop
@@done:
pop si
pop cx
pop dx
pop ax
ret
ImprimirBuffer ENDP

; Convierte en AL (0..99) a dos digitos ASCII con cero a la izquierda, escribe en [DI] y avanza DI
DosDigitos PROC
; Entrada: AL = valor 0..99, DI = destino
; Salida: [DI]=tensASCII, [DI+1]=unitsASCII, DI += 2, AX modificado
aam                 ; AH = AL/10, AL = AL%10 (base 10)
add ah, '0'
add al, '0'
mov [di], ah
mov [di+1], al
add di, 2
ret
DosDigitos ENDP

; Convierte AX (0..9999) a 4 digitos ASCII, escribe en [DI] y avanza DI
CuatroDigitos PROC
; Entrada: AX = valor, DI = destino
; Salida: escribe 4 ASCII, DI += 4, AX, BX, DX modificados
push bx
push dx
mov bx, 1000
xor dx, dx
div bx             ; AX/1000 -> AX=thousands, DX=rem
add al, '0'
mov [di], al
inc di
mov ax, dx
mov bx, 100
xor dx, dx
div bx             ; hundreds
add al, '0'
mov [di], al
inc di
mov ax, dx
mov bx, 10
xor dx, dx
div bx             ; tens
add al, '0'        ; AL = tens digit
mov [di], al
inc di
mov al, dl         ; DL = units remainder
add al, '0'
mov [di], al
inc di
pop dx
pop bx
ret
CuatroDigitos ENDP

; Construye fecha en dateBuf como DD/MM/AAAA seguido de CRLF, y deja longitud en dateLen
ConstruirFecha PROC
push ax
push bx
push cx
push dx
push di
mov ah, 2Ah        ; DOS Get Date
int 21h            ; CX=year, DH=month, DL=day
lea di, bufferFecha
mov al, dl         ; day
call DosDigitos
mov byte ptr [di], '/'
inc di
mov al, dh         ; month
call DosDigitos
mov byte ptr [di], '/'
inc di
mov ax, cx         ; year
call CuatroDigitos
; CRLF
mov byte ptr [di], 0Dh
inc di
mov byte ptr [di], 0Ah
inc di
; dateLen = DI - dateBuf
mov ax, di
sub ax, offset bufferFecha
mov [longitudFecha], ax
pop di
pop dx
pop cx
pop bx
pop ax
ret
ConstruirFecha ENDP

; ============================================================
; CODIGO PRINCIPAL
; ============================================================
INICIO:
; Asegurar DS = CS (modelo .COM)
push cs
pop ds

; Encabezado
lea dx, msgEncabezado
call ImprimirCadena

; Crear directorio en C:\emu8086\MyBuild\ACTIVIAD05
lea dx, msgCrearDir
call ImprimirCadena
lea dx, rutaDirectorio
mov ah, 39h                       ; MKDIR DS:DX -> ASCIIZ
int 21h
jnc DIR_CREADO
; CF=1 -> verificar si ya existe con Get File Attributes (43h)
lea dx, rutaDirectorio
mov ax, 4300h                     ; Get File Attributes of dirPath
int 21h
jc  DIR_ERROR_CF                  ; no existe u otro error
; Existe -> notificar CF activada por existencia
lea dx, msgDirExiste
call ImprimirCadena
jmp DESPUES_DIR
DIR_ERROR_CF:
lea dx, msgDirErrorCF
call ImprimirCadena
jmp DESPUES_DIR
DIR_CREADO:
lea dx, msgDirCreado
call ImprimirCadena
DESPUES_DIR:

; Crear archivo y escribir contenido
lea dx, msgCrearArchivo
call ImprimirCadena

; Construir contenido de fecha en dateBuf
call ConstruirFecha

; Create (turnca si existe podria requerir 3Ch Entonces escribimos; 3Ch Falla si existe)
; Intento 1: crear con 3Ch; si falla porque existe, abrimos con 3Dh modo escritura (2) y truncar no es directo en DOS clásico.
; Para simplicidad: si 3Ch falla, intentamos abrir (3Dh, modo escritura=2) y sobreescribimos desde el principio.
mov cx, 0                         ; atributos normales
lea dx, rutaArchivo
mov ah, 3Ch                       ; CREATE
int 21h
jc  INTENTAR_ABRIR_ESCRITURA
mov [manejador], ax
jmp HACER_ESCRITURA

INTENTAR_ABRIR_ESCRITURA:
mov al, 2                         ; modo 2 = read/write
lea dx, rutaArchivo
mov ah, 3Dh                       ; OPEN
int 21h
jc  ARCHIVO_ERROR
mov [manejador], ax
; Si llegamos aqui, el CREATE fallo pero el OPEN funciono => el archivo ya existia
lea dx, msgArchivoExiste
call ImprimirCadena
; situarse al inicio (por defecto al abrir está al inicio)

HACER_ESCRITURA:
mov bx, [manejador]
mov ah, 40h                       ; WRITE
mov cx, [longitudFecha]
lea dx, bufferFecha
int 21h
jc  ARCHIVO_ERROR_CERRAR
; Verificar bytes escritos
cmp ax, cx
jne ARCHIVO_ERROR_CERRAR

; Cerrar
mov bx, [manejador]
mov ah, 3Eh
int 21h
jc  ARCHIVO_ERROR

lea dx, msgArchivoOk
call ImprimirCadena

; Cambiar al directorio padre
lea dx, msgCambiarDir
call ImprimirCadena
lea dx, rutaPadre
mov ah, 3Bh                       ; CHDIR (Change Directory)
int 21h
jc  ERROR_CAMBIO_DIR
lea dx, msgDirCambiado
call ImprimirCadena
jmp LEER_ARCHIVO

ERROR_CAMBIO_DIR:
lea dx, msgErrorCambio
call ImprimirCadena
jmp LEER_ARCHIVO

ARCHIVO_ERROR_CERRAR:
; Intentar cerrar si había handle válido
push ax
mov bx, [manejador]
mov ah, 3Eh
int 21h
pop ax
ARCHIVO_ERROR:
lea dx, msgArchivoError
call ImprimirCadena
jmp FIN

LEER_ARCHIVO:
lea dx, msgLeerArchivo
call ImprimirCadena

; Abrir solo lectura
mov al, 0                         ; modo lectura
lea dx, rutaArchivo
mov ah, 3Dh
int 21h
jc  LECTURA_ERROR
mov [manejador], ax

; Leer hasta 128 bytes
mov bx, [manejador]
mov cx, 128
lea dx, bufferLectura
mov ah, 3Fh
int 21h
jc  LECTURA_ERROR_CERRAR
mov [bytesLeidos], ax

; Cerrar
mov bx, [manejador]
mov ah, 3Eh
int 21h

; Mostrar contenido
lea dx, msgContenidoLeido
call ImprimirCadena
mov ax, [bytesLeidos]
cmp ax, 0
je ARCHIVO_VACIO
mov cx, [bytesLeidos]
lea si, bufferLectura
call ImprimirBuffer
call ImprimirCRLF
jmp FIN

ARCHIVO_VACIO:
lea dx, msgArchivoVacio
call ImprimirCadena
jmp FIN

LECTURA_ERROR_CERRAR:
; Cerrar si se abrió
push ax
mov bx, [manejador]
mov ah, 3Eh
int 21h
pop ax
LECTURA_ERROR:
lea dx, msgLeerError
call ImprimirCadena

FIN:
lea dx, msgFin
call ImprimirCadena
mov ax, 4C00h
int 21h



