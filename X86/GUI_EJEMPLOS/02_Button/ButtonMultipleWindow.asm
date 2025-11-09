; ========================================================================
; ButtonMultiple.asm
; Ejemplo con múltiples botones manejando diferentes acciones
; 
; Descripción:
;   Ventana con tres botones, cada uno muestra un mensaje diferente.
;
; Arquitectura: x86 (32 bits)
; ========================================================================

.386
.model flat, stdcall
option casemap:none

; ========================================================================
; Prototipos de funciones
; ========================================================================
ExitProcess proto stdcall :DWORD
GetModuleHandleA proto stdcall :DWORD
RegisterClassExA proto stdcall :DWORD
CreateWindowExA proto stdcall :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ShowWindow proto stdcall :DWORD,:DWORD
UpdateWindow proto stdcall :DWORD
GetMessageA proto stdcall :DWORD,:DWORD,:DWORD,:DWORD
TranslateMessage proto stdcall :DWORD
DispatchMessageA proto stdcall :DWORD
DefWindowProcA proto stdcall :DWORD,:DWORD,:DWORD,:DWORD
PostQuitMessage proto stdcall :DWORD
DestroyWindow proto stdcall :DWORD
LoadIconA proto stdcall :DWORD,:DWORD
LoadCursorA proto stdcall :DWORD,:DWORD
MessageBoxA proto stdcall :DWORD,:DWORD,:DWORD,:DWORD

; ========================================================================
; Bibliotecas
; ========================================================================
includelib kernel32.lib
includelib user32.lib

; ========================================================================
; Constantes
; ========================================================================
NULL                equ 0
WS_OVERLAPPEDWINDOW equ 0CF0000h
WS_VISIBLE          equ 10000000h
WS_CHILD            equ 40000000h
CW_USEDEFAULT       equ 80000000h
CS_HREDRAW          equ 2h
CS_VREDRAW          equ 1h
COLOR_WINDOW        equ 5
IDI_APPLICATION     equ 32512
IDC_ARROW           equ 32512
SW_SHOWNORMAL       equ 1

; Mensajes
WM_CREATE           equ 1h
WM_COMMAND          equ 111h
WM_CLOSE            equ 10h
WM_DESTROY          equ 2h

; Estilos de botón
BS_PUSHBUTTON       equ 0h
BS_DEFPUSHBUTTON    equ 1h

; MessageBox
MB_OK               equ 0h
MB_YESNO            equ 4h
MB_ICONINFORMATION  equ 40h
MB_ICONQUESTION     equ 20h
MB_ICONEXCLAMATION  equ 30h
IDYES               equ 6

; IDs de los botones (deben ser únicos)
ID_BTN_INFO         equ 1001
ID_BTN_WARNING      equ 1002
ID_BTN_SALIR        equ 1003

; ========================================================================
; Estructuras
; ========================================================================
MSG STRUCT
    hwnd    DWORD ?
    message DWORD ?
    wParam  DWORD ?
    lParam  DWORD ?
    time    DWORD ?
    pt      QWORD ?
MSG ENDS

WNDCLASSEX STRUCT
    cbSize          DWORD ?
    style           DWORD ?
    lpfnWndProc     DWORD ?
    cbClsExtra      DWORD ?
    cbWndExtra      DWORD ?
    hInstance       DWORD ?
    hIcon           DWORD ?
    hCursor         DWORD ?
    hbrBackground   DWORD ?
    lpszMenuName    DWORD ?
    lpszClassName   DWORD ?
    hIconSm         DWORD ?
WNDCLASSEX ENDS

; ========================================================================
; Datos
; ========================================================================
.data
    szClassName     db "ButtonMultipleClass",0
    szWindowName    db "Ejemplo de Múltiples Botones",0
    szButtonClass   db "BUTTON",0
    
    ; Textos de los botones
    szBtn1Text      db "Información",0
    szBtn2Text      db "Advertencia",0
    szBtn3Text      db "Salir",0
    
    ; Mensajes para cada botón
    szMsg1Title     db "Información",0
    szMsg1Text      db "Este es un mensaje informativo.",0
    
    szMsg2Title     db "¡Advertencia!",0
    szMsg2Text      db "Ten cuidado con las advertencias.",0
    
    szMsg3Title     db "Confirmar Salida",0
    szMsg3Text      db "¿Deseas cerrar la aplicación?",0

.data?
    hInstance       DWORD ?
    hWnd            DWORD ?
    hBtn1           DWORD ?     ; Handle del botón 1
    hBtn2           DWORD ?     ; Handle del botón 2
    hBtn3           DWORD ?     ; Handle del botón 3
    msg             MSG <>
    wc              WNDCLASSEX <>

; ========================================================================
; Código
; ========================================================================
.code

start:
    ; Obtener handle de instancia
    invoke GetModuleHandleA, NULL
    mov hInstance, eax
    
    ; Configurar WNDCLASSEX
    mov wc.cbSize, sizeof WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, offset WndProc
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 0
    mov eax, hInstance
    mov wc.hInstance, eax
    invoke LoadIconA, NULL, IDI_APPLICATION
    mov wc.hIcon, eax
    mov wc.hIconSm, eax
    invoke LoadCursorA, NULL, IDC_ARROW
    mov wc.hCursor, eax
    mov wc.hbrBackground, COLOR_WINDOW+1
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, offset szClassName
    
    ; Registrar clase
    invoke RegisterClassExA, addr wc
    test eax, eax
    jz exit_error
    
    ; Crear ventana
    invoke CreateWindowExA,
        0,
        addr szClassName,
        addr szWindowName,
        WS_OVERLAPPEDWINDOW or WS_VISIBLE,
        CW_USEDEFAULT,
        CW_USEDEFAULT,
        400,                    ; Ancho
        300,                    ; Alto (más espacio para 3 botones)
        NULL,
        NULL,
        hInstance,
        NULL
    
    mov hWnd, eax
    test eax, eax
    jz exit_error
    
    ; Mostrar ventana
    invoke ShowWindow, hWnd, SW_SHOWNORMAL
    invoke UpdateWindow, hWnd
    
    ; Bucle de mensajes
MessageLoop:
    invoke GetMessageA, addr msg, NULL, 0, 0
    test eax, eax
    jz EndProgram
    
    invoke TranslateMessage, addr msg
    invoke DispatchMessageA, addr msg
    jmp MessageLoop

EndProgram:
    invoke ExitProcess, msg.wParam

exit_error:
    invoke ExitProcess, 1

; ========================================================================
; WndProc - Procedimiento de ventana
; ========================================================================
WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    
    ; ----------------------------------------------------------------
    ; WM_CREATE: Crear los tres botones
    ; ----------------------------------------------------------------
    .if uMsg == WM_CREATE
        ; Botón 1: Información (botón estándar)
        invoke CreateWindowExA,
            0,
            addr szButtonClass,
            addr szBtn1Text,
            WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,
            100,                        ; x = 100
            40,                         ; y = 40
            200,                        ; ancho = 200
            35,                         ; alto = 35
            hWnd,
            ID_BTN_INFO,
            hInstance,
            NULL
        mov hBtn1, eax
        
        ; Botón 2: Advertencia (botón estándar)
        invoke CreateWindowExA,
            0,
            addr szButtonClass,
            addr szBtn2Text,
            WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,
            100,                        ; x = 100
            90,                         ; y = 90 (espaciado de 50)
            200,                        ; ancho = 200
            35,                         ; alto = 35
            hWnd,
            ID_BTN_WARNING,
            hInstance,
            NULL
        mov hBtn2, eax
        
        ; Botón 3: Salir (botón por defecto - más grueso)
        invoke CreateWindowExA,
            0,
            addr szButtonClass,
            addr szBtn3Text,
            WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,  ; Botón default
            100,                        ; x = 100
            140,                        ; y = 140
            200,                        ; ancho = 200
            35,                         ; alto = 35
            hWnd,
            ID_BTN_SALIR,
            hInstance,
            NULL
        mov hBtn3, eax
        
        xor eax, eax
        ret
    
    ; ----------------------------------------------------------------
    ; WM_COMMAND: Manejar clics en los botones
    ; ----------------------------------------------------------------
    .elseif uMsg == WM_COMMAND
        ; Obtener ID del control
        mov eax, wParam
        and eax, 0FFFFh
        
        ; Verificar qué botón fue presionado
        .if eax == ID_BTN_INFO
            ; Botón "Información"
            invoke MessageBoxA,
                hWnd,
                addr szMsg1Text,
                addr szMsg1Title,
                MB_OK or MB_ICONINFORMATION
        
        .elseif eax == ID_BTN_WARNING
            ; Botón "Advertencia"
            invoke MessageBoxA,
                hWnd,
                addr szMsg2Text,
                addr szMsg2Title,
                MB_OK or MB_ICONEXCLAMATION
        
        .elseif eax == ID_BTN_SALIR
            ; Botón "Salir" - preguntar confirmación
            invoke MessageBoxA,
                hWnd,
                addr szMsg3Text,
                addr szMsg3Title,
                MB_YESNO or MB_ICONQUESTION
            
            ; Si el usuario presionó "Sí", cerrar la ventana
            .if eax == IDYES
                invoke DestroyWindow, hWnd
            .endif
        .endif
        
        xor eax, eax
        ret
    
    ; ----------------------------------------------------------------
    ; WM_CLOSE: Usuario cierra la ventana
    ; ----------------------------------------------------------------
    .elseif uMsg == WM_CLOSE
        invoke DestroyWindow, hWnd
        xor eax, eax
        ret
    
    ; ----------------------------------------------------------------
    ; WM_DESTROY: Ventana destruida
    ; ----------------------------------------------------------------
    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage, 0
        xor eax, eax
        ret
    .endif
    
    ; Procesamiento por defecto
    invoke DefWindowProcA, hWnd, uMsg, wParam, lParam
    ret
    
WndProc endp

end start
