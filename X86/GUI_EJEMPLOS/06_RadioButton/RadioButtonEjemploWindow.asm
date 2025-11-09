; ========================================================================
; RadioButtonEjemplo.asm - Grupo de radio buttons y selección
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

includelib kernel32.lib
includelib user32.lib

; Constantes generales
NULL                equ 0
WS_OVERLAPPEDWINDOW equ 0CF0000h
WS_VISIBLE          equ 10000000h
WS_CHILD            equ 40000000h
WS_TABSTOP          equ 00010000h
WS_GROUP            equ 00020000h
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

; Radios
BS_RADIOBUTTON      equ 4h
BS_AUTORADIOBUTTON  equ 9h
BM_GETCHECK         equ 0F0h
BM_SETCHECK         equ 0F1h
BST_UNCHECKED       equ 0
BST_CHECKED         equ 1

; IDs
ID_RB_ROJO          equ 6001
ID_RB_VERDE         equ 6002
ID_RB_AZUL          equ 6003
ID_LBL_SELECCION    equ 6004

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
    szClassName     db "RadioBtnEjClass",0
    szWindowName    db "Ejemplo Radio Buttons",0
    szButtonClass   db "BUTTON",0
    szStaticClass   db "STATIC",0

    szRbRojo        db "Rojo",0
    szRbVerde       db "Verde",0
    szRbAzul        db "Azul",0

    szLblTitulo     db "Seleccion actual:",0
    szSelRojo       db "Seleccion actual: Rojo",0
    szSelVerde      db "Seleccion actual: Verde",0
    szSelAzul       db "Seleccion actual: Azul",0

.data?
    hInstance       DWORD ?
    hWnd            DWORD ?
    hRbRojo         DWORD ?
    hRbVerde        DWORD ?
    hRbAzul         DWORD ?
    hLblSel         DWORD ?
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
        CW_USEDEFAULT, CW_USEDEFAULT, 420, 220,
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
        ; Primer radio (inicio de grupo)
        invoke CreateWindowExA, 0, addr szButtonClass, addr szRbRojo,
            WS_CHILD or WS_VISIBLE or WS_GROUP or WS_TABSTOP or BS_AUTORADIOBUTTON,
            20, 20, 120, 20,
            hWnd, ID_RB_ROJO, hInstance, NULL
        mov hRbRojo, eax
        ; Seleccionar por defecto
        invoke SendMessageA, hRbRojo, BM_SETCHECK, BST_CHECKED, 0

        invoke CreateWindowExA, 0, addr szButtonClass, addr szRbVerde,
            WS_CHILD or WS_VISIBLE or BS_AUTORADIOBUTTON,
            20, 45, 120, 20,
            hWnd, ID_RB_VERDE, hInstance, NULL
        mov hRbVerde, eax

        invoke CreateWindowExA, 0, addr szButtonClass, addr szRbAzul,
            WS_CHILD or WS_VISIBLE or BS_AUTORADIOBUTTON,
            20, 70, 120, 20,
            hWnd, ID_RB_AZUL, hInstance, NULL
        mov hRbAzul, eax

        ; Label de selección
        invoke CreateWindowExA, 0, addr szStaticClass, addr szSelRojo,
            WS_CHILD or WS_VISIBLE,
            20, 110, 260, 22,
            hWnd, ID_LBL_SELECCION, hInstance, NULL
        mov hLblSel, eax

        xor eax, eax
        ret

    .elseif uMsg == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh
        .if eax == ID_RB_ROJO
            invoke SetWindowTextA, hLblSel, addr szSelRojo
        .elseif eax == ID_RB_VERDE
            invoke SetWindowTextA, hLblSel, addr szSelVerde
        .elseif eax == ID_RB_AZUL
            invoke SetWindowTextA, hLblSel, addr szSelAzul
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
