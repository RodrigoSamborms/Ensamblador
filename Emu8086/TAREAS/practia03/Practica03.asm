name "p3"   ;

;   Este programa realiza la suma de 5 datos de 16 bits
;   almacenados contiguamente en memoria en formato big endian.
;   Dato1: 0700:0310-0311, Dato2: 0312-0313, Dato3: 0314-0315
;   Dato4: 0316-0317, Dato5: 0318-0319
;   El resultado de 32 bits se almacena en:
;   0700:031A-031D (big endian) y 0700:031E-0321 (little endian)
;   La suma utiliza DX:AX como acumulador de 32 bits
;   manejando los acarreos entre operaciones.

org  100h
jmp inicio

msg1:         db "Seccion D01 - Suma de 5 datos de 16 bits"
msg2:         db "Introduce 5 datos de 16 bits en memoria:"
msg3:         db "Dato1: 0700:0310-0311, Dato2: 0312-0313, Dato3: 0314-0315"
msg4:         db "Dato4: 0700:0316-0317, Dato5: 0700:0318-0319"
msg5:         db "Resultado de 32 bits en 0700:031A-031B-031C-031D (Big Endian)"
msg6:         db "Formato Big Endian: byte alto primero"
msg7:         db "Little Endian en 0700:031E-031F-0320-0321"
msg_tail:
msg1_size = msg2 - msg1
msg2_size = msg3 - msg2
msg3_size = msg4 - msg3
msg4_size = msg5 - msg4
msg5_size = msg6 - msg5
msg6_size = msg6 - msg5
msg7_size = msg_tail - msg7

inicio:
mov ax, 1003h       ;cofiguracion del tama?o de la consola
mov bx, 0           ;consolo de 80x25 caracteres
int 10h

mov dx, 0705h       ;se imprime el primer mensaje en el renglon 0705
mov bx, 0
mov bl, 10011111b   ;paleta de colores
mov cx, msg1_size   ;guion bajo solo para visualizar mejor
mov al, 01b
mov bp, msg1
mov ah, 13h
int 10h

mov dx, 0905h      ;dos lienas depues del primer mensaje
mov bx, 0
mov bl, 10011111b
mov cx, msg2_size
mov al, 01b
mov bp, msg2        ;
mov ah, 13h
int 10h

mov dx, 0B05h
mov bx, 0
mov bl, 10011111b
mov cx, msg3_size
mov al, 01b
mov bp, msg3
mov ah, 13h
int 10h

mov dx, 0C05h
mov bx, 0
mov bl, 10011111b
mov cx, msg4_size
mov al, 01b
mov bp, msg4
mov ah, 13h
int 10h
;-----------------
mov ah, 0           ;pulse una tecla para continuar
int 10110b          ;22 en binario

mov dx, 0D05h
mov bx, 0
mov bl, 11111001b
mov cx, msg5_size
mov al, 01b
mov bp, msg5
mov ah, 13h
int 10h

mov dx, 0E05h
mov bx, 0
mov bl, 11111001b
mov cx, msg6_size
mov al, 01b
mov bp, msg6
mov ah, 13h
int 10h

mov dx, 0F05h
mov bx, 0
mov bl, 11111001b
mov cx, msg7_size
mov al, 01b
mov bp, msg7
mov ah, 13h
int 10h



mov ah, 0           ;pulse una tecla para continuar
int 10110b          ;22 en binario

; Configurar segmento de datos a 0700h para acceder a memoria
mov ax, 0700h
mov ds, ax

; Inicializar acumulador de 32 bits (DX:AX = 0)
xor dx, dx          ; DX = 0 (parte alta de 32 bits)
xor ax, ax          ; AX = 0 (parte baja de 32 bits)
xor cx, cx          ; CX = 0 (para manejo de acarreos adicionales)

; Sumar Dato1 (0310-0311 en big endian)
mov bl, [0x310]     ; byte bajo (menos significativo)
mov bh, [0x311]     ; byte alto (más significativo)
add ax, bx          ; sumar BX a AX
adc dx, 0           ; propagar acarreo a DX
adc cx, 0           ; propagar acarreo a CX (bits 32-39)

; Sumar Dato2 (0312-0313)
mov bl, [0x312]
mov bh, [0x313]
add ax, bx
adc dx, 0
adc cx, 0

; Sumar Dato3 (0314-0315)
mov bl, [0x314]
mov bh, [0x315]
add ax, bx
adc dx, 0
adc cx, 0

; Sumar Dato4 (0316-0317)
mov bl, [0x316]
mov bh, [0x317]
add ax, bx
adc dx, 0
adc cx, 0

; Sumar Dato5 (0318-0319)
mov bl, [0x318]
mov bh, [0x319]
add ax, bx
adc dx, 0
adc cx, 0

; Guardar resultado en formato Big Endian (031A-031D)
; Big Endian: byte más significativo primero
mov [031Ah], dh     ; byte más alto de DX
mov [031Bh], dl     ; byte más bajo de DX
mov [031Ch], ah     ; byte más alto de AX
mov [031Dh], al     ; byte más bajo de AX

; Guardar resultado en formato Little Endian (031E-0321)
; Little Endian: byte menos significativo primero
mov [031Eh], al     ; byte más bajo de AX
mov [031Fh], ah     ; byte más alto de AX
mov [0320h], dl     ; byte más bajo de DX
mov [0321h], dh     ; byte más alto de DX

int 20h


