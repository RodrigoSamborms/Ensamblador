; ========================================================================
; TextBoxMultiline.asm - EDIT multilínea con scroll y límite de longitud
; ========================================================================

.386
.model flat, stdcall
option casemap:none

; Prototipos
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
SendMessageA proto stdcall :DWORD,:DWORD,:DWORD,:DWORD
SetWindowTextA proto stdcall :DWORD,:DWORD
GetWindowTextA proto stdcall :DWORD,:DWORD,:DWORD

includelib kernel32.lib
includelib user32.lib

; Constantes
NULL                equ 0
WS_OVERLAPPEDWINDOW equ 0CF0000h
WS_VISIBLE          equ 10000000h
WS_CHILD            equ 40000000h
WS_BORDER           equ 00800000h
WS_TABSTOP          equ 00010000h
WS_VSCROLL          equ 00200000h
WS_HSCROLL          equ 00100000h
CW_USEDEFAULT       equ 80000000h
CS_HREDRAW          equ 2h
CS_VREDRAW          equ 1h
COLOR_WINDOW        equ 5
IDI_APPLICATION     equ 32512
IDC_ARROW           equ 32512
SW_SHOWNORMAL       equ 1

WM_CREATE           equ 1h
WM_COMMAND          equ 111h
WM_DESTROY          equ 2h

; EDIT styles
ES_LEFT         equ 0h
ES_MULTILINE    equ 4h
ES_AUTOVSCROLL  equ 40h
ES_AUTOHSCROLL  equ 80h
ES_READONLY     equ 800h

; Edit messages / notifications
EM_LIMITTEXT    equ 0C5h
EN_CHANGE       equ 300h

; IDs
ID_EDIT_MULTI   equ 4001
ID_EDIT_INFO    equ 4002
ID_BTN_LIMPIAR  equ 4003
ID_BTN_MOSTRAR  equ 4004
ID_LBL_STATUS   equ 4005

; Estructuras
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

.data
    szClassName     db "TextBoxMultiClass",0
    szWindowName    db "EDIT Multilínea con Scroll",0
    szEditClass     db "EDIT",0
    szStaticClass   db "STATIC",0
    szButtonClass   db "BUTTON",0

    szBtnLimpiar    db "Limpiar",0
    szBtnMostrar    db "Mostrar",0
    szStatusDefault db "Status: Esperando entrada...",0
    szStatusCambio  db "Status: Texto cambiado",0

    szInfoTitle     db "Información",0
    szInfoInit      db "Introduce texto (máx 256 chars).",0

    buffer          db 512 dup(0)

.data?
    hInstance       DWORD ?
    hWnd            DWORD ?
    hEditMulti      DWORD ?
    hEditInfo       DWORD ?
    hLblStatus      DWORD ?
    msg             MSG <>
    wc              WNDCLASSEX <>

.code
start:
    invoke GetModuleHandleA, NULL
    mov hInstance, eax

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

    invoke RegisterClassExA, addr wc
    test eax, eax
    jz exit_error

    invoke CreateWindowExA,
        0, addr szClassName, addr szWindowName,
        WS_OVERLAPPEDWINDOW or WS_VISIBLE,
        CW_USEDEFAULT, CW_USEDEFAULT, 640, 360,
        NULL, NULL, hInstance, NULL
    mov hWnd, eax
    test eax, eax
    jz exit_error

    invoke ShowWindow, hWnd, SW_SHOWNORMAL
    invoke UpdateWindow, hWnd

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

WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    .if uMsg == WM_CREATE
        ; Edit multilínea con scroll vertical
        invoke CreateWindowExA, 0, addr szEditClass, NULL,
            WS_CHILD or WS_VISIBLE or WS_BORDER or WS_TABSTOP or ES_MULTILINE or ES_AUTOVSCROLL or ES_AUTOHSCROLL or ES_LEFT or WS_VSCROLL,
            20, 20, 340, 220,
            hWnd, ID_EDIT_MULTI, hInstance, NULL
        mov hEditMulti, eax
        ; Limitar longitud
        invoke SendMessageA, hEditMulti, EM_LIMITTEXT, 256, 0

        ; Edit informativo readonly
        invoke CreateWindowExA, 0, addr szEditClass, addr szInfoInit,
            WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_AUTOHSCROLL or ES_READONLY,
            380, 20, 220, 60,
            hWnd, ID_EDIT_INFO, hInstance, NULL
        mov hEditInfo, eax

        ; Label status
        invoke CreateWindowExA, 0, addr szStaticClass, addr szStatusDefault,
            WS_CHILD or WS_VISIBLE or SS_LEFT,
            380, 100, 220, 24,
            hWnd, ID_LBL_STATUS, hInstance, NULL
        mov hLblStatus, eax

        ; Botón limpiar
        invoke CreateWindowExA, 0, addr szButtonClass, addr szBtnLimpiar,
            WS_CHILD or WS_VISIBLE or WS_TABSTOP,
            380, 140, 100, 30,
            hWnd, ID_BTN_LIMPIAR, hInstance, NULL

        ; Botón mostrar
        invoke CreateWindowExA, 0, addr szButtonClass, addr szBtnMostrar,
            WS_CHILD or WS_VISIBLE or WS_TABSTOP,
            500, 140, 100, 30,
            hWnd, ID_BTN_MOSTRAR, hInstance, NULL

        xor eax, eax
        ret

    .elseif uMsg == WM_COMMAND
        mov eax, wParam
        mov edx, eax            ; Copia
        and eax, 0FFFFh         ; LOWORD -> ID control
        shr edx, 16             ; HIWORD -> notificación

        ; Notificación de cambio de texto EN_CHANGE
        .if edx == EN_CHANGE && eax == ID_EDIT_MULTI
            invoke SetWindowTextA, hLblStatus, addr szStatusCambio
        .endif

        ; Botón limpiar
        .if eax == ID_BTN_LIMPIAR
            ; Establecer texto vacío
            invoke SetWindowTextA, hEditMulti, addr buffer ; buffer está inicialmente lleno de ceros
            invoke SetWindowTextA, hLblStatus, addr szStatusDefault
        .elseif eax == ID_BTN_MOSTRAR
            invoke GetWindowTextA, hEditMulti, addr buffer, 256
            invoke SetWindowTextA, hEditInfo, addr buffer
        .endif

        xor eax, eax
        ret

    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage, 0
        xor eax, eax
        ret
    .endif

    invoke DefWindowProcA, hWnd, uMsg, wParam, lParam
    ret
WndProc endp

end start
