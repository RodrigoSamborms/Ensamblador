; ========================================================================
; LabelEjemplo.asm
; Ejemplo de etiquetas (STATIC) en Win32 ASM x86
; Muestra varias etiquetas con diferentes estilos y cambia una en runtime.
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
SetWindowTextA proto stdcall :DWORD,:DWORD

includelib kernel32.lib
includelib user32.lib

; Constantes
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

WM_CREATE           equ 1h
WM_COMMAND          equ 111h
WM_DESTROY          equ 2h

; STATIC styles
SS_LEFT         equ 0h
SS_CENTER       equ 1h
SS_RIGHT        equ 2h
SS_SIMPLE       equ 0Bh
SS_SUNKEN       equ 1000h

; IDs
ID_BTN_CAMBIAR  equ 2001
ID_LBL_DIN      equ 1001

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
    szClassName     db "LabelEjClass",0
    szWindowName    db "Ejemplo de Labels (STATIC)",0
    szStaticClass   db "STATIC",0
    szButtonClass   db "BUTTON",0

    szLbl1          db "Izquierda (SS_LEFT)",0
    szLbl2          db "Centro (SS_CENTER)",0
    szLbl3          db "Derecha (SS_RIGHT)",0
    szLblSunken     db "Hundido (SS_SUNKEN)",0

    szDinInicial    db "Dínamico: inicial",0
    szDinNuevo      db "Dínamico: actualizado!",0

    szBtnCambiar    db "Cambiar texto",0

.data?
    hInstance       DWORD ?
    hWnd            DWORD ?
    hLblDin         DWORD ?
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
        0,
        addr szClassName,
        addr szWindowName,
        WS_OVERLAPPEDWINDOW or WS_VISIBLE,
        CW_USEDEFAULT, CW_USEDEFAULT,
        520, 260,
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
        ; Clases
        ; Label izquierda
        invoke CreateWindowExA, 0, addr szStaticClass, addr szLbl1,
            WS_CHILD or WS_VISIBLE or SS_LEFT,
            20, 20, 200, 20,
            hWnd, 100, hInstance, NULL
        ; Label centrado
        invoke CreateWindowExA, 0, addr szStaticClass, addr szLbl2,
            WS_CHILD or WS_VISIBLE or SS_CENTER,
            20, 50, 200, 20,
            hWnd, 101, hInstance, NULL
        ; Label derecha
        invoke CreateWindowExA, 0, addr szStaticClass, addr szLbl3,
            WS_CHILD or WS_VISIBLE or SS_RIGHT,
            20, 80, 200, 20,
            hWnd, 102, hInstance, NULL
        ; Label hundido
        invoke CreateWindowExA, 0, addr szStaticClass, addr szLblSunken,
            WS_CHILD or WS_VISIBLE or SS_LEFT or SS_SUNKEN,
            20, 110, 200, 22,
            hWnd, 103, hInstance, NULL

        ; Label dinámico con ID para cambiar su texto
        invoke CreateWindowExA, 0, addr szStaticClass, addr szDinInicial,
            WS_CHILD or WS_VISIBLE or SS_LEFT or SS_SUNKEN,
            260, 20, 220, 24,
            hWnd, ID_LBL_DIN, hInstance, NULL
        mov hLblDin, eax

        ; Botón para cambiar texto del label dinámico
        invoke CreateWindowExA, 0, addr szButtonClass, addr szBtnCambiar,
            WS_CHILD or WS_VISIBLE,
            260, 60, 150, 30,
            hWnd, ID_BTN_CAMBIAR, hInstance, NULL

        xor eax, eax
        ret

    .elseif uMsg == WM_COMMAND
        ; LOWORD(wParam) = ID control
        mov eax, wParam
        and eax, 0FFFFh
        .if eax == ID_BTN_CAMBIAR
            invoke SetWindowTextA, hLblDin, addr szDinNuevo
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
