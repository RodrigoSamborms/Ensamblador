        name   "n32tobcd"
        org    0x100
        jmp     ini
        
n32     db     0,0,0,0    ;para los arreglos de datos...
bcd10   db     10 dup(0)   ; se usara little endian
num     db     0,0,0,0
den     db     1
coc32   db     0,0,0,0    
residuo db     0

copy_si_di:              ;rutina que copia 
        push    ax       ;el arreglo indicado
        push    cx       ;por el registro SI,
        push    si       ;al arreglo indicado 
        push    di       ;por el arreglo DI.
copy:                    ;El numero de elementos 
        mov     al,[si]  ;que se copiaran se
        mov     [di],al  ;indica en el registro CX
        inc     si
        inc     di
        loop    copy
        pop     di
        pop     si
        pop     cx
        pop     ax
        ret

div32_8:                    ;Division de 32 bits entre 8 bits.
        push    ax
        mov     ah,0
        mov     al,[num]    ;num Numero de 32 bits en formato big endian
        test    [den],0xff  ;den Denominador de 8 bits.
        jz      div_zero    ;coc32 Cociente de 32 bits en formato big endian
        div     [den]       ;residuo Residuo de 8 bits.
        mov     [coc32],al
        mov     al,[num+1]
        div     [den]
        mov     [coc32+1],al
        mov     al,[num+2]
        div     [den]
        mov     [coc32+2],al
        mov     al,[num+3]
        div     [den]
        mov     [coc32+3],al
        mov     [residuo],ah
        clc
        jmp     ediv32_8
div_zero:
        mov     al,0xff
        mov     [coc32],al
        mov     [coc32+1],al
        mov     [coc32+2],al
        mov     [coc32+3],al
        mov     [residuo],al
        stc
ediv32_8:
        test    [coc32],0xFF
        jnz     no_zero
        test    [coc32+1],0xFF
        jnz     no_zero
        test    [coc32+2],0xFF
        jnz     no_zero
        test    [coc32+3],0xFF
no_zero:        
        pop     ax
        ret        
        
ini:
        lea     si,n32
        lea     di,num
        mov     cx,4
        call    copy_si_di
        lea     di,bcd10
        add     di,9
ciclo:        
        mov     al,10
        mov     [den],al
        call    div32_8
        jz      f_ciclo
        mov     al,[residuo]
        mov     [di],al
        dec     di
        push    di
        lea     si,coc32
        lea     di,num
        mov     cx,4
        call    copy_si_di
        pop     di
        jmp     ciclo 
f_ciclo:        
        mov     al,[residuo]
        mov     [di],al
        mov     al,0
        int     0x20

