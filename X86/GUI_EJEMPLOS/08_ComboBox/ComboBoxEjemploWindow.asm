; ========================================================================
; ComboBoxEjemplo.asm - ComboBox con selección y recarga
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

; ComboBox mensajes/estilos
CBS_DROPDOWNLIST    equ 3h
CB_ADDSTRING        equ 143h
CB_GETCURSEL        equ 147h
CB_GETLBTEXT        equ 148h
CB_RESETCONTENT     equ 14Bh

; Notificaciones
CBN_SELCHANGE       equ 1

; IDs
ID_COMBO            equ 8001
ID_LBL_SEL          equ 8002
ID_BTN_RECARGA      equ 8003

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
    szClassName     db "ComboBoxEjClass",0
    szWindowName    db "Ejemplo ComboBox",0
    szComboClass    db "COMBOBOX",0
    szStaticClass   db "STATIC",0
    szButtonClass   db "BUTTON",0

    szLblSelInit    db "Seleccion: (ninguna)",0
    szBtnRecarga    db "Recargar",0

    ; Ítems
    szItem1         db "Rojo",0
    szItem2         db "Verde",0
    szItem3         db "Azul",0
    szItem4         db "Amarillo",0
    szItem5         db "Blanco",0

    bufferTexto     db 128 dup(0)

.data?
    hInstance       DWORD ?
    hWnd            DWORD ?
    hCombo          DWORD ?
    hLblSel         DWORD ?
    hBtnRecarga     DWORD ?
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
        CW_USEDEFAULT, CW_USEDEFAULT, 460, 220,
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

FillCombo proc
    invoke SendMessageA, hCombo, CB_ADDSTRING, 0, offset szItem1
    invoke SendMessageA, hCombo, CB_ADDSTRING, 0, offset szItem2
    invoke SendMessageA, hCombo, CB_ADDSTRING, 0, offset szItem3
    invoke SendMessageA, hCombo, CB_ADDSTRING, 0, offset szItem4
    invoke SendMessageA, hCombo, CB_ADDSTRING, 0, offset szItem5
    ret
FillCombo endp

WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    .if uMsg == WM_CREATE
        ; ComboBox
        invoke CreateWindowExA, 0, addr szComboClass, NULL,
            WS_CHILD or WS_VISIBLE or WS_TABSTOP or CBS_DROPDOWNLIST,
            20, 20, 200, 140,
            hWnd, ID_COMBO, hInstance, NULL
        mov hCombo, eax

        ; Label
        invoke CreateWindowExA, 0, addr szStaticClass, addr szLblSelInit,
            WS_CHILD or WS_VISIBLE,
            240, 20, 180, 24,
            hWnd, ID_LBL_SEL, hInstance, NULL
        mov hLblSel, eax

        ; Botón recarga
        invoke CreateWindowExA, 0, addr szButtonClass, addr szBtnRecarga,
            WS_CHILD or WS_VISIBLE or WS_TABSTOP,
            240, 60, 120, 28,
            hWnd, ID_BTN_RECARGA, hInstance, NULL
        mov hBtnRecarga, eax

        ; Llenar combo
        call FillCombo

        xor eax, eax
        ret

    .elseif uMsg == WM_COMMAND
        mov eax, wParam
        mov edx, eax
        and eax, 0FFFFh         ; ID
        shr edx, 16             ; notificación

        ; Cambio de selección
        .if eax == ID_COMBO && edx == CBN_SELCHANGE
            invoke SendMessageA, hCombo, CB_GETCURSEL, 0, 0
            cmp eax, -1
            je no_sel
            invoke SendMessageA, hCombo, CB_GETLBTEXT, eax, offset bufferTexto
            invoke SetWindowTextA, hLblSel, offset bufferTexto
            jmp end_cmd
        no_sel:
            invoke SetWindowTextA, hLblSel, offset szLblSelInit
        end_cmd:
        .endif

        ; Recargar
        .if eax == ID_BTN_RECARGA
            invoke SendMessageA, hCombo, CB_RESETCONTENT, 0, 0
            call FillCombo
            invoke SetWindowTextA, hLblSel, offset szLblSelInit
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
