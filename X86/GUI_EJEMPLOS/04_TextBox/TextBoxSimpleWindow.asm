; ========================================================================
; TextBoxSimple.asm - EDIT simple + label que muestra el texto
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
GetWindowTextA proto stdcall :DWORD,:DWORD,:DWORD
SetWindowTextA proto stdcall :DWORD,:DWORD

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

; EDIT/STATIC styles
ES_LEFT         equ 0h
ES_AUTOHSCROLL  equ 80h
SS_LEFT         equ 0h
SS_SUNKEN       equ 1000h

; IDs
ID_EDIT_SIMPLE  equ 3001
ID_LBL_MUESTRA  equ 3002
ID_BTN_LEER     equ 3003

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
    szClassName     db "TextBoxSimpleClass",0
    szWindowName    db "TextBox Simple + Label",0
    szEditClass     db "EDIT",0
    szStaticClass   db "STATIC",0
    szButtonClass   db "BUTTON",0

    szInitText      db "Escribe aquí...",0
    szLabelTitle    db "Contenido:",0
    szBtnLeer       db "Leer",0

    buffer          db 128 dup(0)

.data?
    hInstance       DWORD ?
    hWnd            DWORD ?
    hEdit           DWORD ?
    hLabel          DWORD ?
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
        CW_USEDEFAULT, CW_USEDEFAULT, 520, 220,
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
        ; Label título
        invoke CreateWindowExA, 0, addr szStaticClass, addr szLabelTitle,
            WS_CHILD or WS_VISIBLE or SS_LEFT,
            20, 20, 80, 22,
            hWnd, ID_LBL_MUESTRA, hInstance, NULL
        mov hLabel, eax

        ; Edit simple
        invoke CreateWindowExA, 0, addr szEditClass, addr szInitText,
            WS_CHILD or WS_VISIBLE or WS_BORDER or WS_TABSTOP or ES_LEFT or ES_AUTOHSCROLL,
            110, 20, 250, 24,
            hWnd, ID_EDIT_SIMPLE, hInstance, NULL
        mov hEdit, eax

        ; Botón leer
        invoke CreateWindowExA, 0, addr szButtonClass, addr szBtnLeer,
            WS_CHILD or WS_VISIBLE or WS_TABSTOP,
            380, 20, 80, 24,
            hWnd, ID_BTN_LEER, hInstance, NULL

        xor eax, eax
        ret

    .elseif uMsg == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh
        .if eax == ID_BTN_LEER
            invoke GetWindowTextA, hEdit, addr buffer, 128
            invoke SetWindowTextA, hLabel, addr buffer
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
