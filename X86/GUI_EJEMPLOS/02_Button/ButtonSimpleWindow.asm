; ========================================================================
; ButtonSimple.asm
; Ejemplo de un botón simple que muestra un MessageBox al hacer clic
; 
; Descripción:
;   Ventana con un solo botón. Al hacer clic, muestra un cuadro de mensaje.
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

; MessageBox
MB_OK               equ 0h
MB_ICONINFORMATION  equ 40h

; ID del botón
ID_BTN_CLICK        equ 1001

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
    szClassName     db "ButtonSimpleClass",0
    szWindowName    db "Ejemplo de Botón Simple",0
    szButtonClass   db "BUTTON",0           ; Clase predefinida para botones
    szButtonText    db "Hacer Clic",0       ; Texto del botón
    szMsgTitle      db "Botón Presionado",0
    szMsgText       db "¡Hiciste clic en el botón!",0

.data?
    hInstance       DWORD ?
    hWnd            DWORD ?
    hButton         DWORD ?     ; Handle del botón
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
        400,                    ; Ancho: 400 píxeles
        200,                    ; Alto: 200 píxeles
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
    ; WM_CREATE: Se ejecuta cuando se crea la ventana
    ; Aquí creamos el botón
    ; ----------------------------------------------------------------
    .if uMsg == WM_CREATE
        ; Crear el botón
        invoke CreateWindowExA,
            0,                          ; Sin estilos extendidos
            addr szButtonClass,         ; Clase "BUTTON"
            addr szButtonText,          ; Texto: "Hacer Clic"
            WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, ; Estilos
            150,                        ; x = 150 (centrado aprox.)
            70,                         ; y = 70
            100,                        ; ancho = 100
            30,                         ; alto = 30
            hWnd,                       ; Ventana padre
            ID_BTN_CLICK,               ; ID del botón
            hInstance,                  ; Handle de instancia
            NULL                        ; Sin parámetros extra
        
        mov hButton, eax                ; Guardar handle del botón
        xor eax, eax                    ; Retornar 0 (mensaje procesado)
        ret
    
    ; ----------------------------------------------------------------
    ; WM_COMMAND: Se ejecuta cuando un control envía notificación
    ; ----------------------------------------------------------------
    .elseif uMsg == WM_COMMAND
        ; Obtener el ID del control (LOWORD de wParam)
        mov eax, wParam
        and eax, 0FFFFh                 ; Extraer los 16 bits bajos
        
        ; Verificar si es nuestro botón
        .if eax == ID_BTN_CLICK
            ; Obtener código de notificación (HIWORD de wParam)
            mov eax, wParam
            shr eax, 16                 ; Desplazar 16 bits a la derecha
            
            ; Verificar si es BN_CLICKED (código 0)
            .if eax == 0
                ; Mostrar MessageBox
                invoke MessageBoxA,
                    hWnd,               ; Ventana padre
                    addr szMsgText,     ; Mensaje
                    addr szMsgTitle,    ; Título
                    MB_OK or MB_ICONINFORMATION ; Icono de información
            .endif
        .endif
        
        xor eax, eax                    ; Retornar 0
        ret
    
    ; ----------------------------------------------------------------
    ; WM_CLOSE: Usuario quiere cerrar la ventana
    ; ----------------------------------------------------------------
    .elseif uMsg == WM_CLOSE
        invoke PostQuitMessage, 0
        xor eax, eax
        ret
    
    ; ----------------------------------------------------------------
    ; WM_DESTROY: Ventana está siendo destruida
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
