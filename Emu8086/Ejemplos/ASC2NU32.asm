name "p5"
include 'emu8086.inc'

        org 0100h
        jmp ini
        
cadnum  db      "000000000"
n32     db      ?,?,?,?
b       db      ?
DEFINE_GET_STRING

numbyte:
        call    asc2num
        mov     bl,16
        mul     bl
        mov     [b],al
        inc     di
        mov     al,[di]
        call    asc2num
        add     al,[b]
        mov     [b],al
        ret
        
asc2num:
        sub     al,48
        cmp     al,9
        jle     f_asc
        sub     al,7
        cmp     al,15
        jle     f_asc
        sub     al,32
f_asc:  ret
        
ini:    xor ax,ax
        lea     di,cadnum
        lea     si,n32
        mov     dx,9
        call    get_string

        mov     al,[di]
        call    numbyte
        mov     al,[b]
        mov     [si],al
        inc     si
        inc     di
        mov     al,[di]
        call    numbyte
        mov     al,[b]
        mov     [si],al
        inc     si
        inc     di
        mov     al,[di]
        call    numbyte
        mov     al,[b]
        mov     [si],al
        inc     si
        inc     di
        mov     al,[di]
        call    numbyte
        mov     al,[b]
        mov     [si],al
        
        lea     di,n32
        
        int     0x20

        END        
        
      
