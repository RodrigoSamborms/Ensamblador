include 'emu8086.inc'
org 100h
    jmp start

; TestDir.asm - utilidad mínima para depurar cambio de directorio y listado .asm
; Uso:
;   1) Mostrar directorio actual
;   2) Cambiar directorio (acepta C./ruta y normaliza a C:\ruta)
;   3) Listar archivos .asm en directorio actual
;   4) Salir
;
; Nota: pensado para Emu8086. Muestra ruta convertida antes de cambiar.

; Mensajes
msg_menu         db 13,10,'--- TESTDIR MENU ---',13,10
                 db '1. Mostrar directorio actual',13,10
                 db '2. Cambiar directorio',13,10
                 db '3. Listar archivos .asm',13,10
                 db '4. Salir',13,10
                 db 'Opcion: ',0
msg_curdir       db 'Directorio actual: ',0
msg_prompt       db 'Ingrese ruta (ej: C./MiCarpeta o ./SubDir): ',0
msg_conv         db 'Ruta convertida: ',0
msg_chok         db 'Cambio OK',13,10,0
msg_cherr        db 'ERROR al cambiar directorio',13,10,0
msg_list_hdr     db 13,10,'Archivos .asm en el directorio:',13,10,0
msg_list_none    db 'No se encontraron archivos .asm',13,10,0
msg_axerr        db ' AX=',0

; Variables
inbuf            db 128 dup(0)
drive_str        db 2 dup(0)
mask_asm         db '*.asm',0
dta_buffer       db 43 dup(0)
curdir           db 128 dup(0)
outbuf           db 256 dup(0)
hex_chars        db '0123456789ABCDEF'
search_path      db 256 dup(0)  ; buffer para construir X:\path\*.asm

; Macros
DEFINE_PRINT_STRING
DEFINE_GET_STRING

; Subrutinas
; mostrar_directorio_actual
show_curdir:
    push ax
    push dx
    push si
    ; obtener directorio
    mov ah,47h
    mov dl,0
    lea si,inbuf
    int 21h
    ; imprimir
    lea si,msg_curdir
    call print_string
    mov ah,19h
    int 21h
    add al,'A'
    mov [drive_str],al
    mov byte ptr [drive_str+1],0
    lea si,drive_str
    call print_string
    print ':'
    ; agregar '\\' entre unidad y ruta si falta
    lea si,inbuf
    mov al,[si]
    cmp al,92
    je $+6
    mov dl,92
    mov ah,02h
    int 21h
    ; ahora imprimir ruta
    lea si,inbuf
    call print_string
    printn ''
    pop si
    pop dx
    pop ax
    ret

; convertir C./ -> C:\ y '/' -> '\\'; normaliza duplicados y recorta finales
normalize_path:
    push ax
    push bx
    push si
    push di
    lea si,inbuf
    ; Soportar ruta relativa ./... -> <unidad actual>:<dir actual>\...
    mov al,[si]
    cmp al,'.'
    jne .check_drive
    mov ah,[si+1]
    cmp ah,'/'
    je .build_rel
    cmp ah,92            ; '\\'
    je .build_rel
    jmp .check_drive

.build_rel:
    ; Obtener directorio actual en curdir
    mov ah,47h
    mov dl,0
    lea si,curdir
    int 21h
    ; Obtener unidad actual y componer prefijo "X:"
    mov ah,19h
    int 21h
    add al,'A'
    lea di,outbuf
    mov [di],al
    inc di
    mov byte ptr [di],':'
    inc di
    ; asegurar "X:\\" antes de anexar curdir
    mov byte ptr [di],92
    inc di
    ; Copiar curdir a outbuf
    lea si,curdir
.cp_cur:
    mov al,[si]
    mov [di],al
    cmp al,0
    je .after_cur
    inc si
    inc di
    jmp .cp_cur
.after_cur:
    ; Asegurar separador antes del resto
    cmp di,offset outbuf
    je .skip_sep
    dec di
    mov al,[di]
    inc di
    cmp al,92
    je .sep_ok
    mov byte ptr [di],92
    inc di
.sep_ok:
.skip_sep:
    ; Copiar resto de la ruta (después de "./") a outbuf
    lea si,inbuf
    add si,2
.cp_rest:
    mov al,[si]
    mov [di],al
    cmp al,0
    je .wrote_out
    inc si
    inc di
    jmp .cp_rest
.wrote_out:
    ; Sobrescribir inbuf con outbuf
    lea si,outbuf
    lea di,inbuf
.cp_back:
    mov al,[si]
    mov [di],al
    inc si
    inc di
    cmp al,0
    jne .cp_back

.check_drive:
    ; C. -> C:
    lea si,inbuf
    mov al,[si]
    cmp al,0
    je .norm
    mov ah,[si+1]
    cmp ah,'.'
    jne .rep
    mov byte ptr [si+1],':'
.rep:
    ; reemplazo '/'
    mov di,si
.rlp:
    mov al,[di]
    cmp al,0
    je .norm
    cmp al,'/'
    jne .nxt
    mov byte ptr [di],92
.nxt:
    inc di
    jmp .rlp
.norm:
    ; eliminar duplicados y recortar (similar a principal)
    lea si,inbuf
    lea di,inbuf
.n2:
    mov al,[si]
    cmp al,0
    je .trim
    cmp al,92
    jne .cpy
    cmp di,offset inbuf
    je .cpy
    mov ah,[di-1]
    cmp ah,92
    je .skip
.cpy:
    mov [di],al
    inc di
.skip:
    inc si
    jmp .n2
.trim:
    cmp di,offset inbuf
    je .done
.t1:
    cmp di,offset inbuf
    jbe .done
    dec di
    mov al,[di]
    cmp al,92
    je .t2
    cmp al,' '
    je .t1
    inc di
    jmp .done
.t2:
    cmp di,offset inbuf+2
    jne .t1
    inc di
.done:
    mov byte ptr [di],0
    pop di
    pop si
    pop bx
    pop ax
    ret

; ----- utilidades: imprimir AX en hexadecimal -----
; imprime AX como 4 dígitos hex (mayúsculas)
print_hex8: ; AL = byte a imprimir
    push ax
    push bx
    push si
    mov bl,al
    ; alto nibble
    mov al,bl
    shr al,1
    shr al,1
    shr al,1
    shr al,1
    and al,0Fh
    xor ah,ah
    mov si,offset hex_chars
    add si,ax
    mov dl,[si]
    mov ah,02h
    int 21h
    ; bajo nibble
    mov al,bl
    and al,0Fh
    xor ah,ah
    mov si,offset hex_chars
    add si,ax
    mov dl,[si]
    mov ah,02h
    int 21h
    pop si
    pop bx
    pop ax
    ret

print_hex16: ; AX = palabra a imprimir
    push ax
    push bx
    mov bx,ax
    mov al,bh
    call print_hex8
    mov al,bl
    call print_hex8
    pop bx
    pop ax
    ret

; cambiar_directorio usando inbuf
chdir_inbuf:
    push ax
    push dx
    lea dx,inbuf
    mov ah,3Bh
    int 21h
    pop dx
    pop ax
    ret

; listar .asm
list_asm:
    push ax
    push cx
    push dx
    push si
    push di
    ; Mostrar directorio actual antes de buscar (debug)
    print 'DEBUG: Buscando en -> '
    call show_curdir
    
    ; Construir ruta absoluta: X:\path\*.asm en search_path
    ; 1) Obtener unidad actual
    mov ah,19h
    int 21h
    add al,'A'
    lea di,search_path
    mov [di],al
    inc di
    mov byte ptr [di],':'
    inc di
    mov byte ptr [di],92  ; backslash
    inc di
    
    ; 2) Obtener directorio actual
    mov ah,47h
    mov dl,0
    lea si,curdir
    int 21h
    
    ; 3) Copiar curdir a search_path
    lea si,curdir
.cp_dir:
    mov al,[si]
    cmp al,0
    je .add_mask
    mov [di],al
    inc si
    inc di
    jmp .cp_dir
    
.add_mask:
    ; 4) Asegurar separador antes de *.asm
    cmp di,offset search_path+3  ; si estamos justo después de X:\
    je .append
    dec di
    mov al,[di]
    inc di
    cmp al,92
    je .append
    mov byte ptr [di],92
    inc di
    
.append:
    ; 5) Anexar *.asm
    mov byte ptr [di],'*'
    inc di
    mov byte ptr [di],'.'
    inc di
    mov byte ptr [di],'a'
    inc di
    mov byte ptr [di],'s'
    inc di
    mov byte ptr [di],'m'
    inc di
    mov byte ptr [di],0
    
    ; DEBUG: mostrar ruta de búsqueda construida
    print 'DEBUG: Mascara -> '
    lea si,search_path
    call print_string
    printn ''
    
    ; set DTA
    mov ah,1Ah
    lea dx,dta_buffer
    int 21h
    ; find first con ruta absoluta
    mov ah,4Eh
    mov cx,0
    lea dx,search_path
    int 21h
    jc .none
    lea si,msg_list_hdr
    call print_string
.l1:
    lea si,dta_buffer
    add si,30
    call print_string
    printn ''
    mov ah,4Fh
    int 21h
    jnc .l1
    jmp .out
.none:
    lea si,msg_list_none
    call print_string
.out:
    pop di
    pop si
    pop dx
    pop cx
    pop ax
    ret

; Programa principal
start:
.menu:
    lea si,msg_menu
    call print_string
    mov ah,01h
    int 21h
    printn ''
    cmp al,'1'
    je .s1
    cmp al,'2'
    je .s2
    cmp al,'3'
    je .s3
    cmp al,'4'
    je .exit
    printn 'Opcion invalida'
    jmp .menu
.s1:
    call show_curdir
    jmp .menu
.s2:
    lea si,msg_prompt
    call print_string
    lea di,inbuf
    mov dx,120
    call get_string
    call normalize_path
    lea si,msg_conv
    call print_string
    lea si,inbuf
    call print_string
    printn ''
    call chdir_inbuf
    jnc .ok
    lea si,msg_cherr
    call print_string
    ; mostrar código de error en AX
    lea si,msg_axerr
    call print_string
    call print_hex16
    printn ''
    jmp .menu
.ok:
    lea si,msg_chok
    call print_string
    call show_curdir
    jmp .menu
.s3:
    call list_asm
    jmp .menu
.exit:
    mov ax,4C00h
    int 21h
    ret
