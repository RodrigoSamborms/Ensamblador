; ========================================================================
; SumaMejoradaWindow.asm
; Programa que suma dos números usando una interfaz gráfica de Windows
; Autor: Rodrigo Samborms
; Fecha: Octubre 2025
; ========================================================================

.386
.model flat, stdcall
option casemap:none

; ========================================================================
; Prototipos de funciones de Windows API
; ========================================================================
ExitProcess proto stdcall :DWORD
GetModuleHandleA proto stdcall :DWORD
GetCommandLineA proto stdcall
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
BeginPaint proto stdcall :DWORD,:DWORD
EndPaint proto stdcall :DWORD,:DWORD
GetDlgItemInt proto stdcall :DWORD,:DWORD,:DWORD,:DWORD
SetDlgItemInt proto stdcall :DWORD,:DWORD,:DWORD,:DWORD

; ========================================================================
; Prototipos de funciones locales
; ========================================================================
WinMain proto :DWORD, :DWORD, :DWORD, :DWORD
WndProc proto :DWORD, :DWORD, :DWORD, :DWORD

; ========================================================================
; Constantes de Windows
; ========================================================================
NULL                equ 0
TRUE                equ 1
FALSE               equ 0
WM_CREATE           equ 0001h
WM_CLOSE            equ 0010h
WM_DESTROY          equ 0002h
WM_COMMAND          equ 0111h
WM_PAINT            equ 000Fh

CS_HREDRAW          equ 0002h
CS_VREDRAW          equ 0001h
CW_USEDEFAULT       equ 80000000h
SW_SHOWNORMAL       equ 1
SW_SHOWDEFAULT      equ 10

WS_OVERLAPPED       equ 00000000h
WS_CAPTION          equ 00C00000h
WS_SYSMENU          equ 00080000h
WS_MINIMIZEBOX      equ 00020000h
WS_CHILD            equ 40000000h
WS_VISIBLE          equ 10000000h
WS_BORDER           equ 00800000h

WS_EX_CLIENTEDGE    equ 00000200h

ES_LEFT             equ 0000h
ES_NUMBER           equ 2000h
ES_READONLY         equ 0800h

BS_DEFPUSHBUTTON    equ 0001h
SS_LEFT             equ 0000h

COLOR_BTNFACE       equ 15
IDI_APPLICATION     equ 32512
IDC_ARROW           equ 32512

; IDs de controles
IDC_EDIT1           equ 1001
IDC_EDIT2           equ 1002
IDC_BUTTON          equ 1003
IDC_RESULTADO       equ 1004

; ========================================================================
; Estructuras
; ========================================================================
POINT STRUCT
    x   DWORD ?
    y   DWORD ?
POINT ENDS

MSG STRUCT
    hwnd    DWORD ?
    message DWORD ?
    wParam  DWORD ?
    lParam  DWORD ?
    time    DWORD ?
    pt      POINT <>
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

PAINTSTRUCT STRUCT
    hdc         DWORD ?
    fErase      DWORD ?
    rcPaint_left    DWORD ?
    rcPaint_top     DWORD ?
    rcPaint_right   DWORD ?
    rcPaint_bottom  DWORD ?
    fRestore    DWORD ?
    fIncUpdate  DWORD ?
    rgbReserved BYTE 32 dup(?)
PAINTSTRUCT ENDS

; ========================================================================
; Datos
; ========================================================================
.data
ClassName       db "SumaWindowClass", 0
AppName         db "Calculadora - Suma de Numeros", 0
ButtonText      db "BUTTON", 0
ButtonCaption   db "Sumar", 0
EditClass       db "EDIT", 0
StaticClass     db "STATIC", 0
Label1Text      db "Primer numero:", 0
Label2Text      db "Segundo numero:", 0
ResultLabel     db "Resultado:", 0

.data?
hInstance       DWORD ?
CommandLine     DWORD ?

; ========================================================================
; Código
; ========================================================================
.code

start:
    invoke GetModuleHandleA, NULL
    mov hInstance, eax
    invoke GetCommandLineA
    mov CommandLine, eax
    invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    invoke ExitProcess, eax

; ========================================================================
; WinMain - Punto de entrada principal
; ========================================================================
WinMain proc hInst:DWORD, hPrevInst:DWORD, CmdLine:DWORD, CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hwnd:DWORD

    ; Configurar la estructura WNDCLASSEX
    mov wc.cbSize, SIZEOF WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, OFFSET WndProc
    mov wc.cbClsExtra, NULL
    mov wc.cbWndExtra, NULL
    push hInst
    pop wc.hInstance
    mov wc.hbrBackground, COLOR_BTNFACE + 1
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, OFFSET ClassName
    invoke LoadIconA, NULL, IDI_APPLICATION
    mov wc.hIcon, eax
    mov wc.hIconSm, eax
    invoke LoadCursorA, NULL, IDC_ARROW
    mov wc.hCursor, eax
    
    ; Registrar la clase de ventana
    invoke RegisterClassExA, addr wc
    
    ; Crear la ventana principal
    invoke CreateWindowExA, WS_EX_CLIENTEDGE,
                          ADDR ClassName,
                          ADDR AppName,
                          WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX,
                          CW_USEDEFAULT,
                          CW_USEDEFAULT,
                          400,
                          280,
                          NULL,
                          NULL,
                          hInst,
                          NULL
    mov hwnd, eax
    
    ; Mostrar la ventana
    invoke ShowWindow, hwnd, SW_SHOWNORMAL
    invoke UpdateWindow, hwnd
    
    ; Bucle de mensajes
    .WHILE TRUE
        invoke GetMessageA, ADDR msg, NULL, 0, 0
        .BREAK .IF (!eax)
        invoke TranslateMessage, ADDR msg
        invoke DispatchMessageA, ADDR msg
    .ENDW
    
    mov eax, msg.wParam
    ret
WinMain endp

; ========================================================================
; WndProc - Procedimiento de ventana
; ========================================================================
WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    LOCAL num1:DWORD
    LOCAL num2:DWORD
    LOCAL suma:DWORD
    
    .IF uMsg == WM_CREATE
        ; Crear etiqueta "Primer numero:"
        invoke CreateWindowExA, 0,
                              ADDR StaticClass,
                              ADDR Label1Text,
                              WS_CHILD or WS_VISIBLE or SS_LEFT,
                              20, 20, 120, 20,
                              hWnd, NULL, hInstance, NULL
        
        ; Crear campo de texto para el primer número
        invoke CreateWindowExA, WS_EX_CLIENTEDGE,
                              ADDR EditClass,
                              NULL,
                              WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_NUMBER,
                              150, 18, 200, 24,
                              hWnd, IDC_EDIT1, hInstance, NULL
        
        ; Crear etiqueta "Segundo numero:"
        invoke CreateWindowExA, 0,
                              ADDR StaticClass,
                              ADDR Label2Text,
                              WS_CHILD or WS_VISIBLE or SS_LEFT,
                              20, 60, 120, 20,
                              hWnd, NULL, hInstance, NULL
        
        ; Crear campo de texto para el segundo número
        invoke CreateWindowExA, WS_EX_CLIENTEDGE,
                              ADDR EditClass,
                              NULL,
                              WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_NUMBER,
                              150, 58, 200, 24,
                              hWnd, IDC_EDIT2, hInstance, NULL
        
        ; Crear botón "Sumar"
        invoke CreateWindowExA, 0,
                              ADDR ButtonText,
                              ADDR ButtonCaption,
                              WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,
                              150, 100, 100, 30,
                              hWnd, IDC_BUTTON, hInstance, NULL
        
        ; Crear etiqueta "Resultado:"
        invoke CreateWindowExA, 0,
                              ADDR StaticClass,
                              ADDR ResultLabel,
                              WS_CHILD or WS_VISIBLE or SS_LEFT,
                              20, 150, 120, 20,
                              hWnd, NULL, hInstance, NULL
        
        ; Crear campo de texto para el resultado (solo lectura)
        invoke CreateWindowExA, WS_EX_CLIENTEDGE,
                              ADDR EditClass,
                              NULL,
                              WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_READONLY,
                              150, 148, 200, 24,
                              hWnd, IDC_RESULTADO, hInstance, NULL
        
    .ELSEIF uMsg == WM_COMMAND
        mov eax, wParam
        .IF ax == IDC_BUTTON
            ; El usuario hizo clic en el botón Sumar
            
            ; Obtener el primer número
            invoke GetDlgItemInt, hWnd, IDC_EDIT1, NULL, TRUE
            mov num1, eax
            
            ; Obtener el segundo número
            invoke GetDlgItemInt, hWnd, IDC_EDIT2, NULL, TRUE
            mov num2, eax
            
            ; Realizar la suma
            mov eax, num1
            add eax, num2
            mov suma, eax
            
            ; Mostrar el resultado
            invoke SetDlgItemInt, hWnd, IDC_RESULTADO, suma, TRUE
        .ENDIF
        
    .ELSEIF uMsg == WM_CLOSE
        invoke DestroyWindow, hWnd
        
    .ELSEIF uMsg == WM_DESTROY
        invoke PostQuitMessage, NULL
        
    .ELSE
        invoke DefWindowProcA, hWnd, uMsg, wParam, lParam
        ret
    .ENDIF
    
    xor eax, eax
    ret
WndProc endp

end start
