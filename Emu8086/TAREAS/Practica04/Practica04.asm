     
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

    include 'emu8086.inc';incluimos las macrofunciones

    org 100h
    jmp start
;---------------------
;| SEGMENTO DE DATOS |
;---------------------     
;el cero indica null al final de la cadena
msg1:   db "Torres Rivera Rodrigo",0
msg2:   db "Seccion D01",0 
msg3:   db "Dato1 variable de entrada de 16 bits"
msg4:   db "Exponente variable de entrada de 16 bits"
msg5:   db "Resultado variable de salida de 32 bits"

base dw ?   ;variables de 16 bits
exponente dw ?
resultado db 4 dup(0) ;variable de 32 bits

;#### PROCEDIMIENTOS ####
potencia:
    MOV AX, 1
    MOV BX, base
    MOV CX, exponente
    ;JCXZ exp_zero ;evitar bucles infinitos
    elevar: MUL BX
    LOOP elevar 
    ret

           
start:           
    LEA    SI, msg1       ;cargamos el mensaje a enviar
    CALL   print_string   ;imprimimos el mensaje
    PRINTN '' ;salto de linea
    LEA    SI, msg2 
    CALL   print_string         
    PRINTN ;escribe un salto de linea
    PRINT "escribe el valor de la base: "
    CALL SCAN_NUM
    MOV base, CX
    PRINTN ''
    PRINT "escribe el valor del exponente: "
    CALL SCAN_NUM
    MOV exponente, CX
    PRINTN ''
    
    ;punto de debug
    ;PRINT 'entrando al procedimiento'
    ;mov ah, 0          ;espera a presionar una tecla
    ;int 16h
    ;punto de debug
    
    PRINTN ''
    PRINT "verifique el resultado de la operacion "
    PRINT "en la ventana de las variables"
    
    CMP CX, 0 ;verificamos que no sea 0
    JZ Exponente_Cero   ;verificamos si CX es 0
        
    ;llamamos al procedimiento
    CALL potencia
    ;recuperamos los datos DX:AX
    MOV resultado+1, DL;valor bajo de BX
    MOV resultado, DH;valor alto de BX
    
    MOV resultado+3, AL;valor bajo de AX
    MOV resultado+2, AH;valor alto de AX
    JMP fin_programa ;termino el programa

Exponente_Cero: MOV resultado+3, 1;El resultado es 1     
fin_programa:    
    int 20h ;interrupcion para regresar al OS FF88  
def_macros:   
    DEFINE_PRINT_STRING 
    DEFINE_SCAN_NUM
    ;PRINTN ;no requiere definicion
    ret




