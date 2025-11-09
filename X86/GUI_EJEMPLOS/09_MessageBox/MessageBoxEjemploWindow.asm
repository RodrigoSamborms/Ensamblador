; ========================================================================
; MessageBoxEjemplo.asm - Ejemplo de varios MessageBox y retorno
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
MessageBoxA proto stdcall :DWORD,:DWORD,:DWORD,:DWORD
SetWindowTextA proto stdcall :DWORD,:DWORD

includelib kernel32.lib
includelib user32.lib

; Constantes
NULL                equ 0
WS_OVERLAPPEDWINDOW equ 0CF0000h
WS_VISIBLE          equ 10000000h
WS_CHILD            equ 40000000h
WS_TABSTOP          equ 00010000h
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

; MessageBox tipos
MB_OK               equ 0h
MB_OKCANCEL         equ 1h
MB_YESNO            equ 4h
MB_ICONINFORMATION  equ 40h
MB_ICONQUESTION     equ 20h
MB_ICONEXCLAMATION  equ 30h
MB_ICONERROR        equ 10h

; Retornos
IDOK                equ 1
IDCANCEL            equ 2
IDYES               equ 6
IDNO                equ 7

; IDs
ID_BTN_INFO         equ 9001
ID_BTN_PREG         equ 9002
ID_BTN_ERROR        equ 9003
ID_LBL_RESPUESTA    equ 9004

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
    szClassName     db "MsgBoxEjClass",0
    szWindowName    db "Ejemplo MessageBox",0
    szButtonClass   db "BUTTON",0
    szStaticClass   db "STATIC",0

    szBtnInfo       db "Info",0
    szBtnPregunta   db "Pregunta",0
    szBtnError      db "Error",0

    szLblRespInit   db "Respuesta: (ninguna)",0
    szRespSí        db "Respuesta: Sí",0
    szRespNo        db "Respuesta: No",0
    szRespCancel    db "Respuesta: Cancelado",0

    szInfoText      db "Este es un cuadro informativo.",0
    szInfoTitle     db "Información",0
    szPregText      db "¿Deseas continuar?",0
    szPregTitle     db "Confirmación",0
    szErrorText     db "Ocurrió un error simulado.",0
    szErrorTitle    db "Error",0

.data?
    hInstance       DWORD ?
    hWnd            DWORD ?
    hLblResp        DWORD ?
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
        CW_USEDEFAULT, CW_USEDEFAULT, 420, 200,
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
        ; Botón Info
        invoke CreateWindowExA, 0, addr szButtonClass, addr szBtnInfo,
            WS_CHILD or WS_VISIBLE or WS_TABSTOP,
            20, 20, 90, 26,
            hWnd, ID_BTN_INFO, hInstance, NULL
        ; Botón Pregunta
        invoke CreateWindowExA, 0, addr szButtonClass, addr szBtnPregunta,
            WS_CHILD or WS_VISIBLE or WS_TABSTOP,
            120, 20, 90, 26,
            hWnd, ID_BTN_PREG, hInstance, NULL
        ; Botón Error
        invoke CreateWindowExA, 0, addr szButtonClass, addr szBtnError,
            WS_CHILD or WS_VISIBLE or WS_TABSTOP,
            220, 20, 90, 26,
            hWnd, ID_BTN_ERROR, hInstance, NULL

        ; Label respuesta
        invoke CreateWindowExA, 0, addr szStaticClass, addr szLblRespInit,
            WS_CHILD or WS_VISIBLE,
            20, 70, 260, 24,
            hWnd, ID_LBL_RESPUESTA, hInstance, NULL
        mov hLblResp, eax

        xor eax, eax
        ret

    .elseif uMsg == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh
        .if eax == ID_BTN_INFO
            invoke MessageBoxA, hWnd, addr szInfoText, addr szInfoTitle, MB_OK or MB_ICONINFORMATION
        .elseif eax == ID_BTN_PREG
            invoke MessageBoxA, hWnd, addr szPregText, addr szPregTitle, MB_YESNO or MB_ICONQUESTION
            cmp eax, IDYES
            je resp_yes
            cmp eax, IDNO
            je resp_no
            jmp resp_end
        resp_yes:
            invoke SetWindowTextA, hLblResp, addr szRespSí
            jmp resp_end
        resp_no:
            invoke SetWindowTextA, hLblResp, addr szRespNo
        resp_end:
        .elseif eax == ID_BTN_ERROR
            invoke MessageBoxA, hWnd, addr szErrorText, addr szErrorTitle, MB_OK or MB_ICONERROR
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
